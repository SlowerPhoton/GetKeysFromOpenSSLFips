#! /bin/sh

FIPS_VERSION=$1
INSTALLDIR=${2:-library}
VERSIONSDIR=${3:-versions}

MAINDIR=`pwd`

TAGOSL=`echo $FIPS_VERSION | sed 's/OpenSSL/openssl/; s/\([0-9]\)_/\1./g; s/_/-/g' | cat`

cd $VERSIONSDIR
if ! [ -e "$TAGOSL.tar.gz" ]
then 
	if ! wget --tries=0 --read-timeout=10 https://www.openssl.org/source/$TAGOSL.tar.gz 
	then
		cd $MAINDIR
		exit 8
	fi
fi

mkdir $MAINDIR/$TAGOSL
tar -xf $TAGOSL.tar.gz -C $MAINDIR/$TAGOSL --strip-components 1

cd $MAINDIR/$TAGOSL
# circumvent integrity check
sed -i s/"#ifdef OPENSSL_FIPS_DEBUGGER"/"#define OPENSSL_FIPS_DEBUGGER\n#ifdef OPENSSL_FIPS_DEBUGGER"/ fips/fips.c
# allow small keys
sed -i s/"#define OPENSSL_RSA_FIPS_MIN_MODULUS_BITS 1024"/"#define OPENSSL_RSA_FIPS_MIN_MODULUS_BITS 512"/ crypto/rsa/rsa.h
sed -i s/"(nbits < 1024)"/"(nbits < 512)"/ crypto/bn/bn_x931p.c
sed -i s/"(bits < 1024)"/"(bits < 512)"/ crypto/rsa/rsa_gen.c

if false #! ./config --prefix=$INSTALLDIR
then
	cd $MAINDIR
	rm -r $TAGOSL
	exit -1
fi
sed -i 's/-m486//g' Makefile 

#make --quiet && make --quiet install
ret=`echo $?`

cd $MAINDIR
rm -r $TAGOSL

#exit $ret
exit 0
