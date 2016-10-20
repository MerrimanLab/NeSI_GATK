#!/bin/bash
#SBATCH -J s6_realign
#SBATCH -A uoo00053         # Project Account
#SBATCH --time=15:00:00     # Walltime
#SBATCH --mem-per-cpu=31024  # memory/cpu (in MB)
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
source ~/NeSI_GATK/gatk_references.sh

#i=$SLURM_ARRAY_TASK_ID
DIR=$1
sample=$2
i=$3


module load GATK/3.6-Java-1.8.0_40

if ! srun java -Xmx30g -jar $EBROOTGATK/GenomeAnalysisTK.jar \
	-T IndelRealigner \
	-R $REF \
	-I $DIR/temp/${sample}_dedup_reads.bam \
	-o $DIR/temp/${sample}_realigned_reads_${i}.bam \
	-targetIntervals ~/uoo00053/working/${sample}_output.intervals \
	-known ${MILLS} \
	-known ${INDELS} \
	-LOD 5.0 \
	-model USE_READS \
	-log $DIR/logs/${sample}_realign_${i}.log \
	-l INFO \
	-L ${i} ; then

	echo "realign failed"
	exit 1
fi
	 
sbatch -J s7_baserecal_chr${i} ~/NeSI_GATK/s7_baserecal.sl $sample $i
