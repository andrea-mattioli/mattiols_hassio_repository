#!/usr/bin/env bashio

CLIENT_ID=$(bashio::config 'client_id')
CLIENT_SECRET=$(bashio::config 'client_secret')
SUBSCRIPTION_KEY=$(bashio::config 'subscription_key')
DOMAIN=$(bashio::config 'domain')
HAIP=$(bashio::config 'haip')
API_USER=$(bashio::config 'api_user')
API_PASS=$(bashio::config 'api_pass')
MQTT_BROKER=$(bashio::config 'mqtt_broker')
MQTT_PORT=$(bashio::config 'mqtt_port')
MQTT_USER=$(bashio::config 'mqtt_user')
MQTT_PASS=$(bashio::config 'mqtt_pass')
USE_SSL=$(bashio::config 'use_ssl')
API_PIDS=()

check_ssl () {
   CERTS=$(python3 check_cert.py ${DOMAIN})
   echo ${CERTS}
   if [ -z "${CERTS}" ]
   then
     bashio::log.info "no certificate found generate self signed"
	 openssl req -new -x509 -days 365 -nodes \
     -out config/certificate.pem \
     -keyout config/key.pem \
     -subj "/C=IT/ST=Rome/L=Rome/O=IT/CN="${DOMAIN}""
     if [ $? != 0 ]
      then
	bashio::log.error "ERROR can't create self signed certificate"
     fi
     server_key="config/key.pem"
	 server_cert="config/certificate.pem"
   else
    bashio::log.info "certificate found!"
    for i in ${CERTS}
     do
      if [[ $i == *"fullchain.pem"* ]]; then
         server_cert=$i
      elif [[ $i == *"privkey.pem"* ]]; then
         server_key=$i
      fi
    done		  
   fi
}

if [ ${USE_SSL} == true ];
then
   check_ssl
   set_conf_ssl
else
   set_conf_not_ssl
fi

set_conf_ssl () {
bashio::log.info "Setup config file..."
# Setup config
cat << EOF > config/config.yml
api_config:
    client_id: ${CLIENT_ID}
    client_secret: <bticino>${CLIENT_SECRET}<bticino>
    subscription_key: ${SUBSCRIPTION_KEY}
    domain: ${DOMAIN}
    haip: ${HAIP}
    ssl_enable: ${USE_SSL}
    c2c_enable: true
    server_cert: ${server_cert}
    server_key: ${server_key}
EOF
cat << EOF > config/mqtt_config.yml
mqtt_config:
    mqtt_broker: ${MQTT_BROKER}
    mqtt_port: ${MQTT_PORT}
    mqtt_user: ${MQTT_USER}
    mqtt_pass: ${MQTT_PASS}
EOF
}

set_conf_not_ssl () {
bashio::log.info "Setup config file..."
# Setup config
cat << EOF > config/config.yml
api_config:
    client_id: ${CLIENT_ID}
    client_secret: <bticino>${CLIENT_SECRET}<bticino>
    subscription_key: ${SUBSCRIPTION_KEY}
    domain: ${DOMAIN}
    haip: ${HAIP}
    ssl_enable: ${USE_SSL}
    c2c_enable: true
EOF
cat << EOF > config/mqtt_config.yml
mqtt_config:
    mqtt_broker: ${MQTT_BROKER}
    mqtt_port: ${MQTT_PORT}
    mqtt_user: ${MQTT_USER}
    mqtt_pass: ${MQTT_PASS}
EOF
}
# Start API
bashio::log.info "Starting Python Api..."
python3 bticino.py & > /dev/null
API_PID+=($!)
# Start MQTT
bashio::log.info "Starting MQTT Client..."
sleep 3
python3 mqtt.py & > /dev/null
API_PID+=($!)
function stop_api() {
    bashio::log.info "Kill Processes..."
    kill -15 "${API_PID[@]}"
    wait "${API_PID[@]}"
    bashio::log.info "Done."
}
trap "stop_api" SIGTERM SIGHUP

# Wait until all is done
wait "${API_PID[@]}"
