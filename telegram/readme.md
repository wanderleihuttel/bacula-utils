## Enviar mensagem do Bacula usando Telegram


### Criar um Bot no Telegram

```
Adicionar o usuário @BotFather para a sua conta do telegram ou acessar o endereço https://telegram.me/BotFather
e seguir os passos abaixo:
- /newbot - criar um novo bot
- Digitar um nome para o bot. Exemplo: Bacula Test Bot
- Digitar um nome de uusário para o bot. Precisar terminar com 'bot' Exemplo: (bacula_test_bot)

Anotar o token da API (API TOKEN):
1234567890:AAFd2sDMplKGyoajsPWARnSOwa9EqHiy17U

Substituir na url abaixo o valor "@@API_TOKEN@@" pelo token da API
https://api.telegram.org/bot@@API_TOKEN@@/getUpdates
https://api.telegram.org/bot1234567890:AAFd2sDMplKGyoajsPWARnSOwa9EqHiy17U/getUpdates

Enviar uma mensagem para o BOT pelo aplicativo do telegram, por exemplo "HELLO_BOT"
Abrir o browser e colar a URL obtida anteriormente 
Você vai receber uma saída no formato JSON, pegar o valor do 'id' da linha que contém a mensagem enviada anteriomente, que no exemplo acima era "HELLO_BOT"

{"ok":true,"result":[{"update_id":565543449,
"message":{"message_id":3,"from":{"id":123456789,"first_name":"Some Name","last_name":"Some Last Name",
"username":"someusername"},"chat":{"id":123456789,"first_name":"Some Name","last_name":"Some Last Name",
"username":"someuser","type":"private"},"date":1472165730,"text":"HELLO_BOT"}}]}

Agora informe os valores do token da API e o id do usuário no script:
api_token="change_with_your_api_key"
id="change_with_your_user_id"
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
   dbdriver = "MySQL" ou dbdriver = "PostgreSQL"
   ...
}

```

### Instalar dependências

```
### Debian ###
apt-get install curl bc coreutils

### CentOS ###
yum -y install curl bc coreutils
```
