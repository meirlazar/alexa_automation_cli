#!/bin/bash

# This is a working copy that works perfectly, do not modify without making a backup first.

# Author: Meir Lazar
# VersionDate=2.0 12.10.2023 
# Credit: This script relies heavily on alexa_remote_control (https://github.com/thorsten-gehrig/alexa-remote-control) many thanks for the fantastic work done onthis project

########################################################################
########################################################################

SCRIPTPID=$$
IFS=$' \t\n' ;
shopt -s extglob

# CHECKS PREREQS - YOU CAN USE THIS FUNCTION FOR THE FIRST TIME RUNNING IT TO GET THE REQUIRED PACKAGES/BINARIES OR ISNTALL THEM MANUALLY

function GetPreReqs () {
	
if ! which alexa_remote_control; then 
wget https://github.com/thorsten-gehrig/alexa-remote-control/blob/master/alexa_remote_control.sh 
sudo cp alexa_remote_control.sh /usr/bin/alexa_remote_control
sudo chmod +x /usr/bin/alexa_remote_control

wget https://github.com/adn77/alexa-cookie-cli/releases/download/v5.0.1/alexa-cookie-cli-linux-x64
sudo chmod +x alexa-cookie-cli-linux-x64
sudo cp alexa-cookie-cli-linux-x64 /usr/bin/alexa-cookie-cli-linux-x64
fi

if ! which oathtool; then sudo apt install oathtool; fi
if ! which jq; then sudo apt install jq; fi
}

###################################################################################################
# SCRIPT VARIABLES - CHANGE THESE TO MATCH YOUR ENVIRONMENT


TITLE="A L E X A -  A U T O M A T I O N   T O O L"
SCRIPTNAME=$(basename "$0") # The name of the script
SCRIPTDIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
export FULLSCRIPT="${SCRIPTDIR}/${SCRIPTNAME}"
export alexa_remote_control=/usr/bin/alexa_remote_control # GET THIS BINARY AND PLACE IT HERE AND GIVE IT EXECUTABLE PERMS


zipcode='YOURZIPCODEHERE' # change this to your correct zip code

# ECHO DEVICES - TYPE THE VARIABLEs AND WHAT THEY ARE SET TO, TO BE EXACTLY WHAT YOU GET FROM RUNNING THE COMMAND; alexa_remote_control -a 


OFFICEECHO='Office'
COMPUTERECHO='Computer'
LIVINGECHO='Living'
PARENTSECHO='Parent'
DININGECHO='Dining'
ELANAECHO='Elanas'

DEF_ECHO=${OFFICEECHO}  #### CHANGE THIS TO WHAT YOU WANT TO BE YOUR DEFAULT ECHO OR ALEXA DEVICE

# THESE VARS SHOULD BE CUSTOMIZED TO FIT YOUR ENVIRONMENT - LIST ALL YOUR SMART DEVICES HERE - BELOW ARE JUST EXAMPLES, THEY WILL NOT WORK WITHOUT CHANGING THEM

# HEATERS 
OFFICEHEAT='OFFICE HEATER'
JOESSHEAT='JOES HEATER'
BOBHEAT='BOBS HEATER'
HOMETHERM='THERMOSTAT'
KIDSHEAT='KIDSROOM HEATER'


# AC UNITS
PARENTSAC='PARENTS ROOM COOLING'
SANDYAC='SANDYS ROOM COOLING'
DININGAC='DININGROOM COOLING'
OFFICEOLDAC='OFFICE CLIMATE CONTROL'
OFFICEAC='OFFICE COOLING'
LIVINGAC='LIVINGROOM COOLING'

# FANS
OFFICEFAN='OFFICE VENTILATION'
LIVINGFAN='LIVINGROOM VENTILATION'
EXHAUSTFAN='EXHAUST CLIMATE CONTROL'


# OFFICE LIGHTS
OFFICEDESKLIGHT='OFFICE DESK LIGHT'
OFFICESOFALIGHT='OFFICE SOFA LIGHT'
OFFICELIGHTS='OFFICE LIGHTS'

# BEDROOM LIGHTS
DANNIESLIGHT='DANIELS LIGHT'
BUGLIGHT='LADYBUG'
REFAELLIGHT='MOON LIGHT'
NEONLIGHT='NEON LIGHTS'

# OUTDOOR LIGHTS
DECKLIGHT='DECK LIGHTS'
OVERHANGLIGHT='OVERHANG LIGHTS'
DECKLAMP='DECK LATERN'

# DOWNSTAIRS LIGHTS
PANTRYLIGHT='PANTRY LIGHT'
GYMLIGHT='BASEMENT LIGHTS'

# UPSTAIRS LIGHTS
KITCHENLIGHT='KITCHEN LIGHTS'
LIVINGLIGHT='LIVINGROOM LIGHT'

# SECURITY LIGHTS
DECKSECLIGHT='DECK SECURITY LIGHT'
YARDSECLIGHT='BACKYARD SECURITY LIGHT'

# Monitors
OFFICEMONIT='OFFICE MONITORS'
OFFICEDESKMONIT='OFFICE DESK OUTLETS'

