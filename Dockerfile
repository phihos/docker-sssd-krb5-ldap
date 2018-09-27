FROM ubuntu

RUN apt-get update && apt-get install -y \
	samba \
    sssd \
    krb5-user \
    libpam-krb5

COPY assets/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/sssd","-i"]