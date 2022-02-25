ARG BUILD_FROM
FROM $BUILD_FROM

RUN mkdir /hassio_bticino_smarter

WORKDIR /hassio_bticino_smarter

RUN /bin/ash -c 'set -ex && \
    ARCH=`uname -m` && \
    if [ "$ARCH" == "armv7l" ] || [ "$ARCH" == "armhf" ]; then \
        apk add --no-cache \
           bash \
           tzdata \
           python3 \
           py3-pip \
           git \
           gcc \
           mosquitto-clients \
           libressl-dev \
           musl-dev \
           libffi-dev \
           python3-dev \
           cargo \
           \
        && git clone -b v2 https://github.com/andrea-mattioli/bticino_X8000_rest_api.git \
        && mv bticino_X8000_rest_api/* /hassio_bticino_smarter/ \
        && rm -rf bticino_X8000_rest_api; \
    else \
        apk add --no-cache \
           bash \
           tzdata \
           python3 \
           py3-pip \
           git \
           gcc \
           mosquitto-clients \
           chromium \
           chromium-chromedriver \
           libressl-dev \
           musl-dev \
           libffi-dev \
           python3-dev \
           cargo \
           \
        && git clone -b v2 https://github.com/andrea-mattioli/bticino_X8000_rest_api.git \
        && mv bticino_X8000_rest_api/* /hassio_bticino_smarter/ \
        && rm -rf bticino_X8000_rest_api; \
    fi'

COPY run.sh /hassio_bticino_smarter/

RUN chmod a+x /hassio_bticino_smarter/run.sh

RUN pip3 install --upgrade pip

RUN pip3 install -r requirements.txt

CMD [ "/hassio_bticino_smarter/run.sh" ]
