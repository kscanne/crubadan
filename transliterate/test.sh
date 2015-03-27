#!/bin/bash
# Author: Matthew Meyer
#
# Tests are located in the tests/ directory (big suprise!)
# format of a tests name should be:
#     {script the text is in}-{script the text should change to}-{language}
# With this format, there should be two file extensions for each test.
# The file extension ".in" is the input file and the ".expected-out" is what
# the trans tool should change the input to.
#
# After every the trans tool does its thing, it will output a ".out" file extension
# This will then be tested against the expected output and will pass or fail.
#
# Example:
#     We are testing the tools capabilities from cyrillic script to latin script
#     in russian. We put the two files: 
#         cyrillic-latin-ru.in
#         cyrillic-latin-ru.expected-out
#     into the tests directory. If there is output when this script is run, it fails


ls tests/ | sed 's/\..*$//' | sort | uniq | 
while read t
do
  F=`echo $t | sed 's/-.*//'`
  T=`echo $t | sed 's/^.*-\([^-]*\)-.*$/\1/'`
  L=`echo $t | sed 's/^[^-]*-[^-]*-\(.*$\)/\1/'`

  bash trans.sh -i tests/$t.in -o tests/$t.out -l $L -f $F -t $T 
  
  diff -u tests/$t.expected-out tests/$t.out
done



