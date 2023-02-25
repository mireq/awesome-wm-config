# -*- coding: utf-8 -*-
import atexit
import os
import signal
import subprocess
import sys
import time
from multiprocessing import Queue
from pathlib import Path


BASE_DIR = Path(__file__).parent
DISPLAY = ':1'
RESOLUTION = [800, 600]
DPI = 96


process_group_queue = Queue(maxsize=1)


def run_dbus_session():
	print("session", os.getpgrp())
	os.setpgrp()
	print("session", os.getpgrp())
	process_group_queue.put(os.getpgrp())
	proc = subprocess.Popen(['dbus-launch', '/bin/cat'])
	proc.wait()
	time.sleep(1)


def terminate(pid, process_group_id):
	print(pid, process_group_id)
	if process_group_id is None:
		try:
			os.kill(pid, signal.SIGINT)
			os.waitid(pid)
		except Exception:
			pass
		try:
			os.kill(pid, signal.SIGKILL)
		except Exception:
			pass
	else:
		try:
			os.killpg(process_group_id, signal.SIGINT)
			os.waitid(pid)
		except Exception:
			pass
		except KeyboardInterrupt:
			pass
		try:
			os.killpg(process_group_id, signal.SIGKILL)
		except Exception:
			pass


def monitor_and_terminate_process(pid):
	group_id = None

	def at_exit(*args):
		terminate(pid, group_id)

	try:
		group_id = process_group_queue.get()
		atexit.register(at_exit)
		signal.signal(signal.SIGTERM, at_exit)
		signal.signal(signal.SIGINT, at_exit)
		signal.signal(signal.SIGHUP, at_exit)
		os.waitpid(pid, 0)
		at_exit()
	except Exception:
		at_exit()
	except KeyboardInterrupt:
		at_exit()
	else:
		at_exit()


def main():
	pid = os.fork()
	if pid == 0: # child
		run_dbus_session()
	else: # handle quit
		monitor_and_terminate_process(pid)



if __name__ == "__main__":
	main()


#def test_monitor_reconnects():
#	# setup dual monitor
#	#half_width = RESOLUTION[0] // 2
#	#subprocess.Popen(['xrandr', '--setmonitor', 'RIGHT', f'{half_width}/0x{RESOLUTION[1]}/0+{half_width}+0', 'default'])
#	#subprocess.Popen(['xrandr', '--setmonitor', 'LEFT', f'{half_width}/0x{RESOLUTION[1]}/0+0+0', 'none'])
#	time.sleep(0.1)
#
#
#	proc = subprocess.Popen(['memusage', '--png=mem.png', 'awesome', '-c', BASE_DIR / 'rc_new.lua'])
#	#proc = subprocess.Popen(['awesome', '-c', BASE_DIR / 'rc_new.lua'])
#
#	time.sleep(0.1)
#
#	for __ in range(100):
#		subprocess.Popen(['awesome-client', 's = screen.fake_add(100, 100, 100, 100); s:fake_remove()'])
#		time.sleep(0.1)
#	#for __ in range(1000):
#	#	time.sleep(0.0003)
#	#	subprocess.Popen(['xrandr', '--delmonitor', 'LEFT'])
#	#	time.sleep(0.0003)
#	#	subprocess.Popen(['xrandr', '--setmonitor', 'LEFT', f'{half_width}/0x{RESOLUTION[1]}/0+0+0', 'none'])
#	time.sleep(0.5)
#
#	subprocess.Popen(['awesome-client', 'awesome.quit()'])
#
#	proc.wait(timeout=60)
#
#
#def run_tests():
#	try:
#		# run virtual desktop
#		subprocess.Popen(['Xephyr', '-ac', '-noreset', '-screen', f'{RESOLUTION[0]}x{RESOLUTION[1]}', '-dpi', str(DPI), '-host-cursor', '+bs', '+iglx', DISPLAY])
#		os.environ['DISPLAY'] = DISPLAY
#		# wait for start
#		time.sleep(0.5)
#		test_monitor_reconnects()
#	except KeyboardInterrupt:
#		return
#
#
#def main():
#	proc = subprocess.Popen(['dbus-launch', sys.executable, __file__, '--'] + sys.argv[1:], preexec_fn=os.setpgrp)
#	process_group_id = os.getpgid(proc.pid)
#
#	try:
#		proc.wait(timeout=60)
#	except KeyboardInterrupt:
#		pass
#	except Exception:
#		pass
#
#	def at_exit(*args):
#		proc.terminate()
#		try:
#			proc.wait(0.1)
#		except:
#			proc.kill()
#		try:
#			os.killpg(process_group_id, signal.SIGKILL)
#		except Exception:
#			pass
#
#	atexit.register(at_exit)
#	signal.signal(signal.SIGTERM, at_exit)
#	signal.signal(signal.SIGINT, at_exit)
#	signal.signal(signal.SIGHUP, at_exit)
#	at_exit()
#
#
#if __name__ == "__main__":
#	if len(sys.argv) > 1 and sys.argv[1] == '--':
#		run_tests()
#	else:
#		main()
