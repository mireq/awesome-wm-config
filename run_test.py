# -*- coding: utf-8 -*-
import atexit
import os
import signal
import subprocess
import sys
import time
from multiprocessing import Process, Queue
from pathlib import Path


process_group_queue = Queue(1)


BASE_DIR = Path(__file__).parent
DISPLAY = ':1'
RESOLUTION = [800, 600]
DPI = 96


def test_monitor_reconnects():
	# setup dual monitor
	half_width = RESOLUTION[0] // 2
	subprocess.Popen(['xrandr', '--setmonitor', 'LEFT', f'{half_width}/0x{RESOLUTION[1]}/0+0+0', 'default'])
	subprocess.Popen(['xrandr', '--setmonitor', 'RIGHT', f'{half_width}/0x{RESOLUTION[1]}/0+{half_width}+0', 'none'])
	time.sleep(0.1)
	subprocess.Popen(['awesome', '-c', BASE_DIR / 'rc_new.lua'])


def run_tests():
	try:
		process_group_queue.put(os.getpgrp())
		# run virtual desktop
		subprocess.Popen(['Xephyr', '-ac', '-noreset', '-screen', f'{RESOLUTION[0]}x{RESOLUTION[1]}', '-dpi', str(DPI), '-host-cursor', '+bs', '+iglx', DISPLAY])
		os.environ['DISPLAY'] = DISPLAY
		# wait for start
		time.sleep(0.5)
		test_monitor_reconnects()
		time.sleep(10)
	except KeyboardInterrupt:
		return


def main():
	proc = Process(target=run_tests)
	proc.start()
	process_group_id = process_group_queue.get()
	try:
		proc.join()
	except KeyboardInterrupt:
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
		sys.exit()

	atexit.register(at_exit)
	signal.signal(signal.SIGTERM, at_exit)
	signal.signal(signal.SIGINT, at_exit)
	signal.signal(signal.SIGHUP, at_exit)


if __name__ == "__main__":
	main()
