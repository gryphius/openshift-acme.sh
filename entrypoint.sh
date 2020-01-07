#!/bin/sh

WORKDIR=/acme.sh

SLEEPTIME=3600
FAIL_TIMER=20

ACME_SH_CMD="/acme.sh/acme.sh"
CERTIFICATES_DIR="/certificates"

OPTS=""

# Test if acme.sh is where we think it is
if ! [ -e $ACME_SH_CMD ]; then 
 echo "$ACME_SH_CMD does not exist"
 sleep $FAIL_TIMER
 exit 1
fi

# Test if workdir is writable
echo -n "test" > $WORKDIR/testwrite.txt
res=$(cat $WORKDIR/testwrite.txt)
if [ "$res" != "test" ]; then
 echo "Workdir $WORKDIR is not writable. Stopping here."
 sleep $FAIL_TIMER
 exit 1
fi

if [ "$OPENSHIFT_SERVER" == "" ] ; then 
 echo "OPENSHIFT_SERVER is not set. Cannot continue."
 sleep $FAIL_TIMER
 exit 1
fi
if [ "$OPENSHIFT_TOKEN" == "" ] ; then 
 echo "OPENSHIFT_TOKEN is not set. Cannot continue."
 sleep $FAIL_TIMER
 exit 1
fi
if [ "$OPENSHIFT_ROUTE" == "" ] ; then 
 echo "OPENSHIFT_ROUTE is not set. Cannot continue."
 sleep $FAIL_TIMER
 exit 1
fi
if [ "$OPENSHIFT_NAMESPACE" == "" ] ; then 
 echo "OPENSHIFT_NAMESPACE is not set. Cannot continue."
 sleep $FAIL_TIMER
 exit 1
fi


if [ "$CERT_HOSTNAME" == "" ] ; then 
 echo "CERT_HOSTNAME is not set. Cannot continue."
 sleep $FAIL_TIMER
 exit 1
fi

echo "Certificate Hostname(CERT_HOSTNAME): $CERT_HOSTNAME"


if [ "$DYNDNS_SERVER" == "" ] ; then 
 echo "DYNDNS_SERVER is not set. Cannot continue."
 sleep $FAIL_TIMER
 exit 1
fi

echo "Dynamic DNS update Server(DYNDNS_SERVER): $DYNDNS_SERVER"
export NSUPDATE_SERVER=$DYNDNS_SERVER

if [ "$DYNDNS_TSIG" == "" ] ; then 
 echo "DYNDNS_TSIG is not set. Cannot continue."
 sleep $FAIL_TIMER
 exit 1
fi
echo "$DYNDNS_TSIG" > $WORKDIR/tsig 
export NSUPDATE_KEY=$WORKDIR/tsig

if [ "$DYNDNS_ALIAS" != "" ]; then
 OPTS="$OPTS --challenge-alias $DYNDNS_ALIAS"
 echo "Using challenge alias: $DYNDNS_ALIAS"
fi

while true; do
    date
    CMD="$ACME_SH_CMD --issue -d $CERT_HOSTNAME $OPTS --dns dns_nsupdate"
    echo "Executing: $CMD"
    $CMD

    echo "Patching Route..."
    CRT="${CERTIFICATES_DIR}/${CERT_HOSTNAME}/${CERTIFICATE_HOSTNAME}.cer"
    CA="${CERTIFICATES_DIR}/${CERT_HOSTNAME}/ca.cer"
    KEY="${CERTIFICATES_DIR}/${CERT_HOSTNAME}/${CERTIFICATE_HOSTNAME}.key"

    if ! [ -f $CRT ] ; then 
        echo "$CRT not found"
        sleep $SLEEPTIME
        continue
    fi

    if ! [ -f $CA ] ; then 
        echo "$CA not found"
        sleep $SLEEPTIME
        continue
    fi

    if ! [ -f $KEY ] ; then 
        echo "$KEY not found"
        sleep $SLEEPTIME
        continue
    fi

    /install-openshift-cert.sh $OPENSHIFT_SERVER $OPENSHIFT_ROUTE $OPENSHIFT_NAMESPACE $OPENSHIFT_ROUTE $CRT $KEY $CA

    echo "Run completed, next run in $SLEEPTIME seconds"
    sleep $SLEEPTIME
    echo ""
done