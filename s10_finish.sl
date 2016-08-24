#!/bin/bash
#SBATCH -J s10_finish.sl
#SBATCH -A uoo00053         # Project Account
#SBATCH --time=0:02:00     # Walltime
#SBATCH --mem-per-cpu=512  # memory/cpu (in MB)
#SBATCH --cpus-per-task=1   # 12 OpenMP Threads
#SBATCH --nodes=1
#SBATCH -C sb

# Murray Cadzow
# University of Otago
# 29 Jul 2016

# Matt Bixley
# University of Otago
# Jun 2016
DIR=$1

touch $DIR/final/finished.txt 






