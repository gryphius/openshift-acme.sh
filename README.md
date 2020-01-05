# Setup

## Create a service account
oc create sa letsencrypt



Direct docker example:

docker run -e "CERT_HOSTNAME=www.example.com" -e "DYNDNS_SERVER=ns1.example.com" -e "DYNDNS_TSIG=(content of key file)" openshift-acme.sh
