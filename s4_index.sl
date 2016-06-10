#!/bin/bash
#SBATCH -J s4_Index 
#SBATCH -A uoo00052         # Project Account
#SBATCH --time=15:00:00     # Walltime
#SBATCH --mem-per-cpu=9048  # memory/cpu (in MB)
#SBATCH --cpus-per-task=1   # 12 OpenMP Threads
#SBATCH --mail-user=matt.bixley@otago.ac.nz
#SBATCH --mail-type=ALL
#SBATCH -C sb

# Murray Cadzow
# University of Otago
# 20 Oct 2015

# Matt Bixley
# University of Otago
# Jun 2016

export OPENBLAS_MAIN_FREE=1
sample=$1
#echo slurm jobib = $SLURM_JOBID > $SLURM_SUBMIT_DIR/dirs.txt
#echo slurm submit dir = $SLURM_SUBMIT_DIR >> $SLURM_SUBMIT_DIR/dirs.txt
#echo slurm tmp dir = $TMP_DIR >> $SLURM_SUBMIT_DIR/dirs.txt

DIR=$SLURM_SUBMIT_DIR
module load picard/1.140

if ! srun java -Xmx8g -jar $EBROOTPICARD/picard.jar BuildBamIndex INPUT=${sample}_dedup_reads.bam ; then
	echo "index failed"
	exit 1
fi
sbatch ~/s5_indelTarget.sl $sample
