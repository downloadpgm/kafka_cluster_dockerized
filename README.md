# Kafka cluster in Docker

Apache Kafka is a distributed, fast, scalable publish-subscribe messaging system. It persists all messages and is capable of acting as a replay queue.

This Docker image contains Kafka binaries prebuilt and uploaded in Docker Hub.

## Steps to Build Hadoop image
```shell
$ git clone https://github.com/mkenjis/apache_binaries
$ docker image build -t mkenjis/ubkfk_img .
$ docker login   # provide user and password
$ docker image push mkenjis/ubkfk_img
```

## Shell Scripts Inside 

> run_kafka.sh

Sets up the environment for the Kafka cluster by executing the following steps :
- sets environment variables for JAVA and KAFKA
- starts the SSH service and scans the slave nodes for passwordless SSH
- initializes the Kafka system variables
- starts Zookeeper processes in all nodes
- starts Kafka processes in all nodes

> create_conf_files.sh

Creates the following Hadoop files $KAFKA_HOME/config directory :
- server.properties
- zookeeper.properties

## Start Swarm cluster

1. start swarm mode in node1
```shell
$ docker swarm init --advertise-addr <IP node1>
$ docker swarm join-token manager  # issue a token to add a node as manager to swarm
```

2. add more managers in swarm cluster (node2, node3, ...)
```shell
$ docker swarm join --token <token> <IP nodeN>:2377
```

3. start hadoop namenode and datanodes 
```shell
$ docker stack deploy -c docker-compose.yml kfk
$ docker service ls
ID             NAME          MODE         REPLICAS   IMAGE                             PORTS
bz8eebyh55lv   kfk_kfk1      replicated   1/1        mkenjis/ubkfk_img:latest          *:9092->9092/tcp
jp0qe9qzikck   kfk_kfk2      replicated   1/1        mkenjis/ubkfk_img:latest          *:9093->9092/tcp
jwk502t6d9ks   kfk_kfk3      replicated   1/1        mkenjis/ubkfk_img:latest          *:9094->9092/tcp
```

4. access a kafka node
```shell
$ docker container ls   # run it in any node and check which <container ID>
CONTAINER ID   IMAGE                             COMMAND                  CREATED        STATUS       PORTS                                          NAMES
6a93c436202e   mkenjis/ubkfk_img:latest          "/usr/bin/supervisord"   8 hours ago    Up 8 hours   9092/tcp                                       kfk_kfk2.1.ip3j32uvlotcetnyqhyjzkfow
da0713b1c2be   mkenjis/ubkfk_img:latest          "/usr/bin/supervisord"   8 hours ago    Up 8 hours   9092/tcp                                       kfk_kfk1.1.8wewpl9o7pcxlvqn04pc2qxzq
07c056589b70   mkenjis/ubkfk_img:latest          "/usr/bin/supervisord"   8 hours ago    Up 8 hours   9092/tcp                                       kfk_kfk3.1.b51a0gnskvi9vt9knnpp65y1e

$ docker container exec -it <kfk ID> bash
```

5. check zookeeper service
```shell
$ zookeeper-shell.sh kfk1:2181 ls /brokers/ids
Connecting to kfk1:2181

WATCHER::

WatchedEvent state:SyncConnected type:None path:null
[0, 1, 2]
```

6. create a topic in kafka
```shell
$ kafka-topics.sh --create --zookeeper kfk1:2181,kfk2:2181,kfk3:2181 --replication-factor 1 --partitions 1 --topic test
Created topic "test".

$ kafka-topics.sh --list --zookeeper kfk1:2181,kfk2:2181,kfk3:2181
test
```
