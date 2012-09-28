#!/bin/bash

nforenum $NFO
echo "GRFCodec:"
grfcodec -e $FILENAME.grf
echo "md5sum:"
md5sum $FILENAME.grf > $FILENAME.grf.md5
