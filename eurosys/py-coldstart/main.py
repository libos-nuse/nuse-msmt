import os
import sys
import socket

# Importing these verifies that our static modules built correctly
import math
import ssl
import json
import csv

from greenlet import greenlet

#import http.server
import socketserver

def start_http():
    print("this is http server test")
    PORT = 8000
#    Handler = http.server.SimpleHTTPRequestHandler
    Handler = None

    httpd = socketserver.TCPServer(("", PORT), Handler)
    print("listen on fd {}".format(httpd.fileno()))

def hello_world():
    print("\n" * 4)
    print("Welcome to rumprun/python %d.%d!" % sys.version_info[:2])
    print("{} / {}".format(sys.platform, os.name))
    print(json.dumps({'key': 'value'}))

    if socket.has_ipv6:
        print("IPv6 is enabled")

    try:
        import sqlite3
        print("sqlite {} built correctly".format(sqlite3.sqlite_version))
    except ImportError as e:
        print("sqlite3 not built")

    print("\n" * 2)


def test1():
    print(12)
    gr2.switch()
    print(34)

def test2():
    print(56)
    gr1.switch()
    print(78)


gr1 = greenlet(test1)
gr2 = greenlet(test2)

if __name__ == '__main__':
    hello_world()
    gr1.switch()
    start_http()
