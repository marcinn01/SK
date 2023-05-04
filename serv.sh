#!/bin/bash

PID_FILE="./serv.pid"					#zmienna przechowująca identyfikator procesu

#Pomocnicza funkcja start_proces powtarzająca się funkcji start_server
#Jeżeli podany proces jest plikiem wykonywalnym - zostaje on uruchomiony, a jego PID zapisane do pliku PID_FILE 
function start_proces() {
	echo "Server zostal uruchomiony."
	if [ -x  skrypt.sh -a -f skrypt.sh ]
	then
		./skrypt.sh &
	fi
	echo "$!" > "$PID_FILE"				#zapisanie PID do pliku PID_FILE
}

#Uruchamiamy server: 
#	1) sprawdzamy czy plik PID_FILE istnieje - jeżeli tak przechodzimy do 2; w przeciwnym razie sprawdzamy czy proces jest plikiem wykonywalnym,
#	   jeżeli tak - uruchamiamy go i zapisujemy jego PID do pliku PID_FILE; jeżeli nie - wyświetlamy informację, że wskazany proces nie jest wykonywalny
#	2) wczytujemy zawartość pliku do zmiennej i sprawdzamy czy nie jest pusta: jeżeli nie jest - przechodzimy do 3; 
#	   jeżeli jest pusta uruchamiamy proces - wywołujemy funkcję start_proces
#	3) sprawdzamy czy proces o PID zapisanym w pliku PID_FILE faktycznie jest uruchomiony - sprawdzamy czy liczba wierszy po wywołaniu komendy jest równa 1 - 
#	   jeżeli tak "Error: Server jest uruchomiony" + alert dźwiękowy; w przeciwnym razie uruchamiamy proces - wywołujemy funkcję start_proces

#Uwaga odnośnie do komendy "ps -p $state | grep -c $state" -> jeżeli proces o danym PID istnieje, 
#po wpisaniu w terminalu tej komendy wyświtli się 1 wiersz z informacjami o procesie, w przeciwnym razie nie wyświetli się nic
function start_server() {
	if [ -e "$PID_FILE" -a -f "$PID_FILE" ]; then
		state=$(cat "$PID_FILE")		#zmienna przechowująca zawartość pliku PID_FILE
		if [ -n $state ]; then
			#if [ $(ps -ux | grep -c $state) -eq 2 ]; then
			if [ $(ps -p $state | grep -c $state) -eq 1 ]; then
					echo -e "Error: Server jest juz uruchomiony. \a"
			else
				start_proces
			fi
		else
			start_proces
		fi
	else
		if [ -x  skrypt.sh ]
		then
			echo "Server zostal uruchomiony."
			./skrypt.sh &
			echo "$!" > "$PID_FILE"
		else
			echo "Nie mozna uruchomic tego procesu. Sprawdz uprawnienia!"
		fi
	fi
}

#Zatrzymujemy server:
#	1) sprawdzamy czy plik PID_FILE istnieje - jeżeli tak przechodzimy do 2; w przeciwnym razie informacja "Error: Server nie jest uruchomiony." + alert dźwiękowy
#	2) wczytujemy zawartość pliku do zmiennej i sprawdzamy czy nie jest pusta: jeżeli nie jest - przechodzimy do 3; 
#	   jeżeli jest pusta "Error: Server nie jest uruchomiony." + alert dźwiękowy i usuwamy plik PID_FILE
#	3) sprawdzamy czy proces o PID zapisanym w pliku PID_FILE faktycznie jest uruchomiony, jeżeli tak "zabijamy" proces i usuwamy plik PID_FILE,
#	   w przeciwnym razie informacja "Error: Server nie jest uruchomiony." + alert dźwiękowy i usuwamy plik PID_FILE
function stop_server() {
	if [ -e "$PID_FILE" -a -f "$PID_FILE" ]; then
		state=$(cat "$PID_FILE")
		if [ -n $state ]; then
			if [ $(ps -p $state | grep -c $state) -eq 1 ]; then
				kill $state
				rm -r "$PID_FILE"
				echo "Server zostal zatrzymany."
			else
				echo -e "Error: Server nie jest uruchomiony. \a"
				rm -r "$PID_FILE"
			fi
		else
			echo -e "Error: Server nie jest uruchomiony. \a"
			rm -r "$PID_FILE"
		fi
	else
		echo -e "Error: Server nie jest uruchomiony. \a"
	fi
}

