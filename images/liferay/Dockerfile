FROM mdelapenya/jdk:8-openjdk
MAINTAINER Manuel de la Peña <manuel.delapenya@liferay.com>

ARG image_path
ARG data_path
ARG tomcat_version

RUN apt-get update \
  && apt-get install -y curl \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && useradd -ms /bin/bash liferay

ENV LIFERAY_HOME=/usr/local/liferay

RUN mkdir -p "$LIFERAY_HOME" \
	&& mkdir -p "$LIFERAY_HOME"/deploy  \
	&& mkdir -p "$LIFERAY_HOME"/data \
	&& mkdir -p "$LIFERAY_HOME"/docker_temp/lib/ext 

COPY ./images/liferay/docker-entrypoint.sh /usr/local/bin/

RUN ln -s usr/local/bin/docker-entrypoint.sh /entrypoint.sh \
	&& chmod 755 /usr/local/bin/docker-entrypoint.sh \
	&& chown -R liferay:liferay /usr/local/bin/docker-entrypoint.sh

RUN chown -R liferay:liferay $LIFERAY_HOME

WORKDIR /usr/local

COPY $image_path/liferay-bundle.zip $LIFERAY_HOME

COPY $data_path/libs/* $LIFERAY_HOME/docker_temp/lib/ext

RUN unzip -q $LIFERAY_HOME/liferay-bundle.zip -d $LIFERAY_HOME\
	&& rm $LIFERAY_HOME/liferay-bundle.zip \
	&& mv $(ls -d $LIFERAY_HOME/liferay*)/* $LIFERAY_HOME \
	&& ls -lrt $LIFERAY_HOME/docker_temp/ \
	&& cp -r $LIFERAY_HOME/docker_temp/* $(ls -d $LIFERAY_HOME/tomcat*)/ \
	&& rm $LIFERAY_HOME/docker_temp -R 	

COPY $data_path/data $LIFERAY_HOME/data

COPY $data_path/deploy $LIFERAY_HOME/deploy

COPY $data_path/config $LIFERAY_HOME/

COPY ${image_path}/*.xml $LIFERAY_HOME/deploy

RUN chown -R liferay:liferay $LIFERAY_HOME

EXPOSE 8080/tcp
EXPOSE 11311/tcp

USER liferay

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]