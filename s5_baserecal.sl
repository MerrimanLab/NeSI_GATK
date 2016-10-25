#!/bin/bash
#SBATCH -J s5_baseRecal
#SBATCH -A uoo00053         # Project Account
#SBATCH --time=5:59:00     # Walltime
#SBATCH --mem-per-cpu=31024  # memory/cpu (in MB)
#SBATCH --cpus-per-task=1   # 12 OpenMP Threads
#SBATCH -C sb

# Murray Cadzow
# University of Otago
# 20 Oct 2015

# Matt Bixley
# University of Otago
# Jun 2016
echo baserecal start $(date "+%H:%M:%S %d-%m-%Y")

export OPENBLAS_MAIN_FREE=1
source ~/NeSI_GATK/gatk_references.sh

DIR=$1
sample=$2
chr=$(cat ~/NeSI_GATK/contigs_h37.txt | awk -v line=${SLURM_ARRAY_TASK_ID} '{if(NR == line){print}}')

module load GATK/3.6-Java-1.8.0_40


if ! srun java -Xmx30g -jar $EBROOTGATK/GenomeAnalysisTK.jar \
	-T BaseRecalibrator \
	-R $REF \
	-I $DIR/temp/${sample}_dedup_reads_${chr}.bam \
	-o $DIR/temp/${sample}_recal_data_${chr}.grp \
	-knownSites $DBSNP \
	-knownSites $MILLS \
	-knownSites $INDELS \
	-l INFO \
	-cov ReadGroupCovariate \
	-cov QualityScoreCovariate \
	-cov CycleCovariate \
	-cov ContextCovariate \
	-log $DIR/logs/${sample}_baserecal_${chr}.log \
	-L ${chr} ; then

	echo "base recal on chr $i failed"
	echo "base recal failed" >> $DIR/final/failed.txt
	exit 1
fi
echo baserecal finish $(date "+%H:%M:%S %d-%m-%Y")

