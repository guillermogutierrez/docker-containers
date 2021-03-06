FROM openjdk:8
MAINTAINER Guillermo Gutierrez <guillermo.gutierrez@liferay.com>

ARG image_path
ARG data_path
ARG license_path

RUN bash -c 'echo -e Building a Liferay portal using the image  $image_path  the data from  $data_path  and the license ß$license_path'

# Install minimal dependencies
RUN apt-get update \
  && apt-get install -y curl netcat \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && useradd -ms /bin/bash liferay \ 
  && adduser liferay sudo

# Create liferay required directories
ENV LIFERAY_HOME=/usr/local/liferay

RUN mkdir -p "$LIFERAY_HOME" \
	&& mkdir -p "$LIFERAY_HOME"/deploy  \
	&& mkdir -p "$LIFERAY_HOME"/deploy_perm  \
	&& mkdir -p "$LIFERAY_HOME"/data \
	&& mkdir -p "$LIFERAY_HOME"/docker_temp/lib/ext 

# Entrypoint to start tomcat during container run
COPY ./images/liferay/docker-entrypoint.sh /usr/local/bin/

RUN ln -s usr/local/bin/docker-entrypoint.sh /entrypoint.sh \
	&& chmod 755 /usr/local/bin/docker-entrypoint.sh \
	&& chown -R liferay:liferay /usr/local/bin/docker-entrypoint.sh

#RUN chown -R liferay:liferay $LIFERAY_HOME

WORKDIR /usr/local

# Liferay's bundle
COPY $image_path/liferay-bundle.zip $LIFERAY_HOME

# Copy any additional required jar
COPY $data_path/libs/* $LIFERAY_HOME/docker_temp/lib/ext/

# Bundle and libraries installation
RUN unzip -q $LIFERAY_HOME/liferay-bundle.zip -d $LIFERAY_HOME\
	&& rm $LIFERAY_HOME/liferay-bundle.zip \
	&& mv $(ls -d $LIFERAY_HOME/liferay*)/* $LIFERAY_HOME \
	&& ls -lrt $LIFERAY_HOME/docker_temp/ \
	&& cp -r $LIFERAY_HOME/docker_temp/* $(ls -d $LIFERAY_HOME/tomcat*)/ \
	&& rm $LIFERAY_HOME/docker_temp -R 	

# Contents of data
COPY $data_path/data $LIFERAY_HOME/data

# Plugins to be deployed during startup
COPY $data_path/deploy $LIFERAY_HOME/deploy_perm

# portal-ext.properties
COPY $data_path/config $LIFERAY_HOME/

# License deployment
COPY ${license_path}/*.xml $LIFERAY_HOME/deploy_perm

# Permissions update to ensure liferay user will have the required access
#RUN chown -R liferay:liferay $LIFERAY_HOME

VOLUME ["$LIFERAY_HOME/deploy", "$LIFERAY_HOME/logs", "$LIFERAY_HOME/osgi"]

EXPOSE 8080/tcp
EXPOSE 11311/tcp

#USER liferay

# Entrypoint sets CATALINA_HOME independently of the tomcat version
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
