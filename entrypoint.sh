#!/bin/bash

if [ -d "/storage" ]
then
  echo "Storage found at /storage, loading game world from that..."
#  if [ -d /app/storage ]
#  then
#    mv /app/storage /app/storage-old
#  fi
#  ln -s /storage /app/storage
else
  echo "Nothing mounted at /storage, using storage included in image..."
  echo "NOTE: THIS WILL NOT PERSIST BETWEEN RESTARTS!"
fi

cd /app

if [ -v INIT_PAUSE ]
then
  echo "INIT_PAUSE specified, sleeping..."
  while [ 1 -eq 1 ]
  do
    sleep 5
  done
fi

#if [ -d "/conf" ]
#then
  #mv /conf /app/conf -f
#fi


# Catch SIGTERM and send to child.
#_term() {
#  echo "Caught SIGTERM signal!"
#  kill -TERM "$child" 2>/dev/null
#}

#trap _term SIGTERM

echo "Running server..."
#ruby ./server.rb >> /proc/1/fd/1 &
exec ruby ./server.rb >> /proc/1/fd/1
# exec replaces this PID with the server, allowing docker stop to properly send SIGTERM.
# The /proc/1/df/1 just indicates to send output to stdout

# Wait for the server to finish
#child = $!
#wait "$child"
