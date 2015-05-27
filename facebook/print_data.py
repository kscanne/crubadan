#!/usr/bin/python

import facebook
import requests
import sys
import codecs

def printData (post):

    # Print data in XML Format
    if post['comment'] == 'f':
        print "<post>"
    else:
        print "<comment>"
    print "<id>" + post['id'] + "</id>"

    print "<author>" + post['from']['name'] + "</author>"

    print "<timestamp>" + post['created_time'] + "</timestamp>"

    # Check if the post has a message, if not leave the tags empty
    try:
        print "<message>" + post['message'] + "</message>"
    except:
        print "<message></message>" 

    if post['comment'] == 'f':
        print "</post>"
    else:
        print "</comment>"
