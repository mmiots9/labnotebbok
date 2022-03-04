#!/bin/bash

createnotebook (){
    ##------ CHECK INPUT ------##
    if [[ $# -ne 1 ]]
    then
    echo "Error: You must enter a filename for the new lab notebook"
    return
    fi


    ##------ CREATE FOLDER ------##

    # Check if .git folder is present
    if [[ $(find -d .git 2>&1 | grep -v 'No such file' | wc -l) -eq 0 ]]
    then
    echo -e "Error: There is no .git folder in the current working directory. \nPlease go to the folder where .git is to create new notebook in the same folder"
    return
    fi

    # Create folder
    mkdir .labnotebook

    ##------ USEFUL VARIABLES ------##   
    today=$(date +'%b %d %Y')
    aut=$(git config --get user.name)
    red='\033[0;31m'
    green='\033[0;32m'
    ncol='\033[0m'

    ##------ POPULATE FOLDER ------##
    
    # Create config
    echo -e "NOTEBOOK_NAME=$1
LAST_COMMIT=no
LAB_AUTHOR=\"$aut\"
LAST_DAY=no
SHOW_ANALYSIS_FILES=yes
LAB_CSS=.labnotebook/labstyles.css" > .labnotebook/config 

    # Create notebook
    echo "<\!DOCTYPE html>
<html lang=\"en\">
<head>
    <meta charset=\"UTF-8\">
    <meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\">
    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
    <title>$1 Lab notebook</title>
</head>
<body>
<h1 style='text-align: center;'>$1 lab notebook</h1>
<p>Created on: $today</p>
<p>Author: $aut</p>
</body>
</html>
    " > .labnotebook/notebook.html

    eval $(echo mv .labnotebook/notebook.html .labnotebook/$1.html)
    
    ##------ ASK FOR GITIGNORE ------##

    echo "Do you wish to add .notebook folder to .gitignore?"
    select yn in "Yes" "No"; do
    case $yn in
        Yes ) echo ".labnotebook/*" >> .gitignore; break;;
        No ) echo ".notebook folder will be tracked by git"; break;;
    esac
    done

    ##------ CONFIRMATION MESSAGE ------##

    echo -e "\n$green.labnotebook/$1.html labnotebook succesfully created$ncol\n$red Mandatory: when updating the notebook, make sure you are in $(pwd)\n Never change .labnotebook folder name $ncol"

}

