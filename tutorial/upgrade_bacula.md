## Dicas de como efetuar o upgrade do Bacula
1. Force a parada do Bacula (pkill -9 bacula) (tenha certeza que nenhum backup esteja sendo executado)

2. Efetuar um backup do banco de dados do Bacula (executar o script padrão de backup do Bacula, geralmente 
"/etc/bacula/scripts/make_catalog_backup.pl MyCatalog". Copiar em um local seguro o arquivo gerado pelo script.

3. Faça um backup da pasta de configuração do Bacula, geralmente /etc/bacula

4. Se o seu bacula foi instalado via pacotes, é interessante remover todos os pacotes referentes ao Bacula. 
Utilizar o comando: **"apt-get remove nomepacote"**

5. Se o bacula foi instalado via compilação, é interessante utiizar as mesmas opções utilizadas no **"./configure"**

6. Efetuar o download do código fonte, e proseguir como se fosse uma instalação nova

7. Copiar os arquivos de configuração (*.conf) do backup do para o /etc/bacula

8. Verificar se os caminhos que foram informados na compilação são iguais aos da configuração anterior, senão, precisa editar os arquivos, e alterar estes caminhos.

9. Rodar o script para atualizar o banco de dados do Bacula (geralmente **update_bacula_tables** ou **update_mysql_tables** ou **update_postgresql_tables**

10. Executar os comandos de testes dos daemons e certificar-se que não possuem erros de configuração. **bacula-dir -t**, **bacula-sd -t** e **bacula-fd-t**

11. Iniciar o bacula e executar o bconsole

11. Seja Feliz


Em caso de erros é preciso executar o Bacula em modo debug e verificar possíveis erros. As vezes é interessante rodar um **pkill -9** para parar todos os daemons do bacula, e iniciar cada daemon separado, com a opção de debug (-d 500).
**bacula-dir -d 500**, **bacula-sd -d 500**, **bacula-fd -d 500**
