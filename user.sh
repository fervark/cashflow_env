#!/bin/bash

if [ -z $(grep "^GID=" .env) ]; then echo "GID=$(id -g)" >> .env; fi
if [ -z $(grep "^UID=" .env) ]; then echo "UID=$(id -u)" >> .env; fi