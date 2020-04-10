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
client_id: "Recived via mail"<br>
client_secret: "Recived via mail"<br>
subscription_key: "Your Subscription Key"<br>
redirect_url: "Your VALID Redirect Url"<br>
```
### 2.2. Nat API port:5588 on your router/firewall (Only for the first Oauth)

## 3. START

### 3.1. 1st RUN
- Navigate to http://my_hassio_ip:5588/get_code and click ***get your code***

![Alt text](https://github.com/andrea-mattioli/bticino_X8000_rest_api/raw/test/screenshots/api1.png?raw=true "Api Allow")

- **Login with your developer account**


![Alt text](https://github.com/andrea-mattioli/bticino_X8000_rest_api/raw/test/screenshots/api2.png?raw=true "Api Allow")

- **Allow your app permissions**


![Alt text](https://github.com/andrea-mattioli/bticino_X8000_rest_api/raw/test/screenshots/api3.png?raw=true "Api Allow")

- **If you see your Plant Info enjoy!!**


![Alt text](https://github.com/andrea-mattioli/bticino_X8000_rest_api/raw/test/screenshots/api4.png?raw=true "Api Allow")

### 3.2. Request Thermostat status

- **Navigate to http://my_hassio_ip:5588/rest**

**ll return a json with the status of your thermostat!**


![Alt text](https://github.com/andrea-mattioli/bticino_X8000_rest_api/raw/test/screenshots/api5.png?raw=true "Api Allow")


## 4. HOME ASSISTANT INTEGRATION

- **Create a rest sensor for example**

```
- platform: rest
  name: Termostato
  json_attributes:
    - mode
    - function
    - state
    - temperature
    - humidity
  resource: http://my_hassio_ip:5588/rest/
  value_template: '{{ value_json.state }}'
  scan_interval:
   days: 0
   hours: 0 
   minutes: 3
   seconds: 0
- platform: template
  sensors:
    termostato_mode:
      friendly_name: 'Modalità Termostato'
      value_template: '{{ states.sensor.termostato.attributes["mode"] }}'
      entity_id: sensor.termostato
    termostato_function:
      friendly_name: 'Funzione Termostato'
      value_template: '{{ states.sensor.termostato.attributes["function"] }}'
      entity_id: sensor.termostato
    termostato_state:
      friendly_name: 'Stato Termostato'
      value_template: '{{ states.sensor.termostato.attributes["state"] }}'
      entity_id: sensor.termostato
    termostato_temperature:
      friendly_name: 'Temperatura Sala'
      value_template: '{{ states.sensor.termostato.attributes["temperature"] }}'
      entity_id: sensor.termostato
      unit_of_measurement: "°C"
    termostato_humidity:
      friendly_name: 'Umidità Sala'
      value_template: '{{ states.sensor.termostato.attributes["humidity"] }}'
      entity_id: sensor.termostato
      unit_of_measurement: "%"
```

### Results

![Alt text](https://github.com/andrea-mattioli/bticino_X8000_rest_api/raw/test/screenshots/home_ass1.png?raw=true "Api Allow")

###

![Alt text](https://github.com/andrea-mattioli/bticino_X8000_rest_api/raw/test/screenshots/home_ass2.png?raw=true "Api Allow")
