# -*- coding: utf-8 -*-
import atexit
import os
import signal
import subprocess
import sys
import time
from multiprocessing import Process, Queue


process_group_queue = Queue(1)


DISPLAY = ':1'


def run_tests():
	try:
		process_group_queue.put(os.getpgrp())
		subprocess.Popen(['sleep', '10'])
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
