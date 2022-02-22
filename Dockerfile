FROM ubuntu:focal
MAINTAINER <mattpublic@home>

RUN apt-get -q -y update && \
	apt-get -q -y upgrade && \
	apt-get -q -y install --no-install-recommends \
		ca-certificates \
		curl \
		jq \
		&& \
	update-ca-certificates && \
	apt-get -q -y autoremove && \
	apt-get -q -y clean && \
	rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
