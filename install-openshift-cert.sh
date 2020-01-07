#!/bin/sh 
# Arguments: loginserver logintoken projectname routename cert_file key_file ca_cert_file
# ./install-openshift-cert.sh https://console.zh.shift.switchengines.ch token gebastel hello-openshift ssl.crt ssl.key ca.cer
OC=/usr/local/bin/oc 

#https://console.zh.shift.switchengines.ch

OPENSHIFT_SERVER=${1:-"MISSING:OPENSHIFT_SERVER"}
OPENSHIFT_LOGIN_TOKEN=${2:-"MISSING:OPENSHIFT_LOGIN_TOKEN"}
OPENSHIFT_NAMESPACE=${3:-"MISSING:OPENSHIFT_NAMESPACE"}
OPENSHIFT_ROUTE_NAME=${4:-"MISSING:OPENSHIFT_ROUTE_NAME"}

SSL_CERT_FILE=$5
SSL_KEY_FILE=$6
SSL_CA_FILE=$7

echo "Logging in to Openshift on $OPENSHIFT_SERVER ..."
$OC login $OPENSHIFT_SERVER --token=$OPENSHIFT_LOGIN_TOKEN || exit 1

echo "Logged in!"

echo "Selecting project $OPENSHIFT_NAMESPACE ..."
$OC project $OPENSHIFT_NAMESPACE || exit 1

echo "Checking if Route $OPENSHIFT_ROUTE_NAME exists..."
$OC get route $OPENSHIFT_ROUTE_NAME || exit 1 


CERTIFICATE="$(awk '{printf "%s\\n", $0}' ${SSL_CERT_FILE})"
KEY="$(awk '{printf "%s\\n", $0}' ${SSL_KEY_FILE})"
CABUNDLE=$(awk '{printf "%s\\n", $0}' ${SSL_CA_FILE})

oc patch "route/${OPENSHIFT_ROUTE_NAME}" -p '{"spec":{"tls":{"certificate":"'"${CERTIFICATE}"'","key":"'"${KEY}"'","caCertificate":"'"${CABUNDLE}"'"}}}'
