#! /bin/bash

# change to working environment
env=${1-development}

# clear out mongodb
padrino rake -e $env mi:purge
padrino rake -e $env mi:create_indexes

# clear out elasticsearch
padrino rake -e $env tire:index:drop INDEX=ladder_$env
padrino rake -e $env model:index

# load fixtures
padrino rake -e $env model:init