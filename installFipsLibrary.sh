#! /bin/sh

VERSION=$1
INSTALLDIR=${2:-library}
OPENSSLDIR=${3:-library/openssl}
VERSIONS_DIR=${4:-versions}

MAINDIR=`pwd`
cd $VERSIONS_DIR
if ! [ -e "$VERSION.tar.gz" ]
then 
	wget --tries=0 --read-timeout=10 https://github.com/openssl/openssl/archive/$VERSION.tar.gz 
fi

mkdir $MAINDIR/$VERSION 
tar -xf $VERSION.tar.gz -C $MAINDIR/$VERSION --strip-components 1

cd $MAINDIR/$VERSION

if ! ./config fips --with-fipsdir=$INSTALLDIR --prefix=$INSTALLDIR --openssldir=$OPENSSLDIR
then
	cd $MAINDIR
	rm -r $VERSION
	exit -1
fi

sed -i 's/-m486//g' Makefile

make depend &&
make &&
make test &&
make install_sw

ret=`echo $?`

cd $MAINDIR
rm -r $VERSION

exit $ret
