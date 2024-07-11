ARG CIMG_BASE
ARG CIMG_VERSION

FROM cimg/${CIMG_BASE}:${CIMG_VERSION}

ARG CIMG_BASE
ARG DUPLOCTL_VERSION
ARG TARGETARCH

RUN <<EOF
if command -v pip &> /dev/null
then
  pip install duplocloud-client==${DUPLOCTL_VERSION}
else
  URL="https://github.com/duplocloud/duploctl/releases/download/v${DUPLOCTL_VERSION}/duploctl-${DUPLOCTL_VERSION}-linux-${TARGETARCH}.tar.gz"
  sudo curl -s -L "$URL" | sudo tar xvz - -C /usr/local/bin
fi
EOF
