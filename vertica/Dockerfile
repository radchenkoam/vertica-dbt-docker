# Do not use it in a production deployment.
FROM ubuntu:18.04

ARG VERTICA_PACKAGE
ARG VERTICA_DATA
# dbadmin only works currently
ARG VERTICA_DBA_USER=${VERTICA_DBA_USER:-dbadmin}
ARG VERTICA_DBA_PASSWORD=${VERTICA_DBA_PASSWORD:-}
ARG VERTICA_DATABASE_NAME=${VERTICA_DATABASE_NAME:-test}
ARG VERTICA_DATA=${VERTICA_DATA:-/usr/local/share/vertica_data}

ENV SHELL "/bin/bash"
ENV DEBIAN_FRONTEND noninteractive
ENV TERM 1
ENV PYTHON_EGG_CACHE /tmp/.python-eggs

ADD packages/$VERTICA_PACKAGE /tmp/
ADD scripts/cleaner.sh /tmp/

RUN /usr/bin/apt-get update -yqq \
  && /usr/bin/apt-get upgrade --no-install-recommends -yqq \
  && /usr/bin/apt-get install --no-install-recommends -yqq curl ca-certificates locales \
  && /usr/bin/chsh -s /bin/bash root \
  && /bin/rm /bin/sh && ln -s /bin/bash /bin/sh \
  && /usr/sbin/groupadd -r verticadba \
  && /usr/sbin/useradd -r -m -s /bin/bash -g verticadba $VERTICA_DBA_USER \
  && su - $VERTICA_DBA_USER -c 'mkdir /tmp/.python-eggs' \
  && /usr/sbin/locale-gen en_US en_US.UTF-8 \
  && /usr/sbin/dpkg-reconfigure locales \
  && /usr/bin/apt-get install --no-install-recommends -yqq openssh-server openssh-client sysstat dialog libexpat1 iproute2 ntp \
  && /usr/bin/dpkg -i /tmp/$VERTICA_PACKAGE

RUN /opt/vertica/sbin/install_vertica \
  --accept-eula \
  --data-dir $VERTICA_DATA \
  --dba-user $VERTICA_DBA_USER \
  --dba-user-home /home/$VERTICA_DBA_USER \
  --dba-user-password $VERTICA_DBA_PASSWORD \
  --failure-threshold NONE \
  --hosts 127.0.0.1 \
  --large-cluster 1 \
  --license CE \
  --deb /tmp/$VERTICA_PACKAGE

RUN /usr/bin/apt-get remove --purge -y curl ca-certificates libpython2.7 \
  && /bin/bash /tmp/cleaner.sh

ADD ./docker-entrypoint.sh /opt/vertica/bin/
RUN chmod +x /opt/vertica/bin/docker-entrypoint.sh

VOLUME $VERTICA_DATA
ENTRYPOINT ["/opt/vertica/bin/docker-entrypoint.sh"]

EXPOSE 5433
