ARG BASE_IMAGE="python:3.9.4-slim-buster"
FROM $BASE_IMAGE

ENV PYTHONIOENCODING=utf-8
ENV LANG C.UTF-8
ENV DBT_PROFILES_DIR /home/$USER/.dbt

RUN /usr/bin/apt-get update -yqq \
  && /usr/bin/apt-get upgrade --no-install-recommends -yqq \
  && /usr/bin/apt-get install --no-install-recommends -yqq \
    git \
    software-properties-common \
    make \
    build-essential \
    ca-certificates \
    libpq-dev \
  && /usr/bin/apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY requirements.txt ./requirements.txt

RUN pip install --upgrade pip setuptools
RUN pip install --requirement ./requirements.txt
# RUN pip install dbt==0.18.2

# install vertica adapter
RUN pip install dbt-vertica

WORKDIR $DBT_PROFILES_DIR
VOLUME $DBT_PROFILES_DIR

CMD ["dbt seed"]
