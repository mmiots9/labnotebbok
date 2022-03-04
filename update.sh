#!/bin/bash

updatenotebook (){

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

    ##------ CHECK LAST COMMIT AND CREATE TEMP WITH COMMITS------##
    if [[ $LAST_COMMIT == "no" ]]
    then
    git log --oneline --reverse | awk '{print $1}' > .labnotebook/.tempCommitList.txt
    isno=1
    else
        # Check if $LASTCOMMIT is in commit history
        if [[ $(git log --oneline | awk '{print $1}' | grep $LAST_COMMIT | wc -l) -eq 0 ]]
        then
        echo -e "$red Error: Last commit used for the labnotebook ($LAST_COMMIT) is not in current git log.$ncol
        It is possible that you have changed commit history. Please check your git log and insert the commit sha to use in config file.
        "
        return
        fi
    isno=0
    # Create temporary from lastcommit
    git log --oneline $LAST_COMMIT..HEAD --reverse | awk '{print $1}' > .labnotebook/.tempCommitList.txt
    fi
    

    # Check if file is empty: LAST_COMMIT is the last commit yet
    nlines=$(cat .labnotebook/.tempCommitList.txt | wc -l | xargs)

    if [[ nlines -eq 0 ]]
    then
    yellow='\033[1;33m'
    echo -e "$yellow Warning: LAST_COMMIT is already the last commit in history"
    return
    fi



    for i in {1..$nlines}; do
    
        ##------ GET GIT INFO OF THE COMMITS ------##
        # commit sha
        comsha=$(head -n $i .labnotebook/.tempCommitList.txt | tail -n 1)

        # get all info
        if [[ isno -eq 1 ]]
        then
        gday=$(echo $(git log $comsha --pretty=format:"%cs")) # day
        gwhat=$(echo $(git log $comsha --pretty=format:"%s")) # what
        gmessage=$(echo $(git log $comsha --pretty=format:"%b")) # message
        gchanges=$(echo $(git log --pretty="format:" --name-status $comsha)) # changes
        else
          gday=$(echo $(git log $comsha^..$comsha --pretty=format:"%cs")) # day
          gwhat=$(echo $(git log $comsha^..$comsha --pretty=format:"%s")) # what
          gmessage=$(echo $(git log $comsha^..$comsha --pretty=format:"%b")) # message
          gchanges=$(echo $(git log --pretty="format:" --name-status $comsha^..$comsha)) # changes
        fi

        # check if SHOW_ANALYSIS_FILE
        if [[ $SHOW_ANALYSIS_FILES == "yes" ]]
        then
        # choose analysis filename
        echo -e "\ncommit: $comsha \nmessage: $gwhat"
        echo "Which is the analyses file with info about what you've done?" 
        echo $gchanges | awk  '{print NR, $2} END{print NR+1, "none"}'
        read fileans
        ganalysis=$(echo $gchanges | awk  '{print NR, $2} END{print NR+1, "none"}' | awk -v fileans="$fileans" '{if ($1 == fileans) print $2}')
        fi
        
        ##------ WRITE BODY ------##
        # Insert day if is different
        if [[ $LAST_DAY != $gday ]] 
        then 
        echo -e "\n<h2>$gday</h2>" >> .labnotebook/body.html
        fi

        # Insert all other info
        echo "
<h3>$gwhat</h3>
<p>$gmessage</p>
<p>sha: $comsha</p>
<p>Analysis file: $ganalysis</p>

<details>
  <summary>Affected files</summary>
  $(echo $gchanges | awk '{print "<li>", $0, "</li>"}')
</details>" >> .labnotebook/body.html


        # UPDATE DATE
        LAST_DAY=$gday

        isno=0
    done

##------ UPDATE LASTCOMMIT IN CONFIG ------## 
sed -i '' "s/LAST_COMMIT=.*/LAST_COMMIT=$comsha/" .labnotebook/config

##------ UPDATE LASTDAY in CONFIG ------## 
sed -i '' "s/LAST_DAY=.*/LAST_DAY=$gday/" .labnotebook/config

##------ DELETE TEMPCOMMIT ------## 
rm .labnotebook/.tempCommitList.txt

}
