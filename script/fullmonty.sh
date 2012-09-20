#! /bin/bash

time padrino rake mi:drop		                # nuke existing data

time padrino rake import:marc[~/Downloads/tmp/]	# import new MARC data
time padrino rake map:marc		                # XSLT transform
time padrino rake map:mods		                # map XML to vocabs

time padrino rake model:index	                # send mongodb data to ES index
time padrino rake model:merge					# merge duplicate documents (requires index)
time padrino rake model:build					# generate relation hierarchy

time padrino rake model:index	                # send mongodb data to ES index