# ROKUS
DININGROKU='DININGROOM ROKU'
BEDROKU='BEDROOM ROKU'
LIVINGROKU='LIVINGROOM ROKU'

# PRINTERS
PANTRYPRINT='PANTRY PRINTER'
COLORPRINT='LIVINGROOM COLOR PRINTER'

# HOT PLATE
HOTPLATE='HOT PLATE'



# OUTLETS
LIVINGOUTLETS='LIVINGROOM OUTLETS'
ARIELOUTLETS='ARIELS ROOM OUTLETS'
ELANAOUTLETS='ELANAS ROOM OUTLETS'
OFFICEDESKOUTLETS='OFFICE DESK OUTLETS'
JONOUTLETS='JONS ROOM OUTLETS'

# ENTERTAINMENT
PEACOCK='PEACOCK LIGHT'
MOON='MOON LIGHT'

### END



########################################################################
########################################################################

# Functions for the menu, getting data, etc
# function ECHO_RGB () { OUT=$@ ; for X in tput sgr0 ; tput setaf 50 ; } # have each letter use a  figgerent coor sequwntially
function TEAL () { tput sgr0 ; tput setaf 50 ; }
function PURPLE () { tput sgr0 ; tput setaf 57 ; }
function BLUE () { tput sgr0 ; tput setaf 6 ; }
function YELLOW () { tput sgr0 ; tput setaf 3 ; }
function GREY () { tput sgr0 ; tput setaf 8 ; }
function PINK () { tput sgr0 ; tput setaf 99 ; }
function GREEN () { tput sgr0 ; tput setaf 2 ; }
function LIGHTGREEN () { tput sgr0 ; tput setaf 82 ; }
function DARKBLUE () { tput sgr0 ; tput setaf 4 ; }
function RED () { tput sgr0 ; tput setaf 1 ; }
function WHITE () { tput sgr0 ; tput setaf 7 ; }
function BOLD () { tput bold ; }
function CLEAR () { tput sgr0 ; tput clear ; }
function RESET () { tput sgr0 ; }
function SHOW () { tput cup "${1}" "${2}" ; }
function RCOL () { RCOL=$(shuf -n1 -i1-99) ; }

########################################################################
########################################################################

# BOOK CALLED FROM GET_CURR_TEMP BASED ON THE OUTSIDE TEMPERATURE

# ALL THE ECHO DEVICES ON YOUR ACCOUNT OR IN YOUR HOME
ALLDEVICES=$(alexa_remote_control -a  | grep -iEv 'Everywhere|account:alexa|Fire|Device') # place alexa devices to remove in here

########################################################################
########################################################################
# FUNCTIONS FOR EITHER SPEAKING, DOING SOMETHING, OR SAYING/DOING SOMETHING ON ONE OR MORE OF THE ECHO DEVICES

# use this to have alexa say something in the office
function AlexaSay () {
CMD="$*"
export SPEAKVOL=${SPEAKVOL:=30}
alexa_remote_control -d "${DEF_ECHO}" -e speak:"${CMD}"  # specify the echo device to be your primary
sleep 10
}

########################################################################
# use this to have alexa say something on one of the devices, the 1st argument is the device name
function AlexaSayHere  () {
DEVICE=$(grep -i "$1" <<< "${ALLDEVICES}")
shift 1
CMD="$*"
export SPEAKVOL=${SPEAKVOL:=30}
alexa_remote_control -d "${DEVICE^^}" -e speak:"${CMD}"
sleep 10
}

########################################################################
# use this to have alexa say something on all of the devices
function AlexaSayAll () {
CMD="$*"
export SPEAKVOL=${SPEAKVOL:=30}
alexa_remote_control -d "Everywhere" -e speak:"${CMD}"
sleep 10
}

########################################################################
# use this to have alexa do something from the office echo
function AlexaDo () {
CMD="$*"
export SPEAKVOL=${SPEAKVOL:=30}
alexa_remote_control -d "${DEF_ECHO}" -e textcommand:"${CMD}"  # specify the echo device to be your primary
sleep 10
}

########################################################################
# use this to have alexa do something from a device, the first argument is the device name
function AlexaDoHere () {
DEVICE=$(grep -i "$1" <<< "${ALLDEVICES}")
shift 1
CMD="$*"
export SPEAKVOL=${SPEAKVOL:=30}
alexa_remote_control -d "${DEVICE}" -e textcommand:"${CMD}"
sleep 10
}

########################################################################
# use this to have alexa do something on all of the devices

function AlexaDoAll () {
CMD="$*"
export SPEAKVOL=${SPEAKVOL:=30}
alexa_remote_control -d "Everywhere" -e textcommand:"${CMD}"
sleep 10
}

# alexa_remote_control -d "Parents Room" -e textcommand:"Set Volume to 4"
########################################################################
########################################################################

# PLAYBOOKS THAT ALTER THE HOUSE TEMPERATURE BASED ON CURRENT WEATHER AND IF YOU HAVE WEATHERSTATIONS IN/OUT OF YOUR HOME - UPDATED IN REALTIME

