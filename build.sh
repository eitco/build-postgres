#!/usr/bin/env bash

./configure --prefix="$(pwd)"/pgsql --without-icu --without-zlib --without-readline --with-system-tzdata=/usr/share/zoneinfo/

make
make install

cd contrib || exit
make all
make install
cd ..

# distribute license
cp COPYRIGHT pgsql

tar -czvf postgres.tar.gz pgsql

