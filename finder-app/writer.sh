#!/bin/sh

if [ $# -lt 2 ]
then
    echo "Too few arguments. " $0 "is exiting."
    exit 1
elif [ $# -gt 2 ]
then 
    echo "Too many arguments. " $0 "is exiting.."
    exit 1
fi

writefile=$1
writestr=$2
newpath="${writefile%/*}"
mkdir -p ${newpath}
if [ ! -d $newpath ]
then
    echo "directory not created!"
    exit 1
fi

touch $writefile
echo $writestr >> $writefile
