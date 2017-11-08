## Configurar o Postfix para enviar emails usando um servidor SMTP externo

Se for utilizar uma conta do gmail, é preciso habilitar os aplicativos menos seguros.  
Mais detalhes no link: https://support.google.com/accounts/answer/6010255?hl=pt-BR

### Atualizar e instalar dependências

```
apt-get update
apt-get install postfix mailutils libsasl2-modules

Durante a instalação vai abrir um prompt perguntando qual o tipo de configuração de email:
- Selecione Internet
- Digite 'localhost'
```
### Copiar os arquivos (main.cf, generic e sasl_passwd) para /etc/postfix

### Modificar o arquivo /etc/postfix/main.cf e alterar as linhas abaixo
```
myhostname = debian
relayhost = [smtp.dominio.com]:587
```

### Modificar o arquivo /etc/postfix/sasl_passwd com as credenciais
```
Exemplo:
[smtp.domain.com]:587 user@domain.com:password
```

### Modificar o arquivo /etc/postfix/generic com o email genérico para reescrever
```
Example:
root@debian.local       user@domain.com
```

### Verificar o arquivo /etc/mailname e caso esteja com problemas alterar para localhost
```
Example:
echo "localhost" > /etc/mailname
```

### Criar os hash's db's do Postfix com o comando postmap
```
postmap /etc/postfix/sasl_passwd
postmap /etc/postfix/generic
```

### Testar o envio de email
```
echo "OK" | mail -s "Testing mail postfix external SMTP" user@domain.com
```
