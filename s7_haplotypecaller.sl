#!/bin/bash
#SBATCH -J s7_haplotypeCaller
#SBATCH -A nesi00319         # Project Account
#SBATCH --time=5:59:00     # Walltime
#SBATCH --mem-per-cpu=4048  # memory/cpu (in MB)
#SBATCH --cpus-per-task=8   # 12 OpenMP Threads
#SBATCH -C sb
#SBATCH --mail-user=murray.cadzow@otago.ac.nz
#SBATCH --mail-type=FAIL,TIME_LIMIT_90

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

#module load GATK/3.6-Java-1.8.0_40
module load Java/1.8.0_5
if [[ 23 > ${SLURM_ARRAY_TASK_ID} ]]
then
	echo 'haplotypecaller $chr is under 23'
fi

if ! srun java -jar -Xmx30g ~/nesi00319/GATK3.6/nightly-19-11-2016/GenomeAnalysisTK.jar \
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

	echo "haplotypecalled on chr $chr failed"
	echo "$chr" >> $DIR/final/failed_hc_contigs.txt
	if [[ 23 > ${SLURM_ARRAY_TASK_ID} ]]
	then
		echo 'haplotypecaller failed' >> $DIR/final/failed.txt
	fi
	exit 1
fi

if ! srun ~/pigz-2.3.3/pigz -p ${SLURM_JOB_CPUS_PER_NODE} $DIR/final/${sample}_${chr}.raw.snps.indels.g.vcf
then
	echo "pigz failed $chr"
fi
echo haplotypecaller finish $(date "+%H:%M:%S %d-%m-%Y")

