#!/bin/bash
#SBATCH -J s9_haplotypeCaller
#SBATCH -A uoo00053         # Project Account
#SBATCH --time=5:59:00     # Walltime
#SBATCH --mem-per-cpu=4048  # memory/cpu (in MB)
#SBATCH --cpus-per-task=12   # 12 OpenMP Threads
#SBATCH -C sb

# Murray Cadzow
# University of Otago
# 20 Oct 2015

# Matt Bixley
# University of Otago
# Jun 2016
echo haplotypecaller start $(date "+%H:%M:%S %d-%m-%Y")

export OPENBLAS_MAIN_FREE=1

DIR=$1
sample=$2
chr=$(cat ~/NeSI_GATK/contigs_h37.txt | awk -v line=${SLURM_ARRAY_TASK_ID} '{if(NR == line){print}}')

source ~/NeSI_GATK/gatk_references.sh

module load GATK/3.6-Java-1.8.0_40

if ! srun java -jar -Xmx30g $EBROOTGATK/GenomeAnalysisTK.jar \
	-T HaplotypeCaller \
	-R $REF \
	-I $DIR/final/${sample}_baserecal_reads_${chr}.bam \
	-L ${chr} \
	--emitRefConfidence GVCF \
	--variant_index_type LINEAR \
	--variant_index_parameter 128000 \
	--dbsnp $DBSNP \
	-o $DIR/final/${sample}_${chr}.raw.snps.indels.g.vcf \
	-nct ${SLURM_JOB_CPUS_PER_NODE} ; then

	echo "haplotypecalled on chr $i failed"
	touch $DIR/final/failed.txt
	exit 1
fi
echo haplotypecaller finish $(date "+%H:%M:%S %d-%m-%Y")

