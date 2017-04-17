## Configure Postfix to send mail using an external SMTP server


### Update and Install dependencies

```
apt-get update
apt-get install postfix mailutils libsasl2-modules

During the installation, a prompt will appear asking for your general type of mail configuration.
- Select Internet
- Type 'localhost'
```
### Copy the files (main.cf, generic and sasl_passwd) to /etc/postfix

### Modify the file /etc/postfix/main.cf and change the following lines
```
myhostname = debian   # CHANGE ME
relayhost = [smtp.domain.com]:587 # CHANGE ME
```

### Modify the file /etc/postfix/sasl_passwd with your mail credentials
```
Example:
[smtp.domain.com]:587 user@domain.com:password
```

### Modify the file /etc/postfix/generic with your generic mail rewrite
```
Example:
root@debian.local       user@domain.com
```

### Create the hash db file for Postfix by running the postmap command
```
postmap /etc/postfix/sasl_passwd
postmap /etc/postfix/generic
```

### Test mail send
```
echo "OK" | mail -s "Testing mail postfix external SMTP" user@domain.com
```
