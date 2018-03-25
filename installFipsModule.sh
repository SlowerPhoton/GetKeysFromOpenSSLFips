#! /bin/sh

FIPS_VERSION=$1
INSTALLDIR=${2:-library}
VERSIONS_DIR=${3:-versions}

MAINDIR=`pwd`
cd $VERSIONS_DIR
if ! [ -e "$FIPS_VERSION.tar.gz" ]
then 
	wget --tries=0 --read-timeout=10 https://github.com/openssl/openssl/archive/$FIPS_VERSION.tar.gz 
fi

mkdir $MAINDIR/$FIPS_VERSION
tar -xf $FIPS_VERSION.tar.gz -C $MAINDIR/$FIPS_VERSION --strip-components 1

cd $MAINDIR/$FIPS_VERSION
# circumvent integrity check
sed -i s/"#ifdef OPENSSL_FIPS_DEBUGGER"/"#define OPENSSL_FIPS_DEBUGGER\n#ifdef OPENSSL_FIPS_DEBUGGER"/ fips/fips.c
# allow small keys
sed -i s/"#define OPENSSL_RSA_FIPS_MIN_MODULUS_BITS 1024"/"#define OPENSSL_RSA_FIPS_MIN_MODULUS_BITS 512"/ crypto/rsa/rsa.h
sed -i s/"(nbits < 1024)"/"(nbits < 512)"/ crypto/bn/bn_x931p.c
sed -i s/"(bits < 1024)"/"(bits < 512)"/ crypto/rsa/rsa_gen.c

if ! ./config fipscanisteronly --prefix=$INSTALLDIR
then
	cd $MAINDIR
	rm -r $FIPS_VERSION
	exit -1
fi
sed -i 's/-m486//g' Makefile 

make # && make install
ret=`echo $?`

cd $MAINDIR
rm -r $FIPS_VERSION

exit $ret
