#!/bin/bash
clear
echo "list pools" | bconsole | grep "[+|\|]" 
read -p "Digite o nome da Pool que gostaria de excluir os volumes: " pool
echo "Pool selecionada: $pool"
echo ""
read -p "Digite o status dos volumes que gostaria de verificar (Error, Used, Full, Append, Recycled): " volstatus

arraysize=$(echo "list media pool=$pool" | bconsole  | grep "|" | grep -v "MediaId" | grep "$volstatus" | cut -d "|" -f3 | sed 's/ //g' | wc -l)
#volname=$(echo "list media pool=$pool" | bconsole  | grep "|" | grep -v "MediaId" | grep "$volstatus" | cut -d "|" -f3 | sed 's/ //g')
echo ""
for volname in $(echo "list media pool=$pool" | bconsole  | grep "|" | grep -v "MediaId" | grep "$volstatus" | cut -d "|" -f3 | sed 's/ //g'); do 
   #echo "delete volume=$volname pool=$pool yes" ;
   echo "$volname" ;
done
echo -e "Foram encontrados $arraysize volumes com o Status $volstatus\n"

read -p "Tem certeza que deseja excluir todos os $arraysize volumes? Esta operacao e irreversivel! (S-Sim/N-Nao)" confirm

if [ "$confirm" == "s" ] || [ "$confirm" == "S" ]; then
   for volname in $(echo "list media pool=$pool" | bconsole  | grep "|" | grep -v "MediaId" | grep "$volstatus" | cut -d "|" -f3 | sed 's/ //g'); do 
      echo "delete volume=$volname pool=$pool yes" ;
      # Descomentar a linha abaixo para efetuar a exclusão dos volumes no catálogo
      #echo "delete volume=$volname pool=$pool yes" | bconsole ;

      # Se precisar excluir fisicamente pode descomentar o comando abaixo
      # rm -f /backup/$volname
   done
   echo "Excluindo volumes..."
else
   echo "Operacao abortada!"
fi
