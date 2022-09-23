export JAVA_HOME=/usr/local/jre1.8.0_181
export CLASSPATH=$JAVA_HOME/lib
export PATH=$PATH:.:$JAVA_HOME/bin

export KAFKA_HOME=/usr/local/kafka_2.11-2.1.1
export PATH=$PATH:$KAFKA_HOME/bin

service ssh start

echo -e "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config
ssh-keyscan ${HOSTNAME} >~/.ssh/known_hosts
ssh-keyscan localhost >>~/.ssh/known_hosts
ssh-keyscan 0.0.0.0 >>~/.ssh/known_hosts

sleep 20
   
if [ -n "${ZKP_HOST_BROKERS}" ]; then

   mkdir -p $KAFKA_HOME/data

   echo $(expr ${BROKER_ID} + 1) > $KAFKA_HOME/data/myid

   for ZKP_HOST in `echo ${ZKP_HOST_BROKERS} | tr ',' ' '`; do
      DOCKER_NAME=$(ssh root@${ZKP_HOST} "cat /etc/hostname")
      nslookup ${DOCKER_NAME} | tail -2 | sed "s/Address:/${ZKP_HOST}/g" | awk '{print $2 "  " $1}' >>/etc/hosts
   done
   
   create_conf_files.sh

   zookeeper-server-start.sh $KAFKA_HOME/config/zookeeper.properties >/root/zkp.log &

   sleep 20

   kafka-server-start.sh $KAFKA_HOME/config/server.properties >/root/kfk.log &
   
fi
