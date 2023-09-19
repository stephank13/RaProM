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
#/home/skr100/anaconda3/condabin/conda activate RaProM
source /shared/apps/Anaconda3/5.3.0-foss-2018b/bin/activate /home/skr100/.conda/envs/RaProM
#python --version
#source /home/skr100/anaconda3/bin/activate /home/skr100/anaconda3/envs/RaProM
module load NCO

# set file and path parameters
declare -i nt
declare -i rt
declare -i dt

basepath='/home/skr100/MRR/RawSpectra/'
suffix='_RaProM_60s'
failpath='/home/skr100/MRR/RaProM/FailRePro/'

# loop
yy=$1
workpath='/home/skr100/MRR/RaProM/ForRePro/'$yy'/'

for mm in {01..12}; do
for dd in {01..31}; do
rawfile=$basepath$yy'/'$yy$mm'/'$mm$dd'.raw'
rawfile2=$workpath'MRR2_'$yy$mm$dd'.raw'
rawfile3=${rawfile2:0:-4}
rawfile4=$failpath'MRR2_'$yy$mm$dd
outpath='/home/skr100/MRR/RaProM/RePro/'$yy$mm'/'
ncfile=$workpath'MRR2_'$yy$mm$dd
ncfile2=$failpath'MRR2_'$yy$mm$dd
ncfile_out=$outpath'MRR2_'$yy$mm$dd$suffix'.nc'

if [ ! -f $ncfile_out ]; then
  if [ -f $ncfile2*.nc ] && [ -f $rawfile4*.raw ]; then #echo both files exist #; fi

    if [ ! -f $workpath ]; then mkdir -p $workpath ; fi

    # rename and move files
    mv $ncfile2*.nc $ncfile.nc; mv $rawfile4*.raw $rawfile2;

    if [ -f $ncfile.nc ]; then #echo ok ; fi
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
      if [ $dt -lt 60 ]; then #echo 'end time in nc and raw file agree' ; fi

        # add global attributes to nc-file
        . add_attr_MRR.sh $ncfile.nc
        #ncdump -h $ncfile.nc

        # rename and move nc file
        if [ ! -d $outpath ]; then mkdir $outpath ; fi
        mv $ncfile.nc $ncfile_out # || mv $workpath'MRR2_'$yy$mm$dd'-corrected.nc' $workpath'MRR2_'$yy$mm$dd$suffix'.nc'
        chmod 664 $ncfile_out
        chgrp metdata $ncfile_out

        echo $ncfile.nc created
#        rm $rawfile2
      else
        echo 'end time in nc and raw file disagree'
      fi
    fi
    # clean up remaining *.raw files
    rm $workpath*.raw
  fi
else
  echo $ncfile_out' already exists'
fi

done
done
