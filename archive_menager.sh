# Author           : Grzegorz Pozorski
# Created On       : 25.05.2020
# Last Modified By : Grzegorz Pozorski
# Last Modified On : 02.06.2020
# Version          : 1.3 (gotowy projekt)
#
# Description      : program do pakowania i rozpakowywania plików
# Licensed under GPL (see /usr/share/common-licenses/GPL for more details
# or contact # the Free Software Foundation for a copy)

#!/bin/bash

PACKPLIK=""
UNPACKPLIK=""
PIERWOTNYPLIK=""
WYNIKOWYPLIK=""
CZYPLIKISTNIEJE=""
CZYARCHISTNIEJE=""

WYBORDODOPCJI1=""
WYBORAKCJI="cos"
KOMENDA=""
REZULTAT=""

ARCHIWUM=""
WLASNEARCH="false"
USUNPIERWOTNY="false"
UPRAWNIENIA=""
ZMIENUPR="false"
TMP=""
KONIEC="false"

wyborAkcji(){
	WYBORAKCJI=`zenity --list --column=Menu "${MENUAKCJI[@]}" 2>/dev/null --width 300 --height 200`
}
MENUAKCJI=( "Spakuj plik" "Rozpakuj plik" "Zakończ")

wyborDodOpcjiMenu1(){
	WYBORDODOPCJI1=`zenity --list --column=Menu "${MENUWYBORDODOPCJI1[@]}" 2>/dev/null --width 700 --height 300`	
}
MENUWYBORDODOPCJI1=(
"Dodaj plik do własnego lub nowego archiwum (domyślnie plik wynikowy będzie miał identyczną nazwę, ale inne rozszerzenie"
"Nadaj uprawnienia stworzonemu plikowi (domyślnie takie same jak pliku pierwotnego"
"Usuń plik pierwotny (domyślnie pozostanie)"
"Dalej")

#prawie dublowanie funkcji w celu dodania innych funkcjonalności w przyszłosci
wyborDodOpcjiMenu2(){
	WYBORDODOPCJI2=`zenity --list --column=Menu "${MENUWYBORDODOPCJI2[@]}" 2>/dev/null --width 600 --height 300`
}

MENUWYBORDODOPCJI2=(
"Nadaj uprawnienia stworzonemu plikowi (domyślnie takie same jak pliku pierwotnego"
"Usuń plik pierwotny (domyślnie pozostanie)"
"Dalej")

wyborMetody(){

	WYBORMETODY=`zenity --list --column=Menu "${MENUMETOD[@]}" 2>/dev/null --width 300 --height 200`
	
}

MENUMETOD=("zip" "tar.gz" "bzip2")

spakuj(){

	case $1 in 	
		"zip"*) 
				if [ "$WLASNEARCH" = "true" ];
				then
					WYNIKOWYPLIK="$ARCHIWUM.zip"							
				else
					WYNIKOWYPLIK="$PIERWOTNYPLIK.zip"							
				fi
										
				TMP=$WYNIKOWYPLIK' '$PIERWOTNYPLIK
				REZULTAT=`zip -r $TMP`
				INFO=`zenity --info --text "Spakowałem plik $PIERWOTNYPLIK"	2>/dev/null`;;
		
		"tar.gz"*) 
				if [ "$WLASNEARCH" = "true" ];
				then
					WYNIKOWYPLIK="$ARCHIWUM.tar.gz"							
				else
					WYNIKOWYPLIK="$PIERWOTNYPLIK.tar.gz"
				fi
			
				TMP=$WYNIKOWYPLIK' '$PIERWOTNYPLIK
				REZULTAT=`tar -zcvf $TMP`
				INFO=`zenity --info --text "Spakowałem plik $PIERWOTNYPLIK"	2>/dev/null`;;
				
		"bzip2"*) 
				if [ "$WLASNEARCH" = "true" ];
				then
					WYNIKOWYPLIK="$ARCHIWUM.tar.bz2"	
					TMP=$WYNIKOWYPLIK' '$PIERWOTNYPLIK
					REZULTAT=`tar cfvj $TMP`
				else
					WYNIKOWYPLIK="$PIERWOTNYPLIK"
					REZULTAT=`bzip2 -k $WYNIKOWYPLIK`
				fi
																
				INFO=`zenity --info --text "Spakowałem plik $PIERWOTNYPLIK"	2>/dev/null`;;				
	esac

}

