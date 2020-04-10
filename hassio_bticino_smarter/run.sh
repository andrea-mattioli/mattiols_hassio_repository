#!/usr/bin/env bashio

CLIENT_ID=$(bashio::config 'client_id')
CLIENT_SECRET=$(bashio::config 'client_secret')
SUBSCRIPTION_KEY=$(bashio::config 'subscription_key')
REDIRECT_URL=$(bashio::config 'redirect_url')

API_PIDS=()

# Check Options data
if ! bashio::config.has_value 'client_id' || ! bashio::config.has_value 'client_secret' || ! bashio::config.has_value 'subscription_key' || ! bashio::config.has_value 'redirect_url' ; then
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
EOF

# Start API
python3 bticino.py &
API_PID+=($!)


# Register stop
function stop_api() {
    bashio::log.info "Kill Processes..."
    kill -15 "${API_PID[@]}"
    wait "${API_PID[@]}"
    bashio::log.info "Done."
}
trap "stop_api" SIGTERM SIGHUP

# Wait until all is done
wait "${API_PID[@]}"
