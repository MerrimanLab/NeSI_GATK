#!/bin/bash
#SBATCH -J s2_sortSam.sl
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

#sample=$1
sample=FR07921700
export OPENBLAS_MAIN_FREE=1
#echo slurm jobib = $SLURM_JOBID > $SLURM_SUBMIT_DIR/dirs.txt
#echo slurm submit dir = $SLURM_SUBMIT_DIR >> $SLURM_SUBMIT_DIR/dirs.txt
#echo slurm tmp dir = $TMP_DIR >> $SLURM_SUBMIT_DIR/dirs.txt

DIR=$SLURM_SUBMIT_DIR
module load picard/2.1.5

if ! srun java -Xmx8g -jar $EBROOTPICARD/picard.jar SortSam INPUT=~/uoo00053/working/${sample}_aligned_reads.bam OUTPUT=~/uoo00053/working/${sample}_sorted_reads.bam SORT_ORDER=coordinate TMP_DIR=$DIR ; then
	echo "sort sam failed"
	exit 1
fi
sbatch ~/s3_markdup.sl $sample
#rm ${sample}_aligned_reads.bam   ###uncomment after a test run

