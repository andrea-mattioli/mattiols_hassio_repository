#!/usr/bin/with-contenv bashio
CONFIG_PATH=/data/options.json
TOKEN=$(bashio::config 'token')
DOMAIN=$(bashio::config 'domain')
HAIP=$(bashio::config 'haip')
bashio::log.info "DOMAIN: ${DOMAIN}"
bashio::log.info "HAIP: ${HAIP}"
bashio::log.info "TOKEN: ${TOKEN}"
ADDON_PIDS=()
bashio::log.info "start conf for ${DOMAIN}"
check_ssl () {
   CERTS=$(python3 check_cert.py ${DOMAIN})
   echo ${CERTS}
   if [ -z "${CERTS}" ]
   then
     bashio::log.info "no certificate found try to generate it..."
     certbot --nginx --email admin@localhost.it --domain ${DOMAIN} -n --agree-tos --config-dir /ssl/mattiols/ > /dev/null
     if [ $? != 0 ]
      then
	bashio::log.error "ERROR can't validate new certificate"
     fi
   else
    bashio::log.info "certificate found!"
    for i in ${CERTS}
     do
      if [[ $i == *"fullchain.pem"* ]]; then
         cert=$i
      elif [[ $i == *"privkey.pem"* ]]; then
         key=$i
      fi
    done
     sed -i -e "s~/etc/ssl/nginx/localhost.key~$key~g" /etc/nginx/nginx.conf &> /dev/null
     sed -i -e "s~/etc/ssl/nginx/localhost.crt~$cert~g" /etc/nginx/nginx.conf &> /dev/null
     kill -15 "${API_PID[@]}"
     wait "${API_PID[@]}"
     bashio::log.info "Start Mattiols Reverse Proxy..."
     /usr/sbin/nginx & > /dev/null
     API_PID+=($!)
   fi
}

cp -f /etc/nginx/nginx.conf_ssl /etc/nginx/nginx.conf
mkdir -p /etc/ssl/nginx  
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/nginx/localhost.key -out /etc/ssl/nginx/localhost.crt -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=${DOMAIN}" &> /dev/null
sed -i -e "s/##_my_domain_##/${DOMAIN}/g" /etc/nginx/nginx.conf &> /dev/null
sed -i -e "s/##_haip_##/${HAIP}/g" /etc/nginx/nginx.conf &> /dev/null
/usr/sbin/nginx & > /dev/null
API_PID+=($!)
check_ssl

if ! grep -q "certbot" /etc/crontabs/root
 then
   echo "0 12 * * * /usr/bin/certbot renew --quiet --config-dir /ssl/mattiols/ ; nginx -s reload 2>&1 >> /dev/null" >> /etc/crontabs/root
fi

if ! grep -q "noipy" /etc/crontabs/root
 then
   echo "*/5 * * * * /usr/bin/noipy -u ${TOKEN} -n ${DOMAIN} --provider duck 2>&1 >> /dev/null" >> /etc/crontabs/root
fi
# Start Cron
bashio::log.info "Start Cron"
/usr/sbin/crond -b -l 8 -L /dev/null
API_PID+=($!)

# Check IP
bashio::log.info "Check IP Provider"
/usr/bin/noipy -u ${TOKEN} -n ${DOMAIN} --provider duck

function stop_api() {
    bashio::log.info "Kill Processes..."
    kill -15 "${API_PID[@]}"
    wait "${API_PID[@]}"
    bashio::log.info "Done."
}
trap "stop_api" SIGTERM SIGHUP

# Wait until all is done
wait "${API_PID[@]}"
