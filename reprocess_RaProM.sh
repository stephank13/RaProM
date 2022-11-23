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
hpath='/home/skr100/MRR/RaProM/RePro/InconsistentHeights/'

# loop
yy=$1
workpath='/home/skr100/MRR/RaProM/ForRePro/'$yy'/'
if [ ! -f $workpath ]; then mkdir -p $workpath ; fi

# clean up before getting started
if [ "$(ls -A $workpath)" ]; then rm -r $workpath/* ; fi

#mm=10
#dd=01
for mm in {01..12}; do
for dd in {01..31}; do
rawfile=$basepath$yy'/'$yy$mm'/'$mm$dd'.raw'
rawfile2=$workpath'MRR2_'$yy$mm$dd'.raw'
rawfile3=${rawfile2:0:-4}
outpath='/home/skr100/MRR/RaProM/RePro/'$yy$mm'/'
ncfile=$workpath'MRR2_'$yy$mm$dd
#ncfile2=$workpath'MRR2_'$yy$mm$dd'-corrected'
ncfile_out=$outpath'MRR2_'$yy$mm$dd$suffix'.nc'
#echo $rawfile $rawfile2 $ncfile $ncfile_out
#H100='H          0      100      200      300      400      500      600      700      800      900     1000     1100     1200     1300     1400     1500     1600     1700     1800     1900     2000     2100     2200     2300     2400     2500     2600     2700     2800     2900     3000     3100'

if [ -f $rawfile* ]; then

if [ ! -f $ncfile_out ]; then

  # decompress and move if necessary
  if [ ! -f $rawfile2 ]; then
      if [ ! -f $rawfile ]; then
        if [ -f $rawfile.bz2 ]; then
          echo 'bunzip2 '$rawfile'.bz2 to '$rawfile2
          bunzip2 -k $rawfile'.bz2'
        elif [ -f $rawfile.gz ]; then
          echo 'gunzip '$rawfile'.gz to '$rawfile2
          gunzip -c $rawfile'.gz' > $rawfile
        fi
      else
        echo 'first creating '$rawfile'.bz2'
        bzip2 -k $rawfile
      fi
      mv $rawfile $rawfile2
  fi
#  fi
  # echo $ncfile_out

  # check height vector
  grep ^H $rawfile2 | head -n 100  > Hlines.txt
  if grep -v -q 'H[[:blank:]]*0[[:blank:]]*100' Hlines.txt ; then
  # if [ ! $(grep -q -v 'H[[:blank:]]*0[[:blank:]]*100' Hlines.txt) ]; then
  # if [ ! $(grep -q -v 'H          0      100      200      300      400      500      600      700      800      900     1000     1100     1200     1300     1400     1500     1600     1700     1800     1900     2000     2100     2200     2300     2400     2500     2600     2700     2800     2900     3000     3100' Hlines.txt) ]; then
  # if [ ! $(grep -q -v 'H[[:blank:]]*0[[:blank:]]*35' Hlines.txt) ]; then
    #grep 'H[[:blank:]]0[[:blank:]]35[[:blank:]]70[[:blank:]]105[[:blank:]]140[[:blank:]]175[[:blank:]]210[[:blank:]]245[[:blank:]]280[[:blank:]]315[[:blank:]]350[[:blank:]]385[[:blank:]]420[[:blank:]]455[[:blank:]]490[[:blank:]]525[[:blank:]]560[[:blank:]]595[[:blank:]]630[[:blank:]]665[[:blank:]]700[[:blank:]]735[[:blank:]]770[[:blank:]]805[[:blank:]]840[[:blank:]]875[[:blank:]]910[[:blank:]]945[[:blank:]]980[[:blank:]]1015[[:blank:]]1050[[:blank:]]1085[[:blank:]]' Hlines.txt
    echo inconsistent height vectors found
    mv $rawfile2 $hpath
  else

  # reprocess data
  chmod +w $rawfile2
  if [ -f $ncfile.nc ]; then rm $ncfile.nc; fi

  python /home/skr100/MRR/RaProM/RaProM_SK.py -h45 -t60 -d$workpath
  # python /home/skr100/MRR/RaProM/RaProM_SK.py -h58 -t60 -d$workpath

  # rename files
  if [ ! $(ls $ncfile*.nc)==$ncfile.nc ]; then mv $ncfile*.nc $ncfile.nc; fi
  if [ ! $(ls $rawfile3*.raw)==$rawfile2 ]; then mv $rawfile3*.raw $rawfile2; fi

  if [ -f $ncfile.nc ]; then
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

      # rename and move nc file
      if [ ! -d $outpath ]; then mkdir $outpath ; fi
      mv $ncfile.nc $ncfile_out # || mv $workpath'MRR2_'$yy$mm$dd'-corrected.nc' $workpath'MRR2_'$yy$mm$dd$suffix'.nc'
      chmod 664 $ncfile_out
      chgrp metdata $ncfile_out
    else
      echo 'end time in nc and raw file disagree'
      # clean up
      mv $ncfile.nc $failpath
      mv $workpath*.raw $failpath
    fi
  fi
  # clean up remaining *.raw files
  rm $workpath*.raw

  fi

else
  echo $ncfile_out' already exists'
fi

else
  echo 'no matching raw file found for '$yy'-'$mm'-'$dd
fi

done
done
