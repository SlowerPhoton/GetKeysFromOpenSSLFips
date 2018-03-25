#! /bin/sh

# Echoes all releases that have their creatordate at most $DAYS days away from the $FIPS release creatordate. 
# This includes both earlier and later releases. 
# Requires a clone of OpenSSL repository (openssl) in the same folder.  

FIPS=$1
DAYS=$2

cd openssl
DATE_FIPS=`git tag -l $FIPS --format='%(creatordate:iso-strict)'`
#echo DATE_FIPS\: $DATE_FIPS

git tag -l --format='%(refname) %(creatordate:iso-strict)' --sort=creatordate | while read line
do
	TAG=`echo $line | cut -d' ' -f1 | cut -d'/' -f3`; 
	DATE=`echo $line | cut -d' ' -f2`
	DIFF=`echo $(( ($(date --date=$DATE +%s) - $(date --date=$DATE_FIPS +%s))/(60*60*24) ))`
	DIFF=${DIFF#-} # get absolute value
	if [ $DIFF -le $DAYS ]
	then
		#echo TAG\: $TAG; echo DATE\: $DATE; echo DIFF\: $DIFF
		echo $TAG
	fi
done

cd ..
