# docker-wordpress

A Dockerfile that installs the latest wordpress, nginx, php7.0, mariadb 10.2

docker + nginx + mariadb + supervisor + php7


## Installation

The easiest way to get this docker image installed is to pull the latest version
from the Docker registry:

```bash
$ docker pull 9to5/docker-wordpress
```

If you'd like to build the image yourself then:

```bash
$ git clone https://github.com/9to6/docker-wordpress.git
$ cd docker-wordpress
$ sudo docker build -t="9to5/docker-wordpress" .
```

## Usage

```bash
$ sudo docker run -p80:80 -p9001:9001 --name docker-wordpress -d 9to5/docker-wordpress
```

After starting the docker-wordpress-nginx check to see if it started and the port mapping is correct.  This will also report the port mapping between the docker container and the host machine.

```
$ sudo docker ps

0.0.0.0:80 -> 80/tcp docker-wordpress
```
