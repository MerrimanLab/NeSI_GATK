#!/bin/bash
#SBATCH -J s3_MarkDup
#SBATCH -A uoo00053         # Project Account
#SBATCH --time=15:00:00     # Walltime
#SBATCH --mem-per-cpu=4000  # memory/cpu (in MB)
#SBATCH --cpus-per-task=16   # 12 OpenMP Threads
#SBATCH --nodes=1
#SBATCH --mail-user=matt.bixley@otago.ac.nz
#SBATCH --mail-type=ALL
#SBATCH -C sb

# Murray Cadzow
# University of Otago
# 20 Oct 2015

# Matt Bixley
# University of Otago
# Jun 2016

sample=$1
export OPENBLAS_MAIN_FREE=1

#DIR=$SLURM_SUBMIT_DIR
DIR=~/uoo00053/working/
module load picard/2.1.0

if ! srun java -Xmx19g -jar $EBROOTPICARD/picard.jar MarkDuplicates INPUT=~/uoo00053/working/${sample}_sorted_reads.bam OUTPUT=~/uoo00053/working/${sample}_dedup_reads.bam METRICS_FILE=metrics.txt TMP_DIR=$DIR ; then
	echo "markdup failed"
	exit 1
fi
sbatch ~/NeSI_GATK/s4_index.sl $sample
#rm ${sample}_sorted_reads.bam #### uncomment later
