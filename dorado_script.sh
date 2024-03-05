#!/bin/bash
# check settings.csv file exits
if [[ $(find ./ -maxdepth 1 -type f -name "settings.csv") == "./settings.csv" ]] ; then
    echo "
    There is a file called 'settings.csv', it should be set appropriately."
else
    echo "
    There is no file called 'settings.csv', please copy this folder from appropriate path."
    exit -1
fi

# pod5 converter
# input: fast5 file folder
# output: pod5 file folder
# python program or web pod5 converter https://pod5.nanoporetech.com/

# dorado basecaller
# input pod5 file folder
# output result folder: bam file
# $device
# $kitname
# $time
# $modelpath
# $pod5folder

cmd=$(grep "Main program" settings.csv | cut -f 3 -d ",")$(grep "Main program" settings.csv | cut -f 2 -d ",")
basecall=basecaller

echo "command: "$cmd $basecall

device=--device
cuda=$(grep "Device" settings.csv | cut -f 2 -d ",")
#device=""
echo "device: "$device $cuda

modelname=$(grep "Basecalling model" settings.csv | cut -f 2 -d ",")
echo "Model name: "$modelname

modelselect=$(tail -n +$(cut -f 1 -d "," settings.csv |grep -n $modelname | cut -f 1 -d ":") settings.csv | head -n 1)

modelpath=$(echo $modelselect | cut -f 3 -d ",")$(echo $modelselect | cut -f 2 -d ",")
echo "Model path: "$modelpath

pod5folder=$(grep "Data type" settings.csv | cut -f 3 -d ",")
echo "The data type is "$(grep "Data type" settings.csv | cut -f 2 -d ",")"
     path: "$pod5folder

Date=$(date -I)
Outputfile=$Date"_dorado_basecalling.bam"
echo "Output file name: "$Outputfile

if [[ $(grep "Barcoding or not" settings.csv | cut -f 2 -d ",") == "Yes" ]] ; then
    kitname=--kit-name
    BCKit=$(grep "Barcoding kit name" settings.csv | cut -f 2 -d ",")
    flag_bc=1
    trim=--trim
    primer='primers'
    echo "
    Basecalling with barcode kit '$(grep "Barcoding kit name" settings.csv | cut -f 2 -d ",")'"
else
    echo "
    Basecalling without barcode."
    kitname=
    BCKit=
    flag_bc=0
    trim=
    primer=
fi

echo "$cmd $basecall $device $cuda $kitname $BCKit $trim $primer $modelpath $pod5folder > ../$Outputfile"

echo "
     Basecalling..."
#command 1
#$cmd $basecall $device $cuda $kitname $BCKit $trim $primer $modelpath $pod5folder > ../$Outputfile

# dorado dmux

if [[ $flag_bc == 1 ]] ; then
    echo "
    Splitting bam file with barcode with kit '$(grep "Barcoding kit name" settings.csv | cut -f 2 -d ",")'..."

else
    echo "
    Results were not barcoded."
    exit -1
fi

# input bamfile
# $kitname
# $outputdir
# $bamfile
# output demux folder with barcode kit name and barcode
Date=$(date -I)
outputdir="../"$Date"_"$Outputfile"_demux"
output=--output-dir
#command 2
echo "$cmd demux $output $outputdir $kitname $BCKit ../$Outputfile"
#$cmd demux $output $outputdir $kitname $BCKit ../$Outputfile
