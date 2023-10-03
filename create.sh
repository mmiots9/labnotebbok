#!/bin/bash

createnotebook (){
    ##------ CHECK INPUT ------##
    if [[ $# -eq 0 ]]
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
    echo -e "NOTEBOOK_NAME='$*'
LAB_AUTHOR=\"$aut\"
LAST_COMMIT=no
LAST_DAY=no
SHOW_ANALYSIS_FILES=yes
LAB_CSS=.labnotebook/labstyles.css
ANALYSIS_EXT=('.html')" > .labnotebook/config 

    # Create HEAD
    echo "<\!DOCTYPE html>
<html lang=\"en\">
<head>
    <meta charset=\"UTF-8\">
    <meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\">
    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
    <title>$1 Lab notebook</title>
</head>" | awk '{print $0}' > .labnotebook/head.html

 sed -i '' 's/\\//' .labnotebook/head.html
    
    # Create BODY
    echo "<body>
<header>
<h1 id='labtitle'>$1 lab notebook</h1>
<p id='creationdate'>Created on: $today</p>
<p id='labauthor'>Author: $aut</p>
</header>
<main>

</main>
</body>" > .labnotebook/body.html
    
    # Create FOOTER
    echo "</html>" > .labnotebook/footer.html

    # Create CSS
    echo -e "
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

header {
    padding: 1rem;
}

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

details li {
  cursor: text;
  padding-left: 0.5em;
  font-size: 1em;
  margin-left: 3em;
}

p {
  margin: 0.2em 0em;
  font-size: 1em;
}

.analyses-el {
    display: block;
}

.analyses-el li {
    margin-left: 3em;
    padding-left: 0.5em;
}

.commit-el {
    padding: 1rem;
}


.sha-el {
  margin-top: 1em;
}
" > .labnotebook/labstyles.css
    
    ##------ CONFIRMATION MESSAGE ------##

    echo -e "\n$green .labnotebook folder succesfully created\n$red Mandatory: when updating the notebook, make sure you are in $(pwd)\n Never change .labnotebook folder name or content $ncol"

}

