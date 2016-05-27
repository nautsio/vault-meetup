<!-- .slide: data-background="#6C1D5F" -->
<center><div style="width: 75%; height: auto;"><img src="img/xebia.svg"/></div></center>
<br />
<center>
<table>
  <tr>
    <td>**Armin Coralic**</td><td>*[acoralic@xebia.com](mailto:acoralic@xebia.com)*</td>
  </tr>
  <tr>
    <td>**Ivo Verberk**</td><td>*[iverberk@xebia.com](mailto:iverberk@xebia.com)*</td>
  </tr>
  <tr>
    <td>**Werner Buck**</td><td>*[wbuck@xebia.com](mailto:wbuck@xebia.com)*</td>
  </tr>
  <tr><td>&nbsp;</td></tr>
  <tr>
    <td>**Slides**</td><td>[http://nauts.io/vault-meetup](http://nauts.io/vault-meetup)</td>
  </tr>
  <tr>
    <td>**Files**</td><td>[http://github.com/nautsio/vault-meetup](http://github.com/nautsio/vault-meetup)</td>
  </tr>
</table>
</center>

!SLIDE
<!-- .slide: data-background="#6C1D5F" -->
<center>![Vault](img/vault-logo.png)</center>

!SLIDE
# Vault
Vault is a tool for **securely** accessing secrets. A **secret** is anything that 
you want to tightly control access to, such as API keys, passwords, certificates, and more. 
Vault provides a **unified interface** to any secret, while providing **tight access control** 
and recording a detailed **audit log**.

!SUB
# Without Vault
- More and more secrets
- Secrets all over the place
- No insight who uses which secret
- No procedure in case something bad happens

!SUB
# With Vault
- Centralized source for secrets
- Unified access interface
- Pluggable backends

!SUB
# Architecture
<center><div style="width: 75%; height: auto;"><img src="img/vault-architecture.png"/></div></center>

!SUB
# (Un)sealing the Vault
<center><div style="width: 75%; height: auto;"><img src="img/keys.png"/></div></center>

!SLIDE
<!-- .slide: data-background="#6C1D5F" -->
# Backends

!SUB
# Storage Backend
A storage backend is responsible for durable storage of encrypted data. Backends 
are not trusted by Vault and are only expected to provide durability. The storage 
backend is configured when starting the Vault server.

!SUB
# Secret Backend
A secret backend is responsible for managing secrets. Simple secret backends like 
the "generic" backend simply return the same secret when queried. Some backends 
support using policies to dynamically generate a secret each time they are queried.

!SUB
# Auth Backend
Auth backends are the components in Vault that perform authentication and are 
responsible for assigning identity and a set of policies to a user.

!SUB
# Audit Backend
Audit backends are the components in Vault that keep a detailed log of all requests 
and response to Vault.

!SLIDE
<!-- .slide: data-background="#6C1D5F" -->
# Start Workshop

!SLIDE
<!-- .slide: data-background="#6C1D5F" -->
# The Setup
Download the appropriate Vault binary for your platform and add it to your PATH 
so that it can be accessed from anywhere:
<br/>
<br/>
<center>
[Vault Downloads](https://www.vaultproject.io/downloads.html)<br>
[Set PATH on Linux](https://stackoverflow.com/questions/14637979/how-to-permanently-set-path-on-linux)<br>
[Set PATH on Windows](https://stackoverflow.com/questions/1618280/where-can-i-set-path-to-make-exe-on-windows)<br>
</center>

!SUB
# Start vault server
We're going to start the Vault server in dev mode. The dev server is a built-in 
flag to start a pre-configured server that is not very secure but useful for playing 
with Vault locally.
```
$ vault server -dev
==> WARNING: Dev mode is enabled!
...
```
With the dev server running, do the following three things:

1. Copy the export VAULT_ADDR=... command from your terminal output and run it 
in a **different** terminal window. This will configure the Vault client to talk to the dev server.
2. Save the unseal key somewhere. 
3. Do the same as step 2, but with the root token. 

!SUB
# Check the Vault server
Verify the server is running by running ```vault status```.  If it ran successfully, 
the output should look like below:

```
$ vault status
Sealed: false
Key Shares: 1
Key Threshold: 1
Unseal Progress: 0

High-Availability Enabled: false
```
If you see an error about opening a connection, make sure you copied and executed 
the export VAULT_ADDR=... command from above properly.

!SLIDE
<!-- .slide: data-background="#6C1D5F" -->
# Secrets and Policies

!SUB
# Writing secrets

```
$ vault write secret/hello value=world foo=bar
```
This writes the pairs *value=world* and *foo=bar* to the path secret/hello. The secret/ 
prefix is where arbitrary secrets can be read and written.

```
$ echo -n '{"value":"itsasecret"}' | vault write secret/password -
$ echo -n "itsasecret" | vault write secret/password value=-
```
This first command writes the pair *value=itsasecret* the path secret/password
via a full JSON object. The second command writes to the same path but it specifies
the key via the command and the JSON value through stdin.

!SUB
# Reading secrets
Data can be read using vault read. This command is very simple:

```
$ vault read secret/password
Key             Value
lease_id        secret/password/76c844fb-aeba-a766-0a50-2b907072233a
lease_duration  2592000
value           itsasecret
```
You can use the -format flag to get various different formats out from the command. Some formats are easier to use in different environments than others.

You can also use the -field flag to extract an individual field from the secret data.

```
$ vault read -field=value secret/password
itsasecret
```

!SUB
# Deleting secrets

Now that we've learned how to read and write a secret, let's go ahead and delete 
it. We can do this with vault delete:

```
$ vault delete secret/password
Success! Deleted 'secret/password'
```

!SUB (Ivo)
# Policies

* token-create
* policy maken

!SLIDE
<!-- .slide: data-background="#6C1D5F" -->
# Authentication

!SUB
# Authentication: Username & Password
Token authentication is great but if you want to allow users to connect without much effort then the "userpass" combination is a nice way. The "userpass" auth backend allows users to authenticate with Vault using a username and password combination.

To use it we need to enable it
```
vault auth-enable userpass
Successfully enabled 'userpass' at 'userpass'!
```

doc: [auth/userpass.html](https://www.vaultproject.io/docs/auth/userpass.html)

!SUB
We can see which auth backends are enabled
```
vault auth -methods
Path       Type      Description
token/     token     token based credentials
userpass/  userpass
```

Let's create a username & password to authenticate to Vault with root policies instead of using an token
```
vault write auth/userpass/users/meetup password=1234 policies=root
Success! Data written to: auth/userpass/users/meetup
```

Now we can log in with that username & password
```
vault auth -method=userpass username=meetup password=1234
Successfully authenticated!
token: a6e9151d-da97-a3c9-172c-ec3e62aa2d96
token_duration: 0
token_policies: [root]
```

!SLIDE
<!-- .slide: data-background="#6C1D5F" -->
# Recap and next section
# 

!SLIDE
<!-- .slide: data-background="#6C1D5F" -->
# Dynamic Secrets

!SUB
# PostgreSQL Secret backend
The PostgreSQL backend is __dynamic__, meaning secrets are generated when they are accessed.
Vault will connect to PostgreSQL and create an user that will expire.

To use the PostgreSQL secret backend we need to mount it:
```
$ vault mount postgresql
Successfully mounted 'postgresql' at 'postgresql'!
```

Also, let's launch a PostgreSQL server in the background: 
```
$ docker run --name vault-meetup-postgres -e POSTGRES_PASSWORD=shoehorse \
 -p "5432:5432" -d postgres
$ telnet $(docker-machine ip) 5432 # verify you can
```
doc: [secrets/postgresql/](https://www.vaultproject.io/docs/secrets/postgresql/)


!SUB

Let's specify a connecting string so that Vault can connect to PostgresSQL.

```
$ vault write postgresql/config/connection \
    connection_url="postgresql://postgres:shoehorse@$D_IP:5432/postgres?sslmode=disable"
Success! Data written to: postgresql/config/connection
```

The next step is to configure a role. A role is a logical name that maps to a policy 
used to generated those credentials. For example, lets create a "readonly" role:

```
$ vault write postgresql/roles/readonly \
    sql="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';
    GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";"
Success! Data written to: postgresql/roles/readonly
```
Note: more complex GRANT queries can be used to further customize privileges of the role

!SUB

Let's request some PostgreSQL credentials.

```
$ vault read postgresql/creds/readonly
Key            	Value
lease_id       	postgresql/creds/readonly/f2682645-f8cd-dd93-8f3f-427b97707ea4
lease_duration 	2592000
lease_renewable	true
password       	$PASSWORD
username       	$USER
```
The $USER and $PASSWORD will be generated dynamically by Vault. Lets try to connect 
using an interactive container running `psql`:

```
$ docker run -it --rm --link vault-meetup-postgres:postgres postgres \
  psql -h postgres -U $USER -d postgres
```

Enter the $PASSWORD to fully authenticate with PostgreSQL. In psql try **\du**
to list the current users. Perhaps also try to tweak the lease time for new users:
```
$ vault write postgresql/config/lease lease=1h lease_max=24h
```


!SUB
# Transit secret backend
The transit secret backend is used to encrypt/decrypt data in-transit. Vault doesn't store the data sent to the backend. It can also be viewed as "encryption as a service."
The primary use case for the transit backend is to encrypt data from applications while still storing that encrypted data in some primary data store.

To use the transit secret backend we need to mount it
```
$ vault mount transit
Successfully mounted 'transit' at 'transit'!
```

doc: [secrets/transit/index.html](https://www.vaultproject.io/docs/secrets/transit/index.html)

!SUB
After mounting the transit secret backend we need to create a "named encryption key" that can be referenced and used by other applications with independent keys.
```
vault write -f transit/keys/vault-meetup
Success! Data written to: transit/keys/vault-meetup
```

What have we created
```
vault read transit/keys/vault-meetup
Key                     Value
cipher_mode             aes-gcm
deletion_allowed        false
derived                 false
keys                    map[1:1.463208292e+09]
latest_version          1
min_decryption_version  1
name                    vault-meetup
```

!SUB
It's time to actually encrypt something, you can encrypt any data as long as it is base64 encoded. In our case let's encrypt a sentence.
```
echo -n "I am at the Vault meetup" | base64 | vault write transit/encrypt/vault-meetup plaintext=-
Key         Value
ciphertext  vault:v1:o20swhyIdj+DyEAMHQ+1EIlwwN/jKTy/TGA3zDAoXXWHMTxQHKDBZPtBdb7Tj0lLaun9gA==
```

Now let's see try to decrypt it
```
vault write transit/decrypt/vault-meetup ciphertext=vault:v1:o20swhyIdj+DyEAMHQ+1EIlwwN/jKTy/TGA3zDAoXXWHMTxQHKDBZPtBdb7Tj0lLaun9gA==
Key       Value
plaintext SSBhbSBhdCB0aGUgVmF1bHQgbWVldHVw

echo "SSBhbSBhdCB0aGUgVmF1bHQgbWVldHVw" | base64 -D
I am at the Vault meetup
```

!SUB
We can also rotate the key, meaning we can encrypt with a new key but we can decrypt with both keys
```
vault write -f transit/keys/vault-meetup/rotate
Success! Data written to: transit/keys/vault-meetup/rotate

echo -n "Hallo" | base64 | vault write transit/encrypt/vault-meetup plaintext=-
Key         Value
ciphertext  vault:v2:7XTo4TQW+15zRMXA2NED2b8b7Tqrjhc2FVeAaSCbAISP

vault read transit/keys/vault-meetup
Key                     Value
cipher_mode             aes-gcm
deletion_allowed        false
derived                 false
keys                    map[1:1.463208292e+09 2:1.463208919e+09]
latest_version          2
min_decryption_version  1
name                    vault-meetup
```

It is also posible to update the encrypted data to the new key without ever seeing the decryted text
```
vault write transit/rewrap/vault-meetup ciphertext=vault:v1:o20swhyIdj+DyEAMHQ+1EIlwwN/jKTy/TGA3zDAoXXWHMTxQHKDBZPtBdb7Tj0lLaun9gA==
Key         Value
ciphertext  vault:v2:ZruZRACkqXq+DrU0LF3u67s898l1qyqYiCXP2Sj41tMyjU4KUipQextfsDOc+kwIlq2fkg==
```  

!SUB
# Cubbyhole backend
The cubbyhole secret backend is used to store arbitrary secrets within the configured physical storage for Vault.

This backend differs from the generic backend in that the generic backend's values are accessible to any token with read privileges on that path. In cubbyhole, paths are scoped per token; no token can access another token's cubbyhole, whether to read, write, list, or for any other operation. When the token expires, its cubbyhole is destroyed.

doc: [secrets/cubbyhole/index.html](https://www.vaultproject.io/docs/secrets/cubbyhole/index.html)

!SUB
Passing an token to an application that can ask for database access could be sniffed, to make that more save we can store the actual token in cubbyhole and then generate a new token with limited access times that can retrieve that token. If the application can retrieve the token all is fine and cubbyhole is gone, if it can't we know something happened with the token and we need to act.

Let's create a token with limited use
```
vault token-create -use-limit=3


vault token-lookup 8dab6a3b-e8f3-c531-ed0d-34eda8398de5
Key           Value
......
num_uses      3
```

!SUB
Now that we have a token let's add something to cubbyhole and see what happens
```
vault auth 8dab6a3b-e8f3-c531-ed0d-34eda8398de5
Successfully authenticated!

vault write cubbyhole/my-app actual-token=1234
Success! Data written to: cubbyhole/my-app

vault read cubbyhole/my-app
Key           Value
actual-token  1234
```

Reading the value again
```
vault read cubbyhole/my-app
Error reading cubbyhole/my-app: Error making API request.

URL: GET http://127.0.0.1:8200/v1/cubbyhole/my-app
Code: 403. Errors:

* permission denied
```

!SLIDE
<!-- .slide: data-background="#6C1D5F" -->
# Advanced

!SUB
# SSH (Armin)

!SUB
# Github (Werner)

!SLIDE
<!-- .slide: data-background="#6C1D5F" -->
<center>![HashiConf](img/hashiconf.png)</center>
Want to hear **best practices** and the **latest news** about Vault and other HashiCorp products?

TODO: CODE

Come to **HashiConf EU the 13th-15th of June**!
