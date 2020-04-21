#!/usr/bin/env bashio

CLIENT_ID=$(bashio::config 'client_id')
CLIENT_SECRET=$(bashio::config 'client_secret')
SUBSCRIPTION_KEY=$(bashio::config 'subscription_key')
REDIRECT_URL=$(bashio::config 'redirect_url')
API_USER=$(bashio::config 'api_user')
API_PASS=$(bashio::config 'api_pass')
C2C_SUBSCRIPTION=$(bashio::config 'subscribe_c2c')
MQTT_BROKER=$(bashio::config 'mqtt_broker')
MQTT_PORT=$(bashio::config 'mqtt_port')
MQTT_USER=$(bashio::config 'mqtt_user')
MQTT_PASS=$(bashio::config 'mqtt_pass')
MQTT_INTERVAL=$(bashio::config 'mqtt_interval')

API_PIDS=()

# Check Options data
if ! bashio::config.has_value 'client_id' || ! bashio::config.has_value 'client_secret' || ! bashio::config.has_value 'subscription_key' || ! bashio::config.has_value 'redirect_url' || ! bashio::config.has_value 'api_user' || ! bashio::config.has_value 'api_pass'; then
    bashio::exit.nok "No valid options!"
fi

if ! bashio::config.has_value 'mqtt_broker' || ! bashio::config.has_value 'mqtt_port' || ! bashio::config.has_value 'mqtt_user' || ! bashio::config.has_value 'mqtt_pass' ; then 
    bashio::exit.nok "No valid options!"
fi
bashio::log.info "Setup config file..."
# Setup config
cat << EOF > config/config.yml
api_config:
    client_id: ${CLIENT_ID}
    client_secret: ${CLIENT_SECRET}
    subscription_key: ${SUBSCRIPTION_KEY}
    redirect_url: ${REDIRECT_URL}
    api_user: ${API_USER}
    api_pass: ${API_PASS}
    subscribe_c2c: ${C2C_SUBSCRIPTION}
EOF
cat << EOF > config/mqtt_config.yml
mqtt_config:
    mqtt_broker: ${MQTT_BROKER}
    mqtt_port: ${MQTT_PORT}
    mqtt_user: ${MQTT_USER}
    mqtt_pass: ${MQTT_PASS}
    mqtt_interval: ${MQTT_INTERVAL}
EOF
# Start API
python3 bticino.py &
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
