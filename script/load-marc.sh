#! /bin/bash

# change to working environment
env="development"

padrino rake -e $env tire:index:drop INDEX=agents,concepts,resources
padrino rake -e $env mi:drop
padrino rake -e $env mi:create_indexes

for f in $*
do
    time padrino rake -e $env import:marc["$f"]
    time padrino rake -e $env map:marc
    time padrino rake -e $env map:mods
done

time padrino rake -e $env model:index