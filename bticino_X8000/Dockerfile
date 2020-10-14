ARG BUILD_FROM
FROM $BUILD_FROM

RUN mkdir /hassio_bticino_smarter

WORKDIR /hassio_bticino_smarter

RUN apk add --no-cache \
        bash \
        tzdata \
        python3 \
        py3-pip \
        mosquitto-clients \
        openssl \
        nginx \
        certbot \
        certbot-nginx

COPY run.sh /hassio_bticino_smarter/
COPY data/nginx.conf* /etc/nginx/
COPY data/check_cert.py /hassio_bticino_smarter/
COPY data/bticino_X8000_rest_api.tgz /hassio_bticino_smarter/
RUN cd /hassio_bticino_smarter/ && tar -xzf bticino_X8000_rest_api.tgz --strip 1 && rm bticino_X8000_rest_api.tgz


RUN chmod a+x /hassio_bticino_smarter/run.sh

RUN pip3 install -r requirements.txt

CMD [ "/hassio_bticino_smarter/run.sh" ]
