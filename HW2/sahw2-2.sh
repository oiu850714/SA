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

# open an agreement yesno box, and user needs to select yes

dialog --title "Terms and Conditions of Use" --yesno "$(cat ~/.mybrowser/useterm)" 200 100
return_value="${?}"
if [ "${return_value}" == "${DIALOG_OK}" ]; then
    dialog --title "Home Page" --msgbox "$(w3m  "${URL}")" 200 100
elif [ "${return_value}" == "${DIALOG_CANCEL}" ]; then
    dialog --title "Apology" --msgbox "Sorry, you can't use Mango browser" 200 100
    exit 0
fi

# open an inputbox to receive user's input, check whether it's url, built in, shell command, or fucking shit

while true;
do
    exec 3>&1
    new_URL=$(dialog --title "Mango Browser"  --inputbox "${URL}" 200 100 2>&1 1>&3 3>&-)
    return_value="${?}"
    # if user select cancel, then return value will be "0" (DIALOG_CANCEL)
    if [ "${return_value}" == "${DIALOG_CANCEL}" ]; then
        dialog --title "Exit" --msgbox "Bye Bye!!" 200 100
        exit 0
    # user select OK
    elif [ "${return_value}" == "${DIALOG_OK}" ]; then
        url_result=$(w3m -dump "${new_URL}" 2>/dev/null)
        # if new_URL is a valid directory path, w3m will dump this path's content
        # and url_result will not be empty
        if [ "${url_result}" != "" ]; then
            dialog --title "Page" --msgbox "${url_result}" 200 100
            URL="${new_URL}"
        else
        ######### this else block deals with case that input is bulit in command
        ######### or shell command or fucking shit
            maybe_built_in=$(echo "${new_URL}" | grep "^/.*")
            # if maybe_bulit_in isn't empty, then input is a built in command
            
            maybe_shell_command=$(echo "${new_URL}" | grep "^!.*")
            # if maybe_shell_command isn't empty, then input is a shell command

            if [ "${maybe_built_in}" != "" ]; then
                case "${new_URL}" in
                    "/S")
                    dialog --title "Mango Browser" --msgbox "$(curl -s ${URL})" 200 100
                    ;;
                    "/source")
                    dialog --title "Mango Browser" --msgbox "$(curl -s ${URL})" 200 100
                    ;;
                    "/L")
                    all_link=$(lynx -dump -listonly "${URL}" | grep "[[:digit:]]")
                    return_value="${?}"
                    exec 3>&1
                    return_tag=$(dialog --title "Mango Browser" --menu "Links"  200 100 40 ${all_link} 2>&1 1>&3 3>&-)
                    return_cancel="${?}"
                    if [ "${return_cancel}" != "0" ];then
                        continue
                    fi
                    #same redirection trick with inputbox
                    return_tag=$(echo "${return_tag}" | cut -d '.' -f1)
                    if [ "${return_value}" != "0" ];then
                        continue
                    fi
                    link="$(echo ${all_link} | cut -d ' ' -f $((2*${return_tag})))"
                    URL="${link}"
                    dialog --title "Mango Browser" --msgbox "$(w3m  "${URL}")" 200 100
                    ;;
                    "/link")
                    all_link=$(lynx -dump -listonly "${URL}" | grep "[[:digit:]]")
                    return_value="${?}"
                    exec 3>&1
                    return_tag=$(dialog --title "Mango Browser" --menu "Links"  200 100 40 ${all_link} 2>&1 1>&3 3>&-)
                    return_cancel="${?}"
                    if [ "${return_cancel}" != "0" ];then
                        continue
                    fi
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
                    return_cancel="${?}"
                    if [ "${return_cancel}" != "0" ];then
                        continue
                    fi
                    #same redirection trick with inputbox
                    return_tag=$(echo "${return_tag}" | cut -d '.' -f1)
                    if [ "${return_value}" != "0" ];then
                        continue
                    fi
                    link="$(echo ${all_link} | cut -d ' ' -f $((2*${return_tag})))"
                    wget ${URL} -P ~/Downloads/
                    ;;
                    "/download")
                    all_link=$(lynx -dump -listonly "${URL}" | grep "[[:digit:]]")
                    return_value="${?}"
                    exec 3>&1
                    return_tag=$(dialog --title "Mango Browser" --menu "Links"  200 100 40 ${all_link} 2>&1 1>&3 3>&-)
                    return_cancel="${?}"
                    if [ "${return_cancel}" != "0" ];then
                        continue
                    fi
                    #same redirection trick with inputbox
                    return_tag=$(echo "${return_tag}" | cut -d '.' -f1)
                    if [ "${return_value}" != "0" ];then
                        continue
                    fi
                    link="$(echo ${all_link} | cut -d ' ' -f $((2*${return_tag})))"
                    wget ${URL} -P ~/Downloads/
                    ;;
                    "/B")
                    exec 3>&1
                    return_tag=$(dialog --title "Mango Browser" --menu "Bookmarks:"  200 100 50 $(cat  -n ~/.mybrowser/bookmark) 2>&1 1>&3 3>&-)
                    return_cancel="${?}"
                    if [ "${return_cancel}" != "0" ];then
                        continue
                    fi
                    case "${return_tag}" in
                        "1")
                        exec 3>&1
                        add_URL=$(dialog --title "Mango Browser"  --inputbox "Add a bookmark" 200 100 2>&1 1>&3 3>&-)
                        # case when user enter directly or cancel, echo will add a empty line, which crash the /B case
                        if [ "${add_URL}" != "" ]; then
                            echo "${add_URL}">> ~/.mybrowser/bookmark
                        fi
                        ;;
                        "2")
                        #delete_a_bookmark
                        exec 3>&1
                        return_tag=$(dialog --title "Mango Browser" --menu "Delete Bookmark:" 200 100 50 $(cat ~/.mybrowser/bookmark | awk 'BEGIN{line=1} line>=3 {print line-2; print;} {line++}') 2>&1 1>&3 3>&- )
                        new_bookmarks=$( echo $(cat ~/.mybrowser/bookmark) | cut -d ' ' -f 1-$((${return_tag}-1+2)) -f $((${return_tag} + 1+2))- )
                        echo ${new_bookmarks} | xargs -n 1 > ~/.mybrowser/bookmark
                        ;;
                        *)
                        link=$(echo $(cat ~/.mybrowser/bookmark) | cut -d ' ' -f ${return_tag})
                        URL="${link}"
                        dialog --title "Mango Browser" --msgbox "$(w3m "${URL}")" 200 100
                        ;;
                    esac
                    ;;
                    "/bookmark")
                    exec 3>&1
                    return_tag=$(dialog --title "Mango Browser" --menu "Bookmarks:"  200 100 50 $(cat  -n ~/.mybrowser/bookmark) 2>&1 1>&3 3>&-)
                    return_cancel="${?}"
                    if [ "${return_cancel}" != "0" ];then
                        continue
                    fi
                    case "${return_tag}" in
                        "1")
                        exec 3>&1
                        add_URL=$(dialog --title "Mango Browser"  --inputbox "Add a bookmark" 200 100 2>&1 1>&3 3>&-)
                        # case when user enter directly or cancel, echo will add a empty line, which crash the /B case
                        if [ "${add_URL}" != "" ]; then
                            echo "${add_URL}">> ~/.mybrowser/bookmark
                        fi
                        ;;
                        "2")
                        #delete_a_bookmark
                        exec 3>&1
                        return_tag=$(dialog --title "Mango Browser" --menu "Delete Bookmark:" 200 100 50 $(cat ~/.mybrowser/bookmark | awk 'BEGIN{line=1} line>=3 {print line-2; print;} {line++}') 2>&1 1>&3 3>&- )
                        new_bookmarks=$( echo $(cat ~/.mybrowser/bookmark) | cut -d ' ' -f 1-$((${return_tag}-1+2)) -f $((${return_tag} + 1+2))- )
                        echo ${new_bookmarks} | xargs -n 1 > ~/.mybrowser/bookmark
                        ;;
                        *)
                        link=$(echo $(cat ~/.mybrowser/bookmark) | cut -d ' ' -f ${return_tag})
                        URL="${link}"
                        dialog --title "Mango Browser" --msgbox "$(w3m "${URL}")" 200 100
                        ;;
                    esac
                    ;;
                    "/H")
                    dialog --title "Mango Browser" --msgbox "$(cat ~/.mybrowser/help)" 200 100
                    ;;
                    "/help")
                    dialog --title "Mango Browser" --msgbox "$(cat ~/.mybrowser/help)" 200 100
                    ;;
                    *)
                    invalid_input
                    continue
                    ;;
                    esac
            elif [ "${maybe_shell_command}" != "" ]; then
                delete_exclam="$(echo "${maybe_shell_command}" | cut -c 2-)"
                dialog --title "Mango Browser" --msgbox "$(${delete_exclam} 2>>~/.mybrowser/command_error)" 200 100
            else
                dialog --title "Mango Browser" --msgbox "$(cat ~/.mybrowser/invalid_input)" 200 100
            fi
        fi
    fi
done
