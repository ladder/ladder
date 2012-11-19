#! /bin/bash

# change to working environment
env="development"

for f in $*
do
    time padrino rake -e $env import:marc["$f"]
    time padrino rake -e $env map:marc
    time padrino rake -e $env map:mods
done

time padrino rake -e $env model:index