#!/bin/bash

updatenotebook (){

  ##------ USEFUL VARIABLES------##
    red='\033[0;31m'
    yellow='\033[1;33m'

    ##------ CHECK FILES------##

    # .labnotebook
    if [[ $(find -d .labnotebook 2>&1 | grep -v 'No such file' | wc -l) -eq 0 ]]
    then
    echo -e "$red Error: There is no .labnotebook folder in the current working directory. \nPlease go to the folder where .labnotebook is."
    return
    fi

    # config
    if [[ $(find .labnotebook -iname config 2>&1 | grep -v 'No such file' | wc -l) -eq 0 ]]
    then
    echo -e "$red Error: There is no config file in .labnotebook folder. Please provide config file"
    return
    fi

    # Source config file
    source .labnotebook/config

    ##------ CONFIRMATION ------##
    echo "Are you sure you want to update $NOTEBOOK_NAME labnotebook?"
    select yn in "Yes" "No"; do
    case $yn in
        Yes ) echo "updating..."; break;;
        No ) echo "update aborted"; return;;
    esac
    done

    ##------ EVAL IF THERE ARE STAGED FILES WHILE LAB_IGNORE == "NO" AND STOP THE FUNCTION------## 
    if [[ "$LAB_IGNORE" == "no" ]]
    then 
      if [[ $(git status | grep "Changes to be committed:" | wc -l | xargs) != 0 ]]
      then
      echo -e "$red Error: you have staged files to be committed. This is incompatible with updatenotebook. \n Please commit those changes or restore the files prior to launch this function"
      return
      fi
    fi

    ##------ CHECK LAST COMMIT AND CREATE TEMP WITH COMMITS------##
    if [[ "$LAST_COMMIT" == "no" ]]
    then
    git log --author='^(?!labnotebook).*$' --perl-regexp --oneline --reverse | awk '{print $1}' > .labnotebook/.tempCommitList.txt
    isno=1
    else
        # Check if $LASTCOMMIT is in commit history
        if [[ $(git log --author='^(?!labnotebook).*$' --perl-regexp --oneline | awk '{print $1}' | grep $LAST_COMMIT | wc -l) -eq 0 ]]
        then
        echo -e "$red Error: Last commit used for the labnotebook ($LAST_COMMIT) is not in current git log.$ncol
        It is possible that you have changed commit history. Please check your git log and insert the commit sha to use in config file.
        "
        return
        fi
    isno=0
    # Create temporary from lastcommit
    git log --author='^(?!labnotebook).*$' --perl-regexp --oneline $LAST_COMMIT..HEAD --reverse | awk '{print $1}' > .labnotebook/.tempCommitList.txt
    fi
    

    # Check if file is empty: LAST_COMMIT is the last commit yet
    nlines=$(cat .labnotebook/.tempCommitList.txt | wc -l | xargs)

    if [[ nlines -eq 0 ]]
    then
    echo -e "$yellow Warning: LAST_COMMIT is already the last commit in history"
    rm .labnotebook/.tempCommitList.txt
    return
    fi



    for i in $(seq 1 1 $nlines); do
    
        ##------ GET GIT INFO OF THE COMMITS ------##
        # commit sha
        comsha=$(head -n $i .labnotebook/.tempCommitList.txt | tail -n 1)

        # get all info
        if [[ isno -eq 1 ]]
        then
        gday=$(echo $(git log $comsha^..$comsha --pretty=format:'%cI' | sed 's/T.*//')) # day
        gwhat=$(echo $(git log $comsha --pretty=format:"%s")) # what
        gmessage=$(echo $(git log $comsha --pretty=format:"%b")) # message
        gchanges=$(git log --pretty="format:" --name-status $comsha) # changes
        else
          gday=$(echo $(git log $comsha^..$comsha --pretty=format:'%cI' | sed 's/T.*//')) # day
          gwhat=$(echo $(git log $comsha^..$comsha --pretty=format:"%s")) # what
          gmessage=$(echo $(git log $comsha^..$comsha --pretty=format:"%b")) # message
          gchanges=$(git log --pretty="format:" --name-status $comsha^..$comsha) # changes
        fi

        # check if SHOW_ANALYSIS_FILE
        if [[ $ASK_ANALYSIS_FILES == "yes" ]]
        then
        # choose analysis filename
        echo -e "\ncommit: $comsha \nmessage: $gwhat"
        echo "Which is the analyses file with info about what you've done?" 
        echo "$gchanges" | awk  '{print NR, $2} END{print NR+1, "none"}'
        read fileans
        ganalysis=$(echo "$gchanges" | awk  '{print NR, $2} END{print NR+1, "none"}' | \
        awk -v fileans="$fileans" '{if ($1 == fileans) {if ($2 != "none") {print "<code><a href=\"" $2 "\" target=\"_blank\">" $2 "</a></code>"} else {print "<code>" $2 "</code>"}}}')
        fi
        
        ##------ WRITE BODY ------##
        # Insert day if is different
        if [[ $LAST_DAY != $gday ]] 
        then 
        echo -e "\n<h2 class='day-el'>$gday</h2>" >> .labnotebook/body.html
        fi

        # Insert all other info
        echo "
<h3 class='what-el'>$gwhat</h3>
<p class='mess-el'>$gmessage</p>
<p class='sha-el'>sha: $comsha</p>
<p class='analyses-el'>Analysis file: $ganalysis</p>

<details>
  <summary>Affected files</summary>
  $(echo "$gchanges" | awk '{print "<li>", $0, "</li>"}')
</details>" >> .labnotebook/body.html


        # UPDATE DATE
        LAST_DAY=$gday

        isno=0
    done

##------ UPDATE LASTCOMMIT IN CONFIG ------## 
sed -i "s/LAST_COMMIT=.*/LAST_COMMIT=$comsha/" .labnotebook/config

##------ UPDATE LASTDAY in CONFIG ------## 
sed -i "s/LAST_DAY=.*/LAST_DAY=$gday/" .labnotebook/config

##------ DELETE TEMPCOMMIT ------## 
rm .labnotebook/.tempCommitList.txt

##------ EVAL IF COMMIT ------## 
if [[ "$LAB_IGNORE" == "no" ]]
then 

# add .labnotebook files
git add .labnotebook/*
GIT_COMMITTER_NAME="labnotebook" GIT_COMMITTER_EMAIL="labnotebook@email.com" git commit --author="labnotebook <labnotebook@email.com>" -m "update notebook" >/dev/null
fi


}
