#!/bin/bash

# gets if the ip command exists
ip_command=$(type -P ip &>/dev/null && echo true || echo false)

# if ip suite isn't installed
if [ "$ip_command" == false ]
then
	# gets if the ifconfig command exists
	ip_command=$(type -P ifconfig &>/dev/null && echo true || echo false)
	# if the ifconfig is false then
	if [ "$ip_command" == false ]
	then
		# print an apropriate message
		echo "Neither IP suite and ifconfig are installed. Can't Proceed"
		# return error code
		exit 255
	fi
fi

# checks if the mac is a valid one
check_mac () {
	mac="$1"
	IFS=':' read -ra mac_array <<< "$mac"

	# if the length of the array isn't exact 6 (a full MAC) then return
		# 0
	if [[ ${#mac_array[@]} != 6 ]]
	then
		return 0
	fi

	for i in "${mac_array[@]}"
	do
		# if this fails then it's not a hex value
		(( 16#$i)) &> /dev/null
		# if it's not the correct length then return
		if [[ ${#i} != 2 ]]
		then
			return 255
		fi
	done

	return 1
}

# checks if a given oui is valid
check_oui () {
	oui="$1"
	IFS=':' read -ra oui_array <<< "$mac"
	# if the length of the oui isn't correct then
	if [[ ${#oui_array[@]} != 3 ]]
	then
		return 0
	fi
	for i in "${oui_array[@]}"
	do
		# if this fails then it's not a hex value
		(( 16#$i)) &> /dev/null
		# if it's not the correct length then return
		if [[ ${#i} != 2 ]]
		then
			return 255
		fi
	done
	return 1
}

# sets the given MAC
set_mac () {
	ip_command="$1"
	address="$2"
	if [ "$ip_command" == true ]; then
		# requires root access for these commands
        # disables the interface
		eval [ip link set dev "${interface}" down]
        # sets the new address
		eval [ip link set dev "${interface}" address "${address}"]
        # reenables the interface
		eval [ip link set dev "${interface}" up]
	else
        # disables the interface
		eval [ifconfig "${interface}" down]
        # sets the new address
		eval [ifconfig "${interface}" hw ether "${address}"]
        # reenables the interface
		eval [ifconfig "${interface}" up]
	fi
}

print_help_and_exit () {
	echo "Usage: randomac.sh -i <interface> [OPTIONS] "
	echo
	echo "The Script Needs Root Priviledges to Run"
	echo "OPTIONS:"
    echo "    -i|--interface"
	echo "        Sets the interface to change the MAC address. This"
	echo "        option is required"
	echo "    -r|--random-oui"
	echo "        Sets a completely random oui. This is default behaviour"
	echo "    -m|--mac <MAC>"
	echo "        Sets the given MAC as the interface MAC"
	echo "    -o|--oui <OUI>"
	echo "        Sets the given OUI as the OUI of the random MAC"
	echo "    -v|--vendor <Vendor>"
	echo "        Select the OUI of a specific vendor"
	echo "        Available Vendors are:"
	echo "        Intel, Dell, Alpha Networks, TP-Link"
	echo "    -V|--random-vendor"
	echo "        Sets a random vendor from the list"
	echo "No Interface Given"
	exit 255
}

# prints a help message if no arguments are given
if [ $# -eq 0 ]; then
	print_help_and_exit
fi

# if the program isn't run with root priviledges it can't change the MAC
if [ "$EUID" -ne 0 ]; then
	echo "Not run with root priviledges"
	exit 255
fi

interface=""
random_oui=1
random_vendor=0
mac=""
vendor=""

# argument parsing
while [[ $# -gt 0 ]]; do
	key="$1"
	case $key in
        # TODO implement
		-r|--random-oui)
			random_oui=1
			shift # past argument
			;;
		-m|--mac)
			mac="$2"
			shift # past argument
			shift # past value
			;;
		-o|--oui)
			oui="$2"
			random_oui=0
			shift # past argument
			shift # past value
			;;
		-v|--vendor)
			vendor="$2"
			random_oui=0
			shift # past argument
			shift # past value
			;;
		-V|--random-vendor)
			random_vendor=1
			random_oui=0
			shift # past argument
			;;
		-i|--interface)
			interface="$2"
			shift
			shift
			;;
		-h|--help)
			print_help_and_exit
			shift
			shift
			;;
		--default)
			DEFAULT=YES
			shift # past argument
			;;
		*)    # unknown option
			POSITIONAL+=("$1") # save it in an array for later
			shift # past argument
			;;
	esac
done

# if no interface is given
if [ "$interface" == "" ]
then
	# print appropriate message
	echo "No inteface given"
	# exit with code -1 (255)
	exit 255
fi

#if a custom mac was given
if [ "$mac" != "" ]; then
	# test the MAC
	result=$(check_mac "$mac")
	# if the MAC is not valid
	if [ "$result" == "" ];
	then
		echo "Incorrect MAC Given"
		exit 255
	fi
	# sets the MAC using the function
	set_mac "$ip_command" "$mac"
elif [ "$oui" != "" ]; then
	# test the MAC
	result=$(check_oui "$oui")
	# if the OUI is not valid
	if [ "$result" == "" ];
	then
		echo "Incorrect OUI Given"
		exit 255
	fi
fi

# if no oui was given
if [ "$oui" == "" ] ; then
    # if no vendor was given and no random vendor was requested
	if [ "$vendor" == "" ] && [ "$random_vendor" != 1 ]; then
		# gets 8 random bits and discards the two rightmost bits
        random=$(od -A n -t d -N 1 /dev/urandom | tr -d ' ' )
		# integer to hex
		hexval=$(printf "%x" "$random")
		# gets the first byte of the new mac
		address="${hexval}"
		for number in 1 2
			do
            # gets a random 8 bit number
			random=$((RANDOM % 256))
            # gets the random hexadecimal value 
			hexval=$(printf "%02x" "$random")
            # concatenates it to the address
			address="${address}:${hexval}"
		done
	# if a vendor was provided or a random one requested
	elif [ "$vendor" != "" ] || [ "$random_vendor" == 1 ]; then
		# gets the ouis from the file
		source ouis.sh
        
		# chooses a random vendor
		if [ "$random_vendor" == 1 ] ; then
			# non uniform distribution probably
			random=$((RANDOM % ${#vendors[@]} ))
			vendor="${vendors[$random]}"
		fi
		# for every vendor
		case "$vendor" in
			intel)
				random=$((RANDOM % ${#intel_ouis[@]}))
				oui="${intel_ouis[$random]}"
				;;
			tplink)
				random=$((RANDOM % ${#tplink_ouis[@]}))
				oui="${tplink_ouis[$random]}"
				;;
			alpha)
				random=$((RANDOM % ${#alpha_ouis[@]}))
				oui="${alpha_ouis[$random]}"
				;;
			dell)
				random=$((RANDOM % ${#dell_ouis[@]}))
				oui="${dell_ouis[$random]}"
				;;
			default)
				echo "Specified Vendor not Found or Vendor not Given"
				exit 255
				;;
			esac
			address="$oui"
	fi
else
    address="$oui"
fi

# gets the rest of the MAC
for number in 1 2 3
do
	# gets 1 random byte
	random=$((RANDOM & 16#ff)) # from 0 to 255 (1 byte)
	# random=$((od -A n -t d -N 1 /dev/urandom | tr -d ' '))
	# translates that to hex with zero prefix
	hexval=$(printf "%02x" "$random")
	# forms the new address
	address="${address}:${hexval}"
done
echo "$address"
set_mac "$ip_command" "$address"
