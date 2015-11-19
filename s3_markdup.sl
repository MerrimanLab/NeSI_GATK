#!/bin/bash
#SBATCH -J s3_MarkDup 
#SBATCH -A nesi00225         # Project Account
#SBATCH --time=15:00:00     # Walltime
#SBATCH --mem-per-cpu=20048  # memory/cpu (in MB)
#SBATCH --cpus-per-task=1   # 12 OpenMP Threads
#SBATCH --mail-user=murray.cadzow@otago.ac.nz
#SBATCH --mail-type=ALL
#SBATCH -C sb


# Murray Cadzow
# University of Otago
# 20 Oct 2015

sample=$1
export OPENBLAS_MAIN_FREE=1

DIR=$SLURM_SUBMIT_DIR

module load picard/1.140

if ! srun java -Xmx19g -jar $EBROOTPICARD/picard.jar MarkDuplicates INPUT=${sample}_sorted_reads.bam OUTPUT=${sample}_dedup_reads.bam METRICS_FILE=metrics.txt TMP_DIR=$DIR ; then
	echo "markdup failed"
	exit 1
fi
sbatch ~/nesi00225/nesi_gatk/s4_index.sl $sample
rm ${sample}_sorted_reads.bam
