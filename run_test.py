# -*- coding: utf-8 -*-
import atexit
import os
import signal
import subprocess
import sys
import time
from multiprocessing import Queue
from pathlib import Path
import struct


BASE_DIR = Path(__file__).parent
DISPLAY = ':1'
RESOLUTION = [800, 600]
DPI = 96


pid_queue = Queue(maxsize=1)


def test_monitor_reconnects():
	# setup dual monitor
	#half_width = RESOLUTION[0] // 2
	#subprocess.Popen(['xrandr', '--setmonitor', 'RIGHT', f'{half_width}/0x{RESOLUTION[1]}/0+{half_width}+0', 'default'])
	#subprocess.Popen(['xrandr', '--setmonitor', 'LEFT', f'{half_width}/0x{RESOLUTION[1]}/0+0+0', 'none'])
	time.sleep(0.1)

	search_dir = []
	awesome_binary = 'awesome'
	if 'AWESOME_BINARY' in os.environ:
		awesome_binary = os.environ['AWESOME_BINARY']
		search_dir = ['-s', Path(awesome_binary).parent / 'lib']

	proc = subprocess.Popen(['memusage' ,'-t', '--png=mem.png', awesome_binary, '-c', BASE_DIR / 'rc_new.lua'] + search_dir)
	#proc = subprocess.Popen([awesome_binary, '-c', BASE_DIR / 'rc_new.lua'] + search_dir)
	time.sleep(0.3)

	for __ in range(10):
		subprocess.Popen(['awesome-client', 'require("awful").run_test()'])
		time.sleep(0.35)

	time.sleep(0.1)

	#for __ in range(100):
	#	subprocess.Popen(['awesome-client', 's = screen.fake_add(100, 100, 100, 100); s:fake_remove()'])
	#	time.sleep(0.1)
	##for __ in range(1000):
	##	time.sleep(0.0003)
	##	subprocess.Popen(['xrandr', '--delmonitor', 'LEFT'])
	##	time.sleep(0.0003)
	##	subprocess.Popen(['xrandr', '--setmonitor', 'LEFT', f'{half_width}/0x{RESOLUTION[1]}/0+0+0', 'none'])
	#time.sleep(0.5)

	subprocess.Popen(['awesome-client', 'awesome.quit()'])

	proc.wait(timeout=600)


def run_tests():
	try:
		subprocess.Popen(['Xephyr', '-ac', '-noreset', '-screen', f'{RESOLUTION[0]}x{RESOLUTION[1]}', '-dpi', str(DPI), '-host-cursor', '+bs', '+iglx', DISPLAY])
		os.environ['DISPLAY'] = DISPLAY
		test_monitor_reconnects()
	except KeyboardInterrupt:
		return

	#subprocess.Popen(['awesome-client', 's = screen.fake_add(100, 100, 100, 100); s:fake_remove()'])


def run_dbus_session():
	os.setpgrp()
	pid_queue.put(os.getpgrp())
	proc = subprocess.Popen(['dbus-launch', '--binary-syntax'], stdout=subprocess.PIPE)
	data = proc.stdout.read()
	bus_address = data[:data.find(b'\0')]
	data = data[data.find(b'\0')+1:]
	pid = struct.unpack('i', data[:4])[0]
	pid_queue.put(pid)
	os.putenv('DBUS_SESSION_BUS_ADDRESS', bus_address)
	run_tests()


def terminate(pid, process_group_id, dbus_pid):
	if dbus_pid is not None:
		try:
			os.kill(dbus_pid, signal.SIGINT)
			os.waitpid(dbus_pid, 0)
		except Exception:
			pass
		try:
			os.kill(dbus_pid, signal.SIGKILL)
		except Exception:
			pass
	if process_group_id is not None:
		try:
			os.killpg(process_group_id, signal.SIGINT)
			os.waitpid(pid, 0)
		except Exception:
			pass
		except KeyboardInterrupt:
			pass
		try:
			os.killpg(process_group_id, signal.SIGKILL)
		except Exception:
			pass
	elif pid is not None:
		try:
			os.kill(pid, signal.SIGINT)
			os.waitpid(pid, 0)
		except Exception:
			pass
		try:
			os.kill(pid, signal.SIGKILL)
		except Exception:
			pass


def monitor_and_terminate_process(pid):
	group_id = None
	dbus_pid = None

	def at_exit(*args):
		nonlocal pid, group_id, dbus_pid
		terminate(pid, group_id, dbus_pid)
		pid = None
		group_id = None
		dbus_pid = None

	try:
		group_id = pid_queue.get()
		dbus_pid = pid_queue.get()
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
