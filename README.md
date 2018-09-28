# Docker Image with SSSD,KRB5 and LDAP
A Docker image that provides the SSSD serivice with Active Directory configuration.

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
    -e LDAP_URI=ldap://YOUR-AD-LDAP-SERVER/ \
    -v /var/lib/sss
```

The volume is important because it can be mounted with ```--volume-from``` into other containers. These containers just need to have the SSSD client installed and can use the SSSD server remotely.

Optional parameters are:

| Option                        | Default           | Description                                                                                                                          |
|-------------------------------|-------------------|--------------------------------------------------------------------------------------------------------------------------------------|
| LDAP_USER_PRINCIPAL           | userPricipalName  | The LDAP attribute identifying the user name for Kerberos. Set this to a nonexisting entry if this differs from the actiol username. |
| KERBEROS_DNS_DISCOVERY_DOMAIN | ${KERBEROS_REALM} | Change this, if your DNS uses another domain suffic than your AD realm.                                                              |

## Troubleshooting

If something goes wrong run the container with

```
docker run --name sssd ... sssd sssd -d 0x0270 -f
```

In a second console go into the container and try
```
getent USERNAME
```
Substitute *USERNAME* with a username that certainly exists. If nothing is displayed, the user lookup over the LDAP connection does not work. Look into */var/log/sssd* for further hints.

Secondly you can run
```
login USERNAME
```
and enter the correct password. If it says "login incorrect", then the AD part is somehow misconfigured. Again look into */var/log/sssd* for further hints.


## Contributing

This image offers just enough options that it fits my usecase. If you would like to exand the list of options feel free to make a PR.

