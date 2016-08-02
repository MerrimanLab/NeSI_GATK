#!/bin/bash
#SBATCH -J s8_printReads
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

#i=$SLURM_ARRAY_TASK_ID
DIR=$1
sample=$2
i=$3

source ~/NeSI_GATK/gatk_references.sh

module load GATK/3.6-Java-1.8.0_40

if ! srun java -Xmx30g -jar $EBROOTGATK/GenomeAnalysisTK.jar \
	-T PrintReads \
	-R $REF \
	-BQSR $DIR/temp/${sample}_recal_data${i}.grp \
	-I $DIR/temp/${sample}_realigned_reads_${i}.bam \
	-o $DIR/final/${sample}_baserecal_reads_${i}.bam \
	-l INFO \
	-log $DIR/logs/printreads${i}.log \
	-L ${i} ; then

	echo "print reads on chr $i failed"
	exit 1
fi

JOB=$(sbatch -J s9_haplotypecaller_chr${i} ~/NeSI_GATK/s9_haplotypecaller.sl $DIR $sample $i)
echo "chr $i haplotypecaller job submitted $JOB"