function WARMTODAYBOOK () {
AlexaDo TURN ON "${OFFICEAC}"
AlexaDo TURN ON "${OFFICEFAN}"
AlexaDo SET "${HOMETHERM}" COOL
AlexaDo SET "${HOMETHERM}" 75 DEGREES
AlexaDo TURN ON "${LIVINGFAN}"
AlexaDo TURN OFF "${JOESHEAT}"
AlexaDo TURN OFF "${BOBSHEAT}"
AlexaDo TURN OFF "${OFFICEHEAT}"
#ENDOFFUNCTION
}

function NICETODAYBOOK () {
AlexaDo TURN ON "${OFFICEFAN}"
AlexaDo TURN ON "${OFFICEAC}"
AlexaDo OFF "${OFFICEHEAT}"
AlexaDo TURN OFF "${DANSHEAT}"
AlexaDo TURN OFF "${ARIELHEAT}"
AlexaDo TURN ON "${LIVINGFAN}"
#AlexaDo SET "${HOMETHERM}" COOL
#AlexaDo SET "${HOMETHERM}" 77 DEGREES
AlexaDo TURN OFF "${PARENTSHEAT}"
#ENDOFFUNCTION
}

function COOLTODAYBOOK () {
AlexaDo TURN OFF "${OFFICEAC}"
AlexaDo TURN OFF "${OFFICEHEAT}"
AlexaDo TURN OFF ${PORCHFAN}
#AlexaDo SET "${HOMETHERM}" COOL
#AlexaDo SET "${HOMETHERM}" 77 DEGREES
AlexaDo TURN OFF "${LIVINGFAN}"
AlexaDo TURN OFF "${PARENTSHEAT}"
#ENDOFFUNCTION
}

function COLDTODAYBOOK () {
AlexaDo TURN OFF "${OFFICEFAN}"
AlexaDo TURN OFF ${PORCHFAN}
AlexaDo TURN OFF "${LIVINGFAN}"
AlexaDo TURN OFF "${OFFICEAC}"
AlexaDo TURN ON "${OFFICEHEAT}"
AlexaDo SET "${OFFICEHEAT}" 69 DEGREES
#AlexaDo SET "${HOMETHERM}" HEAT
#AlexaDo SET "${HOMETHERM}" 69 DEGREES
AlexaDo TURN ON "${PARENTSHEAT}"
#ENDOFFUNCTION
}


########################################################################
########################################################################

function Menu () {
clear
RCOL ; tput sgr0 ; tput setaf "${RCOL}" ; SHOW 1 20 ; echo "${TITLE}"
RCOL ; tput sgr0 ; tput setaf "${RCOL}" ; SHOW 3 5 ; echo -e "CURRENT DAY AND TIME:\t${DAY} ${HR}:${MIN}"
RCOL ; tput sgr0 ; tput setaf "${RCOL}" ; SHOW 4 5 ; echo -e "OUT-TEMP:${OUTTEMP}  OUT-HUMID:${OUTHUMID}  HOME-TEMP:${INSIDETEMP}  HOME-HUMID:${INSIDEHUMID}"
RCOL ; tput sgr0 ; tput setaf "${RCOL}" ; SHOW 5 5 ; echo -e "SUNRISE:\t${STARTDOW} ${STARTHR}:${STARTMIN}\t\t\t SUNSET:\t${ENDDOW} ${ENDHR}:${ENDMIN}"
RCOL ; tput sgr0 ; tput setaf "${RCOL}" ; SHOW 6 5 ; echo -e "SUNSET OCCURS IN: ${DAYENDSINTHISMIN} MINUTES\t APPROX: ${DAYENDSINTHISHR} HRS"
RCOL ; tput sgr0 ; tput setaf "${RCOL}" ; BOLD ; SHOW 8 15 ; echo "STATUS:    ${WHATSUP}"
RCOL ; tput sgr0 ; tput setaf "${RCOL}" ; SHOW 10 15 ; echo "NEXT SET OF BOOKS TO RUN AT:     ${NEXTRUNTIME}"
RCOL ; tput sgr0 ; tput setaf "${RCOL}" ; SHOW 11 15 ; echo -e "#####  PLAYBOOKS TO EXECUTE: $(echo "${NEXTPLAYBOOKS}" | tr '\n' ' ') #### "

ROW=12
COLUMN=0

while read -r X ; do
RCOL ; tput setaf "${RCOL}" ; tput cup ${ROW} ${COLUMN} ; echo -e "${X}"
let ROW++
if [[ ${ROW} -ge 26 ]]; then ROW=12 ; COLUMN=$((COLUMN + 40)) ; fi
done <<< "${NEXTITEMS}"
}

########################################################################
########################################################################

# FYI - leave the #ENDOFFUNCTION ON EACH FUNCTION - IT IS USED TO DETERMINE WHEN PLAYBOOKS START AND END FOR THE MENU

# BOOKS COMPRISE OF A BUNCH OF TASKS TO DO BASED ON A CERTAIN TIME

