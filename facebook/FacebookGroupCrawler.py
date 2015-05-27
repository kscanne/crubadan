#!/usr/bin/python

import facebook
import requests
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

# Retrieve each post's ID and store in the list "IDs"
IDs = []
for post in feed['data']:
    IDs.append(str(post['id']))

while len(IDs) < numOfPosts:
    print str(len(IDs))

    # Retrieve the next page to crawl
    try:
        feed = requests.get(feed['paging']['next']).json()
    except IndexError:
        maxPosts = True
        break

    # Retrieve the IDs of the posts on the new page
    moreIDs = []
    for post in feed['data']:
        moreIDs.append(str(post['id']))
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
        print "<post>\n<id>" + str(ID) + "</id>\n<author></author>\n<timestamp></timestamp>\n<message></message>\n<comments></comments>\n</post>"
        continue

    # Print data in XML Format
    print "<post>"
    print "<id>" + ID + "</id>"

    # Check if the post has an author, if not leave the tags empty
    try:
        print "<author>" + post['from']['name'] + "</author>"
    except:
        print "<author></author>"

    print "<timestamp>" + post['created_time'] + "</timestamp>"

    # Check if the post has a message, if not leave the tags empty
    try:
        print "<message>" + post['message'] + "</message>"
    except:
        print "<message></message>"

    # COMMENTS
    args = {'fields' : 'id,created_time,from,message', 'limit' : '11'}
    comments = graph.get_object(ID + "/comments", **args)

    for comment in comments['data']:
        print "<comment>"
        print "<id>" + comment['id'] + "</id>"
        print "<author>" + comment['from']['name'] + "</author>"
        print "<timestamp>" + comment['created_time'] + "</timestamp>"
        print "<message>" + comment['message'] + "</message>"
        print "</comment>"

    print "</post>"

print ""
if maxPosts == True:
    print "There are only " + str(len(IDs)) + " posts on the group's page."
print "Total posts crawled: " + str(postCounter)



