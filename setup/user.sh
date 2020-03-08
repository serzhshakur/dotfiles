#!/bin/bash

source ./functions.sh

if [ -z $1 ]
then 
  echo "user name should be specified as an argument"
  exit 1
fi

install_pkg sudo &> /dev/null

user=$1

id -u $user &> /dev/null

if [ $? -eq 1 ]; then
  useradd -m $user
  passwd $user
  
  usermod -aG wheel $user

  # removing user from sudoers files
  for f in /etc/sudoers.d/*
  do
    if [ -f $f ]
    then
      sed -i "/$user/d" $f
    fi
  done
  
  # adding user to sudoers
  echo "$user ALL=(ALL) ALL" > /etc/sudoers.d/20-$user
else
  echo "user already exists"
fi