function ENDWORKDAYBOOK () {
AlexaDo TURN ON "${HOTPLATE}"
AlexaDo TURN ON "${PANTRYLIGHT}"
AlexaDo TURN ON "${KITCHENLIGHT}"
AlexaDo TURN ON "${GYMLIGHT}"
AlexaDo TURN ON "${LIVINGLIGHT}"
AlexaDo TURN ON "${LIVINGFAN}"
AlexaDo SET "${OFFICELIGHTS}" TO FIVE PERCENT
AlexaDo TURN OFF "${PARENTLIGHT}"
AlexaDo TURN ON "${DECKSECLIGHT}"
AlexaDo TURN ON "${YARDSECLIGHT}"
AlexaDo TURN ON "${DECKLIGHT}"
AlexaDo TURN OFF "${PANTRYPRINT}"
AlexaDo TURN OFF "${DANNIESHEAT}"
AlexaDo TURN OFF "${ARYEHHEAT}"
#ENDOFFUNCTION
}

function BEDTIMEBOOK () {
AlexaDo TURN OFF "${OFFICELIGHTS}"
AlexaDo TURN "${HOTPLATE}" OFF
AlexaDo "${GYMLIGHT}" OFF
AlexaDo "${LIVINGLIGHT}" OFF
AlexaDo TURN OFF "${KITCHENLIGHT}"
AlexaDo TURN OFF "${PANTRYLIGHT}"
AlexaDo TURN ON "${DECKSECLIGHT}"
AlexaDo TURN ON "${YARDSECLIGHT}"
AlexaDo TURN ON "${DECKLIGHT}"
AlexaDo TURN OFF "${PANTRYPRINT}"
AlexaDo TURN OFF "${PARENTSPRINT}"
AlexaDo TURN OFF "${PARENTLIGHT}"
AlexaDo I am LEAVING
AlexaDo SET VOLUME TO 3
#ENDOFFUNCTION
}

function SLEEPBOOK () {
AlexaDoHere PARENTS ASK SLEEP JAR TO PLAY RAINSTORM
AlexaDoHere PARENTS Set Volume to 3
AlexaDoHere ARYEHS ASK SLEEP JAR TO PLAY THE DRYER
AlexaDoHere ARYEHS Set Volume to 3
#ENDOFFUNCTION
}

function ENDOFDAYBOOK () {
export SPEAKVOL=30;
AlexaDo "${HOTPLATE}" OFF
AlexaDo TURN ON "${PANTRYLIGHT}"
AlexaDo TURN ON "${OFFICELIGHTS}"
AlexaDo SET "${OFFICELIGHTS}" 100 PERCENT
AlexaDo TURN ON "${GYMLIGHT}"
AlexaDo SET "${GYMLIGHT}" 100 PERCENT
AlexaDo I AM LEAVING
AlexaDo TURN ON "${DECKSECLIGHT}"
AlexaDo TURN ON "${YARDSECLIGHT}"
AlexaDo TURN ON "${DECKLIGHT}"
AlexaDo TURN OFF "${PANTRYPRINT}"
AlexaDo TURN ON "${PARENTLIGHT}"
AlexaDoAll SET VOLUME TO 5
AlexaSayAll I HOPE YOU HAD A FANTASTIC DAY, CUZ IT IS OVER.
#ENDOFFUNCTION
kill -9 ${SCRIPTPID}
exit
}

function EARLYMORNING1BOOK () {
AlexaDo "${OFFICELIGHTS}" COLOR BLUE
AlexaDo "${OFFICELIGHTS}" 10 PERCENT
AlexaDo TURN OFF "${PARENTLIGHT}"
AlexaDo TURN ON "${LIVINGFAN}"
AlexaDo SET VOLUME TO 3
#ENDOFFUNCTION
}

function LOWERTHELIGHTSBOOK () {
AlexaDo TURN OFF "${HOTPLATE}"
AlexaDo TURN OFF "${LIVINGLIGHT}" 
AlexaDo SET "${GYMLIGHT}" 30 PERCENT
AlexaDo "${OFFICELIGHTS}" 5 PERCENT
AlexaDo TURN OFF "${KITCHENLIGHT}"
AlexaDo TURN OFF "${LIVINGFAN}"
#ENDOFFUNCTION
}

function RAISETHELIGHTSBOOK () {
AlexaDo SET "${LIVINGLIGHT}" 75 PERCENT
AlexaDo SET "${GYMLIGHT}" 75 PERCENT
AlexaDo "${OFFICELIGHTS}" 100 PERCENT
AlexaDo TURN ON "${KITCHENLIGHT}"
AlexaDo SET "${KITCHENLIGHT}" 100 PERCENT
#ENDOFFUNCTION
}

function VOLUMEZEROBOOK () {
AlexaDoAll SET VOLUME TO ZERO
#ENDOFFUNCTION
}

function VOLUMENORMALBOOK () {
AlexaDoAll SET VOLUME TO 3
#ENDOFFUNCTION
}

function EARLYMORNING2BOOK () {
AlexaDo STOP PLAYING
AlexaDo "${OFFICELIGHTS}" COLOR PURPLE
AlexaDo "${OFFICELIGHTS}" 20 PERCENT
AlexaDo TURN OFF "${PARENTLIGHT}"
#ENDOFFUNCTION
}

