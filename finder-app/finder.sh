#!/bin/sh

# set -x

if [ $# -lt 2 ]
then
   echo "Not enough arguments."
   exit 1
elif [ $# -gt 2 ]
then
    echo "Too many arguments."
    exit 1
fi

filesdir=$1
searchstr=$2

if [ -d $filesdir ]
then
    results=$( grep -rch $searchstr $filesdir )
else
    echo $filesdir is not a directory
fi 

sum=$(echo "$results" | awk '{sum += $1; count++} END {print sum}')
count=$(echo "$results" | wc -l)
echo "The number of files are" $count "and the number of matching lines are" $sum 
