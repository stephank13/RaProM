#!/bin/bash
# reprocess_RaProM.sh
#--------------------------------
# Description
# reprocess MRR RAW data with RaProM software:
#  - decompress
#  - rename
#  - check and correct for errors
#  - reprocess to nc
#  - clean up
#--------------------------------
# SK, 2022-11-04
#--------------------------------
# activate python environment
#conda init
#/home/skr100/anaconda3/condabin/conda activate RaProM
source /home/skr100/anaconda3/bin/activate /home/skr100/anaconda3/envs/RaProM
#module load NCO

# set file and path parameters
declare -i nt
declare -i rt
declare -i dt

basepath='/home/skr100/MRR/RawSpectra/'
workpath='/home/skr100/MRR/RaProM/ForRePro/'
suffix='_RaProM_60s'
failpath='/home/skr100/MRR/RaProM/FailRePro/'

# loop
yy=$1
mm=10
dd=01
#for mm in {01..12}; do
#for dd in {01..31}; do
rawfile=$basepath$yy'/'$yy$mm'/'$mm$dd'.raw'
rawfile2=$workpath'MRR2_'$yy$mm$dd'.raw'
outpath='/home/skr100/MRR/RaProM/RePro/'$yy$mm'/'
ncfile=$workpath'MRR2_'$yy$mm$dd
ncfile_out=$outpath'MRR2_'$yy$mm$dd$suffix'.nc'

#echo $rawfile $rawfile2 $ncfile $ncfile_out

if [ -f $rawfile* ]; then

if [ ! -f $ncfile_out ]; then

  # decompress and move if necessary
  if [ ! -f $rawfile2 ]; then
      if [ ! -f $rawfile ]; then
        echo 'bunzip2 '$rawfile'.bz2 to '$rawfile2
        bunzip2 -k $rawfile'.bz2'
      else
        echo 'first creating '$rawfile'.bz2'
        bzip2 -k $rawfile
      fi
      mv $rawfile $rawfile2
  fi
#  fi
  # echo $ncfile_out

  # reprocess data
  chmod +w $rawfile2
  rm $ncfile.nc
  python /home/skr100/MRR/RaProM/RaProM_SK.py -h40 -t60 -d$workpath
  # python /home/skr100/MRR/RaProM/RaProM_SK.py -h58 -t60 -d$workpath

  if [ -f $ncfile*.nc ]; then
    # compare last time stamp in raw and nc
    rtstr=$(awk -F" " '{print $2}' <<< $(grep MRR $rawfile2 | tail -n1))
    rt=$(date -d "20${rtstr:0:2}-${rtstr:2:2}-${rtstr:4:2} ${rtstr:6:2}:${rtstr:8:2}:${rtstr:10:2}" +%s)
    ntstr=$(awk -F\"  '{print $2}' <<< $(awk -F, '{print $NF}' <<< $(ncdump -v time_utc -t $ncfile.nc | tail)))
    nt=$(date -d "$ntstr" +%s)
    if [ $nt -gt $rt ]; then
      dt=$(expr $nt - $rt)
    else
      dt=$(expr $rt - $nt)
    fi
    if [ $dt -lt 60 ]; then
      echo 'end time in nc and raw file agree'
      # rename some nc variables
      #ncrename -h -O -d  time_utc,time $ncfile
      #ncrename -h -O -v  time_utc,time $ncfile
      #ncrename -h -O -v  time_utc,time $ncfile

      # add global attributes to nc-file
      ./add_attr_MRR.sh $ncfile

      # rename and move nc file
      if [ ! -d $outpath ]; then
        mkdir $outpath
      fi
      mv $ncfile*.nc $ncfile_out # || mv $workpath'MRR2_'$yy$mm$dd'-corrected.nc' $workpath'MRR2_'$yy$mm$dd$suffix'.nc'
      chmod 664 $ncfile_out
      chgrp metdata $ncfile_out
    else
      echo 'end time in nc and raw file disagree'
      # clean up
      mv $ncfile*.nc $failpath
      mv $workpath*.raw $failpath
    fi
  fi
  # clean up remaining *.raw files
  rm $workpath*.raw

else
  echo $ncfile_out' already exists'
fi

else
  echo 'no matching raw file found for '$yy'-'$mm'-'$dd
fi

#grep -E '^MRR|^H|^TF|^F' 0730.raw > ../0730.raw
#done
#done
