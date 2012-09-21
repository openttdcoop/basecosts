#!/bin/bash

# http://wiki.openttdcoop.org/Basecosts
# http://wiki.ttdpatch.net/tiki-index.php?page=BaseCosts
# NewBaseCost = OldBaseCost * 2^(n-8), where n is the value of property 08.

GRFID="4D 47 03 03"
FILENAME="basecosts"
MAXPARAMS=44
FACTDEF=10

. lib/hg.version.sh

NFO="sprites/$FILENAME.nfo"
[ ! -d "sprites" ] && mkdir sprites

cat >$NFO <<EOF
// Automatically generated by GRFCODEC. Do not modify!
// (Info version 7)
// Format: spritenum imagefile depth xpos ypos xsize ysize xrel yrel zoom flags
  0 * 4 00 00 00 00

 -1 * 0  14 "C" "INFO"
                  "B" "PALS" \w1 "A"
                  "B" "VRSN" \w4 \d$REVISION
                  "B" "MINV" \w4 \d0
                  "B" "NPAR" \w1 \b$MAXPARAMS
                  "T" "URL_" 7F "http://dev.openttdcoop.org/p/basecosts" 00
                  00
            00
EOF
PARAM=0

while [ $PARAM -lt $MAXPARAMS ]; do
cat >>$NFO <<EOB
 -1 * 0  14 "C" "INFO"
                  "C" "PARA"
                      "C" \d$PARAM
                          "T" "NAME" 7F "Type" 00
                          "T" "DESC" 7F `cat data/param-desc` 00
                          "B" "TYPE" \w1 \b0

                          "B" "LIMI" \w8 \d0 \d`cat data/keys | wc -l`
                          "C" "VALU"
`cat data/keys`
                              00
                          00
                      00
                  00
            00
 -1 * 0  14 "C" "INFO"
                  "C" "PARA"
                      "C" \d`let PARAM++; echo $PARAM`
                          "T" "NAME" 7F "Factor" 00
                          "T" "DESC" 7F `cat data/param-desc` 00
                          "B" "TYPE" \w1 \b0
                          "B" "DFLT" \w4 \d$FACTDEF
                          "B" "LIMI" \w8 \d1 \d24
                          "C" "VALU"
`cat data/values`
                              00
                          00
                      00
                  00
            00
EOB
let PARAM+=2
done
cat >>$NFO <<EOF
  0 * 0	08 07 $GRFID "BaseCosts Mod $VERSION" 00
    "http://dev.openttdcoop.org/p/basecosts" 0D
    "Usage Parameters: [<id> <value>]...(max. 22 pairs)" 0D
    "$VERDATE / GPL / Ammler" 00
EOF
TYPE=0
FACT=1
while [ $TYPE -lt $MAXPARAMS ]; do
cat >>$NFO <<EOB
// param$TYPE and param$FACT:
  0 * 0 0D // ActionD <target> <operation> <source1> <source2> [<data>]
    \b$TYPE     // Parameter 0
    80          // if target not set, target = source1 
    FF          // source1: use value from data
    00          // source2: ignored
    \dxFFFF     // data
  0 * 0 0D
    \b$FACT          // if Parameter $FACT unset -> default $FACTDEF
    80 FF 00 \d$FACTDEF

// if parameter $TYPE not set
  0 * 0 09 // Action[07/09] <variable> <varsize> <condition-type> <value> <num-sprites>
    \b$TYPE     // Parameter $TYPE
    02          // size
    \7=         // condition: equal to
    \wxFFFF
    00          // skip the rest

// if parameter $FACT isn't null skip one else set it to $FACTDEF
  0 * 0 09 // Action[07/09] <variable> <varsize> <condition-type> <value> <num-sprites>
    \b$FACT     // Parameter $FACT
    02          // size
    \7!         // condition: not equal to
    \w0
    01          // skip the next
  0 * 0 0D // ActionD <target> <operation> <source1> <source2> [<data>]
    \b$TYPE     // Parameter 0
    00          // target = source1
    FF          // source1: use value from data
    00          // source2: ignored
    \d$FACTDEF  // data

  0 * 0 06 // Action6 (<param-num> <param-size> <offset>){n} FF
    \b$TYPE \b1 \b4  // Parameter $TYPE
    \b$FACT \b1 \b6  // Parameter $FACT
    FF

// Action 0 will be modified by previous Action6
  0 * 0 00 // Action0 <Feature> <Num-props> <Num-info> <Id> (<Property <New-info>)...
    08          // Properties for general variables
    01 01       // 1 properity, 1 type (id)
    00          // ID (TYPE)
    08          // Basecosts
    08          // new value (FACT)
/////////////////////////////////
// NEXT PAIR:
/////////////////////////////////

EOB
let TYPE+=2
let FACT+=2
done

. lib/buildgrf.sh

exit


#################################################
# Snippets / Notes
#################################################

