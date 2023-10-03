#!/bin/bash

updatenotebook (){

  ##------ USEFUL VARIABLES------##
    red='\033[0;31m'
    yellow='\033[1;33m'

    ##------ CHECK FILES------##

    # .labnotebook
    if [ ! -d ".labnotebook" ]; 
    then
    echo -e "$red Error: There is no .labnotebook folder in the current working directory. \nPlease go to the folder where .labnotebook is."
    return
    fi

    # config
    if [ ! -f ".labnotebook/config" ];
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
    if [[ $(git status | grep "Changes to be committed:" | wc -l | xargs) != 0 ]]
    then
    echo -e "$red Error: you have staged files to be committed. This is incompatible with updatenotebook. \n Please commit those changes, restore the files or stage them prior to launch this function"
    return
    fi

    ##------ FORCE UPDATE ------## 
    if [[ $1 == "--force-update" ]] 
    then
      # reset LAST_COMMIT and LAST_DAY
      LAST_COMMIT=no
      LAST_DAY=no 

      # remove content in main
      sed -i '' '/<main>/,/<\/main>/ {//!d;}' .labnotebook/body.html
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
        echo -e "$red Error: Last commit used for the labnotebook ($LAST_COMMIT) is not in current git log history.$ncol
        It is possible that you have changed commit history. Please check your git log and insert the commit sha to use in config file or force the update to start again from the beginning of the git history using updatenotebook --force-update
        "
        return
        fi
    isno=0
    # Create temporary from lastcommit
    git log --author='^(?!labnotebook).*$' --perl-regexp --oneline $LAST_COMMIT..HEAD --reverse | awk '{print $1}' > .labnotebook/.tempCommitList.txt
    fi
    

    # Check if LAST_COMMIT is the last commit yet
    nlines_commits=$(cat .labnotebook/.tempCommitList.txt | wc -l | xargs)

    if [[ nlines_commits -eq 0 ]]
    then
    echo -e "$yellow Warning: LAST_COMMIT is already the last commit in history"
    rm .labnotebook/.tempCommitList.txt
    return
    fi

    ##------ REMOVE MAIN AND BODY CLOSING TAG ------##
    sed -i  '' '/<\/main>/,/<\/body>/d' .labnotebook/body.html


    # Loop through commits
    while read -r comsha
    do
    
        ##------ GET GIT INFO OF THE COMMITS ------##

        # get all info
        if [[ isno -eq 1 ]]
        then
        gday=$(echo $(git log $comsha --pretty=format:'%cs' )) # day
        gwhat=$(echo $(git log $comsha --pretty=format:"%s")) # what
        gmessage=$(echo $(git log $comsha --pretty=format:"%b")) # message
        gchanges=$(git log --pretty="format:" --name-status $comsha | awk '{if ($3) print $1 "&nbsp;&nbsp;&nbsp;&nbsp;", $2 " -> " $3; else print $1 "&nbsp;&nbsp;&nbsp;&nbsp;", $2}') # changes
        else
          gday=$(echo $(git log $comsha^..$comsha --pretty=format:'%cs' )) # day
          gwhat=$(echo $(git log $comsha^..$comsha --pretty=format:"%s")) # what
          gmessage=$(git log $comsha^..$comsha --pretty=format:"%b") # message
          gchanges=$(git log --pretty="format:" --name-status $comsha^..$comsha | awk '{if ($3) print $1 "&nbsp;&nbsp;&nbsp;&nbsp;", $2 " -> " $3; else print $1 "&nbsp;&nbsp;&nbsp;&nbsp;", $2}') # changes
        fi

        # check if SHOW_ANALYSIS_FILE

        ganalysis=''

        analysis_files=()

        # Capture the output of the pipeline into a variable using process substitution
        while IFS= read -r filename; do
          excluded=0  # Numeric flag to track if the filename is excluded
        
          # Check the presence of .labignore and ignore those files
          if [ -f '.labignore' ]; then
            exclude_patterns=()
            while IFS= read -r pattern; do
              exclude_patterns+=("$pattern")
            done < ".labignore"
        
            for pattern in "${exclude_patterns[@]}"; do
              if [[ "$filename" =~ $pattern ]]; then
                excluded=1
                break
              fi
            done
          fi
        
          # Only add the filename if it's not excluded and matches the desired extensions
          if [[ $excluded -eq 0 ]]; then
            for ext in "${ANALYSIS_EXT[@]}"; do
              if [[ "$filename" == *"$ext" ]]; then
                analysis_files+=("$filename")  # Add the filename to the array
                break
              fi
            done
          fi
        done < <(echo "$gchanges" | awk '$1 !~ /^D/ {if ($3) print $3; else print $2}')

        # Check if there are no analysis files and insert none, otherwhise loop through files and create list
        if [[ ${#analysis_files[@]} -eq 0 ]]; then
          ganalysis='<code>none</code>'
        else
          ganalysis='<ul class="analysis_list">'
          for file in "${analysis_files[@]}"; do
            ganalysisnew=$(echo "<li><code><a href='$file'>$file</a></code></li>")
            ganalysis=$(echo -e $ganalysis "\n" $ganalysisnew)
          done
          ganalysis=$(echo -e $ganalysis "\n</ul>")
        fi

        ##------ WRITE BODY ------##
        # Insert day if is different
        if [[ $LAST_DAY != $gday ]] 
        then 
        echo -e "\n<h2 class='day-el'>$gday</h2>" >> .labnotebook/body.html
        fi

        # check if gmessage is empty
        nwmessage=$(echo $gmessage | wc -w | xargs)


        # Insert all other info
        echo "
<div class='commit-el' id='$comsha'>
<h3 class='what-el'>$gwhat</h3>
<p class='mess-el'>$(echo $gmessage | awk -v nwmessage="$nwmessage"  '{if (nwmessage != "0") {print $0, "<br>"}}')</p>
<p class='sha-el'>sha: $comsha</p>
<div class='analyses-el'>Analysis file/s:
$(echo $ganalysis)
</div>
<br>
<details>
  <summary>Changed files</summary>
  <ul>
  $(echo "$gchanges" | awk '{print "<li>", $0, "</li>"}')
  </ul>
</details>
</div>" >> .labnotebook/body.html


        # UPDATE DATE
        LAST_DAY=$gday

        isno=0

        ##------ UPDATE LASTCOMMIT IN CONFIG ------## 
        sed -i '' "s/LAST_COMMIT=.*/LAST_COMMIT=$comsha/" .labnotebook/config

        ##------ UPDATE LASTDAY in CONFIG ------## 
        sed -i ''  "s/LAST_DAY=.*/LAST_DAY=$gday/" .labnotebook/config

    done < .labnotebook/.tempCommitList.txt

##------ INSERT MAIN AND BODY CLOSING TAG ------##
echo "</main>" >> .labnotebook/body.html
echo "</body>" >> .labnotebook/body.html





##------ DELETE TEMPCOMMIT ------## 
rm .labnotebook/.tempCommitList.txt

# add .labnotebook files
git add .labnotebook/*
GIT_COMMITTER_NAME="labnotebook" GIT_COMMITTER_EMAIL="labnotebook@email.com" git commit --author="labnotebook <labnotebook@email.com>" -m "update notebook" >/dev/null

}

