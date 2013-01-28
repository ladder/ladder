#! /bin/bash

# change to working environment
env=${1-development}

# clear out mongodb and elasticsearch
padrino rake -e $env mi:purge
padrino rake -e $env tire:index:drop INDEX=ladder_$env

# create indexes and load fixtures
padrino rake -e $env mi:create_indexes
padrino rake -e $env model:init