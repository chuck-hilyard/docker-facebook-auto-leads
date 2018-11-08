
import http.client
import os
import requests
import subprocess
import time
import consul_kv
import pwd, grp
import re

def install_software():
  subprocess.run(["systemctl", "enable", "rsyslog.service"])
  time.sleep(10)
  subprocess.run(["mkdir", "/etc/skel/.ssh"])
  time.sleep(10)
  subprocess.run(["mkdir", "-m", "777", "/etc/skel/catalog"])
  time.sleep(10)
  subprocess.run(["mkdir", "-m", "777", "/etc/skel/product"])
  time.sleep(10)
  subprocess.run(["mkdir", "-m", "777", "/rl/data/logs/facebook-auto-feed"])
  time.sleep(10)
  subprocess.run(["mkdir", "-m", "777", "/rl/data/autofeed"])
  time.sleep(10)
  subprocess.run(["service", "ssh", "start"])
  time.sleep(10)
  subprocess.run(["service", "rsyslog", "start"])
  time.sleep(10)
  subprocess.run(["service", "cron", "start"])

def add_cronjob():
  conn = consul_kv.Connection(endpoint="http://consul:8500/v1/")
  target_path_env = "facebook-auto-feed/config/ENVIRONMENT"
  target_path_platform = "facebook-auto-feed/config/PLATFORM"
  raw_env = conn.get(target_path_env)
  raw_platform = conn.get(target_path_platform)
  regex_string = "^facebook-auto-feed/config/"
  for k,v in raw_env.items():
    env = re.sub(regex_string, '', v)
  for k,v in raw_platform.items():
    platform = re.sub(regex_string, '', v)
  cronjob_s3_sync = "*/3 * * * * aws s3 sync /home s3://facebook-auto-feed-{0}-{1}".format(env, platform)
  #subprocess.run(["echo", cronjob_s3_sync, ">>", "/var/spool/cron/crontabs/admin"])
  cmd = "echo \"{}\" >> /var/spool/cron/crontabs/admin".format(cronjob_s3_sync)
  p = subprocess.Popen(cmd, shell=True)
  os.waitpid(p.pid, 0)

def create_admin_user():
  # get admin user password from consul
  conn = consul_kv.Connection(endpoint="http://consul:8500/v1/")
  target_path = "facebook-auto-feed/config/admin"
  admin = conn.get(target_path)
  for raw_username, raw_password in admin.items():
    regex_string = "^facebook-auto-feed/config/"
    username = re.sub(regex_string, '', raw_username)
    password = raw_password
    homedir = "/home/{}".format(username)
    subprocess.run(["useradd", "-c", "gecos", "-d", "/tmp/admin", "-N", "-p", password, username])
    time.sleep(3)
    print("update admin password")
    subprocess.run(["usermod", "-p", password, username])

def maintain_config_state():
  print("validating operating environment")

def add_user(allusers):
  for raw_username, raw_password in allusers.items():
    # strip the prefix off allusers/raw_username
    regex_string = "^facebook-auto-feed/users/"
    username = re.sub(regex_string, '', raw_username)
    password = raw_password
    homedir = "/home/{}".format(username)
    subprocess.run(["useradd", "-c", "gecos", "-d", homedir, "-g", "sftp_users", "-m", "-N", "-p", password, username])
    time.sleep(3)
    subprocess.run(["usermod", "-p", password, username])
    time.sleep(3)
    subprocess.run(["chown", "root", homedir])

def remove_user(user):
  print("removing user: ", user)

def compare_user_list(allusers):
  print("comparing users in consul to passwd")

def is_consul_up():
  url = "http://consul:8500/v1/catalog/service/media-team-devops-automation-jenkins-agent"
  response = requests.get(url)
  return response.status_code

def scrape_consul_for_users():
  conn = consul_kv.Connection(endpoint="http://consul:8500/v1/")
  target_path = "facebook-auto-feed/users"
  allusers = conn.get(target_path, recurse=True)
  return allusers

def main():
  while True:
    print("main loop")
    maintain_config_state()
    if is_consul_up() == 200:
      print("consul is up")
      allusers = scrape_consul_for_users()
      compare_user_list(allusers)
      add_user(allusers)
    else:
      print("consul is down")
    time.sleep(60)

if __name__ == '__main__':
  install_software()
  create_admin_user()
  add_cronjob()
  main()
