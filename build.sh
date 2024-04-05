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


  for library in $(ls pgsql/lib)
  do
      echo "modifying $library"
      echo "otool -l $library" && otool -l "$library"
      echo install_name_tool -id "@rpath/$library" "$library" && install_name_tool -id "@rpath/$library" "$library"
      echo otool -l "$library" && otool -l "$library"

      for binary in $(ls pgsql/bin/)
      do
          echo install_name_tool -add_rpath '@executable_path/../lib' "$binary" && install_name_tool -add_rpath '@executable_path/../lib' "$binary"
          echo install_name_tool -change "$library" "@rpath/$library" "$binary" && install_name_tool -change "$library" "@rpath/$library" "$binary"
      done
  done

else

  chrpath --replace '$ORIGIN/../lib' pgsql/bin/*
fi

# distribute license
cp COPYRIGHT pgsql

tar -czvf "postgres-$version-$2.tar.gz" pgsql > /dev/null

{
  echo "MAJOR_VERSION=$majorVersion"
  echo "MINOR_VERSION=$minorVersion"
  echo "VERSION=$majorVersion.$minorVersion"
} >> "$GITHUB_OUTPUT"