wyswietlSciage(){

	SCIAGA=`zenity --info --text "
		Przypomnienie\n\n
			Prawa dostępu:\n
	7 - Czytanie, pisanie, wykonywanie\n
	6 - Czytanie, pisanie\n
	5 - Czytanie, wykonywanie\n
	4 - Czytanie\n
	3 - Pisanie, wykonywanie\n
	2 - Pisanie\n
	1 - Wykonywanie\n
	0 - Brak\n
	\n
			Części uprawnień:\n
	#-- - prawo dostępu właściciela pliku\n
	-#- - prawo dostępu grupy\n
	--# - prawo dostępu pozostałych\n
	
	" 2>/dev/null --width 400 --height 600`

}


sprawdzCzyIstnieje(){
	
	KOMENDA=`pwd`' -name '$1				
	CZYPLIKISTNIEJE=`find $KOMENDA 2>/dev/null`
										
	if [ -n "$CZYPLIKISTNIEJE" ];
	then							
			CZYPLIKISTNIEJE="1"
	else
			INFO=`zenity --info --text "W bieżącym katalogu nie ma podanego pliku! Uruchom program jeszcze raz i podaj istniejący plik" 2>/dev/null`
			CZYPLIKISTNIEJE="0"
	fi

}

dodatkowaOpcja1(){
	
	while [ "do breaka" ]
	do			
		if [ "$ARCHIWUM" = "" ];
		then 
			ARCHIWUM=`zenity --entry --text "Podaj nazwę archiwum bez rozszerzenia" 2>/dev/null`	
		else 
			break
		fi	
	done
	
	KOMENDA=`pwd`' -name '$ARCHIWUM				
	CZYARCHISTNIEJE=`find $KOMENDA 2>/dev/null`
													
	if [ -n "$CZYARCHISTNIEJE" ];
	then 
		INFO=`zenity --info --text "archiwum istnieje" 2>/dev/null`			
	else
		INFO=`zenity --info --text "archiwum nie istnieje - tworzysz nowe" 2>/dev/null`											
	fi
	
	WLASNEARCH="true"	

}

dodatkowaOpcja2(){
					
	while [ "do breaka" ]
	do

		UPRAWNIENIA=`zenity --entry --text "Wpisz 3 cyfry nadające uprawnienia (np 700)" 2>/dev/null`

		DLUGOSCUPR=${#UPRAWNIENIA}
		if [ $DLUGOSCUPR -eq 3 ];
		then 
			#sprawdzenie czy kazda z 3 zmienia uprawnienia
			i=0
			until [ $i -gt 2 ]
			do
				CZESCUPR=${UPRAWNIENIA:$i:1} 
				
				if [[ $CZESCUPR -lt 0 ]] || [[ $CZESCUPR -gt 7 ]]
				then 										
					wyswietlSciage
					INFO=`zenity --info --text "Nadaj poprawnie uprawnienia! Wpisz trzykrotnie cyfre od 0 do 7" 2>/dev/null`
					
					break
				else
					(( i=i+1 ))
					continue					
				fi
				
																		
			done
		
			if [ $i -eq 3 ]; then break
			fi
		
		else
			
			INFO=`zenity --info --text "Wpisz 3 cyfry!"	2>/dev/null`							
		fi
	
	done

	ZMIENUPR="true"
						
}

wykonajOpcjeDod(){

	if [ "$ZMIENUPR" = "true" ]
	then
		TMP="$UPRAWNIENIA"' '$WYNIKOWYPLIK
		UPRAWNIENIA=`chmod $TMP`
		ZMIENUPR="false"
	fi
	
	if [ "$USUNPIERWOTNY" = "true" ]
	then
		INFO=`zenity --info --text "Usunąłem plik $PIERWOTNYPLIK" 2>/dev/null`
		REZULTAT=`rm $PIERWOTNYPLIK`
		USUNPIERWOTNY="false"
	fi

}

rozpakuj(){

	case $1 in

		*.zip)	
				WYNIKOWYPLIK=${1%.zip*}
				REZULTAT=`unzip $1`
				INFO=`zenity --info --text "Rozakowałem plik $PIERWOTNYPLIK" 2>/dev/null`					
				;;
		*.tar.gz)
				WYNIKOWYPLIK=${1%.zip*}		
				REZULTAT=`tar -zxvf $1`
				INFO=`zenity --info --text "Rozakowałem plik $PIERWOTNYPLIK" 2>/dev/null`					
				;;
		*.tar.bz2)	
				WYNIKOWYPLIK=${1%.bz2*}	
				REZULTAT=`tar xfvj $1`
				INFO=`zenity --info --text "Rozakowałem plik $PIERWOTNYPLIK" 2>/dev/null`					
				;;		
		*.bz2)		
				WYNIKOWYPLIK=${1%.bz2*}
				REZULTAT=`bzip2 -dk $UNPACKPLIK`
				INFO=`zenity --info --text "Rozakowałem plik $PIERWOTNYPLIK" 2>/dev/null`					
				;;		
		*)		INFO=`zenity --info --text "plik ma złe/nieznane rozszerzenie, nie można go rozpakować" 2>/dev/null`		
				;;
	esac

}