function MORNINGBOOK () {
export SPEAKVOL=30;
AlexaDo "${HOTPLATE}" ON
AlexaDo TURN ON "${PANTRYLIGHT}"
AlexaDo TURN ON "${KITCHENLIGHT}"
AlexaDo TURN ON "${GYMLIGHT}"
AlexaDo TURN ON "${LIVINGLIGHT}"
AlexaDo TURN OFF "${DECKSECLIGHT}"
AlexaDo TURN OFF "${DECKLIGHT}"
AlexaDo TURN OFF "${PANTRYPRINT}"
AlexaDo TURN OFF "${PARENTLIGHT}"
AlexaDo SET VOLUME TO 3
AlexaDo ASK SLEEP JAR TO PLAY THUNDERSTORM
#ENDOFFUNCTION
}

function GOINGOUTBOOK () {
AlexaDo TURN OFF "${HOTPLATE}"
AlexaDo TURN OFF "${OFFICELIGHTS}"
AlexaDo TURN OFF "${KITCHENLIGHT}"
AlexaDo TURN OFF "${LIVINGLIGHT}"
AlexaDo TURN OFF "${PARENTLIGHT}"
AlexaDo TURN OFF "${PANTRYPRINT}"
AlexaDo TURN OFF "${PANTRYLIGHT}"
AlexaDo TURN OFF "${GYMLIGHT}"
AlexaDo TURN OFF "${LIVINGFAN}"
#ENDOFFUNCTION
}

function COMINGHOMEBOOK () {
AlexaDo "${HOTPLATE}" ON
AlexaDo TURN ON "${KITCHENLIGHT}"
AlexaDo TURN ON "${PANTRYLIGHT}"
AlexaDo TURN ON "${GYMLIGHT}"
AlexaDo TURN ON "${LIVINGLIGHT}"
AlexaDo TURN ON "${LIVINGFAN}"
#ENDOFFUNCTION
}


function WHATSGOINGONBOOK () {
export SPEAKVOL=50;
AlexaDoHere DINING WHAT ARE MY NOTIFICATIONS
sleep 20
AlexaDoHere DINING TELL ME THE WEATHER FORECAST FOR TODAY
sleep 20
#ENDOFFUNCTION
}

function SETMOODBOOK () {
AlexaDo TURN OFF "${BEDLIGHTS}"
AlexaDo SET VOLUME TO 3
AlexaDo PLAY ROMANTIC MUSIC
#ENDOFFUNCTION
}


function TURNOFFTVSBOOK () {
AlexaDo TURN OFF "${DININGROKU}"
AlexaDo TURN OFF "${BEDROKU}"
#ENDOFFUNCTION
}


function WAKEUPBOOK () {
AlexaDoAll STOP PLAYING
AlexaDoAll SET VOLUME TO 3
AlexaDo PLAY NEW AGE MUSIC
export SPEAKVOL=40; AlexaSayAll EVERYONE WAKE UP. WAKE UP. WAKE UP. ITS "${TODAY}"
AlexaDoAll SET VOLUME TO 3
#ENDOFFUNCTION
}



function MUSICTIMEBOOK () {
AlexaDo SET VOLUME TO 3
AlexaDo PLAY SHINEDOWN RADIO
AlexaDo TURN OFF "${OFFICESOFALIGHT}"
#ENDOFFUNCTION
}

function SECURITYLIGHTSONBOOK () {
AlexaDo TURN ON "${DECKSECLIGHT}"
AlexaDo TURN ON "${YARDSECLIGHT}"
AlexaDo TURN ON "${DECKLIGHT}"
#ENDOFFUNCTION
}

function SECURITYLIGHTSOFFBOOK () {
AlexaDo TURN OFF "${DECKSECLIGHT}"
AlexaDo TURN OFF "${YARDSECLIGHT}"
AlexaDo TURN OFF "${DECKLIGHT}"
#ENDOFFUNCTION
}

function SAVEELECTRICITYBOOK () {
AlexaDo SET VOLUME TO 0
AlexaDo TURN OFF "${HOTPLATE}"
AlexaDo TURN OFF "${OFFICELIGHTS}"
AlexaDo TURN OFF "${KITCHENLIGHT}"
AlexaDo TURN OFF "${PARENTLIGHT}"
AlexaDo TURN OFF "${PANTRYPRINT}"
AlexaDo TURN OFF "${PANTRYLIGHT}"
AlexaDo TURN OFF "${GYMLIGHT}"
AlexaDo TURN OFF "${LIVINGLIGHT}"
AlexaDo TURN OFF "${LIVINGFAN}"
AlexaDo stop playing
#ENDOFFUNCTION
}

# ADD OROUTINE ABOVE AFRER THIS DAY
# AlexaDo TURN OFF "${LIVINGFAN}"
# AlexaDo TURN OFF "${LIVINGLIGHT}"

#########################################################################################

