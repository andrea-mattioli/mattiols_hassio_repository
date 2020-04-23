# Bticino Home Assistant Integration
Chronothermostat Bticino X8000 Integration

**BY NOW READ ONLY**

[![stable](http://badges.github.io/stability-badges/dist/stable.svg)](http://github.com/badges/stability-badges)

## 1. First step

### 1.1. Register a Developer account
Sign up for a new Developer account on Works with Legrand website (https://developer.legrand.com/login).

### 1.2. Subscribe to Legrand APIs
Sign in, go to menu "API > Subscriptions" and make sure you have "Starter Kit for Legrand APIs" subscription activated; if not, activate it.

![Alt text](https://github.com/andrea-mattioli/bticino_X8000_rest_api/raw/test/screenshots/subscription.PNG?raw=true "App Register")

### 1.3. Register a new application
Go to menu "User > My Applications" and click on "Create new" to register a new application:
- Insert a **valid public URL** in "First Reply Url". 
- Make sure to tick the checkbox near scopes `comfort.read` and `comfort.write`

Submit your request and wait for a response via email from Legrand (it usually takes 1-2 days max).
If your app has been approved, you should find in the email your "Client ID" and "Client Secret" attributes.

```
Public Url = https://myWebServerIP:myWebServerPort/rest
```
```
First Reply Url = https://myWebServerIP:myWebServerPort/callback
```
![Alt text](https://github.com/andrea-mattioli/bticino_X8000_rest_api/raw/test/screenshots/app1.png?raw=true "App Register")
![Alt text](https://github.com/andrea-mattioli/bticino_X8000_rest_api/raw/test/screenshots/app2.png?raw=true "App Register")

## 2. CONFIGURATION

### 2.1. Update your config
```
    client_id: "Recived via mail"
    client_secret: "Recived via mail"
    subscription_key: "Your Subscription Key"
    redirect_url: "Your VALID Redirect Url"
    api_user: "Chose your api user (Login for http://myip:5588 NOT for Legrand)"
    api_pass: "Chose your api password (Login for http://myip:5588 NOT for Legrand)"
    subscribe_c2c: "True|False Use to receive thermostat status from Legrand (Safe 500 query/day)"
```
### 2.2. Nat API port:5588 on your router/firewall (Only for the first Oauth)
N.B Use a valid ssl certificate for path "/callback" you can do it with nginx or apache reverse proxy
## 3. START

### 3.1. 1st RUN
- Navigate to http://my_hassio_ip:5588/ and click ***get your code***

![Alt text](https://github.com/andrea-mattioli/bticino_X8000_rest_api/raw/test/screenshots/api1.png?raw=true "Api Allow")

- **Login with your developer account**


![Alt text](https://github.com/andrea-mattioli/bticino_X8000_rest_api/raw/test/screenshots/api2.png?raw=true "Api Allow")

- **Allow your app permissions**


![Alt text](https://github.com/andrea-mattioli/bticino_X8000_rest_api/raw/test/screenshots/api3.png?raw=true "Api Allow")

- **If you see your Plant Info enjoy!!**


![Alt text](https://github.com/andrea-mattioli/bticino_X8000_rest_api/raw/test/screenshots/api4.png?raw=true "Api Allow")

### 3.2. Request Thermostat status

- **Navigate to http://my_hassio_ip:5588/rest**

**ll return a json with the status of your thermostats!**


![Alt text](https://github.com/andrea-mattioli/bticino_X8000_rest_api/raw/test/screenshots/api5.png?raw=true "Api Allow")


## 4. HOME ASSISTANT INTEGRATION

- **Create a rest sensor for example**

```
- platform: mqtt
  name: termostato_sala_temperature
  state_topic: "/bticino/f9160185-7a27-4f70-e053-27182d0a51c5/status"
  unit_of_measurement: '°C'
  value_template: "{{ value_json['temperature'] }}"
- platform: mqtt
  name: termostato_sala_humidity
  state_topic: "/bticino/f9160185-7a27-4f70-e053-27182d0a51c5/status"
  unit_of_measurement: '%'
  value_template: "{{ value_json.humidity }}"
- platform: mqtt
  name: termostato_sala_function
  state_topic: "/bticino/f9160185-7a27-4f70-e053-27182d0a51c5/status"
  value_template: "{{ value_json.function }}"
- platform: mqtt
  name: termostato_sala_state
  state_topic: "/bticino/f9160185-7a27-4f70-e053-27182d0a51c5/status"
  value_template: "{{ value_json.state }}"
- platform: mqtt
  name: termostato_sala_mode
  state_topic: "/bticino/f9160185-7a27-4f70-e053-27182d0a51c5/status"
  value_template: "{{ value_json.mode }}"
```
change the state_topic for each thermostat
### Results

![Alt text](https://github.com/andrea-mattioli/bticino_X8000_rest_api/raw/test/screenshots/home_ass1.PNG?raw=true "Api Allow")

###

![Alt text](https://github.com/andrea-mattioli/bticino_X8000_rest_api/raw/test/screenshots/home_ass2.PNG?raw=true "Api Allow")
