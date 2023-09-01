# https://hub.docker.com/r/rancher/k3s/tags
# https://github.com/k3s-io/k3s/blob/master/package/Dockerfile
FROM rancher/k3s:v1.26.2-k3s1

COPY server.sh /server.sh
RUN chmod +x /server.sh

ENTRYPOINT []
CMD [ "/server.sh" ]
