#!/bin/bash

# Colours
declare -r greenColour="\e[0;32m\033[1m"
declare -r endColour="\033[0m\e[0m"
declare -r redColour="\e[0;31m\033[1m"
declare -r blueColour="\e[0;34m\033[1m"
declare -r yellowColour="\e[0;33m\033[1m"
declare -r purpleColour="\e[0;35m\033[1m"
declare -r turquoiseColour="\e[0;36m\033[1m"
declare -r grayColour="\e[0;37m\033[1m"

# ctrl + c
trap ctrl_c INT


function ctrl_c() {
	echo -e "\n[-] Saliendo...\n"
	exit 1
}


function examples() {

	echo -e 'For nmap tcp scan:\n\tauto_recon -n -t -i 127.0.0.1 -o oN\n'
	echo -e 'For nmap udp scan:\n\tauto_recon -n -u -i 127.0.0.1 -o oN\n'
	echo -e 'For nmap version a default scripts scan:\n\tauto_recon -n -v -i 127.0.0.1 -p 22,25,53,80 -o oN\n'

}

function tcp_scan() {

	ip_address=$1
	export_format=$2

	# Escaneo tcp sobre la direccion indicada y el formato de exportacion indicado
	nmap -sS --min-rate 5000 -p- --open -vvv -n -Pn $ip_address $export_format allPorts
	echo "--------------------------------------------------------------------------------"
	getPorts allPorts
	echo "--------------------------------------------------------------------------------"

	echo -e "\n\n--------------Initializing vulnerabilities and version analysis--------------\n\n"

	# Automaticamente cuando termine el analisis anterior, realiza un analisis de las vulnerabilidades y version y servicios que corren sobre cada puerto
	open_ports=$(cat allPorts.tmp | tr -d '\n')
	nmap -sV -sC -p$open_ports $ip_address -oN openPorts
	
	# Si esta el puerto 80 entre los puertos abiertos realiza un http-enum de nmap
	echo $open_ports | tr ',' '\n' > openPorts.tmp
	while FS= read -r line; do
		if [ '$line' = '80' ]; then
			# Inicio el script http-enum
			nmap --script http-enum -p80 $ip_address -oN webScan
		fi
	done
	
	
}

#examples

while getopts "uti:po:v" arg; do
	case $arg in
		t) tcp_scan="yes";;
		u) udp_scan="yes";;
		h) help_panel="yes";;
		i) remote_ip=$OPTARG;;
		o) export_format=$OPTARG;;
	esac
done

if [ "$tcp_scan" ]; then
	echo -e "\n${yellowColour}-------------- Initializing tcp scan for $remote_ip as --> nmap -sS --min-rate 5000 -p- --open -n -Pn <ip> <export_format> allPorts --------------${endColour}\n"
	tcp_scan $remote_ip $export_format
fi


if [ "$udp_scan" ]; then
	echo -e "\n${yellowColour}-------------- Initializing udp scan for $remote_ip as --> nmap -sU --min-rate 10000 -p- --open -n -Pn $remote_ip $expor_format allPorts --------------${endColour}\n"
	udp_scan $remote_ip $export_format
fi

if [ "$help_panel" ]; then
	echo -e ""
fi






