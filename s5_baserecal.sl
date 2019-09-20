#!/bin/bash
#SBATCH -J s5_baseRecal
#SBATCH --time=5:59:00     # Walltime
#SBATCH --mem-per-cpu=31024  # memory/cpu (in MB)
#SBATCH --cpus-per-task=1   # 12 OpenMP Threads
#SBATCH --ntasks=1

# Murray Cadzow
# University of Otago
# 20 Oct 2015

# Matt Bixley
# University of Otago
# Jun 2016
echo baserecal start $(date "+%H:%M:%S %d-%m-%Y")

export OPENBLAS_MAIN_FREE=1
source ~/uoo02378/NeSI_GATK/gatk_references.sh

DIR=$1
sample=$2
chr=$(cat ~/uoo02378/NeSI_GATK/contigs_h37.txt | awk -v line=${SLURM_ARRAY_TASK_ID} '{if(NR == line){print}}')

#module load GATK/4.0.11.0-gimkl-2017a

module restore
module load  Java/1.8.0_144

if ! srun ~/uoo02378/gatk-4.1.3.0/gatk --java-options "-Xmx30g" --spark-runner LOCAL \
	 BaseRecalibrator \
	-R $REF \
	-I $DIR/temp/${sample}_dedup_reads.bam \
	-O $DIR/temp/${sample}_recal_data_${chr}.recal_data.csv \
	--known-sites $DBSNP \
	--known-sites $MILLS \
	--known-sites $INDELS \
	--verbosity  INFO \
	-L ${chr} ; then
	#-cov ReadGroupCovariate \
	#-cov QualityScoreCovariate \
	#-cov CycleCovariate \
	#-cov ContextCovariate \
	#-log $DIR/logs/${sample}_baserecal_${chr}.log \

	echo "base recal on chr $i failed"
	echo "base recal failed" >> $DIR/final/failed.txt
	exit 1
fi
#rm $DIR/temp/${sample}_gathered.ba[mi]
echo baserecal finish $(date "+%H:%M:%S %d-%m-%Y")

