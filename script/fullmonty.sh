#! /bin/bash

time padrino rake mi:drop		                # nuke existing data
time padrino rake marc:import[~/Downloads/tmp/]	# import new MARC data
time padrino rake marc:map		                # slowest part; XSLT transform
time padrino rake mods:map		                # map XML to vocabs
time padrino rake tree:build					# generate relation hierarchy
time padrino rake tire:index	                # send mongodb data to ES index
