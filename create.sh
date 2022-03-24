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
    today=$(date +'%Y-%m-%d')
    aut=$(git config --get user.name)
    red='\033[0;31m'
    green='\033[0;32m'
    ncol='\033[0m'

    ##------ POPULATE FOLDER ------##
    
    # Create config
    echo -e "NOTEBOOK_NAME=$1
LAB_AUTHOR=\"$aut\"
LAST_COMMIT=no
LAST_DAY=no
ASK_ANALYSIS_FILES=yes
SHOW_ANALYSIS_FILES=yes
LAB_CSS=.labnotebook/labstyles.css" > .labnotebook/config 

    # Create HEAD
    echo "<\!DOCTYPE html>
<html lang=\"en\">
<head>
    <meta charset=\"UTF-8\">
    <meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\">
    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
    <title>$1 Lab notebook</title>" | awk '{print $0}' > .labnotebook/head.html

 sed -i '' 's/\\//' .labnotebook/head.html
    
    # Create BODY
    echo "</head>
<body>
<h1>$1 lab notebook</h1>
<p>Created on: $today</p>
<p>Author: $aut</p>" > .labnotebook/body.html
    
    # Create FOOTER
    echo "</body>
</html>" > .labnotebook/footer.html

    # Create CSS
    echo -e "
h1 {
    color: red;
    text-align: center;
    font-size: 2.5em;
}

h2 {
    text-align: center;
    border: 1px solid red;
    font-size: 1.875em;
}

h3 {
    font-weight: bold;
    margin: 1em 0em 0.2em 0em;
    font-size: 1.2em;
}

details {
	font-size: 1em;
	cursor: pointer;
	display: inline
}

details > li {
  padding-left: 2em;
  font-size: 1em;
}

p {
  margin: 0.2em 0em;
  font-size: 1em;
}
    " > .labnotebook/labstyles.css
    
    ##------ ASK FOR GITIGNORE ------##

    echo "Do you wish to add .notebook folder to .gitignore?"
    select yn in "Yes" "No"; do
    case $yn in
        Yes ) echo ".labnotebook/*" >> .gitignore; echo "LAB_IGNORE=yes" >> .labnotebook/config; break;;
        No ) echo ".notebook folder will be tracked by git"; echo "LAB_IGNORE=no" >> .labnotebook/config; break;;
    esac
    done

    ##------ CONFIRMATION MESSAGE ------##

    echo -e "\n$green .labnotebook folder succesfully created\n$red Mandatory: when updating the notebook, make sure you are in $(pwd)\n Never change .labnotebook folder name or content $ncol"

}

