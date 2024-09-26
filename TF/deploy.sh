#!/bin/bash

apt-get update
apt install -y docker.io
docker run -d -p 3000:3000 ygalidan/netflixfrontend:v1.0.37