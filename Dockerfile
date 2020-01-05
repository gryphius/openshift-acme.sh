FROM neilpang/acme.sh
MAINTAINER "Oli Schacher" <oli@wgwh.ch>


ENV OC_VERSION "v3.11.0"
ENV OC_RELEASE "openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit"


RUN curl -L https://github.com/openshift/origin/releases/download/$OC_VERSION/$OC_RELEASE.tar.gz | tar -C /usr/local/bin -xzf - --strip-components=1

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
