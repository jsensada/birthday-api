#!/bin/bash

## Installations content:
sudo DEBIAN_FRONTEND=noninteractive apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install python3 python3-pip python3-flask gunicorn -y
sudo pip install mysql-connector-python --break-system-packages

## Setting up the birthday-api app
sudo mkdir /opt/birthday-api
sudo mv /tmp/app.py /opt/birthday-api/app.py
sudo adduser birthday-api --gecos "" --disabled-password
sudo chown -R birthday-api:birthday-api /opt/birthday-api

## Create a systemd service for birthday-api
sudo mv /tmp/birthday-api.service /etc/systemd/system/birthday-api.service
sudo systemctl daemon-reload
sudo systemctl enable birthday-api.service