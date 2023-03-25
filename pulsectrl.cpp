/* Simple pulseaudio control / monitor */

#include <cstdint>
#include <iomanip>
#include <iostream>
#include <locale.h>
#include <mutex>
#include <signal.h>
#include <string>
#include <sys/prctl.h>
#include <thread>
#include <unistd.h>

#include <pulse/pulseaudio.h>


using namespace std;


enum Target {
	TARGET_SINK,
	TARGET_SOURCE
};

enum Action {
	ACTION_TOGGLE_MUTE,
	ACTION_SET_MUTE,
	ACTION_CHANGE_VOLUME,
	ACTION_SET_VOLUME
};

class PulseControl;

struct VolumeAction
{
	Target target;
	Action action;
	float value;
};

constexpr int CLOSING_RETURN_CODE = 42;

class PulseControl
{
public:
	PulseControl();
	~PulseControl();
	PulseControl(const PulseControl&) = delete;
	bool initialize();
	void close();
	void run();
	void perform_action(VolumeAction action);
	void parse_stdin();
	void quit_loop(int ret = 0);

private:
	static void signal_quit_callback(pa_mainloop_api *m, pa_signal_event *e, int sig, void *userdata);
	static void context_callback(pa_context *c, void *userdata);
	static void subscribe_callback(pa_context *c, pa_subscription_event_type_t type, uint32_t idx, void *userdata);
	static void server_info_callback(pa_context *c, const pa_server_info *i, void *userdata);

	static void perform_action_state_callback(pa_operation *op, void *userdata);

	static void default_sink_info_callback(pa_context *c, const pa_sink_info *i, int eol, void *userdata);
	static void sink_info_callback(pa_context *c, const pa_sink_info *i, int eol, void *userdata);
	static void default_source_info_callback(pa_context *c, const pa_source_info *i, int eol, void *userdata);
	static void source_info_callback(pa_context *c, const pa_source_info *i, int eol, void *userdata);

	static void sink_action_callback(pa_context *c, const pa_sink_info *i, int eol, void *userdata);
	static void source_action_callback(pa_context *c, const pa_source_info *i, int eol, void *userdata);

private:
	pa_mainloop* _mainloop;
	pa_mainloop_api* _mainloop_api;
	pa_signal_event* _sigint;
	pa_context* _context;
	const char* _default_sink_name;
	const char* _default_source_name;
	uint32_t _default_sink_idx;
	uint32_t _default_source_idx;

	// Structure used to change volume
	pa_cvolume _volume_control;
	// Data of next volume action
	VolumeAction _next_action;
	mutex _action_mutex;
};


PulseControl::PulseControl():
	_mainloop(nullptr),
	_mainloop_api(nullptr),
	_sigint(nullptr),
	_context(nullptr),
	_default_sink_idx(0),
	_default_source_idx(0)
{
}

PulseControl::~PulseControl()
{
	close();
}

bool PulseControl::initialize()
{
	/* Initialize main loop */
	_mainloop = pa_mainloop_new();
	if (!_mainloop) {
		cerr << "pa_mainloop_new() failed" << endl;
		return false;
	}

	_mainloop_api = pa_mainloop_get_api(_mainloop);
	if (!_mainloop_api) {
		cerr << "pa_mainloop_get_api() failed" << endl;
		return false;
	}

	/* Register signal API */
	if (pa_signal_init(_mainloop_api) != 0)
	{
		cerr << "pa_signal_init() failed" << endl;
		return false;
	}

	/* Register action to CTRL+C */
	_sigint = pa_signal_new(SIGINT, signal_quit_callback, this);
	if (!_sigint)
	{
		cerr << "pa_signal_new() failed" << endl;
		return false;
	}
	signal(SIGPIPE, SIG_IGN);
	prctl(PR_SET_PDEATHSIG, SIGINT);

	/* Initialize context */
	_context = pa_context_new(_mainloop_api, "PulseAudio control");
	if (!_context) {
		cerr << "pa_context_new() failed" << endl;
		return false;
	}

	/* Call context_callback on state change */
	pa_context_set_state_callback(_context, context_callback, this);

	/* Connect to pulseaudio */
	if (pa_context_connect(_context, nullptr, PA_CONTEXT_NOAUTOSPAWN, nullptr) < 0) {
		cerr << "pa_context_connect() failed" << endl;
		return false;
	}

	return true;
}

void PulseControl::close()
{
	// Cleanup resources
	if (_context) {
		pa_context_unref(_context);
		_context = nullptr;
	}

	if (_sigint) {
		pa_signal_free(_sigint);
		pa_signal_done();
		_sigint = nullptr;
	}

	if (_mainloop) {
		pa_mainloop_free(_mainloop);
		_mainloop = nullptr;
	}
}

