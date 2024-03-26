#!/usr/bin/env bash

./configure --prefix="$(pwd)"/pgsql --without-icu --without-zlib --without-readline --with-system-tzdata=/usr/share/zoneinfo/
#./configure --prefix="$(pwd)"/pgsql --without-zlib --without-readline --with-system-tzdata=/usr/share/zoneinfo/

make
make install

cd contrib || exit
make all
make install
cd ..

chrpath --replace \\\$ORIGIN/../lib pgsql/bin/*

tar -czvf postgres.tar.gz pgsql

