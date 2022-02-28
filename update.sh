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

    # html
    if [[ $(find .labnotebook -iname $NOTEBOOK_NAME.html 2>&1 | grep -v 'No such file' | wc -l) -eq 0 ]]
    then
    echo -e "Error: There is not an .html file in .labnotebook matching NOTEBOOK_NAME variable from config.\nIf you have changed the name of the notebook, please change it also in config file."
    return
    fi

    ##------ CONFIRMATION ------##
    echo "Are you sure you want to update .labnotebook/$NOTEBOOK_NAME.html?"
    select yn in "Yes" "No"; do
    case $yn in
        Yes ) echo "updating..."; break;;
        No ) echo "update aborted"; return;;
    esac
    done

    ##------ CHECK LAST COMMIT AND CREATE TEMP WITH COMMITS------##
    if [[ $LASTCOMMIT -eq "no" ]]
    then
    git log --oneline --reverse | awk '{print $1}' > .labnotebook/.tempCommitList.txt
    else
        # Check if $LASTCOMMIT is in commit history
        if [[ $(git log --oneline | awk '{print $1}' | grep $LASTCOMMIT | wc -l) -eq 0 ]]
        then
        echo -e "$red Error: Last commit used for the labnotebook ($LASTCOMMIT) is not in current git log.$ncol
        It is possible that you have changed commit history. Please check your git log and insert the commit sha to use in config file.
        "
        return
        fi
    # Create temporary from lastcommit
    git log --oneline $LASTCOMMIT..HEAD --reverse | awk '{print $1}' > .labnotebook/.tempCommitList.txt
    fi

    ## WRITE IN A TEMP FILE

    nlines=$(cat .labnotebook/.tempCommitList.txt | wc -l | xargs)

    for i in {1..$nlines}; do
    
        ##------ GET GIT INFO OF THE COMMITS ------##
        # commit sha
        comsha=$(head -n $i .labnotebook/.tempCommitList.txt | tail -n 1)

        # get all info
        if [[ i -eq 1 ]]
        then
        gday=$(echo $(git log $comsha --pretty=format:"%cs")) # day
        gwhat=$(echo $(git log $comsha --pretty=format:"%s")) # what
        gmessage=$(echo $(git log $comsha --pretty=format:"%b")) # message
        gchanges=$(echo $(git log --pretty="format:" --name-status $comsha)) # changes


        # check if SHOW_ANALYSIS_FILE
        if [[ $SHOW_ANALYSIS_FILE -eq "yes" ]]
        then
        # choose filename
        echo -e "\ncommit: $comsha \nmessage: $gwhat"
        echo "Which is the analyses file with info about what you've done?"
        echo $gchanges | awk  '{print NR, $2} END{print NR+1, "none"}'
        read fileans

        ganalysis=$(echo $gchanges | awk  '{print NR, $2} END{print NR+1, "none"}' | awk -v fileans="$fileans" '{if ($1 == fileans) print $2}')
        fi
        else
          gday=$(echo $(git log $comsha^..$comsha --pretty=format:"%cs")) # day
          gwhat=$(echo $(git log $comsha^..$comsha --pretty=format:"%s")) # what
          gmessage=$(echo $(git log $comsha^..$comsha --pretty=format:"%b")) # message
          gchanges=$(echo $(git log --pretty="format:" --name-status $comsha^..$comsha)) # changes

          # check if SHOW_ANALYSIS_FILE
              if [[ $SHOW_ANALYSIS_FILE -eq "yes" ]]
              then
              # choose filename
              echo -e "\ncommit: $comsh \nmessage:$gwat"
              echo "Which is the analyses file with info about what you've done?" 
              echo $gchanges | awk  '{print NR, $2} END{print NR+1, "none"}'
              read fileans

              ganalysis=$(echo $gchanges | awk  '{print NR, $2} END{print NR+1, "none"}' | awk -v fileans="$fileans" '{if ($1 == fileans) print $2}')
              fi
        fi
        
        ##------ WRITE TEMP FILE ------##
        
        # delete </body> </html> from notebook
        grep -ve "^</html>" .labnotebook/$NOTEBOOK_NAME.html | grep -ve "^</body>" > .labnotebook/temp.$NOTEBOOK_NAME.html
        
        # Insert day if is different
        if [[ lastday -ne $gday ]] 
        then 
        echo "<h2 style='text-align: center;'>$gday</h1>" >> .labnotebook/temp.$NOTEBOOK_NAME.html
        fi
        
    done

#     # git log f3f2^..f3f2
}