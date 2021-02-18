ARG BUILD_FROM
FROM $BUILD_FROM

RUN mkdir /hassio_bticino_smarter

WORKDIR /hassio_bticino_smarter

RUN apk add --no-cache \
        bash \
        tzdata \
        python3 \
        py3-pip \
        git \
        mosquitto-clients \
        chromium \
        chromium-chromedriver \
    \
  && git clone -b v2 https://github.com/andrea-mattioli/bticino_X8000_rest_api.git \
  && mv bticino_X8000_rest_api/* /hassio_bticino_smarter/ \
  && rm -rf bticino_X8000_rest_api/

COPY run.sh /hassio_bticino_smarter/

RUN chmod a+x /hassio_bticino_smarter/run.sh

RUN pip3 install -r requirements.txt

CMD [ "/hassio_bticino_smarter/run.sh" ]
