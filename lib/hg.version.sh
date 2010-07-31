#!/bin/bash
#detect version:
TAG=`hg id -t | grep -v tip`
if [ $TAG ]; then
  VERSION="$TAG"
else
  VERSION="r`hg id -n`"
fi

