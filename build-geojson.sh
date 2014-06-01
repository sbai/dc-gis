#!/bin/bash
# Bulk extract ESRI shapefiles for census tracts, census blocks, and voting
# precincts and convert to GeoJSON.

function shp2geojson() {
  filename="$rootdir/$2-$3.geojson"
  rm -f "$filename"
  ogr2ogr -f GeoJSON -t_srs crs:84 "$filename" "$1.shp"
}

function convert() {
  cd $1
  for z in *.{zip,ZIP}; do
    unzip -o "$z"
  done
  for shp in *.shp; do
    shp2geojson ${shp%\.*} $2 ${1%/}
  done
  cd $OLDPWD
}

function convertall() {
  cd $1
  for d in */; do
    convert "$d" "$1"
  done
  cd $rootdir
}

shopt -s nullglob
rootdir=`pwd`

# Extract all zip files.
echo "Extracting census tract data..."
convertall "census-tracts"
echo "Extracting census block data..."
convertall "census-blocks"
echo "Extracting ward data..."
convertall "wards"
echo "Extracting voting precint data..."
convertall "voting-precincts"
