#!/bin/bash
#SBATCH -J s8_finish.sl
#SBATCH -A nesi00319         # Project Account
#SBATCH --time=0:10:00     # Walltime
#SBATCH --mem-per-cpu=512  # memory/cpu (in MB)
#SBATCH --cpus-per-task=1   # 12 OpenMP Threads
#SBATCH --nodes=1
#SBATCH -C sb
#SBATCH --mail-user=murray.cadzow@otago.ac.nz
#SBATCH --mail-type=FAIL,TIME_LIMIT_90

# Murray Cadzow
# University of Otago
# 29 Jul 2016

# Matt Bixley
# University of Otago
# Jun 2016
DIR=$1
srun tar -czf  $DIR/final/logs.tar.gz $DIR/logs $DIR/*.out $DIR/jobs.txt
srun cp $DIR/jobs.txt $DIR/final/jobs.txt

touch $DIR/final/finished.txt 






