#! /bin/bash

curl -XDELETE http://localhost:9200/    # clear ES index
padrino rake -e production mi:drop                    # clear mongodb

for f in $*
do
    time padrino rake -e production import:marc["$f"]
    time padrino rake -e production map:marc
    time padrino rake -e production map:mods
done

time padrino rake -e production model:index           # reindex everything
