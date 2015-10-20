#!/bin/bash
#SBATCH -J s3_MarkDup 
#SBATCH -A uoo00008         # Project Account
#SBATCH --time=15:00:00     # Walltime
#SBATCH --mem-per-cpu=4048  # memory/cpu (in MB)
#SBATCH --cpus-per-task=1   # 12 OpenMP Threads
#SBATCH --mail-user=murray.cadzow@otago.ac.nz
#SBATCH --mail-type=ALL


# Murray Cadzow
# University of Otago
# 20 Oct 2015

sample=$1
export OPENBLAS_MAIN_FREE=1

DIR=$SLURM_SUBMIT_DIR

module load picard/1.140

srun java -Xmx3g -jar $EBROOTPICARD/picard.jar MarkDuplicates INPUT=${sample}_sorted_reads.bam OUTPUT=${sample}_dedup_reads.bam METRICS_FILE=metrics.txt TMP_DIR=$TMP_DIR

