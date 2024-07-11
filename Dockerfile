ARG CIMG_BASE
ARG CIMG_VERSION

FROM cimg/${CIMG_BASE}:${CIMG_VERSION}

RUN pip install duplocloud-client
