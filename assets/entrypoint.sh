#!/bin/bash
set -e

# check mandatory input
[ -z "${KERBEROS_REALM}" ] && echo "KERBEROS_REALM must be defined" && exit 1
[ -z "${LDAP_URI}" ] && echo "LDAP_URI must be defined" && exit 1
[ -z "${LDAP_BASE_DN}" ] && echo "LDAP_BASE_DN must be defined" && exit 1
[ -z "${LDAP_BIND_DN}" ] && echo "LDAP_BIND_DN must be defined" && exit 1
[ -z "${LDAP_BIND_PASSWORD}" ] && echo "LDAP_BIND_PASSWORD must be defined" && exit 1

# check optional input
[ -z "${KERBEROS_DNS_DISCOVERY_DOMAIN}" ] && KERBEROS_DNS_DISCOVERY_DOMAIN=${KERBEROS_REALM}
[ -z "${LDAP_USER_PRINCIPAL}" ] && LDAP_USER_PRINCIPAL="userPrincipalName"
[ -z "${LDAP_ENUMERATE}" ] && LDAP_ENUMERATE="false"
[ -z "${LDAP_IGNORE_GROUP_MEMBERS}" ] && LDAP_IGNORE_GROUP_MEMBERS="true"
[ -z "${LDAP_USER_MEMBEROF}" ] && LDAP_USER_MEMBEROF="memberOf"

# put config files in place
cat >/etc/krb5.conf <<EOL
[libdefaults]

    default_realm = ${KERBEROS_REALM}
    dns_lookup_realm = true
    dns_lookup_kdc = true
EOL

cat >/etc/sssd/sssd.conf <<EOL
[sssd]
config_file_version = 2
services = nss, pam
domains = ${KERBEROS_REALM}

[domain/${KERBEROS_REALM}]
enumerate = ${LDAP_ENUMERATE}
ignore_group_members = ${LDAP_IGNORE_GROUP_MEMBERS}
cache_credentials = true
id_provider = ldap
access_provider = ldap
auth_provider = krb5
chpass_provider = krb5
ldap_uri = ${LDAP_URI}
ldap_search_base = ${LDAP_BASE_DN}
krb5_realm = ${KERBEROS_REALM}
dns_discovery_domain = ${KERBEROS_DNS_DISCOVERY_DOMAIN}
ldap_tls_reqcert = never
ldap_schema = ad
ldap_id_mapping = True
ldap_user_principal = ${LDAP_USER_PRINCIPAL}
ldap_user_member_of = ${LDAP_USER_MEMBEROF}
ldap_access_order = expire
ldap_account_expire_policy = ad
ldap_force_upper_case_realm = true
ldap_user_search_base =  ${LDAP_BASE_DN}
ldap_group_search_base =  ${LDAP_BASE_DN}
ldap_default_bind_dn = ${LDAP_BIND_DN}
ldap_default_authtok = ${LDAP_BIND_PASSWORD}
sudo_provider = none
fallback_homedir = /home/%u
default_shell = /bin/bash
skel_dir = /etc/skel
krb5_auth_timeout=60
EOL

cat >/etc/nsswitch.conf <<EOL
passwd:         compat sss
group:          compat sss
shadow:         compat
gshadow:        files

hosts:          files dns
networks:       files

protocols:      db files
services:       db files
ethers:         db files
rpc:            db files
netgroup:       nis sss
EOL

# fix permissions
chmod 600 /etc/sssd/sssd.conf

# create db directory if not exists
mkdir -p /var/lib/sss/db
mkdir -p /var/lib/sss/pipes/private
mkdir -p /var/lib/sss/mc

exec "$@"
