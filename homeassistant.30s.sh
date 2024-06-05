#!/bin/bash

# ENTITIES
#
# <xbar.title>HomeAssistant plugin for xbar</xbar.title>
# <xbar.version>v0.1</xbar.version>
# <xbar.author>Andrei Gavriliu and Jon Bartlett</xbar.author>
# <xbar.author.github>andrei.gavriliu + Jon Bartlett</xbar.author.github>
# <xbar.desc>Small App to show some important information (to me, at least)</xbar.desc>
# <xbar.image>https://brands.home-assistant.io/_/panel_custom/logo.png</xbar.image>
# <xbar.dependencies>bash,jq</xbar.dependencies>
# <xbar.abouturl>https://github.com/jonbartlett/xbar-homeassistant-plugin</xbar.abouturl>

# PREFERENCES
# <xbar.var>string(HA_URL_INT=""): HomeAssistant internal URL</xbar.var>
# <xbar.var>string(HA_URL_EXT=""): HomeAssistant external URL</xbar.var>
# <xbar.var>string(HA_TOKEN=""): HomeAssistant Long-Lived Token</xbar.var>

# ENTITIES
#
# <xbar.var>string(ENTITY_GRID_POWER="sensor.eagle_200_meter_power_demand"): Grid Power entity</xbar.var>
# <xbar.var>string(ENTITY_SOLAR_POWER="sensor.primo_3_0_1_1_ac_power"): Solar Power entity</xbar.var>

# checking internal URL
####################################################################################################
JSON_RESPONSE=$(curl --silent --max-time 1 -X GET -H "Authorization: Bearer ${HA_TOKEN}" -H "Content-Type: application/json" "${HA_URL_INT}/api/")
HA_INSTALLATION_TYPE=$(/usr/local/bin/jq -r '.message' <<< "${JSON_RESPONSE}")
if [ "${HA_INSTALLATION_TYPE}" == "API running." ]; then
    HA_URL_INT_CHECK="true"
else
    HA_URL_INT_CHECK="false"
fi

# checking external URL
####################################################################################################
JSON_RESPONSE=$(curl --silent --max-time 1 -X GET -H "Authorization: Bearer ${HA_TOKEN}" -H "Content-Type: application/json" "${HA_URL_EXT}/api/")
HA_INSTALLATION_TYPE=$(/usr/local/bin/jq -r '.message' <<< "${JSON_RESPONSE}")
if [ "${HA_INSTALLATION_TYPE}" == "API running." ]; then
    HA_URL_EXT_CHECK="true"
else
    HA_URL_EXT_CHECK="false"
fi

# set active URL
####################################################################################################
if [ "$HA_URL_INT_CHECK" = "true" ] && [ "$HA_URL_EXT_CHECK" = "true" ]; then HA_URL="${HA_URL_INT}"; fi
if [ "$HA_URL_INT_CHECK" = "false" ] && [ "$HA_URL_EXT_CHECK" = "true" ]; then HA_URL="${HA_URL_EXT}"; fi

# translate response to icons
####################################################################################################
if [ "$HA_URL_INT_CHECK" = "true" ]; then HA_URL_INT_CHECK="✔️"; else HA_URL_INT_CHECK="✖️"; fi
if [ "$HA_URL_EXT_CHECK" = "true" ]; then HA_URL_EXT_CHECK="✔️"; else HA_URL_EXT_CHECK="✖️"; fi

# get entity details
####################################################################################################
_get_entity_state() {
    JSON_RESPONSE=$(curl --silent -X GET -H "Authorization: Bearer ${HA_TOKEN}" -H "Content-Type: application/json" "${HA_URL}/api/states/${1}")
    /usr/local/bin/jq -r '.state' <<< "${JSON_RESPONSE}"
}
_get_entity_name() {
    JSON_RESPONSE=$(curl --silent --max-time 1 -X GET -H "Authorization: Bearer ${HA_TOKEN}" -H "Content-Type: application/json" "${HA_URL}/api/states/${1}")
    /usr/local/bin/jq -r '.attributes.friendly_name' <<< "${JSON_RESPONSE}"
}

_calculate() {
    printf "%s\n" "$@" | bc -l;
}

# set font color based on darkmode status
####################################################################################################
if [ "$XBARDarkMode" == "true" ]; then
    FONT_COLOR="| color=white"
else
    FONT_COLOR="| color=black"
fi

# build output
####################################################################################################

GREEN='\033[1;32m';
YELLOW='\033[1;33m';
BLUE='\033[1;34m';
PURPLE='\033[1;35m';
RED='\033[1;31m';
NC='\033[0m';

GRID_KWATTS=$(_get_entity_state "$ENTITY_GRID_POWER")
CONV="1000"

GRID_WATTS=$(_calculate "$GRID_KWATTS*1000")
GRID_WATTS=${GRID_WATTS%.*} #convert to Int

if [[ $GRID_WATTS -lt 1000 ]]; then PREFIX=$NC; fi;
if [[ $GRID_WATTS -ge 1500 ]]; then PREFIX=$BLUE; fi;
if [[ $GRID_WATTS -ge 2000 ]]; then PREFIX=$PURPLE; fi;
if [[ $GRID_WATTS -ge 2500 ]]; then PREFIX=$RED; fi;

SOLAR_WATTS=$(_get_entity_state "$ENTITY_SOLAR_POWER") # Returns Watts
SOLAR_KWATTS=$(_calculate "$SOLAR_WATTS/1000")

echo "☀️ $SOLAR_WATTS ⚡${PREFIX} $GRID_WATTS"

