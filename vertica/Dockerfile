# Do not use it in a production deployment.
FROM ubuntu:18.04

ARG VERTICA_PACKAGE
ARG VERTICA_DBA_USER
ARG VERTICA_DBA_PASSWORD
ARG VERTICA_DATABASE_NAME

# dbadmin only works currently
ENV DBA_USER=${VERTICA_DBA_USER:-dbadmin}
ENV DBA_PASSWORD=${VERTICA_DBA_PASSWORD:-}
ENV DATABASE_NAME=${VERTICA_DATABASE_NAME:-test}
ENV VERTICADATA /home/$DBA_USER/vertica_data

ENV SHELL "/bin/bash"
ENV DEBIAN_FRONTEND noninteractive
ENV TERM 1
ENV PYTHON_EGG_CACHE /tmp/.python-eggs

# RUN echo VERTICA_PACKAGE=$VERTICA_PACKAGE, VERTICA_DBA_USER=$VERTICA_DBA_USER VERTICA_DBA_PASSWORD=$VERTICA_DBA_PASSWORD DATABASE_NAME=$DATABASE_NAME
# RUN echo DBA_USER=$DBA_USER, DBA_PASSWORD=$DBA_PASSWORD, DATABASE_NAME=$DATABASE_NAME, VERTICADATA=$VERTICADATA

ADD packages/$VERTICA_PACKAGE /tmp/
ADD scripts/cleaner.sh /tmp/

RUN /usr/bin/apt-get update -yqq \
  && /usr/bin/apt-get upgrade --no-install-recommends -yqq \
  && /usr/bin/apt-get install --no-install-recommends -yqq curl ca-certificates locales \
  && /usr/bin/chsh -s /bin/bash root \
  && /bin/rm /bin/sh && ln -s /bin/bash /bin/sh \
  && /usr/sbin/groupadd -r verticadba \
  && /usr/sbin/useradd -r -m -s /bin/bash -g verticadba $DBA_USER \
  && su - $DBA_USER -c 'mkdir /tmp/.python-eggs' \
  && /usr/sbin/locale-gen en_US en_US.UTF-8 \
  && /usr/sbin/dpkg-reconfigure locales \
  && /usr/bin/apt-get install --no-install-recommends -yqq openssh-server openssh-client sysstat dialog libexpat1 iproute2 ntp \
  && /usr/bin/dpkg -i /tmp/$VERTICA_PACKAGE

RUN /opt/vertica/sbin/install_vertica \
  --accept-eula \
  --data-dir $VERTICADATA \
  --dba-user $DBA_USER \
  --dba-user-home /home/$DBA_USER \
  --dba-user-password $DBA_PASSWORD \
  --failure-threshold NONE \
  --hosts 127.0.0.1 \
  --large-cluster 1 \
  --license CE \
  --deb /tmp/$VERTICA_PACKAGE

RUN /usr/bin/apt-get remove --purge -y curl ca-certificates libpython2.7 \
  && /bin/bash /tmp/cleaner.sh \
  && /usr/bin/apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD ./docker-entrypoint.sh /opt/vertica/bin/
RUN chmod +x /opt/vertica/bin/docker-entrypoint.sh

VOLUME /home/$DBA_USER/vertica_data
ENTRYPOINT ["/opt/vertica/bin/docker-entrypoint.sh"]

EXPOSE 5433