void PulseControl::run() {
	while (1) {
		// Try initialize or wait 2 seconds
		if (!initialize()) {
			close();
			sleep(2);
			continue;
		}

		// Run main loop and clear resources after loop
		int ret = 0;
		if (pa_mainloop_run(_mainloop, &ret) < 0) {
			cerr << "pa_mainloop() failed" << endl;
		}
		close();

		// Check if main loop was stopped by quit call
		if (ret == CLOSING_RETURN_CODE) {
			// If yes, finish loop
			return;
		}

		sleep(2);
	}
}

void PulseControl::perform_action(VolumeAction action)
{
	/* Dispatch volume action to sink / sorces */
	pa_operation *op = nullptr;

	// Lock mutex to prevent race condition on shared _next_action
	_action_mutex.lock();

	// Update next action
	_next_action = action;

	/* Action is performed after info call, because current volume / toggle
	 * status is required for toggle and volume change action */
	switch (_next_action.target) {
		case TARGET_SINK:
			op = pa_context_get_sink_info_by_index(_context, _default_sink_idx, sink_action_callback, this);
			break;
		case TARGET_SOURCE:
			op = pa_context_get_source_info_by_index(_context, _default_source_idx, source_action_callback, this);
			break;
	}

	if (op) {
		// Unlock after operation
		pa_operation_set_state_callback(op, perform_action_state_callback, this);
	}
	else {
		_action_mutex.unlock();
	}
}

void PulseControl::parse_stdin() {
	/*
	 * Parse stdin line by line
	 *
	 * Stdin format:
	 * <target> <operation> [<operand>]
	 *
	 * Target is 'sink' or 'source'
	 * Operations are:
	 * - mute_toggle
	 * - mute_set
	 * - mute_clear
	 * - set <volume>
	 * - change [-]<volume>
	 *
	 * Volume float point number from 0.0 to 1.0
	 *
	 * Change supports negative numbers, for example sink change -0.1 will
	 * decrease volume by 10%.
	 */
	for (string line; getline(cin, line);) {
		if (!_context) {
			continue;
		}

		size_t pos = 0;
		string token;

		// Find delimiter
		pos = line.find(' ');
		if (pos == string::npos) {
			continue;
		}

		token = line.substr(0, pos);
		line.erase(0, pos + 1);

		// Only source and sink targets are available
		if (token != "source" and token != "sink") {
			continue;
		}

		// Create temporary action object
		VolumeAction action;
		action.target = TARGET_SINK;
		action.value = 0.0;

		if (token == "source") {
			action.target = TARGET_SOURCE;
		}

		// Process mute actions
		if (line == "mute_toggle") {
			action.action = ACTION_TOGGLE_MUTE;
			perform_action(action);
			continue;
		}
		if (line == "mute_set") {
			action.action = ACTION_SET_MUTE;
			action.value = 1.0;
			perform_action(action);
			continue;
		}
		if (line == "mute_clear") {
			action.action = ACTION_SET_MUTE;
			perform_action(action);
			continue;
		}

		// Volume needs another operand
		pos = line.find(' ');
		if (pos == string::npos) {
			continue;
		}
		token = line.substr(0, pos);
		line.erase(0, pos + 1);

		// Parse volume
		try {
			action.value = stof(line);
		}
		catch (invalid_argument& /* ia */) {
			continue;
		}

		// Change volume
		if (token == "change") {
			action.action = ACTION_CHANGE_VOLUME;
			perform_action(action);
			continue;
		}
		if (token == "set") {
			action.action = ACTION_SET_VOLUME;
			perform_action(action);
			continue;
		}
	}
}

void PulseControl::quit_loop(int ret) {
	// Quit main loop with optional return code
	if (_mainloop_api) {
		_mainloop_api->quit(_mainloop_api, ret);
	}
}


// Quit event loop
void PulseControl::signal_quit_callback(pa_mainloop_api * /* mainloop_api */, pa_signal_event * /* event */, int /* sig */, void *userdata)
{
	PulseControl* pulse = static_cast<PulseControl *>(userdata);
	if (pulse) {
		// Special code to distinguish between disconnect and signal
		pulse->quit_loop(CLOSING_RETURN_CODE);
	}
}

