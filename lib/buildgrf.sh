#!/bin/bash

nforenum $NFO
grfcodec -e $FILENAME.grf
md5sum $FILENAME.grf > $FILENAME.grf.md5

