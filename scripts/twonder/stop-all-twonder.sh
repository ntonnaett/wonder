#!/bin/bash

# Read config
SCRIPTDIR=`dirname $0`
source ${SCRIPTDIR}/../configs/cluster.conf

for node in $CLUSTER_NODES;
do
    rsh $USER_NAME@$node killall twonder
done
