# Mikrotik-External-Captive-Portal
Overview
In this setup:

A FreeRADIUS server on Ubuntu authenticates users on a MikroTik Hotspot.
The Hotspot network (192.168.2.0/24) is configured on MikroTik’s ether2, while the FreeRADIUS server resides on the 192.168.18.0/24 subnet, connected to ether1.
