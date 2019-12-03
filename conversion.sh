#!/bin/bash
#set -x
cvsUsername=$1
cvsPassword=$2
cvsAppName=$3
gitRepoName=$4
gitRemoteURL=$5
filesToDelete=""

#------------------------------------------------------------------
# Define Files(+ its history) you want to remove from repository: 
#------------------------------------------------------------------
secretFilesToDelete=(README.docx src/com/cool/project/services/service/SomeHelper.java)

#----------------------------------------------------------------------------------------------
# First prepare a replacement.txt file which has all the variables to replace
# Repeat below command for all the secret String you want to replace with ***REMOVED***
#----------------------------------------------------------------------------------------------
true > replacement.txt #this is for empty the file
echo 'error' >> replacement.txt
#echo '"secondSecretWordFromAnyFile"' >> replacement.txt


if [ ! -f "bfg.jar" ]; then
	echo -e '\e[96mdownloading bfg jar'
	curl http://repo1.maven.org/maven2/com/madgag/bfg/1.13.0/bfg-1.13.0.jar -o bfg.jar
fi

echo -e "\e[35m************ Getting project from CVS - start ************\e[0m"
mkdir -p cvs/CVSROOT
sshpass -v -p ${cvsPassword} scp -r ${cvsUsername}@10.40.40.40:/usr/webdev/cvsroot/$cvsAppName cvs
echo -e "\e[35m************ Getting project from CVS - done ************\e[0m"
echo
echo 

echo -e "\e[92m************ CVS TO GIT - start ************\e[0m"
if [ ! -d $PWD/git ]; then
		mkdir -p git/"$gitRepoName" && cd git/"$gitRepoName" && git cvsimport -v -a -k -d `realpath ../..`/cvs "$gitRepoName" && cd ../../
fi
echo -e "\e[92m************ CVS TO GIT - end ************\e[0m"

cd git/${gitRepoName};echo; echo -e "\e[44mWe are in this working directory\e[0m"; pwd;echo
 
echo 'secretFilesToDelete'; echo "$secretFilesToDelete[@]"
for FILE in "${secretFilesToDelete[@]}"
do
    echo "file $FILE"
	if [ ! -f "$FILE" ]
	then
		echo "******** $FILE does not exist"
		# exit 1
	else
		echo "******** $FILE does exist"
	fi
done

echo; echo -e "\e[45mBFG Operation starting\e[0m"; pwd; 
if [ -v secretFilesToDelete ]; then
	echo 'creating mirror repo'
	cd .. && git clone --mirror ${gitRepoName} ${gitRepoName}.git 
	
	echo -e "\e[44mcreating List of files from where secret needs to be removed.\e[0m"
	filesToDelete="{" 
	for FILE in "${secretFilesToDelete[@]}"
	do
		filesToDelete=${filesToDelete},`basename $FILE` 
	done
	filesToDelete=${filesToDelete}"}"
	
	java -jar ../bfg.jar --replace-text ../replacement.txt  -fi $filesToDelete --no-blob-protection ${gitRepoName}.git
	echo; echo -e "\e[44mPruning and cleaning\e[0m"
	cd ${gitRepoName}.git && git reflog expire --expire=now --all && git gc --prune=now --aggressive
	git remote set-url origin $gitRemoteURL
	echo; echo -e "\e[44mPushing to remote.\e[0m"
	git push
	echo; echo -e "\e[45mBFG Operation finished, repository is pushed to remote.\e[0m"; 
else	
	git push -u origin -all
fi
