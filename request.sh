#!/bin/sh
while true
do
  echo $(curl -s $1)
  sleep 0.5
done  
