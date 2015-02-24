#!/bin/bash
TEANGA=ga
URL=borel.slu.edu
cat test-in.txt |
while read x
do
	if echo $x | egrep '^TEST [^ ]+ [^ ]+$' > /dev/null
	then
		echo $x
		TEANGA=`echo $x | sed 's/^TEST *//; s/ .*//'`
		URL=`echo $x | egrep -o '[^ ]+$'`
	else
		echo $x | perl norm.pl "${TEANGA}" "${URL}"
	fi
done > test-out-new.txt
diff -u test-out.txt test-out-new.txt
