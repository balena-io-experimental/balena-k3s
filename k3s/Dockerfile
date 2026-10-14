# https://docs.k3s.io/advanced#running-k3s-in-docker
# renovate: datasource=docker depName=rancher/k3s
FROM rancher/k3s:v1.36.4-k3s1

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT []
CMD [ "/entrypoint.sh" ]
