#! /bin/bash
die () {
    echo >&2 "$@"
    exit 1
}

# ensure we have enough args
[ "$#" -eq 2 ] || die "Error: 2+ arguments required, $# provided"

# change to working environment
env=$1
echo "Using environment: $env"

for f in ${*:2}
do
    time padrino rake -e $env import:marc["$f"]
    time padrino rake -e $env map:marc
done

time padrino rake -e $env model:index