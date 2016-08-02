#!/bin/bash
#SBATCH -J s7_baseRecal
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

sample=$1
i=$2

DIR=$SLURM_SUBMIT_DIR
module load GATK/3.6-Java-1.8.0_40


if ! srun java -Xmx30g -jar $EBROOTGATK/GenomeAnalysisTK.jar \
	-T BaseRecalibrator \
	-R $REF \
	-I $DIR/${sample}_realigned_reads_${i}.bam \
	-o $DIR/${sample}_recal_data${i}.grp \
	-knownSites $DBSNP \
	-knownSites $MILLS \
	-knownSites $INDELS \
	-l INFO \
	-cov ReadGroupCovariate \
	-cov QualityScoreCovariate \
	-cov CycleCovariate \
	-cov ContextCovariate \
	-log $DIR/${sample}_baserecal${i}.log \
	-L ${i} ; then

	echo "base recal on chr $i failed"
	exit 1
fi
sbatch -J s8_applyrecal_chr${i} ~/NeSI_GATK/s8_applyrecal.sl $sample $i
