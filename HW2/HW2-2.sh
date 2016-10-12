#!/bin/sh

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
tmpfile="tmp.txt"
# URL is the url the browser will go to.

#Open the browser and check user's agreement

invalid_input()
{
    dialog --title "Mango Browser" --msgbox "$(cat ~/.mybrowser/invalid_input)" 200 100
}


dialog --title "Terms and Conditions of Use" --yesno "$(cat ~/.mybrowser/useterm)" 200 100
return_value="${?}"
if [ "${return_value}" == "${DIALOG_OK}" ]; then
    dialog --title "Home Page" --msgbox "$(w3m  "${URL}")" 200 100
elif [ "${return_value}" == "${DIALOG_CANCEL}" ]; then
    dialog --title "Apology" --msgbox "Sorry, you can't use Mango browser" 200 100
    exit 0
fi

# open an inputbox to receive user's input, check whether it's an url

while true;
do
    exec 3>&1
    new_URL=$(dialog --title "Mango Browser"  --inputbox "${URL}" 200 100 2>&1 1>&3 3>&-)
    return_value="${?}"
    if [ "${return_value}" == "${DIALOG_CANCEL}" ]; then
        dialog --title "Exit" --msgbox "Bye Bye!!" 200 100
        exit 0
    elif [ "${return_value}" == "${DIALOG_OK}" ]; then
        url_result=$(w3m -dump "${new_URL}" 2>/dev/null)
        # if new_URL is a valid directory path, w3m will dump this path's content
        if [ "${url_result}" != "" ]; then
            dialog --title "Page" --msgbox "${url_result}" 200 100
            URL="${new_URL}"
        else
            maybe_bulit_in=$(echo "${new_URL}" | grep "^/.*")
            # "^/.*" first char is '/', and .* means any string 
            return_value="${?}"
            if [ ${return_value} == "0" ]; then
                case "${new_URL}" in
                    "/S")
                    dialog --title "Mango Browser" --msgbox "$(curl -s ${URL})" 200 100
                    ;;
                    "/L")
                    all_link=$(lynx -dump -listonly "${URL}" | grep "[[:digit:]]")
                    return_value="${?}"
                    exec 3>&1
                    return_tag=$(dialog --title "Mango Browser" --menu "Links"  200 100 40 ${all_link} 2>&1 1>&3 3>&-)
                    #same redirection trick with inputbox
                    return_tag=$(echo "${return_tag}" | cut -d '.' -f1)
                    if [ "${return_value}" != "0" ];then
                        continue
                    fi
                    link="$(echo ${all_link} | cut -d ' ' -f $((2*${return_tag})))"
                    URL="${link}"
                    dialog --title "Mango Browser" --msgbox "$(w3m  "${URL}")" 200 100
                    ;;			
                    "/D")
                    all_link=$(lynx -dump -listonly "${URL}" | grep "[[:digit:]]")
                    return_value="${?}"
                    exec 3>&1
                    return_tag=$(dialog --title "Mango Browser" --menu "Links"  200 100 40 ${all_link} 2>&1 1>&3 3>&-)
                    #same redirection trick with inputbox
                    return_tag=$(echo "${return_tag}" | cut -d '.' -f1)
                    if [ "${return_value}" != "0" ];then
                        continue
                    fi
                    link="$(echo ${all_link} | cut -d ' ' -f $((2*${return_tag})))"
                    wget ${URL} -P ~/Downloads/
                    ;;
                    "/B")
                    ;;
                    "/H")
                    dialog --title "Mango Browser" --msgbox "$(cat ~/.mybrowser/help)" 200 100
                    ;;
                    *)
                    invalid_input
                    continue
                    ;;
                    esac
            else
                dialog --title "Mango Browser" --msgbox "$(cat ~/.mybrowser/invalid_input)" 200 100
            fi
        fi
    fi
done
