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


    for binary in $(ls pgsql/bin/)
    do
        bin_rel=pgsql/bin/$binary
        echo install_name_tool -add_rpath '@executable_path/../lib' "$bin_rel" && install_name_tool -add_rpath '@executable_path/../lib' "$bin_rel"
    done

  for lib_rel in $(ls pgsql/lib/*.dylib)
  do
      library=${lib_rel#pgsql/lib/}
      echo "modifying $lib_rel"
      install_name_tool -id "@rpath/$library" "$lib_rel"

      otool -L "$lib_rel"

      for binary in $(ls pgsql/bin/)
      do
          bin_rel=pgsql/bin/$binary
          install_name_tool -change "$library" "@rpath/$library" "$bin_rel"
          echo install_name_tool -change "$(pwd)/pgsql/lib/$library" "@rpath/$library" "$bin_rel" && install_name_tool -change "$(pwd)/pgsql/lib/$library" "@rpath/$library" "$bin_rel"
      done
  done

  for binary in $(ls pgsql/bin/)
  do
      bin_rel=pgsql/bin/$binary
      otool -L "$bin_rel"
  done

  echo "current directory is $(pwd)"

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

