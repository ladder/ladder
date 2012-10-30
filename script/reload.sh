#! /bin/bash

curl -XDELETE http://localhost:9200/    # clear ES index
padrino rake mi:drop                    # clear mongodb

source `pwd`/`dirname $0`/load-marc.sh  ~/Downloads/tmp/

time padrino rake model:index           # reindex everything