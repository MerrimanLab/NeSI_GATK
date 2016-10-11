#!/bin/bash
#SBATCH -J s10_finish.sl
#SBATCH -A uoo00053         # Project Account
#SBATCH --time=0:10:00     # Walltime
#SBATCH --mem-per-cpu=512  # memory/cpu (in MB)
#SBATCH --cpus-per-task=1   # 12 OpenMP Threads
#SBATCH --nodes=1
#SBATCH -C sb
#SBATCH --mail-user=murray.cadzow@otago.ac.nz
#SBATCH --mail-type=ALL

# Murray Cadzow
# University of Otago
# 29 Jul 2016

# Matt Bixley
# University of Otago
# Jun 2016
DIR=$1
srun cp -r $DIR/logs $DIR/*.out $DIR/jobs.txt $DIR/final/
srun tar -czf $DIR/final/logs.tar.gz $DIR/final/*.out $DIR/final/logs/

touch $DIR/final/finished.txt 






