#!/bin/bash

#
# This file is generated by 'bootstrap/template.py --render'
# See also bootstrap/config.py
#

set -xueo pipefail

# refer to /usr/share/i18n/locales
INPUTFILE=en_US
# refer to /usr/share/i18n/charmaps
CHARMAP=UTF-8
# locale to generate in /usr/lib/locale
# glibc/localedef will normalize UTF-8 to utf8, follow the naming style
LOCALE=$INPUTFILE.utf8

# if locale is already correct, exit
( locale | grep LC_ALL | grep -i $LOCALE ) && exit 0

# if locale not available, generate locale into /usr/lib/locale
if ! ( locale --all-locales | grep -i $LOCALE )
then
    # no-archive means create its own dir
    localedef --inputfile $INPUTFILE --charmap $CHARMAP --no-archive $LOCALE
fi

# update locale conf and global env file
# set both LC_ALL and LANG for safe

# update conf for Debian family
FILE=/etc/default/locale
if [ -f $FILE ]
then
    echo LC_ALL="$LOCALE" > $FILE
    echo LANG="$LOCALE" >> $FILE
fi

# update conf for RedHat family
FILE=/etc/locale.conf
if [ -f $FILE ]
then
    # LC_ALL is not valid in this file, set LANG only
    echo LANG="$LOCALE" > $FILE
fi

# update global env file
FILE=/etc/environment
if [ -f $FILE ]
then
    # append LC_ALL if not exist
    grep LC_ALL $FILE || echo LC_ALL="$LOCALE" >> $FILE
    # append LANG if not exist
    grep LANG $FILE || echo LANG="$LOCALE" >> $FILE
fi