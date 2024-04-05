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

if [ "$2" = "osx" ]; then


  install_name_tool -add_rpath '@executable_path/../lib' pgsql/bin/*

  for library in psql/lib/*.dylib
  do
      otool -l $library
      install_name_tool -id "@rpath/$library" "$library"
      otool -l $library

      install_name_tool -change "$library" "@rpath/$library" pgsql/bin/*
  done

else

  chrpath --replace '$ORIGIN/../lib' pgsql/bin/*
fi

# distribute license
cp COPYRIGHT pgsql

tar -czvf "postgres-$version-$2.tar.gz" pgsql

{
  echo "MAJOR_VERSION=$majorVersion"
  echo "MINOR_VERSION=$minorVersion"
  echo "VERSION=$majorVersion.$minorVersion"
} >> "$GITHUB_OUTPUT"