while getopts "hv" OPTION; 
do
        case $OPTION in

			v)
				echo "Author           : Grzegorz Pozorski"
				echo "Created On       : 25.05.2020"
				echo "Last Modified By : Grzegorz Pozorski"
				echo "Last Modified On : 03.06.2020"
				echo "Version          : 1.3 "
				echo "Description      : program do pakowania i rozpakowywania plików"
				exit 0
				;;

			h)
				echo "Zastosowanie"
				echo "Uzyj opcji -h aby wyświetlić ten wydruk (./nazwa -h) "
				echo "Uzyj opcji -v aby wyświetlić informacje o autorze i wersji (./nazwa -v) "
				exit 0
				;;

        esac
done


#głowna pętla
while [ "$KONIEC" = "false" ]
do

	wyborAkcji
	
	case $WYBORAKCJI in 
	
		"Spakuj "*)

			PACKPLIK=`zenity --entry --text "Podaj nazwę pliku do spakowania" 2>/dev/null`
			
			sprawdzCzyIstnieje $PACKPLIK
			
			if [ $CZYPLIKISTNIEJE = "0" ]; then break
			fi
				
			PIERWOTNYPLIK="$PACKPLIK"

			while [ "$WYBORDODOPCJI1" != "Dalej" ]
			do			
				wyborDodOpcjiMenu1	

				case $WYBORDODOPCJI1 in 
					"Dodaj "*) dodatkowaOpcja1;;
					"Nadaj "*) dodatkowaOpcja2;;
					"Usuń "*) USUNPIERWOTNY="true";;
					"Dalej"*) ;;
				esac
				
			done
									
			wyborMetody
			
			spakuj $WYBORMETODY
			
			#nieobslugiwany przypadek pliku bez praw dostępu
			

		;;

		"Rozpakuj "*)

			UNPACKPLIK=`zenity --entry --text "Podaj nazwę pliku do rozpakowania" 2>/dev/null`

			sprawdzCzyIstnieje $UNPACKPLIK
				
			if [ $CZYPLIKISTNIEJE = "0" ]; then break
			fi
			
			PIERWOTNYPLIK="$UNPACKPLIK"
	
			while [ "$WYBORDODOPCJI2" != "Dalej" ]
			do	
				wyborDodOpcjiMenu2
					
				case $WYBORDODOPCJI2 in 
					"Nadaj "*) dodatkowaOpcja2;;
					"Usuń "*) USUNPIERWOTNY="true";;
					"Dalej"*) ;;
				esac
				
			done
			
			rozpakuj $UNPACKPLIK

			#nieobslugiwany przypadek pliku bez praw dostępu
		;;	

		"Zakończ"*)
			KONIEC="true"
			echo "Program zakończył swoje działanie"
			break
		;;
		
	esac

	wykonajOpcjeDod
	
	#przygotuj do ponownego działania
	CZYPLIKISTNIEJE=""
	CZYARCHISTNIEJE=""
	WLASNEARCH="false"
	TMP=""
	WYBORDODOPCJI1=""
	KONIEC="false"
	ARCHIWUM=""
done

