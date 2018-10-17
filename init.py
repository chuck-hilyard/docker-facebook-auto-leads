
import http.client
import os
import requests
import subprocess
import time

def install_software():
  subprocess.run(["mkdir", "/etc/skel/.ssh"])
  subprocess.run(["mkdir", "/etc/skel/catalog"])

def main():
  while True:
    print("main loop")
    time.sleep(60)

if __name__ == '__main__':
  install_software()
  main()
