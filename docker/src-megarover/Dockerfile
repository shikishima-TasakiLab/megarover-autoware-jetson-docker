ARG AUTOWARE_JETSON="jetson/autoware:r32.3.1-1.14.0"
FROM ${AUTOWARE_JETSON}

USER root
RUN apt-get update && \
    apt-get install -y \
        ros-melodic-rosserial-python \
        mpg321 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV LANG=C.UTF-8

USER ros
COPY ./entrypoint.sh /tmp/entrypoint.sh
ENTRYPOINT [ "/tmp/entrypoint.sh" ]
