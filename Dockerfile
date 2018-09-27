FROM ubuntu

RUN apt-get update && apt-get install -y \
      sssd \
      krb5-user

COPY assets/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME /var/lib/sss
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/sssd","-i"]