void PulseControl::context_callback(pa_context *c, void *userdata)
{
	// On context state change
	if (!c || !userdata) {
		return;
	}

	PulseControl* pulse = static_cast<PulseControl*>(userdata);
	pa_operation *op = nullptr;

	switch (pa_context_get_state(c))
	{
		case PA_CONTEXT_CONNECTING:
		case PA_CONTEXT_AUTHORIZING:
		case PA_CONTEXT_SETTING_NAME:
			break;
		case PA_CONTEXT_READY:
			// Check default sink / source
			op = pa_context_get_server_info(c, server_info_callback, userdata);
			// Subscribe to events
			pa_context_set_subscribe_callback(c, subscribe_callback, userdata);
			pa_context_subscribe(c, static_cast<pa_subscription_mask>(PA_SUBSCRIPTION_MASK_SINK | PA_SUBSCRIPTION_MASK_SOURCE | PA_SUBSCRIPTION_MASK_SERVER | PA_SUBSCRIPTION_MASK_CARD), nullptr, nullptr);
			break;
		default:
			pulse->quit_loop(0);
			break;
	}

	if (op) {
		pa_operation_unref(op);
	}
}


void PulseControl::subscribe_callback(pa_context *c, pa_subscription_event_type_t type, uint32_t idx, void *userdata)
{
	// Process volume / sink-source change events
	if (!c || !userdata) {
		return;
	}

	unsigned facility = type & PA_SUBSCRIPTION_EVENT_FACILITY_MASK;

	pa_operation *op = nullptr;

	switch (facility) {
		case PA_SUBSCRIPTION_EVENT_SINK:
			op = pa_context_get_sink_info_by_index(c, idx, sink_info_callback, userdata);
			break;
		case PA_SUBSCRIPTION_EVENT_SOURCE:
			op = pa_context_get_source_info_by_index(c, idx, source_info_callback, userdata);
			break;
		case PA_SUBSCRIPTION_EVENT_SERVER:
		case PA_SUBSCRIPTION_EVENT_CARD:
			op = pa_context_get_server_info(c, server_info_callback, userdata);
			break;
		default:
			break;
	}

	if (op) {
		pa_operation_unref(op);
	}
}


void PulseControl::server_info_callback(pa_context *c, const pa_server_info *i, void *userdata)
{
	if (!c || !userdata) {
		return;
	}

	// Set default sink
	pa_operation *op = pa_context_get_sink_info_by_name(c, i->default_sink_name, default_sink_info_callback, userdata);
	if (op) {
		pa_operation_unref(op);
	}

	// Set default source
	op = pa_context_get_source_info_by_name(c, i->default_source_name, default_source_info_callback, userdata);
	if (op) {
		pa_operation_unref(op);
	}
}


void PulseControl::perform_action_state_callback(pa_operation *op, void *userdata)
{
	// Unlock mutex used to prevent race conditionon on _next_action
	PulseControl* pulse = static_cast<PulseControl*>(userdata);
	if (pa_operation_get_state(op) != PA_OPERATION_RUNNING) {
		pulse->_action_mutex.unlock();
		pa_operation_unref(op);
	}
}


void PulseControl::default_sink_info_callback(pa_context *c, const pa_sink_info *i, int eol, void *userdata)
{
	if (!c || !i || !userdata) {
		return;
	}

	PulseControl* pulse = static_cast<PulseControl*>(userdata);

	if (i->index != pulse->_default_sink_idx) {
		// Display default sink
		cout << "default sink\t" << i->name << endl;
		pulse->_default_sink_idx = i->index;
		sink_info_callback(c, i, eol, userdata);
	}
}


void PulseControl::sink_info_callback(pa_context *c, const pa_sink_info *i, int eol, void *userdata)
{
	if (!c || !i || !userdata || eol != 0) {
		return;
	}

	PulseControl* pulse = static_cast<PulseControl*>(userdata);

	char default_flag = ' ';
	char mute_flag = ' ';

	if (i->index == pulse->_default_sink_idx) {
		default_flag = '*';
	}
	if (i->mute) {
		mute_flag = 'M';
	}

	// Display volume of default sink
	float volume = (float)pa_cvolume_avg(&(i->volume)) / (float)PA_VOLUME_NORM;
	cout << "volume sink\t" << default_flag << mute_flag << '\t' << setw(6) << setprecision(5) << fixed << showpoint << volume << "\t" << i->name << endl;
}


void PulseControl::default_source_info_callback(pa_context *c, const pa_source_info *i, int eol, void *userdata)
{
	if (!c || !i || !userdata) {
		return;
	}

	PulseControl* pulse = static_cast<PulseControl*>(userdata);

	if (i->index != pulse->_default_source_idx) {
		// Display default source
		cout << "default source\t" << i->name << endl;
		pulse->_default_source_idx = i->index;
		source_info_callback(c, i, eol, userdata);
	}
}


