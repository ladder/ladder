#! /bin/bash

curl -XDELETE http://localhost:9200/            # delete existing index
time padrino rake mi:drop		                # delete existing data

time padrino rake import:marc[~/Downloads/tmp/]	# import new MARC data
time padrino rake map:marc		                # XSLT transform
time padrino rake map:mods --trace              # map XML to vocabs

time padrino rake model:index	                # create/update ES index