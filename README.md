Openshift Certificates using Let's encrypt / DNS dynamic updates

 * create route for the application to be updated, with empty cert (openshift will use the default).
 * `oc create sa letsencrypt`
 * give edit permission to the service account (oc command?)
 * deploy this image  ( gryphius/openshift-acme )
 * set environment variables:
  * `CERT_HOSTNAME` : hostname, should match the one in the route
  * `DYNDNS_SERVER` : RFC2196 update server
  * `DYNDNS_TSIG` : Tsig key file content (best stored in a secret)
  * `DYNDNS_ALIAS` (optional): If using CNAME aliasing for dyndns updates, set the target host here
  * `OPENSHIFT_SERVER` : login url for the openshift server
  * `OPENSHIFT_ROUTE` : name of the route to update
  * `OPENSHIFT_NAMESPACE` : project name containing the route to be updated
  * `OPENSHIFT_TOKEN` : login token of the service user. Can be directly attached from the service secret, if on the same server



