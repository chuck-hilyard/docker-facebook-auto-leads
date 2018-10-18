FROM ubuntu:latest

RUN apt-get update && apt-get upgrade -y && apt-get install -y python3 python3-pip openssh-server 
RUN pip3 install requests consulate consul_kv

COPY sshd_config /etc/ssh/sshd_config
COPY init.py /tmp/init.py

RUN groupadd sftp_users

EXPOSE 2222

CMD [ "python3", "-u", "/tmp/init.py" ]
