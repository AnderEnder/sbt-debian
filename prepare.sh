#!/bin/sh

set -e

export LC_ALL=C
export LANG=C

dir=$(dirname "$0")

version=$(dpkg-parsechangelog --show-field Version -l"$dir"/debian/changelog | tr '.-' ' ')
major=$(echo $version | cut -d" " -f 1)
minor=$(echo $version | cut -d" " -f 2)
patch=$(echo $version | cut -d" " -f 3)
debian=$(echo $version | cut -d" " -f 4)

upstream_version="${major}.${minor}.${patch}"

#make -f "$dir"/debian/rules -C "$dir" get-orig-source

# Dependencies
# sudo apt-get install wget default-jre ant ivy

echo "Getting the launcher"
wget -O "${dir}/sbt-launch-${upstream_version}.jar" \
     https://repo.typesafe.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/${upstream_version}/sbt-launch.jar

echo "Packing the launcher"
tar czf "$dir"/../sbt_${upstream_version}.orig-launcher.tar.gz \
    -C "$dir" "sbt-launch-${upstream_version}.jar"

echo "Preparing the ivy repository"
ant -buildfile prepare-build.xml -Dsbt.version=${upstream_version}

echo "Packing the ivy repository"
tar czf "$dir"/../sbt_${upstream_version}.orig-ivy2.tar.gz \
    -C "$dir" ivy2

echo "Packing the preparation script itself"
tar czf "$dir"/../sbt_${upstream_version}.orig.tar.gz \
    -C "$dir" \
    prepare-build.xml \
    ivysettings.xml \
    README.md \
    prepare.sh

echo "Cleaning up"
rm -rf "${dir}/boot" \
       "${dir}/ivy2" \  
       "${dir}/cache" \
       "${dir}/sbt-launch-${upstream_version}.jar"

