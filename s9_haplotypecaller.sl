#!/bin/bash
#SBATCH -J s9_haplotypeCaller
#SBATCH -A uoo00053         # Project Account
#SBATCH --time=15:00:00     # Walltime
#SBATCH --mem-per-cpu=4048  # memory/cpu (in MB)
#SBATCH --cpus-per-task=16   # 12 OpenMP Threads
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
i=$3
source ~/NeSI_GATK/gatk_references.sh

DIR=$SLURM_SUBMIT_DIR
module load GATK/3.6-Java-1.8.0_40

if ! srun java -jar -Xmx30g $EBROOTGATK/GenomeAnalysisTK.jar \
	-T HaplotypeCaller \
	-R $REF \
	-I $DIR/final/${sample}_baserecal_reads_${i}.bam \
	-L ${i} \
	--emitRefConfidence GVCF \
	--variant_index_type LINEAR \
	--variant_index_parameter 128000 \
	--dbsnp $DBSNP \
	-o $DIR/final/${sample}_${i}.raw.snps.indels.g.vcf \
	-nct 16 ; then

	echo "haplotypecalled on chr $i failed"
	exit 1
fi

