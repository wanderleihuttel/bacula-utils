## Send bacula messages using telegram:


### Create a Telegram Bot 

```
Add the user @BotFather to your telegram account or access the address https://telegram.me/BotFather 
and follow the steps below:
- /newbot - create a new bot
- Type a name for your bot. Example: Bacula Test Bot
- Type a username for your bot. It must end in 'bot' Example: (bacula_test_bot)

Get the API KEY:
1234567890:AAFd2sDMplKGyoajsPWARnSOwa9EqHiy17U

- Replace the url with your API KEY
https://api.telegram.org/bot${API_TOKEN}/getUpdates
https://api.telegram.org/bot1234567890:AAFd2sDMplKGyoajsPWARnSOwa9EqHiy17U/getUpdates

Open in browser the URL. You will receive a JSON output, get the 'id' value.

{"ok":true,"result":[{"update_id":565543449,
"message":{"message_id":3,"from":{"id":123456789,"first_name":"Some Name","last_name":"Some Last Name",
"username":"someusername"},"chat":{"id":123456789,"first_name":"Some Name","last_name":"Some Last Name",
"username":"someuser","type":"private"},"date":1472165730,"text":"hello"}}]}
```
### Fill the fields in scripts

```
DBHOST="localhost"
DBPORT="localhost"
DBNAME="bacula"
DBUSER="bacula"
DBPASSWD="bacula"

In postgresql is possible to create a file in home folder called ".pgpass" with the following content:
(need replacement with correct values)
hostname:port:database:username:password

Set permission only for the owner
chmod 600 ~/.pgpass
```


### Add a RunsScript in JobDefs Resource

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


### Install dependencies

```
apt-get install curl
```