#restartujemy serwer
#	1) sprawdzamy czy plik istnieje - jeżeli tak, to przechodzimy do 2; jeżeli nie - wyświetlamy "Ten proces nie jest uruchomiony - nie mozna zrestartowac" + alert dźwiękowy
#	2) wczytujemy zawartość pliku do zmiennej i sprawdzamy czy nie jest pusta: jeżeli nie jest - przechodzimy do 3; 
#	   jeżeli jest pusta wyświetlamy informację "Ten proces nie jest uruchomiony - nie mozna zrestartowac" + alert dźwiękowy i usuwamy plik PID_FILE
#	3) sprawdzamy czy proces o PID zapisanym w pliku PID_FILE jest uruchomiony jeżeli tak "zabijamy" proces i uwuamy plik, a następnie wywołujemy funkcję start_server; 
#	   w przeciwnym razie wyświetlamy informację "Ten proces nie jest uruchomiony - nie mozna zrestartowac" + alert dźwiękowy i usuwamy plik PID_FILE
function restart_server() {
	if [ -e "$PID_FILE" -a -f "$PID_FILE" ]; then
		state=$(cat "$PID_FILE")
		if [ -n $state ]; then
			if [ $(ps -p $state | grep -c $state) -eq 1 ]; then
				kill $(cat "$PID_FILE")
				rm -r "$PID_FILE"
				echo "Server zostal zatrzymany."
				start_server
			else
				echo -e "Ten proces nie jest uruchomiony - nie mozna zrestartowac \a"
				rm -r "$PID_FILE"
			fi
		else
			echo -e "Ten proces nie jest uruchomiony - nie mozna zrestartowac \a"
			rm -r "$PID_FILE"
		fi
	else
		echo -e "Ten proces nie jest uruchomiony - nie mozna zrestartowac \a"
	fi
}

#sprawdzamy status procesu
#	1) sprawdzamy czy plik istnieje - jeżeli tak, to przechodzimy do 2; jeżeli nie - wyświetlamy informację "Server nie jest uruchomiony"
#	2) wczytujemy zawartość pliku do zmiennej i sprawdzamy czy nie jest pusta: jeżeli nie jest - przechodzimy do 3; 
#	   jeżeli jest pusta wyświetlamy informację "Server nie jest uruchomiony" i usuwamy plik PID_FILE
#	3) sprawdzamy czy proces o PID zapisanym w pliku PID_FILE faktycznie jest uruchomiony - sprawdzamy czy liczba wierszy po wywołaniu komendy jest równa 1 - 
#	   jeżeli tak informacja "Server jest uruchomiony"; w przeciwnym razie "Server nie jest uruchomiony" i usuwamy plik PID_FILE
function status_server() {
	if [ -e "$PID_FILE" -a -f "$PID_FILE" ]; then
		state=$(cat "$PID_FILE")
		if [ -n $state ]; then
			if [ $(ps -p $state | grep -c $state) -eq 1 ]; then
				echo "Server jest uruchomiony."
			else
				echo "Server nie jest uruchomiony"
				rm -r "$PID_FILE"
			fi
		else
			echo "Server nie jest uruchomiony."
			rm -r "$PID_FILE"
		fi
	else
		echo "Server nie jest uruchomiony."
	fi
}

#Sprawdzamy, czy nie podano zbyt wielu argumentów; jeżeli liczba argumentów \in {0, 1} zostanie wywołana instrukcja case
#w przeciwnym razie użytkownik dostaje infromację o podaniu zbyt dużej liczby argumentów
if [ $# -le 1 ]; then 
	case "$1" in
		start)
			start_server
			;;
		stop)
			stop_server
			;;
		restart)
			restart_server
			;;
		status)
			status_server
			;;
		--help)
			echo "Opcje programu:"
			echo "start - startuje server"
			echo "stop - stopuje server"
			echo "status - podaje status servera"
			echo "restart - restaruje server"
			;;
		*) echo "Menu: $0 {start|stop|restart|status|--help}"
	esac
else 
	echo "Podano zbyt dużo argumentów!"
	bash serv.sh --help
fi
exit 0