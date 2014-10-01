import datetime, xmlrpclib

wp_url = "http://localhost:5130/xmlrpc.php"
wp_username = "davidbliu"
wp_password = "asdf"
wp_blogid = "PBL Blog"

status_draft = 0
status_published = 1

server = xmlrpclib.ServerProxy(wp_url)

title = "another auomatically generated post here"
content = "Body with lots of content AND STUFF"
date_created = xmlrpclib.DateTime(datetime.datetime.strptime("2009-10-20 21:08", "%Y-%m-%d %H:%M"))
categories = ["somecategory"]
tags = ["sometag", "othertag"]
data = {'title': title, 'description': content, 'dateCreated': date_created, 'categories': categories, 'mt_keywords': tags}

post_id = server.metaWeblog.newPost(wp_blogid, wp_username, wp_password, data, status_published)