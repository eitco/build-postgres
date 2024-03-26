#!/usr/bin/env bash

tagName=$1
echo "tagName = $tagName"

vString=${tagName#REL}
vString=${vString#_}
majorVersion=${vString%%_*}
vString=${vString#${majorVersion}_}
minorVersion=${vString%%_*}
vString=${vString#${minorVersion}}
vString=${vString#_}
patch=${vString%%-*}

if [ -z "$patch" ]; then
    version=$majorVersion.${minorVersion%%-*}
else
    version=$majorVersion.$minorVersion.$patch
fi

./configure --prefix="$(pwd)"/pgsql --without-icu --without-zlib --without-readline --with-system-tzdata=/usr/share/zoneinfo/

make
make install

cd contrib || exit
make all
make install
cd ..

# distribute license
cp COPYRIGHT pgsql

tar -czvf "postgres-$version-$2.tar.gz" pgsql

