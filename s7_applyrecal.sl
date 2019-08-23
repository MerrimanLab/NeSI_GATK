#!/bin/bash
#SBATCH -J s6_applyrecal
#SBATCH --time=5:59:00     # Walltime
#SBATCH --mem-per-cpu=31024  # memory/cpu (in MB)
#SBATCH --cpus-per-task=1   # 12 OpenMP Threads
#SBATCH --mail-user=murray.cadzow@otago.ac.nz
#SBATCH --mail-type=FAIL,TIME_LIMIT_90

# Murray Cadzow
# University of Otago
# 20 Oct 2015

# Matt Bixley
# University of Otago
# Jun 2016
echo applybqsr start $(date "+%H:%M:%S %d-%m-%Y")

export OPENBLAS_MAIN_FREE=1

DIR=$1
sample=$2
chr=$(cat ~/uoo02378/NeSI_GATK/contigs_h37.txt | awk -v line=${SLURM_ARRAY_TASK_ID} '{if(NR == line){print}}')

source ~/uoo02378/NeSI_GATK/gatk_references.sh

module restore
module load GATK/4.1.0.0-gimkl-2017a


if ! srun java -Xmx30g -jar $EBROOTGATK/gatk-package-4.1.0.0-local.jar \
	ApplyBQSR \
	-R $REF \
	-bqsr-recal-file $DIR/final/${sample}_baserecal_reads_gathered.table \
	-I $DIR/temp/${sample}_dedup_reads.bam \
	-O $DIR/final/${sample}_baserecal_reads_${chr}.bam \
	--emit-original-quals true \
	-L ${chr} ; then

	echo "applybqsr on chr $i failed"
	echo "applybqsr failed chr $i" >> $DIR/final/failed.txt
	exit 1
fi
#rm $DIR/temp/${sample}_dedup_reads_${chr}.ba*
echo applybqsr finish $(date "+%H:%M:%S %d-%m-%Y")

