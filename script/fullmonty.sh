#! /bin/bash

time padrino rake marc:import[~/Downloads/tmp/]
time padrino rake marc:map
time padrino rake mods:map
#time padrino rake mods:map[remap]
time padrino rake tire:index
