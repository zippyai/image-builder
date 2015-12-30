FROM circleci/ubuntu-server:trusty-latest

# Avoid any installation scripts interact with upstart
# So divert now, but undivert at the end
RUN echo 'exit 101' > /usr/sbin/policy-rc.d \
	&& chmod +x /usr/sbin/policy-rc.d \
        && dpkg-divert --local --rename --add /sbin/initctl \
        && ln -s /bin/true /sbin/initctl

ADD circleci-install /usr/local/bin/circleci-install

ADD circleci-provision-scripts/base.sh /opt/circleci-provision-scripts/base.sh
ADD circleci-provision-scripts/circleci-specific.sh /opt/circleci-provision-scripts/circleci-specific.sh
RUN circleci-install base_requirements  && circleci-install circleci_specific

# Databases
ADD circleci-provision-scripts/mysql.sh /opt/circleci-provision-scripts/mysql.sh
RUN circleci-install mysql_56

ADD circleci-provision-scripts/mongo.sh /opt/circleci-provision-scripts/mongo.sh
RUN circleci-install mongo

ADD circleci-provision-scripts/postgres.sh /opt/circleci-provision-scripts/postgres.sh
RUN circleci-install postgres

ADD circleci-provision-scripts/misc.sh /opt/circleci-provision-scripts/misc.sh
RUN circleci-install redis
RUN circleci-install memcached

# Docker
ADD circleci-provision-scripts/lxc-docker.sh /opt/circleci-provision-scripts/lxc-docker.sh
RUN circleci-install lxc_docker

ADD circleci-provision-scripts/docker.sh /opt/circleci-provision-scripts/docker.sh
RUN circleci-install docker_compose

# Browsers
ADD circleci-provision-scripts/firefox.sh /opt/circleci-provision-scripts/firefox.sh
RUN circleci-install firefox

ADD circleci-provision-scripts/chrome.sh /opt/circleci-provision-scripts/chrome.sh
RUN circleci-install chrome

# Android
ADD scripts/circle-android /usr/local/bin/circle-android
ADD circleci-provision-scripts/android-sdk.sh /opt/circleci-provision-scripts/android-sdk.sh
RUN circleci-install android_sdk platform-tools
RUN circleci-install android_sdk android-22
RUN circleci-install android_sdk android-23

# Languages
ADD circleci-provision-scripts/python.sh /opt/circleci-provision-scripts/python.sh
RUN circleci-install python 3.5.1

ADD circleci-provision-scripts/nodejs.sh /opt/circleci-provision-scripts/nodejs.sh
RUN circleci-install nodejs v5.1.1

ADD circleci-provision-scripts/java.sh /opt/circleci-provision-scripts/java.sh
RUN circleci-install java

ADD circleci-provision-scripts/go.sh /opt/circleci-provision-scripts/go.sh
RUN circleci-install golang

ADD circleci-provision-scripts/ruby.sh /opt/circleci-provision-scripts/ruby.sh
RUN circleci-install ruby 2.2.2

ADD circleci-provision-scripts/php.sh /opt/circleci-provision-scripts/php.sh
RUN circleci-install php 5.6.16
RUN circleci-install php 7.0.0

#RUN circleci-install scala

# Qt
ADD circleci-provision-scripts/qt.sh /opt/circleci-provision-scripts/qt.sh
RUN circleci-install qt

# Undivert upstart
RUN rm /usr/sbin/policy-rc.d && rm /sbin/initctl && dpkg-divert --rename --remove /sbin/initctl

LABEL circleci.user="ubuntu"