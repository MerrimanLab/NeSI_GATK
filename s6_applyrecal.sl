#!/bin/bash
#SBATCH -J s6_printReads
#SBATCH -A uoo00053         # Project Account
#SBATCH --time=5:59:00     # Walltime
#SBATCH --mem-per-cpu=31024  # memory/cpu (in MB)
#SBATCH --cpus-per-task=1   # 12 OpenMP Threads
#SBATCH -C sb
#SBATCH --mail-user=murray.cadzow@otago.ac.nz
#SBATCH --mail-type=FAIL,TIME_LIMIT_90

# Murray Cadzow
# University of Otago
# 20 Oct 2015

# Matt Bixley
# University of Otago
# Jun 2016
echo applyrecal start $(date "+%H:%M:%S %d-%m-%Y")

export OPENBLAS_MAIN_FREE=1

DIR=$1
sample=$2
chr=$(cat ~/NeSI_GATK/contigs_h37.txt | awk -v line=${SLURM_ARRAY_TASK_ID} '{if(NR == line){print}}')

source ~/NeSI_GATK/gatk_references.sh

module load GATK/3.6-Java-1.8.0_40

if ! srun java -Xmx30g -jar $EBROOTGATK/GenomeAnalysisTK.jar \
	-T PrintReads \
	-R $REF \
	-BQSR $DIR/temp/${sample}_recal_data_${chr}.grp \
	-I $DIR/temp/${sample}_dedup_reads.bam \
	-o $DIR/final/${sample}_baserecal_reads_${chr}.bam \
	-l INFO \
	-log $DIR/logs/printreads_${chr}.log \
	-L ${chr} ; then

	echo "print reads on chr $i failed"
	echo 'print reads failed' > $DIR/final/failed.txt
	exit 1
fi

echo applyrecal finish $(date "+%H:%M:%S %d-%m-%Y")

