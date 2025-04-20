#!/bin/bash

## Installations content:
sudo DEBIAN_FRONTEND=noninteractive apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install python3 python3-pip gunicorn -y

## Setting up the birthday-api app
sudo mkdir /opt/brithday-api
sudo mv /tmp/app.py /opt/brithday-api/app.py
sudo adduser brithday-api --gecos "" --disabled-password
sudo chown -R brithday-api:brithday-api /opt/brithday-api
sudo pip install -r /tmp/requirements.txt

## Create a systemd service for brithday-api
sudo mv /tmp/brithday-api.service /etc/systemd/system/birthday-api.service
sudo systemctl daemon-reload
sudo systemctl enable birthday-api.service