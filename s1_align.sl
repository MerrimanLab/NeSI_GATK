#!/bin/bash
#SBATCH -J s1_align
#SBATCH -A nesi00225         # Project Account
#SBATCH --time=15:00:00     # Walltime
#SBATCH --mem-per-cpu=4000  # memory/cpu (in MB)
#SBATCH --cpus-per-task=16   # 12 OpenMP Threads
#SBATCH --nodes=1
#SBATCH --mail-user=murray.cadzow@otago.ac.nz
#SBATCH --mail-type=ALL
#SBATCH -C sb

# Murray Cadzow
# University of Otago
# 20 Oct 2015

sample=$1
file1=$2
file2=$3
export OPENBLAS_MAIN_FREE=1

#echo slurm jobib = $SLURM_JOBID > $SLURM_SUBMIT_DIR/dirs.txt
#echo slurm submit dir = $SLURM_SUBMIT_DIR >> $SLURM_SUBMIT_DIR/dirs.txt
#echo slurm tmp dir = $TMP_DIR >> $SLURM_SUBMIT_DIR/dirs.txt

DIR=$SLURM_SUBMIT_DIR
module load BWA/0.7.12-goolf-1.5.14
module load SAMtools/1.2-goolf-1.5.14

REF=~/uoo00053/reference_files/hs37d5/hs37d5.fa

RG="@RG\tID:group1\tSM:${sample}\tPL:illumina\tLB:lib1\tPU:unit1"
if ! bwa mem -M -t 16 -R $RG $REF $file1 $file2 2> ${sample}_bwa.log | samtools view -bh - >  ${sample}_aligned_reads.bam ; then
	echo "BWA failed"
	exit 1
fi

#test to make sure aligned file is approximately the size we would expect
# MAKE ACTUAL SYNTAX for if condition - currently psuedo condition
# take new file and see if it is similar to the sum of the input files
#if [ expr $(stat --format %s ${sample}_aligned_reads.bam)  - $(expr $(stat --format %s $file1) + $(stat --format %s $file2)) ]; then # current observation is that bam should be approximately sum of input file sizes
#	echo "File size too small"
#	exit 1
#fi
sbatch ~/nesi00225/nesi_gatk/s2_sortSam.sl $sample

