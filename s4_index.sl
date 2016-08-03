#!/bin/bash
#SBATCH -J s4_Index 
#SBATCH -A uoo00053         # Project Account
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
DIR=$1
sample=$2
source ~/NeSI_GATK/gatk_references.sh


module load picard/2.1.0

if ! srun java -Xmx8g -jar $EBROOTPICARD/picard.jar BuildBamIndex INPUT=$DIR/temp/${sample}_dedup_reads.bam ; then
	echo "index failed"
	exit 1
fi
#sbatch ~/NeSI_GATK/s5_indelTarget.sl $sample

Ncontigs=$(cat ~/NeSI_GATK/contigs_h37.txt | wc -l)
sbatch -J s7_baserecal --array=1-$Ncontigs ~/NeSI_GATK/s7_baserecal.sl $DIR $sample

