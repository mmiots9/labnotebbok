#!/bin/bash

labnotebook() {

    ##------ CHECK INPUT ------##
    if [[ $# -ne 1 ]]
    then
    echo "Usage: labnotebook --version"
    return
    fi

    if [[ $1 != "--version" ]]
    then
    echo "Usage: labnotebook --version"
    return
    fi

    ##------ PRINT VERSION ------##
    echo "1.1.2-MacOS"

}