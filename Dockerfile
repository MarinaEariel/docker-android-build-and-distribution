# Dockerfile for Android build and distribution

FROM ubuntu:18.04

MAINTAINER Marina Cuello "marina.cuello@gmail.com"

# Based on uber/android-build-environment and javiersantos/android-ci

# General setup
ENV DEBIAN_FRONTEND noninteractive

# Update apt-get and add repos
RUN rm -rf /var/lib/apt/lists/*
RUN apt-get -qq update
RUN apt-get dist-upgrade -y


# Installing packages
RUN apt-get install -y \
  autoconf \
  bzip2 \
  curl \
  git \
  libc6-i386 \
  lib32stdc++6 \
  lib32gcc1 \
  lib32ncurses5 \
  lib32z1 \
  locales \
  openssh-client \
  software-properties-common \
  unzip \
  wget \
  --no-install-recommends

RUN apt-add-repository ppa:openjdk-r/ppa
RUN apt-add-repository ppa:ansible/ansible
RUN apt-get update

RUN apt-get install -y \
  ansible \
  openjdk-8-jdk \
  --no-install-recommends

RUN apt-get clean

# Setup locale
RUN locale-gen en_US.UTF-8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

# Install Android SDK
RUN wget https://dl.google.com/android/android-sdk_r24.4.1-linux.tgz
RUN tar -xvzf android-sdk_r24.4.1-linux.tgz
RUN mv android-sdk-linux /usr/local/android-sdk
RUN rm android-sdk_r24.4.1-linux.tgz

ENV ANDROID_COMPONENTS platform-tools,android-23,android-24,build-tools-23.0.2,build-tools-24.0.0

# Install Android tools
RUN echo y | /usr/local/android-sdk/tools/android update sdk --filter "${ANDROID_COMPONENTS}" --no-ui -a

# Install Android NDK
RUN wget http://dl.google.com/android/repository/android-ndk-r12-linux-x86_64.zip
RUN unzip android-ndk-r12-linux-x86_64.zip
RUN mv android-ndk-r12 /usr/local/android-ndk
RUN rm android-ndk-r12-linux-x86_64.zip

# Environment variables
ENV ANDROID_HOME /usr/local/android-sdk
ENV ANDROID_SDK_HOME $ANDROID_HOME
ENV ANDROID_NDK_HOME /usr/local/android-ndk
ENV JENKINS_HOME $HOME
ENV PATH ${INFER_HOME}/bin:${PATH}
ENV PATH $PATH:$ANDROID_SDK_HOME/tools
ENV PATH $PATH:$ANDROID_SDK_HOME/platform-tools
ENV PATH $PATH:$ANDROID_SDK_HOME/build-tools/23.0.2
ENV PATH $PATH:$ANDROID_SDK_HOME/build-tools/24.0.0
ENV PATH $PATH:$ANDROID_NDK_HOME
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/

# Fix permissions
RUN chown -R $RUN_USER:$RUN_USER $ANDROID_HOME $ANDROID_SDK_HOME $ANDROID_NDK_HOME
RUN chmod -R a+rx $ANDROID_HOME $ANDROID_SDK_HOME $ANDROID_NDK_HOME

