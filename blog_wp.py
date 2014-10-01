import datetime, xmlrpclib

wp_url = "http://localhost:5130/xmlrpc.php"
wp_username = "davidbliu"
wp_password = "asdf"
wp_blogid = "PBL Blogf"

status_draft = 0
status_published = 1

server = xmlrpclib.ServerProxy(wp_url)

title = "pizza man is gone"
content = "Body with lots of content"
date_created = xmlrpclib.DateTime(datetime.datetime.strptime("2009-10-20 21:08", "%Y-%m-%d %H:%M"))
categories = ["somecategory"]
tags = ["sometag", "othertag"]
data = {'title': title, 'description': content, 'dateCreated': date_created, 'categories': categories, 'mt_keywords': tags}

# post_id = server.metaWeblog.newPost(wp_blogid, wp_username, wp_password, data, status_published)

# new_name = 'random_luser'
# new_pass = 'password'
# new_email = 'pbl.historians@gmail.com'
# # print server.metaWeblog.newUser.__dict__
# server.metaWeblog.newUsesr(new_name, new_pass)

#
# load up posts from yaml file
#
import yaml

stream = open("posts_dump.yaml", 'r')
data =  yaml.load(stream)

# 
# print data

print len(data)
for post in data:
	print post['title']
	print post['date']

	title = post['title']
	content = post['body']
	date_created = xmlrpclib.DateTime(post['date'])
	categories = ["old posts"]
	tags = ["old", "blah"]
	data = {'title': title, 'description': content, 'dateCreated': date_created, 'categories': categories, 'mt_keywords': tags}
	post_id = server.metaWeblog.newPost(wp_blogid, wp_username, wp_password, data, status_published)