function GetCurrentWeather () {

URL="https://www.weatherusa.net/forecasts/zip:${zipcode}"    
WDUMP=$(w3m -dump "${URL}" | grep -E '[0-9]')

OUTTEMPERATURE=$(awk '{for (I=1;I<NF;I++) if ($I == "LIKE") print $(I+1),$(I+2)}' <<< ${WDUMP})
OUTTEMP=$(sed 's/[^0-9]*//g' <<< "${OUTTEMPERATURE}")
OUTHUMID=$(grep -i "HUMIDITY" <<< ${WDUMP} | grep -Eow '[0-9]+')

# BASED ON THE CURRENT WEATHER - USE THE CORRECT PLAYBOOK - THIS WILL ONLY BE USED IF YOU SPECIFY 'SETWEATHER' FOR A SPECIFIC TIME IN THE SCHEDULE BELOW
case "${OUTTEMP}" in
[1][0-9][0-9] )  MODE="WARMTODAYBOOK" ;;
[8-9][0-9] ) MODE="WARMTODAYBOOK" ;;
[6-7][0-9] ) MODE="NICETODAYBOOK" ;;
[4-5][0-9] ) MODE="COOLTODAYBOOK" ;;
[0-3][0-9] ) MODE="COLDTODAYBOOK" ;;
esac

export WDUMP OUTTEMPERATURE OUTTEMP MODE OUTHUMID
}

#########################################################################################

function GetHouseWeather () {
INSIDEURL='http://192.168.1.201' # IF YOU HAVE A WEBUI WEATHER STATION SUCH AS WITH A ARDUINO NODEMCU WITH TEMP/HUMIDITY SENSOR - THIS SCRIPT CAN READ THE INSIDE TEMP/HUMIDITY
INSIDEDUMP=$(timeout 6 w3m -dump "${INSIDEURL}" | grep -E '[0-9]+' | cut -d- -f2 | cut -d. -f1)

if [[ -n ${INSIDEDUMP} ]] ; then 
INSIDETEMP=$(head -3 <<< ${INSIDEDUMP} | tail -1 | cut -d: -f2)
INSIDEHUMID=$(head -2 <<< ${INSIDEDUMP} | tail -1 | cut -d: -f2)
OUTTEMP=$(head -6 <<< ${INSIDEDUMP} | tail -1 | cut -d: -f2)
OUTHUMID=$(head -5 <<< ${INSIDEDUMP} | tail -1 | cut -d: -f2)
fi


if [[ -z ${OUTTEMP} ]] || [[ -z ${OUTHUMID} ]]; then GetCurrentWeather; fi 

INSIDETEMP=${INSIDETEMP:=$OUTTEMP}
INSIDEHUMID=${INSIDEHUMID:=$OUTHUMID}

export INSIDETEMP INSIDEHUMID OUTTEMP OUTHUMID
}

#########################################################################################

# THIS CAN BE USED TO TURN ON AND OFF A HOUSE EXHAUST FAN - IT ASSUMES YOU HAVE TO OPEN AND CLOSE A WINDOW MANUALLY...
function TheExhaustFan () {
if [[ -z "${OUTTEMP}" ]]; then return; fi
if [[ "${OUTTEMP}" -ge 75 ]] || [[ "${OUTHUMID}" -ge 80 ]] ; then 
WHATSUP="NOTICE: TURNING OFF ${EXHAUSTFAN}" ;
Menu ; sleep 60
AlexaDoHere DINING set volume to 6
AlexaSayHere DINING PLEASE BE ADVISED. I AM TURNING OFF ${EXHAUSTFAN} OFF IN TWO MINUTES. PLEASE CLOSE THE ${EXHAUSTFAN} WINDOW.
sleep 2m
AlexaDoHere DINING set volume to 0
AlexaDo TURN OFF ${EXHAUSTFAN}
AlexaDo SET "${HOMETHERM}" COOL
AlexaDo SET "${HOMETHERM}" 75 DEGREES
AlexaDo TURN ON "${LIVINGFAN}"
return ;
fi

if [[ "${OUTTEMP}" -lt 75 ]] && [[ "${OUTHUMID}" -lt 65 ]] ; then 
WHATSUP="NOTICE: TURNING ON ${EXHAUSTFAN}" ; Menu ; sleep 60
AlexaDoHere DINING set volume to 6
AlexaSayHere DINING WARNING. WARNING. TURNING ON ${EXHAUSTFAN} ON IN TWO MINUTES. OPEN THE WINDOW.
sleep 2m
AlexaSayHere DINING WARNING. WARNING. TURNING ON ${EXHAUSTFAN} ON IN 30 SECONDS. OPEN THE WINDOW.
sleep 30
AlexaDoHere DINING set volume to 0
AlexaDo TURN ON ${EXHAUSTFAN}
AlexaDo SET "${HOMETHERM}" OFF
AlexaDo TURN ON "${LIVINGFAN}"
return ;
fi

}

#########################################################################################

# GETS THE CURRENT TIME, DATE
function UpdateNow () { read DAY HR MIN< <(date '+%^A %H %M') ; }


#########################################################################################

# GETS THE CURRENT TIME, DATE, SUNRISE, SUNSET TIMES

