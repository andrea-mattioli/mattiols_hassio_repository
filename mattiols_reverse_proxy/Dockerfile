ARG BUILD_FROM
FROM $BUILD_FROM
RUN mkdir /mattiols_reverse_proxy

WORKDIR /mattiols_reverse_proxy

RUN apk add --no-cache \
        bash \
        python3 \
        py3-pip \
        openssl \
        nginx \
        certbot \
        certbot-nginx
COPY run.sh /mattiols_reverse_proxy
COPY data/nginx.conf* /etc/nginx/
COPY data/check_cert.py /mattiols_reverse_proxy/

RUN chmod a+x /mattiols_reverse_proxy/run.sh

RUN pip3 install noipy

CMD [ "/mattiols_reverse_proxy/run.sh" ]
