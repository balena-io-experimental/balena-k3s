FROM rancher/k3s:v1.26.2-k3s1

ENTRYPOINT ["sh"]
CMD ["-c", "--", "/bin/k3s server --tls-san server ${EXTRA_K3S_SERVER_ARGS}"]
