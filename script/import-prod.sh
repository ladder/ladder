#! /bin/bash

curl -XDELETE http://localhost:9200/
padrino rake -e production mi:drop
padrino rake -e production mi:create_indexes

for f in $*
do
    time padrino rake -e production import:marc["$f"]
    time padrino rake -e production map:marc
    time padrino rake -e production map:mods
done

time padrino rake -e production model:index
