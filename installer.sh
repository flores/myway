#!/usr/bin/env bash

for i in sinatra sanitize aws-ses; do
  sudo gem install $i
done

