#!/usr/bin/python

import facebook
import requests
import sys
import codecs
sys.stdout=codecs.getwriter('utf-8')(sys.stdout)
import print_data

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

# Retrieve the group's feed
if numOfPosts <= 10:
    args = {'fields' : 'id', 'limit' : str(numOfPosts)}
else:
    args = {'fields' : 'id', 'limit' : '11'}
feed = graph.get_object(groupID + "/feed", **args)

total = 0
posts = []
comments = []
# Append all posts and comments into list "posts"
for post in feed['data']:
    total += 1
    try:
        temp = graph.get_object(post['id'])
        temp['comment'] = 'f'
        posts.append(temp)
    except:
        pass
    
    # Retrieve the post's comments
    args = {'fields' : 'id,created_time,from,message', 'limit' : '11'}
    comments = graph.get_object(str(post['id']) + "/comments", **args)

    # Apped the post's comments
    for comment in comments['data']:
        comment['comment'] = 't'
        posts.append(comment)

# Retrieve the next page to crawl and append all posts and comments into list "posts"
while total < int(numOfPosts):    
    try:
        feed = requests.get(feed['paging']['next']).json()
    except IndexError:
        maxPosts = True
        break

    # Append each post
    for post in feed['data']:
        total += 1
        try:
            temp = graph.get_object(post['id'])
            temp['comment'] = 'f'
            posts.append(temp)
        except:
            pass

        # Retrieve the post's comments
        args = {'fields' : 'id,created_time,from,message', 'limit' : '11'}
        comments = graph.get_object(post['id'] + "/comments", **args)

        # Append the post's comments
        for comment in comments['data']:
            comment['comment'] = 't'
            posts.append(comment)

for post in posts:
    print_data.printData(post)


print ""
if maxPosts == True:
    print "There are only " + str(total) + " posts on the group's page."
print "Total posts crawled: " + str(total)



