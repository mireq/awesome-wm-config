# -*- coding: utf-8 -*-
import atexit
import os
import signal
import subprocess
import sys
import time
from pathlib import Path


BASE_DIR = Path(__file__).parent
DISPLAY = ':1'
RESOLUTION = [800, 600]
DPI = 96


def test_monitor_reconnects():
	# setup dual monitor
	half_width = RESOLUTION[0] // 2
	subprocess.Popen(['xrandr', '--setmonitor', 'RIGHT', f'{half_width}/0x{RESOLUTION[1]}/0+{half_width}+0', 'default'])
	subprocess.Popen(['xrandr', '--setmonitor', 'LEFT', f'{half_width}/0x{RESOLUTION[1]}/0+0+0', 'none'])
	time.sleep(0.1)
	proc = subprocess.Popen(['memusage', '--png=mem.png', 'awesome', '-c', BASE_DIR / 'rc_new.lua'])
	time.sleep(1)
	subprocess.Popen(['awesome-client', 'awesome.quit()'])

	proc.wait(timeout=10)


def run_tests():
	try:
		# run virtual desktop
		subprocess.Popen(['Xephyr', '-ac', '-noreset', '-screen', f'{RESOLUTION[0]}x{RESOLUTION[1]}', '-dpi', str(DPI), '-host-cursor', '+bs', '+iglx', DISPLAY])
		os.environ['DISPLAY'] = DISPLAY
		# wait for start
		time.sleep(0.5)
		test_monitor_reconnects()
	except KeyboardInterrupt:
		return


def main():
	proc = subprocess.Popen(['dbus-launch', sys.executable, __file__, '--'] + sys.argv[1:], preexec_fn=os.setpgrp)
	process_group_id = os.getpgid(proc.pid)

	try:
		proc.wait(timeout=10)
	except KeyboardInterrupt:
		pass
	except Exception:
		pass

	def at_exit(*args):
		proc.terminate()
		try:
			proc.wait(0.1)
		except:
			proc.kill()
		try:
			os.killpg(process_group_id, signal.SIGKILL)
		except Exception:
			pass

	atexit.register(at_exit)
	signal.signal(signal.SIGTERM, at_exit)
	signal.signal(signal.SIGINT, at_exit)
	signal.signal(signal.SIGHUP, at_exit)
	at_exit()


if __name__ == "__main__":
	if len(sys.argv) > 1 and sys.argv[1] == '--':
		run_tests()
	else:
		main()
