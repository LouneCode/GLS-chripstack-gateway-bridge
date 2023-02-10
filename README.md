# GLS ChirpStack Gateway Bridge - with the Fine timestamp support (for TDOA geolocation)

This project implements a Fine Timestamp property to [ChirpStack Gateway Bridge](https://github.com/chirpstack/chirpstack-gateway-bridge). GLS ChirpStack Gateway Bridge is a Docker image and it  runs on a PC, Raspberry Pi 4 and Compute module4. 

The module should installed with the [GLS Basic Station Docker image](https://github.com/LouneCode/gls-basicstation) to get Fine Timestamp property working on Chirpstack LNS.

The Fine Timestamp solution works with following LoRa concentators which can use GPS PPS signal:  SX1302, SX1303 LoRa concentrators modules (RAK2287, RAK5146, RAK831, WM1302 concentrator modules or RAK7248, RAK7248C, RAK7271, RAK7371 WisGate Development gateways).

GLS ChirpStack Gateway Bridge is fully function version of the original [ChirpStack Gateway Bridge](https://www.chirpstack.io/gateway-bridge/community/source/) and it enables the fineTimeSinceGpsEpoch field in uplink event JSON messages with a nanosecond precision as follows:

&nbsp;

``` sourceCode
...
"rxInfo": [
    {
        "gatewayId": "0016c001ffxxxxxx",
        "uplinkId": 3232276575,
        "time": "2022-12-26T12:01:47.709920+00:00",
        "timeSinceGpsEpoch": "1356091325.709920s",
        "fineTimeSinceGpsEpoch": "1356091325.263021396s",
        "rssi": -45,
        "snr": 14.25,
        "location": {
            "latitude": 62.1979847889177,
            "longitude": 21.123254060745244
        },
        "context": "AAAAAAAAAAAAMgABVWHvOA==",
        "metadata": {
            "region_common_name": "EU868",
            "region_name": "eu868"
        }
    },
...
```
&nbsp;

# Installation

Replace following components on [ChirpStack](https://www.chirpstack.io/) v4 LoRaWAN® Network Server stack:
- Basic Station  -> GLS Basic Station back end (In picture: LoRa Gateway)
- ChirpStack Gateway Bridge -> GLS ChirpStack Gateway Bridge

&nbsp;

![Shirpstack architecture](https://www.chirpstack.io/static/img/graphs/architecture.dot.png)

&nbsp;

## 1) Compile GLS ChirpStack Gateway Bridge Docker image 

``` sourceCode

$ git clone https://github.com/LouneCode/GLS-chripstack-gateway-bridge.git GLS-chripstack-gateway-bridge 
$ cd GLS-chripstack-gateway-bridge
$ sudo docker build --build-arg REMOTE_TAG=v4.0.5 . -t gls-chirpstack-gateway-bridge:4.0.5.1
$ docker images

```

&nbsp;

## 2) CompileGLS Basic Station Docker image 

&nbsp;

See [GLS Basic Station](https://github.com/LouneCode/gls-basicstation) Docker image compilation instuctions.

&nbsp;

## 3) Stop Docker compose stack

&nbsp;

``` sourceCode

$ Docker compose down

```
&nbsp;

## 4) Configure docker-compose.yml

&nbsp;

``` sourceCode

$ nano docker-compose.yml

services:
  chirpstack:
    image: chirpstack/chirpstack:4.0.0
    command: -c /etc/chirpstack
    restart: unless-stopped
    volumes:
      - ./configuration/chirpstack:/etc/chirpstack
      - ./lorawan-devices:/opt/lorawan-devices
    depends_on:
      - postgres
      - mosquitto
      - redis
    environment:
      - MQTT_BROKER_HOST=mosquitto
      - REDIS_HOST=redis
      - POSTGRESQL_HOST=postgres
    ports:
      - 8080:8080

  chirpstack-gateway-bridge-eu868-ws:
# image: chirpstack/chirpstack-gateway-bridge:4.0.5
    image: gls-chirpstack-gateway-bridge:4.0.5.1
    restart: unless-stopped
    ports:
      - 3001:3001
    volumes:
      - ./configuration/chirpstack-gateway-bridge:/etc/chirpstack-gateway-bridge
    depends_on:
      - mosquitto
      
  gls-basicstation-0:
    image: gls-basicstation:2.0.6.1
    container_name: gls-basicstation-0
    restart: unless-stopped
    devices:
      - /dev/ttyACM0:/dev/ttyACM0
    environment:
      TC_URI: "ws://chirpstack-gateway-bridge-eu868-ws:3001"  #required if network_mode: host"
      MODEL: "SX1303"
      INTERFACE: "USB"
      DESIGN: "CORECELL"
      DEVICE: "/dev/ttyACM0"
      GATEWAY_EUI: "E12E01FFFE1AEDD33"
      TC_KEY: "rtyRTJ6....eyJ0eXA5lkvgFTg"   # Copy here your API key from the LNS 
      .
      .
      .  

```
&nbsp;

## 5) Restart Docker compose stack

&nbsp;

``` sourceCode

$ docker compose up -d

$ docker-compose logs -f --since 15m


```
&nbsp;

Please refer to the following links for more information.

- [ChirpStack documentation](https://www.chirpstack.io/)
- [chirpstack-gateway-bridge](https://github.com/chirpstack/chirpstack-gateway-bridge)
- [GLS Basic Station](https://github.com/LouneCode/gls-basicstation)

&nbsp;

## License

The contents of this repository (not of those repositories linked or used by this one) are under BSD 3-Clause License.

Copyright (c) 2023 LouneCode - Only husky in the village <postia.lounelle@live.com>
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice,
   this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. Neither the name of this project nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.