#! /bin/bash

curl -XDELETE http://localhost:9200/    # clear ES index
padrino rake mi:drop                    # clear mongodb
padrino rake mi:create_indexes          # create indexes

for f in $*
do
    time padrino rake import:marc["$f"]
    time padrino rake map:marc
    time padrino rake map:mods
done

time padrino rake model:index           # reindex everything