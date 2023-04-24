ARG CI_REGISTRY_IMAGE
ARG TAG
ARG DOCKERFS_TYPE
ARG DOCKERFS_VERSION
ARG JUPYTERLAB_DESKTOP_VERSION
FROM ${CI_REGISTRY_IMAGE}/matlab-runtime:R2018b_u0${TAG}

LABEL maintainer="nathalie.casati@chuv.ch"

ARG DEBIAN_FRONTEND=noninteractive
ARG CARD
ARG CI_REGISTRY
ARG APP_NAME
ARG APP_VERSION

LABEL app_version=$APP_VERSION
LABEL app_tag=$TAG

WORKDIR /apps/${APP_NAME}

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \
    curl unzip libgtk-3-0 libglib2.0-0 dbus-x11 \
    at-spi2-core libgl1-mesa-dri && \
    curl -sSOL http://meg.univ-amu.fr/GARDEL/GARDEL_linux.zip && \
    mkdir ./install && \
    unzip -q -d ./install GARDEL_linux.zip && \
    chmod 755 ./install/GARDEL_standalone/GARDELv2 && \
    rm GARDEL_linux.zip && \
    apt-get remove -y --purge curl unzip && \
    apt-get autoremove -y --purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV APP_SPECIAL="no"
ENV APP_CMD="ln -s /apps/${APP_NAME}/install/GARDEL_standalone/* ~ ; LD_LIBRARY_PATH=/usr/local/MATLAB/MATLAB_Runtime/v95/runtime/glnxa64:/usr/local/MATLAB/MATLAB_Runtime/v95/bin/glnxa64:/usr/local/MATLAB/MATLAB_Runtime/v95/sys/os/glnxa64:/usr/local/MATLAB/MATLAB_Runtime/v95/extern/bin/glnxa64:${LD_LIBRARY_PATH} /apps/${APP_NAME}/install/GARDEL_standalone/GARDELv2"
ENV PROCESS_NAME="/apps/${APP_NAME}/install/GARDEL_standalone/GARDELv2"
ENV APP_DATA_DIR_ARRAY=""
ENV DATA_DIR_ARRAY=""

HEALTHCHECK --interval=10s --timeout=10s --retries=5 --start-period=30s \
  CMD sh -c "/apps/${APP_NAME}/scripts/process-healthcheck.sh \
  && /apps/${APP_NAME}/scripts/ls-healthcheck.sh /home/${HIP_USER}/nextcloud/"

COPY ./scripts/ scripts/

ENTRYPOINT ["./scripts/docker-entrypoint.sh"]
