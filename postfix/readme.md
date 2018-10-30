## Configurar o Postfix para enviar emails usando um servidor SMTP externo

Se for utilizar uma conta do gmail, é preciso habilitar os aplicativos menos seguros.  
Mais detalhes no link: https://support.google.com/accounts/answer/6010255?hl=pt-BR

### Atualizar e instalar dependências

```
# Debian
apt-get update
apt-get install postfix mailutils libsasl2-modules

Durante a instalação vai abrir um prompt perguntando qual o tipo de configuração de email:
- Selecione Internet
- Digite 'localhost'

# CentOS
yum install postfix cyrus-sasl-plain
yum remove ssmtp
```
### Copiar os arquivos (main.cf, generic e sasl_passwd) para /etc/postfix

### Modificar o arquivo /etc/postfix/main.cf e alterar as linhas abaixo
```
myhostname = hostname_of_machine
relayhost = [smtp.domain.com]:587
```

### Modificar o arquivo /etc/postfix/sasl_passwd com as credenciais
```
Exemplo:
[smtp.domain.com]:587 sender@domain.com:password
```

### Modificar o arquivo /etc/postfix/generic com o email genérico para reescrever
```
Exemplo: (pode conter mais de uma linha)
root@hostname             sender@domain.com
root@hostname.local       sender@domain.com
```

### Modificar o arquivo /etc/postfix/sender_relay com o email do remetente
```
Example:
sender@domain.com.br   [smtp.domain.com.br]:587
```

### Verificar o arquivo /etc/mailname e caso esteja com problemas alterar para localhost
```
Example: (only for Debian)
echo "localhost" > /etc/mailname
```

### Criar os hash's db's do Postfix com o comando postmap
```
postmap /etc/postfix/sasl_passwd
postmap /etc/postfix/generic
postmap /etc/postfix/sender_relay
```

### Reiniciar o Postfix
```
systemctl restart postfix
```

### Testar o envio de email
```
echo "OK" | mail -s "Testing mail postfix external SMTP" someemail@domain.com
```

### Resolvendo Problemas
Em caso de erro é preciso checar os logs para maiores informações:
```
No CentOS:
tail -f /var/log/maillog

No Debian
tail -f /var/log/mail.log
```
