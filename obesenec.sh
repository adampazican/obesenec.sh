#Obesenec je vzdelávacia hra, ktorá učí nové slová alebo slovné spojenia a tak rozširuje slovnú zásobu a vedomosti. Cieľom hry je uhádnuť slovo (slovné spojenie) pričom máte iba obmedzený počet 
#chybných krokov. Zo slova poznáme začiatočné, koncové písmeno a celkový počet znakov. Ostatné písmena hádame stlačením klávesy pre daný znak. Každé správne uhádnuté písmeno sa zobrazí v 
#hľadanom slove. Pokiaľ zadáme nesprávny znak, pribudne dielik na šibenicu pre obesenca. Hra končí uhádnutím slova, alebo vybudovaním šibenice s obesencom.  

#Vytvorte jednoduchú bash aplikáciou ovládanú pomocou menu. Hru je možné prerušiť hru a znovu pokračovať. Po prerušení hry sa dostáva spať do menu. Pri spustení hry sa načíta náhodné slovíčko 
#zo slovníka (súbor/funkcia) a vykresli sa začiatočný stav šibenice spolu s počtom znakov ktoré hádame. Po stlačení znaku sa obrazovka prekresli. Akékoľvek rozšírenia – počítanie skóre, 
#modifikácie, rozšírenia levelov sú povolené.

#Náhodné číslo vieme získať pomocou $RANDOM. Príklad použitia: https://coderwall.com/p/s2ttyg/random-number-generator-in-bash
#Pracujte každý samostatne.
let celkoveSkore
let skore
let chyby
let zivot

slova=("bratislava" "kosice" "presov" "zilina" "banska bystrica" "nitra" "trnava" "trencin" "martin" "poprad" "prievidza" "zvolen" "povazska bystrica" "michalovce" "nove zamky" "spisska nova ves" "komarno" "humenne" "levice" "bardejov" "liptovsky mikulas" "lucenec" "piestany" "ruzomberok" "topolcany" "trebisov" "cadca" "dubnica nad vahom" "rimavska sobota" "partizanske" "vranov nad toplou" "dunajska streda" "pezinok" "sala" "hlohovec" "brezno" "senica" "snina" "nove mesto nad vahom" "ziar nad hronom" "roznava" "senec" "dolny kubin" "banovce nad bebravou" "puchov" "malacky" "handlova" "kezmarok" "stara lubovna" "sered" "kysucke nove mesto" "galanta" "skalica" "detva" "levoca" "samorin" "sabinov" "revuca" "velky krtis" "myjava" "zlate moravce" "bytca" "moldava nad bodvou" "svidnik" "holic" "nova dubnica" "stupava" "filakovo" "stropkov" "kolarovo" "sturovo" "banska stiavnica" "surany" "tvrdosin" "velke kapusany" "stara tura" "modra" "krompachy" "vrable" "velky meder" "secovce" "krupina" "namestovo" "vrutky" "svit" "turzovka" "kralovsky chlmec" "liptovsky hradok" "hrinova" "hnusta" "hurbanovo" "nova bana" "trstena" "sahy" "tornala" "zeliezovce" "krasno nad kysucou" "medzilaborce" "spisska bela" "lipany" "turcianske teplice" "zarnovica" "nemsova" "sobrance" "gelnica" "velky saris" "vrbove" "rajec" "poltar" "dobsina" "svaty jur" "ilava" "gabcikovo" "kremnica" "sladkovicovo" "gbely" "sastin-straze" "sliac" "brezova pod bradlom" "bojnice" "medzev" "strazske" "turany" "novaky" "trencianske teplice" "tisovec" "leopoldov" "giraltovce" "vysoke tatry" "spisske podhradie" "hanusovce nad toplou" "cierna nad tisou" "tlmace" "spisske vlachy" "jelsava" "podolinec" "rajecke teplice" "spisska stara ves" "modry kamen" "dudince")
slova_length=${#slova[*]}

let running=false
let slow_render

let rand
let vybrane_slovo
let vybrane_slovo_length
let vybrane_slovo_special_chars
let hadane_slovo

function generujSlovo(){
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

function initRoundState() {
	skore=0
	running=true
	slow_render=true
}

function init() {
	celkoveSkore=0

	chyby=0
	zivot=5	

	initRoundState

	generujSlovo
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
	echo   "Skore: ${celkoveSkore}  Zivot: ${zivot}    ${skore}/$((vybrane_slovo_length-vybrane_slovo_special_chars))     ${hadane_slovo}"
	slow_render=false
}

function spracujTah() {
	hladane_pismeno=$1
	hladane_pismeno_length=${#hladane_pismeno}

	if [ "$1" == "!p" ]
	then
		return 22
	elif [ "$1" == "!r" ]
	then
		init
		return
	fi

	if [ $hladane_pismeno_length -gt 1 ] && [ "$hladane_pismeno" == "$vybrane_slovo" ] 
	then
		if [ $((vybrane_slovo_length-vybrane_slovo_special_chars-skore)) -gt $skore ]
		then
			((zivot++))
		fi
		((celkoveSkore+=(vybrane_slovo_length-vybrane_slovo_special_chars)-skore))
		((skore=vybrane_slovo_length-vybrane_slovo_special_chars))
		hadane_slovo=$vybrane_slovo
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
		((celkoveSkore=celkoveSkore+1*multiplier))
	else
		((zivot--))
	fi
}


function gameLoop() {
	while [ $running == true ]
	do
		clear
		vykresliHraciuPlochu
		read -p "Zadaj pismeno:" "pismeno"
		spracujTah "$pismeno"

		if [ $? -eq 22 ]
		then
			break
		fi

		if [ $zivot -eq 0 ]
		then
			clear
			hadane_slovo=$vybrane_slovo
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
	if [ $running == true ] || ( [ $running == false ]  && [ $zivot -gt 0 ] )
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
				if [ $running == false ]
				then
					initRoundState
					generujSlovo
				fi
				gameLoop
				break
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
				echo "Po uhadnuti vsetkych pismen slova hrac vyhral kolo a môže pokračovať v hre"
				echo "Ak hráč pozná odpoveď, mozee skusit uhadnut cele slovo. Ak uhadne viac ako polku slova naraz získa spať jeden zivot"
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