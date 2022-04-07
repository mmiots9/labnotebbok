#!/bin/bash

exportnotebook () {

    ##------ CHECK INPUT ------##
    if [[ $# -ne 1 ]]
    then
    echo "Error: You must enter a filename for the new lab notebook"
    return
    fi

    ##------ CHECK FILES------##

    # .labnotebook
    if [[ $(find -d .labnotebook 2>&1 | grep -v 'No such file' | wc -l) -eq 0 ]]
    then
    echo -e "Error: There is no .labnotebook folder in the current working directory. \nPlease go to the folder where .labnotebook is."
    return
    fi

    # config
    if [[ $(find .labnotebook -iname config 2>&1 | grep -v 'No such file' | wc -l) -eq 0 ]]
    then
    echo -e "Error: There is no config file in .labnotebook folder. Please provide config file"
    return
    fi

    source .labnotebook/config

    # head
    if [[ $(find .labnotebook -iname head.html 2>&1 | grep -v 'No such file' | wc -l) -eq 0 ]]
    then
    echo -e "Error: There is no head.html file in .labnotebook folder."
    return
    fi

    # body
    if [[ $(find .labnotebook -iname body.html 2>&1 | grep -v 'No such file' | wc -l) -eq 0 ]]
    then
    echo -e "Error: There is no body.html file in .labnotebook folder."
    return
    fi

    # footer
    if [[ $(find .labnotebook -iname footer.html 2>&1 | grep -v 'No such file' | wc -l) -eq 0 ]]
    then
    echo -e "Error: There is no footer.html file in .labnotebook folder."
    return
    fi

    # css
    if [[ $(find $LAB_CSS 2>&1 | grep -v 'No such file' | wc -l) -eq 0 ]]
    then
    echo -e "Error: There is no $LAB_CSS file"
    return
    fi

    ##------ ASK IF SUBSTITUTE DESTINATION FILE ------##

    if [[ $(find $1 2>&1 | grep -v 'No such file' | wc -l) -eq 1 ]]
    then 
    echo "Are you sure you want to overwrite $1?"  
    select yn in "Yes" "No"; do
    case $yn in
        Yes ) echo "writing file..."; break;;
        No ) echo "you have stopped the export"; return;;
    esac
    done
    fi

    ##------ WRITE HEAD ------##
    cat .labnotebook/head.html >| $1

    ##------ EVALUATE IF SHOW_ANALYSIS_FILES AND CHANGE CSS ------## 
    if [[ $SHOW_ANALYSIS_FILES == "yes" ]] 
    then
    sed -i '' '/analyses-el/,/}/s/\(display: \).*$/\1block;/' .labnotebook/labstyles.css
    else
    sed -i '' '/analyses-el/,/}/s/\(display: \).*$/\1none;/' .labnotebook/labstyles.css
    fi

    ##------ ASK IF CSS IN HEAD ------##
    echo "Do you want $LAB_CSS to be copied in html head as <style> or it must be linked?"
    select yn in "Copied" "Linked"; do
    case $yn in
        Copied ) echo "<style>" >> $1; cat $LAB_CSS >> $1; echo "</style>" >> $1; break;;
        Linked ) echo "<link rel=\"stylesheet\" href=\"$LAB_CSS\">"; break;;
    esac
    done

    ##------ WRITE BODY ------##
    cat .labnotebook/body.html >> $1

    ##------ WRITE FOOTER ------##
    cat .labnotebook/footer.html >> $1

}