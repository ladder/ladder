#! /bin/bash

curl -XDELETE http://localhost:9200/    # clear ES index
padrino rake mi:drop                    # clear mongodb

for f in $*
do
    time padrino -e production rake import:marc["$f"]
    time padrino -e production rake map:marc
    time padrino -e production rake map:mods
done

time padrino -e production rake model:index           # reindex everything
