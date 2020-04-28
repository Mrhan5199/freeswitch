import time, datetime

# i = 0
# list_table = []
# for i in range(1,4):
#     tm = time.strftime("%H:%M:%S", time.localtime())
#     k = list_table.append(tm)
#     print(tm)
# else:
#     print((list_table))

import re

import socket
import fcntl
import struct
  
def get_ip_address(ifname):
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    return socket.inet_ntoa(fcntl.ioctl(
        s.fileno(),
        0x8915,  # SIOCGIFADDR
        struct.pack('256s', ifname[:15])
    )[20:24])