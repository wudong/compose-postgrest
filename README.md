# Database Dictionary

This is a database dictionary for the TT event database. 


# To get a certificate for local develop:

```
docker-compose run --rm --entrypoint "certbot -d tt.graceliu.uk --manual --preferred-challenges dns certonly" certbot
```

and follow the steps.

Cannot use the webroot approach cause letencrypt doesn't support it for local ip address.

The [guide](https://www.reddit.com/r/FoundryVTT/comments/o9zz1u/setting_up_ssl_using_google_domains_not_cloud_w/) has more details
on how to do it.

Alternatively, [Making and trusting your own certificates](https://letsencrypt.org/docs/certificates-for-localhost/)

The simplest way to generate a private key and self-signed certificate for localhost is with this openssl command:

```
openssl req -x509 -out localhost.crt -keyout localhost.key \
-newkey rsa:2048 -nodes -sha256 \
-subj '/CN=localhost' -extensions EXT -config <( \
printf "[dn]\nCN=localhost\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:localhost\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")
```

You can then configure your local web server with localhost.crt and localhost.key, and install localhost.crt in your list of locally trusted roots.

If you want a little more realism in your development certificates, you can use `minica` to generate your own local root certificate, 
and issue end-entity (aka leaf) certificates signed by it. You would then import the root certificate rather than a self-signed end-entity certificate.

# Nginx proxy_pass for upstream  
```
location /api {
        rewrite ^/api/(.*)$ /$1 break;
        proxy_pass http://postgrest:3000/;
}   
```
Notice the ending slash in the proxy_pass. It is important.

# Nginx proxy_pass for upstream within the host network. 
use server `host.docker.internal` to access the host port from docker container.;
Note this only works on Docker Desktop not in production environment.


# export keycloak realm and user.

```
/opt/keycloak/bin/kc.sh export --dir /opt/keycloak/data/import --users realm_file --realm ttevents
```

# export keycloak realm public keys to postgrest

```
curl -o ./config/postgrest/keys.json https://tt.graceliu.uk/auth/realms/ttevents/protocol/openid-connect/certs
```

# postgres
