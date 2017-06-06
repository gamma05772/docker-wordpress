# docker-wordpress

A Dockerfile that installs the latest wordpress, nginx, php7.0, mariadb 10.2 on Ubuntu 16.04 xenial

docker + nginx + mariadb + supervisor + php7

Thanks to [eugeneware](https://github.com/eugeneware/docker-wordpress-nginx) for helping making this repository. 

## Installation


### Docker Hub

```bash
$ docker pull 9to5/wordpress
```

If you'd like to build the image yourself then:

```bash
$ git clone https://github.com/9to6/docker-wordpress.git
$ cd docker-wordpress
$ sudo docker build -t="9to5/wordpress" .
```

## Usage

Start

```bash
$ sudo docker run -p80:80 -p9001:9001 --name wordpress -d 9to5/wordpress
```

Stop and remove

```bash
$ sudo docker rm -f wordpress
```

After starting the 9to5/wordpress check to see if it started and the port mapping is correct.  
This will also report the port mapping between the docker container and the host machine.

```
$ sudo docker ps

0.0.0.0:80 -> 80/tcp
0.0.0.0:9001->9001/tcp
```

You can use also volume mount, `wp-content` directory for *theme*, *plugins* and so on.

```bash
$ sudo docker run -p80:80 -p9001:9001 --name wordpress -d -v/host/directory/wp-content:/usr/share/nginx/www/wp-content 9to5/wordpress
```

You can use supervisord admin web page

```
http://yoursitedomain.com:9001
```

default username and password is:  
username: `supervisor`  
password: `supervisor()`  

You can also change these.

Check this area in the file, *supervisord.conf*

```
[inet_http_server]
port = 0.0.0.0:9001
username = supervisor
password = supervisor()
```

If you don't want to expose the port 9001, you can remove that

```bash
$ sudo docker run -p80:80 --name wordpress -d 9to5/wordpress
```

