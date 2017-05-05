#!/bin/bash

#notes
#PROJECT naming convention is molecule_XXsolv_temp (on the folder)
#the files additionally have a timestep added e.g. molecule_XXsolv_temp_timestep

#assumptions
# project folder name will be used as the prefix of the input,prm,key,etc. filenames
# e.g. project folder will be : HN3_73solv_298K, files in the folder may be HN3_73solv_298K_114
# see http://www.molcas.org/documentation/manual/node77.html for DYNAMIX input options

#arguments:
# r) root folder (the base folder that your molcas project folder is located inside of), e.g. /work/LAS/some-lab/user/
# p) project (the name of the project folder)
# b) begintimestep
# e) endtimestep
# s) timestep size
# d) dt (typically 41.  41 atomic units (a.u.) ~ 1 femtosecond) this will be used to find the appropriate timestep in the log file
#       so it needs to represent the timestep used for the previous run (the project level), it can be tuned in the input template for this experiment
# t) template - full path to the input template
#example

while getopts r:p:b:e:s:d:h:t: option
do
        case "${option}"
        in
                r) ROOT=${OPTARG};;
                p) PROJECT=${OPTARG};;
                b) BEGINTIMESTEP=${OPTARG};;
                e) ENDTIMESTEP=${OPTARG};;
                s) STEPSIZE=${OPTARG};;
                d) DT=${OPTARG};;
                t) TEMPLATE=${OPTARG};;
        esac
done


if [ ! -d "$ROOT/$PROJECT" ]; then
  echo ERROR: PROJECT folder path is incorrect
  exit 1
fi

if [ ! -f "$TEMPLATE" ]; then
  echo ERROR: template.input path is incorrect
  exit 1
fi

for ((STEP=$BEGINTIMESTEP; STEP<=$ENDTIMESTEP; STEP+=$STEPSIZE)); do

  DOWNSTREAM=Trajectory_${STEP}fs

  if [ -d "$ROOT/$PROJECT/$DOWNSTREAM" ]; then
    echo ERROR: Downstream folder path already exists
    exit 1
  fi


  mkdir $ROOT/$PROJECT/$DOWNSTREAM

  cp $TEMPLATE $ROOT/$PROJECT/$DOWNSTREAM/$DOWNSTREAM.input

  find $ROOT/$PROJECT -maxdepth 1 -name $PROJECT*.prm -exec cp {} $ROOT/$PROJECT/$DOWNSTREAM/$DOWNSTREAM.prm \;
  find $ROOT/$PROJECT -maxdepth 1 -name $PROJECT*.key -exec cp {} $ROOT/$PROJECT/$DOWNSTREAM/$DOWNSTREAM.key \;

  sed -i 's/'"$PROJECT"'.*.prm/'"$DOWNSTREAM"'.prm/g' $ROOT/$PROJECT/$DOWNSTREAM/$DOWNSTREAM.key

  #might want to consider changing the job name in each of the sbatch scripts, or make a sbatch array
  cp $ROOT/$PROJECT/molcas_sub $ROOT/$PROJECT/$DOWNSTREAM/molcas_sub
  sed -i 's/file_name/'"$DOWNSTREAM"'/g' $ROOT/$PROJECT/$DOWNSTREAM/molcas_sub

  find $ROOT/$PROJECT/TMP -name $PROJECT*.$STEP -exec cp {} $ROOT/$PROJECT/$DOWNSTREAM/$DOWNSTREAM.xyz \;

  sed -n '/Velocities [(]*time.*'"$(echo "$STEP*$DT" | bc)"'/,/^$/{//!p}' $ROOT/$PROJECT/$PROJECT*.log | tail -n +4 | head -n -1 | cut -b 17-56 > $ROOT/$PROJECT/$DOWNSTREAM/$DOWNSTREAM.velocity.xyz

  cd $ROOT/$PROJECT/$DOWNSTREAM

  sbatch molcas_sub

  cd -

done
