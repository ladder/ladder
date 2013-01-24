#! /bin/bash

# change to working environment
env="development"

padrino rake -e $env tire:index:drop INDEX=agents,concepts,resources
padrino rake -e $env mi:purge
padrino rake -e $env mi:create_indexes
padrino rake -e $env model:init