## Enviar mensagem do Bacula usando Telegram


### Criar um Bot no Telegram

```
Adicionar o usuário @BotFather para a sua conta do telegram ou acessar o endereço https://telegram.me/BotFather
e seguir os passos abaixo:
- /newbot - criar um novo bot
- Digitar um nome para o bot. Exemplo: Bacula Test Bot
- Digitar um nome de uusário para o bot. Precisar terminar com 'bot' Exemplo: (bacula_test_bot)

Anotar a chave da API (API KEY):
1234567890:AAFd2sDMplKGyoajsPWARnSOwa9EqHiy17U

Substituir na url com a chave da API
https://api.telegram.org/bot${API_KEY}/getUpdates
https://api.telegram.org/bot1234567890:AAFd2sDMplKGyoajsPWARnSOwa9EqHiy17U/getUpdates

Enviar uma mensagem para o BOT, abrir o browser e colar a URL obtida.
Você vai receber uma saída no formato JSON, pegar o valor do 'id'.

{"ok":true,"result":[{"update_id":565543449,
"message":{"message_id":3,"from":{"id":123456789,"first_name":"Some Name","last_name":"Some Last Name",
"username":"someusername"},"chat":{"id":123456789,"first_name":"Some Name","last_name":"Some Last Name",
"username":"someuser","type":"private"},"date":1472165730,"text":"hello"}}]}
```

### Incluir o parâmetro "RunsScript" na configuração do JobDefs no arquivo bacula-dir.conf

```
JobDefs {
   ...
   RunScript {
     Command = "/etc/bacula/scripts/_send_telegram.sh %i"
     RunsWhen = After
     RunsOnFailure = yes
     RunsOnClient = no
     RunsOnSuccess = yes # default, you can drop this line
  }
}
```

### Incluir o parâmetro "dbdriver" na configuração do Catálogo no arquivo bacula-dir.conf
```
Catalog {
   ...
   dbdriver = "mysql" ou dbdriver = "pgsql"
   ...
}

```

### Instalar dependências

```
### Debian ###
apt-get install curl bc

### CentOS ###
yum -y install curl bc
```
