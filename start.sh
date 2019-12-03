#!/bin/bash
# Description:  A wrapper script used to stop/start another script.

#--------------------------------------
# Define Global Environment Settings:
#--------------------------------------

# Name and location of a persistent PID file
cvsUsername='MKumar'
cvsPassword='cvsPassword'
cvsAppName='project1'
gitRepoName='project1'
gitRemoteURL='https://MKumar-001@dev.azure.com/MKumar-001/TestProject/_git/project1'
gitPassword='gitPasswordHash'


#--------------------------------------------------------------------------------------------------------------
# Define Files(+ its history, secretFilesToDelete) from which, you want to replace secrets in conversion.sh
#--------------------------------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------------------------------
# Define secrets(+ its history) you want to replace with text: ***REMOVED*** from repository in conversion.sh
#--------------------------------------------------------------------------------------------------------------


#-----------------------------------------------------
# Script does following:
# 1) Convert cvs to git
# 2) Remove secrets from git using bfg
# 3) Push git repo to git remote using gitRemoteURL
#-----------------------------------------------------
./conversion.sh ${cvsUsername} ${cvsPassword} ${cvsAppName} ${gitRepoName} ${gitRemoteURL} 
