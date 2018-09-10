#!/bin/sh
while true
do
  echo $(curl -s $1)
  sleep 1
done  
