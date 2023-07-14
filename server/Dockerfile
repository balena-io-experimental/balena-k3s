# https://hub.docker.com/r/rancher/k3s/tags
# https://github.com/k3s-io/k3s/blob/master/package/Dockerfile
FROM rancher/k3s:v1.26.2-k3s1

# hadolint ignore=DL3018
RUN apk add --no-cache tini

COPY entry.sh /entry.sh
RUN chmod +x entry.sh

ENTRYPOINT [ "/sbin/tini", "--"]
CMD [ "/entry.sh" ]
