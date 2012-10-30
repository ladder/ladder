#! /bin/bash

for f in $*
do
    time padrino rake import:marc["$f"]
    time padrino rake map:marc
    time padrino rake map:mods
done

