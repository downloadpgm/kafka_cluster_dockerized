FROM mkenjis/ubjava_img

#ARG DEBIAN_FRONTEND=noninteractive
#ENV TZ=US/Central

RUN apt-get update && apt-get install -y dnsutils
 
WORKDIR /usr/local

# git clone https://github.com/mkenjis/apache_binaries
ADD kafka_2.11-2.1.1.tgz .
 
WORKDIR /root
RUN echo "" >>.bashrc \
 && echo 'export KAFKA_HOME=/usr/local/kafka_2.11-2.1.1' >>.bashrc \
 && echo 'export PATH=$PATH:$KAFKA_HOME/bin' >>.bashrc

# authorized_keys already create in ubjava_img to enable containers connect to each other via passwordless ssh

# declare the Hadoop name and data directories to be exported
VOLUME /usr/local/kafka_2.11-2.1.1/data

COPY create_conf_files.sh .
RUN chmod +x create_conf_files.sh
 
COPY run_kafka.sh .
RUN chmod +x run_kafka.sh

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 9092

CMD ["/usr/bin/supervisord"]