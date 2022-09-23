FROM ubuntu:16.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=US/Central

RUN apt-get update && apt-get install -y supervisor openssh-server openssh-client vim iputils-ping dnsutils
 
WORKDIR /usr/local

# git clone https://github.com/mkenjis/apache_binaries
ADD jre-8u181-linux-x64.tar.gz .
ADD kafka_2.11-2.1.1.tgz .
 
WORKDIR /root
RUN echo "" >>.bashrc \
 && echo 'export JAVA_HOME=/usr/local/jre1.8.0_181' >>.bashrc \
 && echo 'export CLASSPATH=$JAVA_HOME/lib' >>.bashrc \
 && echo 'export PATH=$PATH:.:$JAVA_HOME/bin' >>.bashrc \
 && echo "" >>.bashrc \
 && echo 'export KAFKA_HOME=/usr/local/kafka_2.11-2.1.1' >>.bashrc \
 && echo 'export PATH=$PATH:$KAFKA_HOME/bin' >>.bashrc

# creates ssh private and public keys, 
# and creates authorized_keys to enable containers connect to each other via passwordless ssh
RUN /bin/bash -c "ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa <<<y 2>&1 >/dev/null" \
 && cp .ssh/id_rsa.pub .ssh/authorized_keys

COPY create_conf_files.sh .
RUN chmod +x create_conf_files.sh
 
COPY run_kafka.sh .
RUN chmod +x run_kafka.sh

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 9092

CMD ["/usr/bin/supervisord"]
