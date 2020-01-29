FROM jenkins/jenkins:lts
LABEL maintainer="bruce.becker@uefa.ch"
EXPOSE 8080
EXPOSE 50000
USER root
RUN apt-get update && apt-get install -y \
    gcc \
    python-dev \
    python-virtualenv \
    python-pip  \
    libffi-dev  \
    libssl-dev \
    vim \
    bind9-host
USER jenkins
COPY plugins.txt /casc/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /casc/plugins.txt
