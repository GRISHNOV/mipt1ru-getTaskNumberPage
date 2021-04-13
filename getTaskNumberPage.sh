# !/bin/bash

# Allows you to get information about the task number in the "Koryavov" physics textbook by requesting to mipt1.ru website

# templates for parsing the response from mipt1.ru
taskFound_SubStr="<b style='color: green;'>Задача"
taskNotFound_SubStr="<b style='color: red;'>Задача"
invalidTaskNumber_SubStr="<b style='color: red;'>Укажите номер задачи корректно!"
taskNumberEndLine_SubStr="</b><br><br><br>"

# CLI color codes
YC='\033[1;33m' # Yellow color
GC='\033[1;32m' # Green  color
CC='\033[1;36m' # Cyan   color
RC='\033[1;31m' # Red    color
NC='\033[0m'    # No     color

echo -e "\n${YC}start of the script${NC}"

echo -en "\n"
echo -e "select the volume you need:"
echo -e "1 -- Mechanics book"
echo -e "2 -- Thermodynamics and Molecular Physics book"
echo -e "3 -- Electricity and Magnetism book"
echo -e "4 -- Optics book"
echo -e "5 -- Atomic and Nuclear Physics book"
echo -en "\n"

read bookVolume

if ! ((bookVolume >= 1 && bookVolume <=5)) ; then
	echo -e "${RC}input error, accept number only from 1 to 5${NC}"
	echo -e "\n${YC}end of the script${NC}\n"
	exit
fi

echo -en "\n"
echo -e "select the task number you need (for example 2.1):"
echo -en "\n"

read taskNumber

echo -e "${CC}trying to request mipt1.ru with curl...${NC}"

if ! dataForParsing=$(curl --silent https://mipt1.ru/1_2_3_4_5_kor.php\?sem=${bookVolume}\&zad=${taskNumber}) ; then
	echo -e "${RC}request error${NC}"
	echo -e "\n${YC}end of the script${NC}\n"
	exit
else
	echo -e "${CC}request complete${NC}"
fi

# getting a string with information about the requested task from the received html document
parsedData=$(iconv -f "windows-1251" <<< ${dataForParsing} | grep ${taskNumberEndLine_SubStr})

case "$parsedData" in

	*"$taskFound_SubStr"* )
		echo -e "${GC}success${NC}"
		buffer=${parsedData%$taskNumberEndLine_SubStr*}
		result=${buffer#*"'>"}
		echo $result
		;;

	*"$taskNotFound_SubStr"* )
		echo -e "${RC}failure${NC}"
		buffer=${parsedData%$taskNumberEndLine_SubStr*}
		result=${buffer#*"'>"}
		echo $result
		;;

	*"$invalidTaskNumber_SubStr"* 	)
		echo -e "${RC}invalid task number input${NC}"
		buffer=${parsedData%$taskNumberEndLine_SubStr*}
		result=${buffer#*"'>"}
		echo $result
		;;

	*) 
		echo -e "${RC}unexpected response from the server${NC}"
		;;
		
esac

echo -e "\n${YC}end of the script${NC}\n"