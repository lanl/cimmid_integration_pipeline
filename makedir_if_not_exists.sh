#!/bin/sh

# Makes directory if it does not exists.

DIR_NAME=$1

if [ ! -d "$DIR_NAME" ]; then
    mkdir $DIR_NAME
fi
