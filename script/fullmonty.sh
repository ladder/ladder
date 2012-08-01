#! /bin/bash

top -l 1 | grep PhysMem
time padrino rake marc:import[~/Downloads/tmp/]

top -l 1 | grep PhysMem
time padrino rake marc:map

top -l 1 | grep PhysMem
time padrino rake mods:map

top -l 1 | grep PhysMem
time padrino rake tire:index

top -l 1 | grep PhysMem
