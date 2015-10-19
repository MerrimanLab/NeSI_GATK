#!/bin/bash
#SBATCH -J s3_MarkDup 
#SBATCH -A uoo00008         # Project Account
#SBATCH --time=00:01:00     # Walltime
#SBATCH --mem-per-cpu=1024  # memory/cpu (in MB)
#SBATCH --cpus-per-task=1   # 12 OpenMP Threads

# Murray Cadzow
# University of Otago
# 20 Oct 2015


export OPENBLAS_MAIN_FREE=1

DIR=$SLURM_SUBMIT_DIR

module load picard/1.140

echo "srun java -jar $EBROOTPICARD/picard.jar MarkDuplicates INPUT=sorted_reads.bam OUTPUT=dedup_reads.bam METRICS_FILE=metrics.txt TMP_DIR=./"

