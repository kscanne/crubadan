#!/bin/bash
# Author: Matthew Meyer

DIR=~/.transliterate

ls $DIR | 
while read x
do
  echo $x | sed 's/-/ /g' | sed 's/\..*//g'
  cat $DIR/$x | egrep 'LANG' | sed 's/LANG//'
done



