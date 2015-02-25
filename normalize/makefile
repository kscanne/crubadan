
langs.txt: rules.txt
	egrep '^LANG ' rules.txt | sed 's/^LANG  *//' | tr "," "\n" | LC_ALL=C sort -u > $@

# slow.
crubtest: FORCE langs.txt
	cat langs.txt | while read x; do echo "$x..."; retrofix -t $x; done

FORCE:

clean:
	rm -f langs.txt test-out-new.txt
