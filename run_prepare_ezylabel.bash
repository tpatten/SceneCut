#!/bin/bash

export LD_PRELOAD=$LD_PRELOAD:/usr/lib/x86_64-linux-gnu/libstdc++.so.6:/usr/lib/x86_64-linux-gnu/libprotobuf.so.9

echo "Running script to prepare data"

#status=`awk 'END {print $NF}' computation_status.txt`
#echo 'Last word is ' $status
#if [ "$status" = "success" ]; then
#  echo "Successfully finished"
#else
#  echo "Continuing..."
#  matlab -nodisplay -nosplash -nodesktop -r "run('prepare_dataset');exit;" | tail -n +11 > /dev/null
#  sleep 5
#fi


matlab -nodisplay -nosplash -nodesktop -r "run('prepare_dataset');exit;" | tail -n +11 > /dev/null
