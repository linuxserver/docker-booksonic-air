FROM ghcr.io/linuxserver/baseimage-ubuntu:bionic

# set version label
ARG BUILD_DATE
ARG VERSION
ARG BOOKSONIC_AIR_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="chbmb"

# environment settings
ENV BOOKSONIC_AIR_HOME="/app/booksonic-air" \
BOOKSONIC_AIR_SETTINGS="/config" \
LANG="C.UTF-8"

RUN \
 echo "**** install runtime packages ****" && \
 apt-get update && \
 apt-get install -y \
	--no-install-recommends \
	ca-certificates \
	ffmpeg \
	flac \
	fontconfig \
	lame \
	openjdk-8-jre \
	ttf-dejavu && \
 echo "**** fix XXXsonic status page ****" && \
 find /etc -name "accessibility.properties" -exec rm -fv '{}' + && \
 find /usr -name "accessibility.properties" -exec rm -fv '{}' + && \
 echo "**** install BOOKSONIC-AIR ****" && \
 if [ -z ${BOOKSONIC_AIR_RELEASE+x} ]; then \
 	BOOKSONIC_AIR_RELEASE=$(curl -sX GET "https://api.github.com/repos/popeen/Booksonic-Air/releases/latest" \
        | awk '/tag_name/{print $4;exit}' FS='[""]'); \
 fi && \
 mkdir -p \
	${BOOKSONIC_AIR_HOME} && \
 curl -o \
 ${BOOKSONIC_AIR_HOME}/booksonic.war -L \
	"https://github.com/popeen/Booksonic-Air/releases/download/${BOOKSONIC_AIR_RELEASE}/booksonic.war" && \
 echo "**** cleanup ****" && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

# add local files
COPY root/ /

# ports and volumes
EXPOSE 4040
VOLUME /config
