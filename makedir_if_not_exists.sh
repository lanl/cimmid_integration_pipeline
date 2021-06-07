#!/bin/sh

############################################################################################
# Makes directory if it does not exists.
# Usage: ./makedir_if_not_exists.sh DIRECTORY_NAME
# DIRECTORY_NAME: Name of the directory that needs to exist.
############################################################################################

if [ "$#" -lt 1 ] ; then
    echo "Usage: ./makedir_if_not_exists.sh DIRECTORY_NAME"
    echo "DIRECTORY_NAME: Name of the directory that needs to exist"
    exit
fi

DIR_NAME=$1

if [ ! -d "$DIR_NAME" ]; then
    mkdir $DIR_NAME
fi
