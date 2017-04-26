#!/bin/bash

#assumptions
# 1. upstream folder name will be used as the prefix of the input,prm,key filenames


#arguments:
# u = upstream folder - full path
# s = step number for downstream

while getopts u:s: option
do
        case "${option}"
        in
                u) UPSTREAM=${OPTARG};;
                s) STEP=${OPTARG};;
        esac
done

DOWNSTREAM=Trajectory_${STEP}fs

if [ ! -d "$UPSTREAM" ]; then
  echo ERROR: Upstream folder path is incorrect
fi

mkdir $UPSTREAM/$DOWNSTREAM

cp $UPSTREAM/*.input $UPSTREAM/$DOWNSTREAM/$DOWNSTREAM.input
cp $UPSTREAM/*.prm $UPSTREAM/$DOWNSTREAM/$DOWNSTREAM.prm
cp $UPSTREAM/*.key $UPSTREAM/$DOWNSTREAM/$DOWNSTREAM.key

sed -i 's/{$UPSTREAM}*.prm/$DOWNSTREAM.prm/g' $UPSTREAM/$DOWNSTREAM/$DOWNSTREAM.key

#might want to consider changing the job name in each of the sbatch scripts, or make a sbatch array
cp $UPSTREAM/molcas_sub $UPSTREAM/$DOWNSTREAM/molcas_sub
sed -i 's/file_name/$DOWNSTREAM/g' $UPSTREAM/$DOWNSTREAM/molcas_sub
