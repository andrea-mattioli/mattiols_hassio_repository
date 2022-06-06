#!/usr/bin/with-contenv bashio
CONFIG_PATH=/data/options.json
CLIENT_ID=$(bashio::config 'client_id')
CLIENT_SECRET=$(bashio::config 'client_secret')
SUBSCRIPTION_KEY=$(bashio::config 'subscription_key')
DOMAIN=$(bashio::config 'domain')
HAIP=$(bashio::config 'haip')
MQTT_BROKER=$(bashio::config 'mqtt_broker')
MQTT_PORT=$(bashio::config 'mqtt_port')
MQTT_USER=$(bashio::config 'mqtt_user')
MQTT_PASS=$(bashio::config 'mqtt_pass')
LEGRAND_USER=$(bashio::config 'legrand_user')
LEGRAND_PASS=$(bashio::config 'legrand_pass')
JSON_FILE="/config/.bticino_smarter/smarter.json"
ARCH=$(uname -m)
FLAG=0
API_PIDS=()
#Check smarter file
if [ -s "$JSON_FILE" ] 
then
	bashio::log.info "Smarter file already exist and contain some data."
else
	bashio::log.info "Init Smarter file ..."
    mkdir -p /config/.bticino_smarter/
    cp config/smarter.json /config/.bticino_smarter/smarter.json
    if [ "$ARCH" != "armv7l" ] || [ "$ARCH" != "armhf" ] 
    then
        FLAG=1
        bashio::log.info "64bit Version detected"
    else
        bashio::log.info "32bit Version detected can't use autologin"
    fi
fi
bashio::log.info "Setup config file..."
# Setup config
cat << EOF > config/config.yml
api_config:
    client_id: ${CLIENT_ID}
    client_secret: <bticino>${CLIENT_SECRET}<bticino>
    subscription_key: ${SUBSCRIPTION_KEY}
    domain: ${DOMAIN}
    haip: ${HAIP}
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
if [ $FLAG = 1 ]
then
    if [ ! -z ${LEGRAND_USER} ] || [ ! -z ${LEGRAND_PASS} ]
    then 
        bashio::log.info "Trying autologin to Legrand..."
        python3 login.py ${LEGRAND_USER} ${LEGRAND_PASS} ${HAIP} ${CLIENT_ID}
        if [ $? = 0 ]
        then
            bashio::log.info "Succesfully autologin to Legrand"
        else
            bashio::log.info "Something went wrong, can't autologin to Legrand please use a manual procedure"
        fi
    else
        bashio::log.info "Can't use auto login (legrand_user or legrand_pass not set on the addon config), please use a manual procedure"
    fi
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
