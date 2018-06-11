############################################################
# Dockerfile to run Tactic Containers 
# Based on Centos 6 image
############################################################

FROM centos:centos6

ENV REFRESHED_AT 2016-10-23

# Reinstall glibc-common to get deleted files (i.e. locales, encoding UTF8) from the centos docker image
#RUN yum -y reinstall glibc-common
RUN yum -y update glibc-common

# Setup a minimal env
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV HOME /root

# set a better shell prompt
RUN echo 'export PS1="[\u@docker] \W # "' >> /root/.bash_profile

# Install dependecies
RUN yum -y install https://download.postgresql.org/pub/repos/yum/10/redhat/rhel-6-x86_64/pgdg-centos10-10-2.noarch.rpm
RUN yum -y install nc httpd postgresql10 python-lxml python-imaging python-crypto python-psycopg2 unzip git ImageMagick

# TODO add ffmpeg

# install supervisord
RUN /bin/rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm && \
    yum -y install python-setuptools && \
    easy_install supervisor && \
    mkdir -p /var/log/supervisor && \ 
    mkdir -p /etc/supervisor/conf.d/
ADD supervisord.conf /etc/supervisor/supervisord.conf

# Ssh server
# start and stop the server to make it generate host keys
RUN yum -y install openssh-server && \
    service sshd start && \
    service sshd stop
# set root passord at image launch with -e ROOT_PASSWORD=my_secure_password
ADD bootstrap.sh /usr/local/bin/bootstrap.sh

# Clean up
RUN yum clean all

EXPOSE 80 22

# Start Tactic stack
CMD ["/usr/local/bin/bootstrap.sh"]
