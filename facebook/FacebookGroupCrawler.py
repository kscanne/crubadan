#!/usr/bin/python

import facebook
import re
import urllib2
import sys

try:
    accessToken = str(sys.argv[1])
except IndexError:
    accessToken = raw_input('Enter your access token: ')

try:
    groupID = str(sys.argv[2])
except IndexError:
    groupID = raw_input('Enter the page ID: ')

try:
    numOfPosts = int(sys.argv[3])
except IndexError:
    numOfPosts = int(raw_input('Enter the number of posts to crawl: '))

maxPosts = False

# Access to Facebook Graph API
graph = facebook.GraphAPI(accessToken)

# Retrieve the IDs of the posts in the group's feed
if numOfPosts <= 10:
    args = {'fields' : 'id', 'limit' : str(numOfPosts)}
else:
    args = {'fields' : 'id', 'limit' : '11'}
feed = graph.get_object(groupID + "/feed", **args)

# Extract each post's ID and store in the list "IDs"
IDs = re.findall(r"\'id\': \'([\d_]+)\'", str(feed))
while len(IDs) < numOfPosts:
    feed = re.sub(r'[\\]', r'', str(feed))
    # Extract the URL of the next page to crawl 
    newURL = re.findall(r".next.: ?u?.([\w||\?||&||/||\.||:||=||_]+).", str(feed))

    # Open and Read the URL of the next page to crawl
    try:
        response = urllib2.urlopen(str(newURL[0]))
    except IndexError:
        maxPosts = True
        break
    feed = response.read()

    # Extract the IDs of the posts on the new page and store in the temp list "moreIDs"
    moreIDs = re.findall(r".id.: ?.([\d_]+).", str(feed))
    counter = 0

    # Append the new IDs from "moreIDs" onto the complete ID list, "IDs"
    while len(IDs) < numOfPosts and len(moreIDs) > counter:
        IDs.append(str(moreIDs[counter]))
        counter += 1

postCounter = 0
for ID in IDs:
    postCounter += 1
    # Try to create an object, "post", for each ID
    try:
        post = graph.get_object(id = str(ID))
    except:
        print "<post>\n<id>" + str(ID) + "</id>\n<author></author>\n<message></message>\n</post>"
        continue

    # Extract "name" from the "from" field
    name = re.search(r".name.: ?u?.(?P<name>.*?).}", str(post['from']))

    # Print data in XML Format
    print "<post>"
    print "<id>" + ID + "</id>"

    # Check if the post has an author, if not leave the tags empty
    try:
        print "<author>" + unicode(name.group('name'), 'unicode-escape') + "</author>"
    except:
        print "<author></author>"

    print "<timestamp>" + post['created_time'] + "</timestamp>"

    # Check if the post has a message, if not leave the tags empty
    try:
        print "<message>" + post['message'] + "</message>"
    except:
        print "<message></message>"

    print "</post>"

print ""
if maxPosts == True:
    print "There are only " + str(len(IDs)) + " posts on the group's page."
print "Total posts crawled: " + str(postCounter)



