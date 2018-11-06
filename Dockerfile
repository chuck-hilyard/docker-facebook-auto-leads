FROM ubuntu:latest

RUN apt-get update && apt-get upgrade -y && DEBIAN_FRONTEND=noninteractive apt-get install -yq python3 python3-pip openssh-server rsyslog systemd awscli inotify-tools
RUN pip3 install requests consulate consul_kv

COPY sshd_config /etc/ssh/sshd_config
COPY init.py /tmp/init.py

RUN groupadd sftp_users

#RUN useradd -c "admin"  /home/admin -G sftp_users admin
RUN useradd -c "admin" -d / admin
ADD crontab /var/spool/cron/crontabs/admin
RUN chmod 0600 /var/spool/cron/crontabs/admin
RUN chown admin /var/spool/cron/crontabs/admin
#RUN mkdir -p /rl/{product,data/shared/configs,data/logs}; chmod -R 777 /rl

ADD cron.sh /tmp/cron.sh
RUN chmod 0777 /tmp/cron.sh


EXPOSE 2222

#USER admin

CMD [ "python3", "-u", "/tmp/init.py" ]
