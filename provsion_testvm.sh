#!/bin/bash
set -e

if [ $1 ]
then
    source $1
else
    echo "No variable file set"
    exit -1
fi

FLAVOR=${FLAVOR:-4}
KEY=${KEY:-"ndipanov-thinkpad"}
NAME="ansible-"${NAME:-"devstack-test"}

if [ -n "$(nova list | grep ${NAME})" ]
then
    echo "$NAME already exists - delete it first"
    exit -1
fi

nova boot --image ${IMAGE} --flavor ${FLAVOR} --nic net-name=internal --key-name ${KEY} ${NAME}
echo "Waiting for ${NAME} to come up..."
while [ -z "$(nova list | grep $NAME".*ACTIVE")" ]
do
    sleep 1
done
echo "${NAME} is up!"
FLOATING_IP_ID=$(neutron floatingip-list | grep $FLOATING_IP | awk '{ print $2 }')
echo "Floating IP ID found: $FLOATING_IP_ID"
STATIC_IP=$(nova list | perl -n -e "/^.*${NAME}.*internal=(\\d+\\.\\d+\\.\\d+\\.\\d+)/ && print \$1" )
echo "Static IP found: $STATIC_IP"
PORT_ID=$(neutron port-list | grep $STATIC_IP | awk '{ print $2 }')
echo "Port found: $PORT_ID"
neutron floatingip-associate $FLOATING_IP_ID $PORT_ID
