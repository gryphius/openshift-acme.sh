
FROM centos:8
MAINTAINER "Oli Schacher" <oli@wgwh.ch>

RUN yum install -y \
  openssl \
  openssh-clients \
  bind-utils \
  curl \
  socat \
  tzdata \
  tar \
  git \
  && yum clean all

ENV LE_CONFIG_HOME /certificates

ENV AUTO_UPGRADE 1

RUN git clone https://github.com/Neilpang/acme.sh.git /acme-sh-inst && cd /acme-sh-inst && ./acme.sh --install --home /acme.sh --config-home /certificates --cert-home /certificates --force && cd .. && rm -Rf /acme-sh-inst 

RUN chgrp -R 0 /acme.sh \
  && chmod -R g+rwX /acme.sh

RUN mkdir -p /certificates  && chgrp -R 0 /certificates \
  && chmod -R g+rwX /certificates

VOLUME /certificates


ENV OC_VERSION "v3.11.0"
ENV OC_RELEASE "openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit"


RUN curl -L https://github.com/openshift/origin/releases/download/$OC_VERSION/$OC_RELEASE.tar.gz | tar -C /usr/local/bin -xzf - --strip-components=1

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ADD install-openshift-cert.sh /install-openshift-cert.sh 
RUN chmod +x /install-openshift-cert.sh 

ENTRYPOINT ["/entrypoint.sh"]
