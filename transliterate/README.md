Transliterator
===============
**Author: Matthew Meyer**

install.sh
---------
This script creates a hidden directory in your home called ".tranliterate/" with the purpose 
of making the rule lookup easier. It also creates a .user_pref.trans file to keep track of 
preferences for those who are primarily focusing on one kind of tranliterating, and also creates 
an alias to run the tool from any directory and set local preferences to use instead of global. 

trans.sh
---------
This script transliterates text from one script to another in the same language. 
Run if with the "--help" flag for documentation.

tests/
-------
A collection of tests to be sure that the rules we have work.

rules/
---------
A collection of rules to help transliterate. Currently there are only a couple of romanizations.

TODO:
---------
* add more rules
* add different language switches for scripts
* add tests for every rule set
* make it read from stdin to stdout by default