function GetDateTimeFromInternet () {

URL="https://www.weatherusa.net/forecasts/zip:${zipcode}"
WDUMP=$(w3m -dump "${URL}" | grep -E '[0-9]')

# GET CURRENT TIME AND DATE
read DAY HR MIN< <(date '+%^A %H %M')
SUNRISE=$(awk '{for (I=1;I<NF;I++) if ($I == "Sunrise") print $(I+1),$(I+2)}' <<< ${WDUMP})
SUNSET=$(awk '{for (I=1;I<NF;I++) if ($I == "Sunset") print $(I+1),$(I+2)}' <<< ${WDUMP})
read STARTDOW STARTHR STARTMIN< <(date --date="${DAY} ${SUNRISE}" '+%^A %H %M')
read ENDDOW ENDHR ENDMIN< <(date --date="${TODAY} ${SUNSET}" '+%^A %H %M')

# Get the amount of time left before DAY ends
DAYENDSECSEPOC=$(date -d "+${ENDDOW} ${ENDHR}:${ENDMIN}" "+%s")
CURRSECEPOC=$(date "+%s")
TOTALCURRSEC=$((DAYENDSECSEPOC - CURRSECEPOC))
DAYENDSINTHISMIN=$((TOTALCURRSEC / 60))
DAYENDSINTHISHR=$((TOTALCURRSEC / 3600))

export SUNSET STODAY ENDDOW ENDHR ENDMIN STARTDOW STARTHR STARTMIN DAYENDSINTHISMIN DAYENDSINTHISHR

#ENDOFFUNCTION
}


#########################################################################################

# THIS FUNCTION FINDS THE NEXT PLAYBOOK TO EXECUTE AND THE TIME IT WILL RUN TO DISPLAY IN THE MENU

function GetNextPlayBooks () {
unset  NEXTRUNTIME NEXTINDEX NEXTPLAYBOOKS WAITINMIN NEXTITEMS MODE NEXTITEMS

# WHEN SCRIPT IS EXECUTED, THE SCHEDULE ARRAY IS LOADED AND THIS LOOKS AT (%w     day of week (0..6); 0 is Sunday)
# d=$(date "+%w"); h=$(date "+%H") ; m=$(date "+%M")

for ((m=0;m<10080;m++)); do 
	if grep "$(date -d "+${m} minutes" "+%^A %H:%M")" <<< $(printf "%s\n" "${SCHEDULE[@]}"); then
		NEXTRUNTIME="$(date -d "+${m} minutes" "+%^A %H:%M")" ; NEXTINDEX=$(grep "${NEXTRUNTIME}" <<< $(printf "%s\n" "${SCHEDULE[@]}")) ; break;	
	fi 
done


readarray -t SCHEDULE< <(printf "%s\n" "${SCHEDULE[@]}" | grep -v "${NEXTINDEX}")
NEXTPLAYBOOKS="${NEXTINDEX/$NEXTRUNTIME/}"
GetCurrentWeather;
NEXTPLAYBOOKS=${NEXTPLAYBOOKS/SETWEATHER/$MODE} ;


NEXTCURRSECEPOC=$(date -d "+${NEXTRUNTIME}" "+%s")
CURRSECEPOC=$(date "+%s") ;
TOTALCURRSEC=$((NEXTCURRSECEPOC - CURRSECEPOC)) ;
WAITINMIN=$((TOTALCURRSEC / 60))
export WAITINMIN NEXTPLAYBOOKS NEXTRUNTIME SCHEDULE
# for next scheduled tasks
NEXTITEMS=$(for x in ${NEXTPLAYBOOKS} ; do awk "/function ${x}/,/#END/" "${FULLSCRIPT}" | grep -iE "^ALEXA.*"; done)
}


##################### THIS IS THE SCHEDULE ARRAY THAT WILL DETERMINE AT WHAT DAY AND TIME WILL A PLAYBOOK BE EXECUTED ############################
#################### MODIFY/ADD/REMOVE ANY PART OF THE SCHEDULE AND CREATE NEW ONES FOR OTHER DAYS OF THE WEEK - MODIFY AS YOU SEE FIT ################################


SCHEDULE+=("SUNDAY 15:00 WHATSGOINGONBOOK SETWEATHER")
SCHEDULE+=("SUNDAY 16:30 MUSICTIMEBOOK WHATSGOINGONBOOK SETWEATHER")
SCHEDULE+=("SUNDAY 17:00 SETWEATHER")
SCHEDULE+=("SUNDAY 17:30 TURNOFFTVSBOOK VOLUMEZEROBOOK SETWEATHER")
SCHEDULE+=("SUNDAY 18:00 WHATSGOINGONBOOK SETWEATHER")
SCHEDULE+=("SUNDAY 18:30 EVENINGBOOK SETWEATHER")
SCHEDULE+=("SUNDAY 19:00 TURNOFFTVSBOOK VOLUMEZEROBOOK")


SCHEDULE+=("MONDAY 19:30 WHATSGOINGONBOOK SETWEATHER")
SCHEDULE+=("MONDAY 20:00 EVENINGBOOK SETWEATHER")
SCHEDULE+=("MONDAY 21:00 ENDOFDAYBOOK VOLUMENORMALBOOK SETWEATHER")
SCHEDULE+=("MONDAY 21:30 ENDOFDAYBOOK VOLUMENORMALBOOK SETWEATHER")
SCHEDULE+=("MONDAY 22:00 VOLUMENORMALBOOK VOLUMENORMALBOOK SETWEATHER")


