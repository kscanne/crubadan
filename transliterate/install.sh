#!/bin/bash
# Author: Matthew Meyer

PWD=`pwd`
GLOBAL=~/.transliterate
PREF=~/.user_pref.trans
RULES=$PWD/rules

if [ ! -d $GLOBAL ]
then
  mkdir $GLOBAL
fi

# don't know whether or not i should cp or mv
if [ -d $RULES ]
then
  cp $RULES/* $GLOBAL/
fi

if [ ! -f $PREF ]
then
  touch $PREF
  echo "F:latin" >> $PREF
  echo "T:latin" >> $PREF
  echo "L:all" >> $PREF
fi

if [ -f ~/.bash_aliases ]
then
  ALIAS=~/.bash_aliases
else
  ALIAS=~/.bashrc
fi

EXIST=`cat $ALIAS | egrep '^alias trans=.*$'`
if [ "$EXIST" = "" ]
then
  echo "alias trans='bash $PWD/trans.sh'" >> $ALIAS
fi