void PulseControl::source_info_callback(pa_context *c, const pa_source_info *i, int eol, void *userdata)
{
	if (!c || !i || !userdata || eol != 0) {
		return;
	}

	PulseControl* pulse = static_cast<PulseControl*>(userdata);

	char default_flag = ' ';
	char mute_flag = ' ';

	if (i->index == pulse->_default_source_idx) {
		default_flag = '*';
	}
	if (i->mute) {
		mute_flag = 'M';
	}

	// Display volume of default source
	float volume = (float)pa_cvolume_avg(&(i->volume)) / (float)PA_VOLUME_NORM;
	cout << "volume source\t" << default_flag << mute_flag << '\t' << setw(6) << setprecision(5) << fixed << showpoint << volume << "\t" << i->name << endl;
}


void PulseControl::sink_action_callback(pa_context *c, const pa_sink_info *i, int eol, void *userdata)
{
	// Perform action on sink
	if (!c || !i || !userdata || eol != 0) {
		return;
	}

	PulseControl* pulse = static_cast<PulseControl*>(userdata);

	pulse->_volume_control.channels = i->volume.channels;
	for (uint8_t ch = 0; ch < pulse->_volume_control.channels; ++ch) {
		pulse->_volume_control.values[ch] = i->volume.values[ch];
	}

	pa_operation *op = nullptr;
	float volume;
	switch (pulse->_next_action.action) {
		case ACTION_TOGGLE_MUTE:
			op = pa_context_set_sink_mute_by_index(c, i->index, !i->mute, nullptr, nullptr);
			break;
		case ACTION_SET_MUTE:
			op = pa_context_set_sink_mute_by_index(c, i->index, (int)pulse->_next_action.value, nullptr, nullptr);
			break;
		case ACTION_CHANGE_VOLUME:
			volume = (float)pa_cvolume_avg(&(i->volume)) / float(PA_VOLUME_NORM);
			volume += pulse->_next_action.value;
			if (volume < 0) {
				volume = 0.0;
			}
			if (volume > 1.5) {
				volume = 1.5;
			}
			pa_cvolume_set(&pulse->_volume_control, pulse->_volume_control.channels, int(volume * PA_VOLUME_NORM));
			op = pa_context_set_sink_volume_by_index(c, i->index, &pulse->_volume_control, nullptr, nullptr);
			break;
		case ACTION_SET_VOLUME:
			pa_cvolume_set(&pulse->_volume_control, pulse->_volume_control.channels, int(pulse->_next_action.value * PA_VOLUME_NORM));
			op = pa_context_set_sink_volume_by_index(c, i->index, &pulse->_volume_control, nullptr, nullptr);
			break;
	}

	if (op) {
		pa_operation_unref(op);
	}
}

void PulseControl::source_action_callback(pa_context *c, const pa_source_info *i, int eol, void *userdata)
{
	// Perform action on source
	if (!c || !i || !userdata || eol != 0) {
		return;
	}

	PulseControl* pulse = static_cast<PulseControl*>(userdata);

	pulse->_volume_control.channels = i->volume.channels;
	for (uint8_t ch = 0; ch < pulse->_volume_control.channels; ++ch) {
		pulse->_volume_control.values[ch] = i->volume.values[ch];
	}

	pa_operation *op = nullptr;
	float volume;
	switch (pulse->_next_action.action) {
		case ACTION_TOGGLE_MUTE:
			op = pa_context_set_source_mute_by_index(c, i->index, !i->mute, nullptr, nullptr);
			break;
		case ACTION_SET_MUTE:
			op = pa_context_set_source_mute_by_index(c, i->index, (int)pulse->_next_action.value, nullptr, nullptr);
			break;
		case ACTION_CHANGE_VOLUME:
			volume = (float)pa_cvolume_avg(&(i->volume)) / float(PA_VOLUME_NORM);
			volume += pulse->_next_action.value;
			if (volume < 0) {
				volume = 0.0;
			}
			if (volume > 1.5) {
				volume = 1.5;
			}
			pa_cvolume_set(&pulse->_volume_control, pulse->_volume_control.channels, int(volume * PA_VOLUME_NORM));
			op = pa_context_set_source_volume_by_index(c, i->index, &pulse->_volume_control, nullptr, nullptr);
			break;
		case ACTION_SET_VOLUME:
			pa_cvolume_set(&pulse->_volume_control, pulse->_volume_control.channels, int(pulse->_next_action.value * PA_VOLUME_NORM));
			op = pa_context_set_source_volume_by_index(c, i->index, &pulse->_volume_control, nullptr, nullptr);
			break;
	}

	if (op) {
		pa_operation_unref(op);
	}
}

int main(int, char *[])
{
	setlocale(LC_NUMERIC, "C");
	PulseControl ctrl;
	std::thread parse_thread(&PulseControl::parse_stdin, &ctrl);
	ctrl.run();
	return 0;
}
