# xbar-homeassistant-plugin
![Screenshot 2021-04-15 at 18 25 34](https://user-images.githubusercontent.com/3742238/114904733-738dab00-9e18-11eb-98cc-e0a66a21d187.png)

## Description
[xbar](https://xbarapp.com/) plugin for my [Home Assistant](https://www.home-assistant.io/). Forked from original code at https://github.com/AndreiGavriliu/xbar-homeassistant-plugin with updates to use new HA REST API and modified for my use. It is currently configured to pull household power stats from Home Assistant (Solar Generation and Grid Usage). 

## Usage
This plugin requires the following information:
* `HA_URL_INT`: Internal HomeAssistant URL (e.g. `http://192.168.0.10:8123`)
* `HA_URL_EXT`: External HomeAssistant URL (e.g. `https://my.smart.home`)
* `HA_TOKEN`: HomeAssistant [Long Lived Access Token](https://www.home-assistant.io/docs/authentication/#your-account-profile)
* `ENTITY_GRID_POWER`: Entity Name (e.g. `sensor.eagle_200_meter_power_demand`)
* `ENTITY_SOLAR_POWER`: Entity Name (e.g. `sensor.primo_3_0_1_1_ac_power)

