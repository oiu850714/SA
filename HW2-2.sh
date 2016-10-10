#!/usr/local/bin/bash

# SA HW2-2
# convention:
# 1.	All string comparisons use [ "${str}" == "YOU_WANT_TO_COMPARE" ]
#	to prevent "unset variable syntax error".

#declare const

: ${DIALOG_OK=0}
: ${DIALOG_CANCEL=1}
: ${DIALOG_HELP=2}
: ${DIALOG_EXTRA=3}
: ${DIALOG_ITEM_HELP=4}
: ${DIALOG_ESC=255}

#declare variable

URL="https://google.com"
# URL is the url the browser will go to.

#Open the browser and check user's agreement

dialog --title "Terms and Conditions of Use" --yesno "$(cat .mybrowser/useterm)" 200 100
return_value="${?}"
if [ "${return_value}" == "${DIALOG_OK}" ]; then
        dialog --title "Home Page" --msgbox "$(w3m  "${URL}")" 200 100
elif [ "${return_value}" == "${DIALOG_CANCEL}" ]; then
	dialog --title "Apology" --msgbox "Sorry, you can't use Mango browser" 200 100
fi

# open an inputbox to receive user's input, check whether it's an url

dialog --title "Mango Browser"  --inputbox "${URL}" 200 100
return_value="${?}"
if [ "${return_value}" == "${DIALOG_CANCEL}" ]; then
	dialog --title "Exit" --msgbox "Bye Bye!!" 200 100
	exit 0
fi


