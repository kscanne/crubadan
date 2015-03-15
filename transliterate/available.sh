#!/bin/bash
# Author: Matthew Meyer

ls ~/.transliterate/ | sed 's/-/ /g' | sed 's/\..*//g'