SCHEDULE+=("TUESDAY 10:30 MORNINGBOOK VOLUMENORMALBOOK SETWEATHER")
SCHEDULE+=("TUESDAY 12:30 VOLUMEZEROBOOK TURNOFFTVSBOOK STARTOFDAYBOOK SETWEATHER")
SCHEDULE+=("TUESDAY 16:00 TURNOFFTVSBOOK SECLIGHTSONBOOK SETMOODBOOK SETWEATHER")
SCHEDULE+=("TUESDAY 20:30 SLEEPBOOK TURNOFFTVSBOOK VOLUMEZEROBOOK SETNOISEBOOK")
SCHEDULE+=("TUESDAY 21:00 SETWEATHER")
SCHEDULE+=("TUESDAY 22:00 TURNOFFTVSBOOK STARTOFDAYBOOK SETNOISEBOOK SETWEATHER")
SCHEDULE+=("TUESDAY 22:30 SLEEPBOOK WHATSGOINGONBOOK SETWEATHER")


SCHEDULE+=("WEDNESDAY 00:30 SETWEATHER LOWERTHELIGHTSBOOK")
SCHEDULE+=("WEDNESDAY 01:00 SETWEATHER SECLIGHTSONBOOK SAVEELECTRICITYBOOK BEDTIMEBOOK")
SCHEDULE+=("WEDNESDAY 06:30 SAVEELECTRICITYBOOK SECLIGHTSONBOOK")
SCHEDULE+=("WEDNESDAY 10:00 SECURITYLIGHTSOFFBOOK WAKEUPBOOK SETWEATHER")
SCHEDULE+=("WEDNESDAY 11:00 MORNINGBOOK SETWEATHER")

SCHEDULE+=("THURSDAY 08:00 WHATSGOINGONBOOK WAKEUPBOOK")
SCHEDULE+=("THURSDAY 12:30 WHATSGOINGONBOOK MUSICTIMEBOOK SETWEATHER")
SCHEDULE+=("THURSDAY 14:00 SETWEATHER")
SCHEDULE+=("THURSDAY 14:30 TURNOFFTVSBOOK VOLUMEZEROBOOK")
SCHEDULE+=("THURSDAY 15:00 WHATSGOINGONBOOK SETWEATHER")
SCHEDULE+=("THURSDAY 15:30 VOLUMEZEROBOOK SETWEATHER")
SCHEDULE+=("THURSDAY 16:00 TURNOFFTVSBOOK VOLUMEZEROBOOK")
SCHEDULE+=("THURSDAY 21:30 ENDOFDAYBOOK SETWEATHER")

SCHEDULE+=("FRIDAY 17:00 SETWEATHER")
SCHEDULE+=("FRIDAY 17:30 TURNOFFTVSBOOK SETWEATHER")
SCHEDULE+=("FRIDAY 18:00 WHATSGOINGONBOOK SETWEATHER")
SCHEDULE+=("FRIDAY 18:30 EVENINGBOOK SETWEATHER")
SCHEDULE+=("FRIDAY 19:00 TURNOFFTVSBOOK VOLUMEZEROBOOK")
SCHEDULE+=("FRIDAY 19:30 WHATSGOINGONBOOK ENDOFDAYBOOK SETWEATHER")

SCHEDULE+=("SATURDAY 20:00 EVENINGBOOK SETWEATHER")
SCHEDULE+=("SATURDAY 21:00 ENDOFDAYBOOK VOLUMENORMALBOOK SETWEATHER")
SCHEDULE+=("SATURDAY 21:30 ENDOFDAYBOOK VOLUMENORMALBOOK SETWEATHER")
SCHEDULE+=("SATURDAY 22:00 ENDOFDAYBOOK SECURITYLIGHTSONBOOK SETWEATHER")



################################################################################################################################
# MAIN 

clear

GetPreReqs # CHECKS PREREQS - YOU CAN USE THIS FUNCTION FOR THE FIRST TIME RUNNING IT TO GET THE REQUIRED PACKAGES/BINARIES OR ISNTALL THEM MANUALLY

alexa_remote_control -l ; # LOGOUT
alexa_remote_control -login ; # LOGIN 
alexa_remote_control -d "${DEF_ECHO}" -e textcommand:"say hi" ; # TEST ALEXA FUNCTIONALY - FOR DEBUGGING PURPOSES

while true ; do
unset WAITINMIN WHATSUP SPEAKVOL
	GetHouseWeather; GetDateTimeFromInternet ; GetNextPlayBooks ; Menu
	for ((i=WAITINMIN;i>0;i--)); do WHATSUP="COUNTING DOWN FOR ${i} minutes ..." ; GetHouseWeather ; UpdateNow ; Menu ; sleep 60 ; done
    for x in "${NEXTPLAYBOOKS}"; do	for ((i=5;i>0;i--)); do export WHATSUP="RUNNING IN ${i} SECONDS: ${x}"; clear ; Menu; sleep 1s; clear; done ; ${x} ;  done
done


################################################################################################################################



