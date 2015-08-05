# Version 1.0
FROM ubuntu:14.04
MAINTAINER Florian GAUVIN "florian.gauvin@nl.thalesgroup.com"

ENV DEBIAN_FRONTEND noninteractive

#Download all the packages needed

RUN apt-get update && \
	apt-get install -y software-properties-common && \
	add-apt-repository ppa:openjdk-r/ppa && \
	apt-get update && apt-get install -y \
	build-essential \
	cmake \
	git \
	python \
	wget \
	unzip \
	bc\
	language-pack-en \
	default-jdk \
	libtool \
	automake \
	autoconf \
	zlib1g-dev \
	openjdk-8-jdk \
	zip \
        && apt-get clean 

#Download and install the latest version of Docker (You need to be the same version to use this Dockerfile)

RUN wget -qO- https://get.docker.com/ | sh

#Download Apache Felix and decompress it

WORKDIR /usr

RUN wget http://www.eu.apache.org/dist//felix/org.apache.felix.main.distribution-5.0.1.tar.gz &&\
	tar -xf org.apache.felix.main.distribution-5.0.1.tar.gz 

#Clone a complete buildroot environment pre-configured with an openjdk9 package

RUN git clone -v https://github.com/florian-gauvin/Buildroot-Openjdk.git /usr/buildroot

##Build the small tar file with openjdk9 in it

WORKDIR /usr/buildroot
	
RUN make

#Decompress the tar file made by buildroot, copy apache felix in the buildroot environment, then recompress all the files

WORKDIR /usr/buildroot/output/images

RUN tar -xf rootfs.tar &&\
	rm rootfs.tar && \
	cp -r /usr/felix-framework-5.0.1/ usr/ && \
	tar -cf rootfs.tar *

#When the builder image is launch, it creates the openjdk9 and felix docker image that you will be able to see by running the command : docker images

ENTRYPOINT for i in `seq 0 100`; do sudo mknod -m0660 /dev/loop$i b 7 $i; done && \
	service docker start && \
	docker import - felix.image < rootfs.tar && \
	/bin/bash


