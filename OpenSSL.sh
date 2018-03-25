#! /bin/sh

VERSIONS_DIR=versions
OUT=compilable.txt
FIPS_BRANCH=OpenSSL-fips-2_0-stable
DAYS=365

REMOVE_OPENSSL=false
REMOVE_VERSIONS=false

INSTALLDIR=`pwd`/library
OPENSSLDIR=$INSTALLDIR/openssl

MAINDIR=`pwd`

# download OpenSSL if needed
if [ ! -d openssl ]
then
	git clone https://github.com/openssl/openssl.git
fi

if ! [ -d "$VERSIONS_DIR" ]
then
	mkdir $VERSIONS_DIR
fi

if [ -e $OUT ]
then
	rm $OUT
fi

( cd openssl; git tag --merged origin/$FIPS_BRANCH --sort=creatordate; ) | while read FIPS_VERSION
do
	mkdir -p $INSTALLDIR
	echo attempting to install $FIPS_VERSION >> $OUT
	if bash installFipsModuleFromOpenssl.sh $FIPS_VERSION $INSTALLDIR $VERSIONS_DIR
	then
		echo module $FIPS_VERSION installed correctly >> $OUT
		mv $INSTALLDIR fips-backup
		( bash relevantVersions.sh $FIPS_VERSION $DAYS ) | while read VERSION
		do	
			cp -r fips-backup $INSTALLDIR
				if bash installFipsLibrary.sh $VERSION $INSTALLDIR $OPENSSLDIR $VERSIONS_DIR
				then
					echo library $VERSION installed correctly >> $OUT
					if make && timeout 5s ./OpenSSL-fips -b 1024 -c 15 -f > keys/$FIPS_VERSION\=$VERSION.txt
					then
						echo SUCCESS\: $FIPS_VERSION $VERSION >> $OUT
						rm OpenSSL-fips
					fi
				fi	
			rm -r $INSTALLDIR
			mkdir -p $INSTALLDIR
		done
		rm -r fips-backup
	fi
	rm -r $INSTALLDIR
done

if "$REMOVE_OPENSSL"
then
	rm -r openssl
fi

if "$REMOVE_VERSIONS"
then
	rm -r $VERSIONS_DIR
fi

cd $MAINDIR

#sudo systemctl hibernate


