#!/bin/sh
#
# Generic python environment for OpenFIDO
#

error()
{
    echo '*** ABNORMAL TERMINATION ***'
    echo 'See error Console Output stderr for details.'
    echo "See https://github.com/openfido/loadshape for help"
    exit 1
}

trap on_error 1 2 3 4 6 7 8 11 13 14 15

set -x # print commands
set -e # exit on error
set -u # nounset enabled

if [ ! -f "/usr/local/bin/gridlabd" ]; then
    echo "ERROR [openfido.sh]: '/usr/local/bin/gridlabd' not found" > /dev/stderr
    error
elif [ ! -f "$OPENFIDO_INPUT/config.csv" ]; then
    OPTIONS=$(cd $OPENFIDO_INPUT; ls -1 | tr '\n' ' ')
    if [ ! -z "$OPTIONS" ]; then
        echo "WARNING [openfido.sh]: '$OPENFIDO_INPUT/config.csv' not found, using all input files by default" > /dev/stderr
    else
        echo "ERROR [openfido.sh]: no input files"
        error
    fi
else
    OPTIONS=$(cd $OPENFIDO_INPUT ; cat config.csv | tr '\n' ' ')
fi

export DEBIAN_FRONTEND=noninteractive
apt-get -q -y update > /dev/null
apt-get -q -y install python3 python3-pip > /dev/null
python3 -m pip install -q -r requirements.txt > /dev/null

# process config file
if [ -e "config.csv" ]; then
    LOCATION_DATA=$(grep ^LOCATION_DATA, "config.csv" | cut -f2- -d, | tr ',' ' ')
    echo "Config settings:"
    echo "  LOCATION_DATA = ${LOCATION_DATA:-}"
else
    echo "No 'config.csv', using default settings:"
    echo "LOCATION_DATA = "
fi

echo '*** INPUTS ***'
ls -l $OPENFIDO_INPUT

python3 openfido.py || error

echo '*** OUTPUTS ***'
ls -l $OPENFIDO_OUTPUT

echo '*** RUN COMPLETE ***'
echo 'See Data Visualization and Artifacts for results.'

echo '*** END ***'

