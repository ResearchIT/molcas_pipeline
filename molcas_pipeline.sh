#!/bin/bash

#notes
#PROJECT naming convention is molecule_XXsolv_temp (on the folder)
#the files additionally have a timestep added molecule_XXsolv_temp

#assumptions
# 1. PROJECT folder name will be used as the prefix of the input,prm,key filenames


#arguments:
# b = ROOT directory - absolute full path of the folder
#     which contains the folder with the initial molcas run
# p = PROJECT folder - folder name of initial molcas run
# s = step number for downstream

while getopts r:p:b:e:s:d:h: option
do
        case "${option}"
        in
                r) ROOT=${OPTARG};;
                p) PROJECT=${OPTARG};;
                b) BEGINTIMESTEP=${OPTARG};;
                e) ENDTIMESTEP=${OPTARG};;
                s) STEPSIZE=${OPTARG};;
                d) DT=${OPTARG};;
                h) HOP=${OPTARG};;
        esac
done


if [ ! -d "$ROOT/$PROJECT" ]; then
  echo ERROR: PROJECT folder path is incorrect
  exit 1
fi

for ((STEP=$BEGINTIMESTEP; STEP<=$ENDTIMESTEP; STEP+=$STEPSIZE)); do

  DOWNSTREAM=Trajectory_${STEP}fs

  if [ -d "$ROOT/$PROJECT/$DOWNSTREAM" ]; then
    echo ERROR: Downstream folder path already exists
    exit 1
  fi


  mkdir $ROOT/$PROJECT/$DOWNSTREAM

  cp template.input $ROOT/$PROJECT/$DOWNSTREAM/$DOWNSTREAM.input

  sed -i 's/dtvalue/'"$DT"'/g' $ROOT/$PROJECT/$DOWNSTREAM/$DOWNSTREAM.input
  sed -i 's/hopvalue/'"$HOP"'/g' $ROOT/$PROJECT/$DOWNSTREAM/$DOWNSTREAM.input

  find $ROOT/$PROJECT -name $PROJECT*.prm -exec cp {} $ROOT/$PROJECT/$DOWNSTREAM/$DOWNSTREAM.prm \;
  find $ROOT/$PROJECT -name $PROJECT*.key -exec cp {} $ROOT/$PROJECT/$DOWNSTREAM/$DOWNSTREAM.key \;

  sed -i 's/'"$PROJECT"'.*.prm/'"$DOWNSTREAM"'.prm/g' $ROOT/$PROJECT/$DOWNSTREAM/$DOWNSTREAM.key

  #might want to consider changing the job name in each of the sbatch scripts, or make a sbatch array
  cp $ROOT/$PROJECT/molcas_sub $ROOT/$PROJECT/$DOWNSTREAM/molcas_sub
  sed -i 's/file_name/'"$DOWNSTREAM"'/g' $ROOT/$PROJECT/$DOWNSTREAM/molcas_sub

  find $ROOT/$PROJECT/TMP -name $PROJECT*.$STEP -exec cp {} $ROOT/$PROJECT/$DOWNSTREAM/$DOWNSTREAM.xyz \;

  sed -n '/Velocities [(]*time.*8200/,/^$/{//!p}' $ROOT/$PROJECT/$PROJECT*.log | tail -n +4 | head -n -1 | cut -b 17-56 > $ROOT/$PROJECT/$DOWNSTREAM/$DOWNSTREAM.velocity.xyz

done
