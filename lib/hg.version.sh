#!/bin/bash
#detect version:
TAG=`hg id -t | grep -v tip`
REVISION=`hg parent --template="{rev}"`
if [ $TAG ]; then
  VERSION="$TAG"
else
  VERSION="r`hg id -n`"
fi
echo "Version: $VERSION"
VERDATE=`hg parent --template="{date|shortdate}"`
