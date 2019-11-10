#Obesenec je vzdelávacia hra, ktorá učí nové slová alebo slovné spojenia a tak rozširuje slovnú zásobu a vedomosti. Cieľom hry je uhádnuť slovo (slovné spojenie) pričom máte iba obmedzený počet chybných krokov. Zo slova poznáme začiatočné, koncové písmeno a celkový počet znakov. Ostatné písmena hádame stlačením klávesy pre daný znak. Každé správne uhádnuté písmeno sa zobrazí v hľadanom slove. Pokiaľ zadáme nesprávny znak, pribudne dielik na šibenicu pre obesenca. Hra končí uhádnutím slova, alebo vybudovaním šibenice s obesencom.  

#Vytvorte jednoduchú bash aplikáciou ovládanú pomocou menu. Hru je možné prerušiť hru a znovu pokračovať. Po prerušení hry sa dostáva spať do menu. Pri spustení hry sa načíta náhodné slovíčko zo slovníka (súbor/funkcia) a vykresli sa začiatočný stav šibenice spolu s počtom znakov ktoré hádame. Po stlačení znaku sa obrazovka prekresli. Akékoľvek rozšírenia – počítanie skóre, modifikácie, rozšírenia levelov sú povolené.

#Náhodné číslo vieme získať pomocou $RANDOM. Príklad použitia: https://coderwall.com/p/s2ttyg/random-number-generator-in-bash
#Pracujte každý samostatne.
let skore
let chyby
let zivot

slova=(bratislava zilina "kysucke nove mesto")
slova_length=${#slova[*]}

let running

let rand
let vybrane_slovo
let vybrane_slovo_length
let vybrane_slovo_special_chars
let hadane_slovo


function init() {
	skore=0
	chyby=0
	zivot=5	
	running=true

	rand=$(( $RANDOM % $slova_length ))
	vybrane_slovo=${slova[$rand]}
	vybrane_slovo_length=${#vybrane_slovo}
	vybrane_slovo_special_chars=2
	hadane_slovo=""

	for (( index=0; index < $vybrane_slovo_length; index++ ))
	do
		if [ $index -eq 0 ] || [ $index -eq $(( vybrane_slovo_length - 1 )) ]
		then
			hadane_slovo+=${vybrane_slovo:index:1}
		elif [ "${vybrane_slovo:index:1}" == " " ]
		then
			hadane_slovo+=" "
			((vybrane_slovo_special_chars++))
		else
			hadane_slovo+=_
		fi
	done

}



function vykresliHraciuPlochu() {
	echo "____________"
	echo "|          |"
	echo "|"
	echo "|"
	echo "|"
	echo "|"
	echo "|"
	echo "|"
	echo "|_____________"
	echo "|             |"
	echo "|             |"
	echo "|_____________|"
	echo "Skore: ${skore}  Zivot: ${zivot}    ${skore}/$((vybrane_slovo_length-vybrane_slovo_special_chars))     ${hadane_slovo}"
}

function spracujTah() {
	hladane_pismeno=$1
	if [ $1 == h ]
	then
		echo helpscreen 
	elif [ $1 == r ]
	then
		init
	fi

	multiplier=0
	for (( index=0; index < $vybrane_slovo_length; index++ ))
	do
		if [ ${vybrane_slovo:index:1} == $hladane_pismeno ] && [  ${hadane_slovo:index:1} == _ ]
		then
			((multiplier++))
			hadane_slovo="${hadane_slovo:0:index}$hladane_pismeno${hadane_slovo:index+1}"
		fi
	done

	if [ $multiplier -gt 0 ]
	then
		((skore=skore+1*multiplier))
	else
		((zivot--))
	fi
}

init

while [ running=true ]
do
	clear
	vykresliHraciuPlochu
	let pismeno
	read -p "Zadaj pismeno:" pismeno
	spracujTah $pismeno

	if [ $zivot -eq 0 ]
	then
		echo "Prehral si!"
		break
	fi

	if [ $skore -eq $((vybrane_slovo_length-vybrane_slovo_special_chars)) ]
	then 
		echo "Vyhral si!"
		clear
		vykresliHraciuPlochu
		break
	fi
done


