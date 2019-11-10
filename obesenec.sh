#Obesenec je vzdelávacia hra, ktorá učí nové slová alebo slovné spojenia a tak rozširuje slovnú zásobu a vedomosti. Cieľom hry je uhádnuť slovo (slovné spojenie) pričom máte iba obmedzený počet 
#chybných krokov. Zo slova poznáme začiatočné, koncové písmeno a celkový počet znakov. Ostatné písmena hádame stlačením klávesy pre daný znak. Každé správne uhádnuté písmeno sa zobrazí v 
#hľadanom slove. Pokiaľ zadáme nesprávny znak, pribudne dielik na šibenicu pre obesenca. Hra končí uhádnutím slova, alebo vybudovaním šibenice s obesencom.  

#Vytvorte jednoduchú bash aplikáciou ovládanú pomocou menu. Hru je možné prerušiť hru a znovu pokračovať. Po prerušení hry sa dostáva spať do menu. Pri spustení hry sa načíta náhodné slovíčko 
#zo slovníka (súbor/funkcia) a vykresli sa začiatočný stav šibenice spolu s počtom znakov ktoré hádame. Po stlačení znaku sa obrazovka prekresli. Akékoľvek rozšírenia – počítanie skóre, 
#modifikácie, rozšírenia levelov sú povolené.

#Náhodné číslo vieme získať pomocou $RANDOM. Príklad použitia: https://coderwall.com/p/s2ttyg/random-number-generator-in-bash
#Pracujte každý samostatne.
let skore
let chyby
let zivot

slova=(bratislava zilina "kysucke nove mesto")
slova_length=${#slova[*]}

let running=false
let slow_render

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
	slow_render=true

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

function echoif() {
	word=$1
	condition=$2

	if [ $slow_render == true ]
	then
		sleep .3
	fi

	if [ $condition == 1 ]
	then
		echo "$word"
	else
		echo ${word:0:1}
	fi
}


function vykresliHraciuPlochu() {
	echo   "____________"
	echoif "|          |"   $((zivot < 5))
	echoif "|          o"   $((zivot < 4))
	echoif "|         /|\\" $((zivot < 3))
	echoif "|          |"   $((zivot < 2))
	echoif "|         / \\" $((zivot < 1))
	echo   "|_____________"
	echo   "|             |"
	echo   "|             |"
	echo   "|_____________|"
	echo   "Skore: ${skore}  Zivot: ${zivot}    ${skore}/$((vybrane_slovo_length-vybrane_slovo_special_chars))     ${hadane_slovo}"
	slow_render=false
}

function spracujTah() {
	hladane_pismeno=$1
	if [ $1 == "!p" ]
	then
		return 22
	elif [ $1 == "!r" ]
	then
		init
		return
	fi

	multiplier=0
	for (( index=0; index < $vybrane_slovo_length; index++ ))
	do
		if [ "${vybrane_slovo:index:1}" == $hladane_pismeno ] && [  "${hadane_slovo:index:1}" == _ ]
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


function gameLoop() {
	while [ $running == true ]
	do
		clear
		vykresliHraciuPlochu
		let pismeno
		read -p "Zadaj pismeno:" pismeno
		spracujTah $pismeno

		if [ $? -eq 22 ]
		then
			break
		fi

		if [ $zivot -eq 0 ]
		then
			clear
			vykresliHraciuPlochu
			echo "Prehral si!"
			running=false
			break
		fi

		if [ $skore -eq $((vybrane_slovo_length-vybrane_slovo_special_chars)) ]
		then 
			clear
			vykresliHraciuPlochu
			echo "Vyhral si!"
			running=false
			break
		fi
	done

	startMenu
}

function startMenu() {
	echo "Obesenec ultimate"
	start_menu=()
	if [ $running == true ]
	then 
		start_menu+=("Pokracovat")
	fi
	start_menu+=(
		"Nova hra"
		"Pomoc"
		"Koniec"
	)

	PS3='Vyber akciu: '

	select option in "${start_menu[@]}"
	do    
		case $option in 
			"Pokracovat")
				gameLoop
				;;
			"Nova hra")
				init
				gameLoop
				break 
				;;
			"Pomoc")
				if [ $running == true ]
				then
					echo "Vyberom moznosti Pokracovat pokracujes v rozohranej hre"
				fi
				echo "Novu hru zapnes vyberom moznosti Nova hra"
				echo "V hre sa hadaju slova po jednom pismenku, pricom na zaciatku su zname len prve a posledne pismeno slova a jeho dlzka"
				echo "Hrac ma 5 zivotov a po vycerpani zivotov hra konci prehrou"
				echo "Po uhadnuti vsetkych pismen slova hra konci vyhrou"
				echo "ingame prikazy: "
				echo "!p -> pauza"
				echo "!r -> restart"
				echo "Vyberom moznosti Pomoc zobrazis tuto napovedu"
				echo "Vyberom moznosti Koniec ukoncis hru"
				;;
			"Koniec") 
				break ;;
		esac
	done
}

clear
startMenu