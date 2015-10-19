#!/bin/bash
#SBATCH -J s2_SortSam
#SBATCH -A uoo00008         # Project Account
#SBATCH --time=00:01:00     # Walltime
#SBATCH --mem-per-cpu=1024  # memory/cpu (in MB)
#SBATCH --cpus-per-task=1   # 12 OpenMP Threads

export OPENBLAS_MAIN_FREE=1
#echo slurm jobib = $SLURM_JOBID > $SLURM_SUBMIT_DIR/dirs.txt
#echo slurm submit dir = $SLURM_SUBMIT_DIR >> $SLURM_SUBMIT_DIR/dirs.txt
#echo slurm tmp dir = $TMP_DIR >> $SLURM_SUBMIT_DIR/dirs.txt

DIR=$SLURM_SUBMIT_DIR
module load picard/1.140


echo "srun java -jar $EBROOTPICARD/picard.jar SortSam INPUT=aligned_reads.bam OUTPUT=sorted_reads.bam SORT_ORDER=coordinate TMP_DIR=./"
