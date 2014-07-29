FROM brimstone/ubuntu:14.04

MAINTAINER brimstone@the.narro.ws

# TORUN

ENV GOPATH /go

ENV PACKAGES git golang ca-certificates

# Set our command
ENTRYPOINT ["/go/bin/goiardi"]
CMD []

# Install the packages we need, clean up after them and us
RUN apt-get update \
	&& dpkg -l | awk '/^ii/ {print $2}' > /tmp/dpkg.clean \
    && apt-get install -y --no-install-recommends $PACKAGES \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists \

	&& go get -v github.com/ctdk/goiardi \

	&& apt-get remove -y --purge $PACKAGES \
	&& apt-get autoremove -y --purge \
	&& dpkg -l | awk '/^ii/ {print $2}' > /tmp/dpkg.dirty \
	&& apt-get remove --purge -y $(diff /tmp/dpkg.clean /tmp/dpkg.dirty | awk '/^>/ {print $2}') \
	&& rm /tmp/dpkg.* \
	&& rm -rf $GOPATH/src \
	&& rm -rf $GOPATH/pkg
