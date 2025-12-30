from re import findall
from subprocess import Popen, PIPE
import paramiko
import netmiko

def ping (host,ping_count):

    for ip in host:
        data = ""
        output= Popen(f"ping {ip} -n {ping_count}", stdout=PIPE, encoding="utf-8")

        for line in output.stdout:
            data = data + line
            ping_test = findall("TTL", data)

        if ping_test:
            print(f"{ip} : Successful Ping")
        else:
            print(f"{ip} : Failed Ping")

nodes = ["8.8.8.8", "9.76.144.104", "9.76.151.11", "9.92.205.5", "9.92.205.101"]

ping(nodes,3)