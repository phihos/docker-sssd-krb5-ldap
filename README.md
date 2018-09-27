# Docker Image with SSSD,KRB5 and LDAP
A Docker image that provides the SSSD serivice with Active Directory configuration

## Introduction

This image provides a way to let PAM authenticate against active directory inside you Docker containers.
The configuration is done in a way that you do not need the AD administrator's password to use it. AD_LDAP credentials are sufficient.

## Running

```
docker run --name sssd \
    -e KERBEROS_REALM=YOURDOMAIN.TLD
    -e LDAP_BASE_DN="DC=YOURDOMAIN,DC=TLD" \
    -e LDAP_BIND_DN="CN=SOMEACCOUNT,DC=YOURDOMAIN,DC=TLD" \
    -e LDAP_BIND_PASSWORD=SOMEPASSWORD \
    -e LDAP_URI=ldap://YOUR-AD-LDAP-SERVER/
```

Optional parameters are:

| Option                        | Default           | Description                                                                                                                          |
|-------------------------------|-------------------|--------------------------------------------------------------------------------------------------------------------------------------|
| LDAP_USER_PRINCIPAL           | userPricipalName  | The LDAP attribute identifying the user name for Kerberos. Set this to a nonexisting entry if this differs from the actiol username. |
| KERBEROS_DNS_DISCOVERY_DOMAIN | ${KERBEROS_REALM} | Change this, if your DNS uses another domain suffic than your AD realm.                                                              |


