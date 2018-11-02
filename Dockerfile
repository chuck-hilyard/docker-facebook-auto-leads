FROM ubuntu:latest

RUN apt-get update && apt-get upgrade -y && apt-get install -y python3 python3-pip openssh-server rsyslog systemd 
RUN pip3 install requests consulate consul_kv

COPY sshd_config /etc/ssh/sshd_config
COPY init.py /tmp/init.py

RUN groupadd sftp_users

#RUN useradd -c "admin"  /home/admin -G sftp_users admin
RUN useradd -c "admin" -d / admin
ADD crontab /var/spool/cron/crontabs/admin
RUN chmod 0600 /var/spool/cron/crontabs/admin
RUN chown admin /var/spool/cron/crontabs/admin

ADD cron.sh /tmp/cron.sh
RUN chmod 0777 /tmp/cron.sh


EXPOSE 2222

#USER admin

CMD [ "python3", "-u", "/tmp/init.py" ]
