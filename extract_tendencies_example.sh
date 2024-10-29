#! /bin/bash
#SBATCH -c 1                # Number of cores (-c)
#SBATCH -t 0-04:00          # Runtime in D-HH:MM, minimum of 10 minutes
#SBATCH -p partition_name       # Partition to submit to
#SBATCH --mem=1000 
#SBATCH --array=1-12


# example script to extract relevant values from CAM history file if saving 
# QDIFF,SDIFF,UDIFF,VDIFF as shown in file user_nl_cam_example. 

CASE="replay_case"

mkdir /path/to/your/output/Run/archive/${CASE}/replay_tend/ 

PATH1="/path/to/your/output/Run/archive/Run/archive/${CASE}/atm/hist/${CASE}"
PATH2="/path/to/your/output/Run/archive/Run/archive/${CASE}/replay_tend/${CASE}"

# History file has 3 outputs every 6 hours, corresponding to 0hr and 3hr twice. 
# The relevant values are in either of the 3hr timesteps.
# ncea -d time,1,1 replay_case.cam.h1.1999-01-01-00000.nc out.nc (example of how to subset)

month=$SLURM_ARRAY_TASK_ID
for day in {1..31}; do
for which in {0..7..2}; do # for 3 timesteps per 6-hr period
hour=$(($which*10800))
monthno=$(printf '%02d' $month)
dayno=$(printf '%02d' $day)
hourno=$(printf '%05d' $hour)
for year in {1980..1981}; do
    yearno=$(printf '%04d' $year)
    filename="${PATH1}.cam.h1.${yearno}-${monthno}-${dayno}-${hourno}.nc"
    filename2="${PATH2}.cam.h1.${yearno}-${monthno}-${dayno}-${hourno}.nc"
   
    echo $filename

    if [ ! -f $filename2 ] ; then
        ncea -d time,1,1 -v QDIFF,UDIFF,VDIFF,SDIFF $filename ${PATH2}temp11_${SLURM_ARRAY_TASK_ID}.nc 
        mv ${PATH2}temp11_${SLURM_ARRAY_TASK_ID}.nc $filename2

    else
        echo $filename2 "already exists"
    fi
done
done
done
