#!/bin/bash
#SBATCH -J s1_align
#SBATCH -A uoo00008         # Project Account
#SBATCH --time=00:01:00     # Walltime
#SBATCH --mem-per-cpu=1040  # memory/cpu (in MB)
#SBATCH --cpus-per-task=1   # 12 OpenMP Threads
#SBATCH --nodes=1
#SBATCH --mail-user=murray.cadzow@otago.ac.nz
#SBATCH --mail-type=ALL

export OPENBLAS_MAIN_FREE=1

#echo slurm jobib = $SLURM_JOBID > $SLURM_SUBMIT_DIR/dirs.txt
#echo slurm submit dir = $SLURM_SUBMIT_DIR >> $SLURM_SUBMIT_DIR/dirs.txt
#echo slurm tmp dir = $TMP_DIR >> $SLURM_SUBMIT_DIR/dirs.txt

DIR=$SLURM_SUBMIT_DIR
module load BWA/0.7.12-goolf-1.5.14
module load SAMtools/1.2-goolf-1.5.14

RG="@RG\tID:group1\tSM:${sample}\tPL:illumina\tLB:lib1\tPU:unit1"
echo "bwa mem -M -t 12 -R $RG $REF 30x_1.fastq.gz 30x_2.fastq.gz | samtools view -bh - >  aligned_reads.bam"

