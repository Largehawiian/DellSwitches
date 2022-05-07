#!/usr/bin/env python
#load this script using the start-on-boot parameter in
#order to back up the switch each time the switch reloads
import telnetlib
import os
import re
import time
import string
import sys
import threading
HOST = '10.100.100.243'
PORT = 23
LOGIN_STRING = "Login:"
PASSWORD_STRING = "Password:"
TERMINAL_LEN_ZERO = "terminal length 0\n"
TERMINAL_MONITOR = "terminal monitor\n"
ENABLE_STRING = "enable\n"
CONFIG_STRING = "configure\n"
USERNAME = 'admin'
PASSWORD = 'Art2235user!'
ENABLE_PASSWORD = ''
TIMEOUT = 3
def do_terminal_settings(tn):
    tn.write(TERMINAL_MONITOR)
    tn.read_until("#")
    tn.write(TERMINAL_LEN_ZERO)
    tn.read_until("#")
def do_login(tn):
    tn.read_until(LOGIN_STRING, TIMEOUT)
    tn.write(USERNAME + "\n")
    tn.read_until(PASSWORD_STRING, TIMEOUT)
    tn.write(PASSWORD + "\n")
    tn.read_until(">", TIMEOUT)
    tn.write(ENABLE_STRING)
    tn.read_until("#", TIMEOUT)
def do_config(tn):
    tn.read_until("#", TIMEOUT)
    tn.write("copy running-config tftp://172.16.4.193/lab-switch-test.txt\n");
    tn.read_until("(y/n)", TIMEOUT)
    tn.write("y");
    tn.read_until("#", TIMEOUT)
def main():
    telnet = telnetlib.Telnet(HOST,PORT)
    do_login(telnet)
    do_terminal_settings(telnet)
    do_config(telnet)
    telnet.close()
    t = threading.Timer(10.0, main)
    t.start()

t = threading.Timer(10.0,main)
t.start()