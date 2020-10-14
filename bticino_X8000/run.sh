#!/usr/bin/env bashio

CLIENT_ID=$(bashio::config 'client_id')
CLIENT_SECRET=$(bashio::config 'client_secret')
SUBSCRIPTION_KEY=$(bashio::config 'subscription_key')
DOMAIN=$(bashio::config 'domain')
API_USER=$(bashio::config 'api_user')
API_PASS=$(bashio::config 'api_pass')
MQTT_BROKER=$(bashio::config 'mqtt_broker')
MQTT_PORT=$(bashio::config 'mqtt_port')
MQTT_USER=$(bashio::config 'mqtt_user')
MQTT_PASS=$(bashio::config 'mqtt_pass')
SSL_ENABLE=$(bashio::config 'use_ssl')
ENABLE_CRON=0


API_PIDS=()

my_port=$(echo ${DOMAIN} | awk -F ":" '{print $2}')
my_domain=$(echo ${DOMAIN} | awk -F ":" '{print $1}')
if [ ! -z "${my_port}" ]
  then
    REST=$DOMAIN
    DOMAIN=$my_domain
else
    REST="${DOMAIN}:5588"
fi

mkdir ./log/

# Check Options data
if ! bashio::config.has_value 'client_id' || ! bashio::config.has_value 'client_secret' || ! bashio::config.has_value 'subscription_key' || ! bashio::config.has_value 'domain' || ! bashio::config.has_value 'api_user' || ! bashio::config.has_value 'api_pass'; then
    bashio::exit.nok "No valid options!"
fi

if ! bashio::config.has_value 'mqtt_broker' || ! bashio::config.has_value 'mqtt_port' || ! bashio::config.has_value 'mqtt_user' || ! bashio::config.has_value 'mqtt_pass' ; then 
    bashio::exit.nok "No valid options!"
fi
API_PIDS=()

check_ssl () {
   CERTS=$(python3 check_cert.py ${DOMAIN})
   echo ${CERTS}
   if [ -z "${CERTS}" ]
   then
     bashio::log.info "no certificate found try to generate it..."
     certbot --nginx --email admin@localhost.it --domain ${DOMAIN} -n --agree-tos --config-dir /ssl/bticino/ > /dev/null
     if [ $? != 0 ]
      then
	bashio::log.error "ERROR can't validate new certificate"
     fi
     if ! grep -q "certbot" /etc/crontabs/root
	 ENABLE_CRON=1
      then
        echo "0 12 * * * /usr/bin/certbot renew --quiet --config-dir /ssl/bticino/ 2>&1 >> /var/log/cron" >> /etc/crontabs/root
	    ENABLE_CRON=1
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
     nginx & > /dev/null
	 if [ $ENABLE_CRON -eq 1 ]
	    then 
          crond & > /dev/null
     fi		  
   fi
}
if [ ${SSL_ENABLE} == true ];
then
   cp -f /etc/nginx/nginx.conf_ssl /etc/nginx/nginx.conf
   mkdir -p /etc/ssl/nginx  
   openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/nginx/localhost.key -out /etc/ssl/nginx/localhost.crt -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=${DOMAIN}" &> /dev/null
   sed -i -e 's/##_my_domain_##/${DOMAIN}/g' /etc/nginx/nginx.conf &> /dev/null
   nginx & > /dev/null
   API_PID+=($!)
   check_ssl
fi

bashio::log.info "Setup config file..."
# Setup config
cat << EOF > config/config.yml
api_config:
    client_id: ${CLIENT_ID}
    client_secret: <bticino>${CLIENT_SECRET}<bticino>
    subscription_key: ${SUBSCRIPTION_KEY}
    domain: ${REST}
    api_user: ${API_USER}
    api_pass: ${API_PASS}
    use_ssl: ${SSL_ENABLE}
    c2c_enable: true
EOF
cat << EOF > config/mqtt_config.yml
mqtt_config:
    mqtt_broker: ${MQTT_BROKER}
    mqtt_port: ${MQTT_PORT}
    mqtt_user: ${MQTT_USER}
    mqtt_pass: ${MQTT_PASS}
EOF
# Start API
python3 bticino.py & > /dev/null
API_PID+=($!)
# Start MQTT
sleep 3
python3 mqtt.py & > /dev/null
API_PID+=($!)
if [ ${SSL_ENABLE} == true ];
 then
  bashio::log.info "Api address: https://${REST}/"
 else
  bashio::log.info "Api address: http://${REST}/" 
fi
function stop_api() {
    bashio::log.info "Kill Processes..."
    kill -15 "${API_PID[@]}"
    wait "${API_PID[@]}"
    bashio::log.info "Done."
}
trap "stop_api" SIGTERM SIGHUP

# Wait until all is done
wait "${API_PID[@]}"
