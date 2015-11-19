#!/bin/bash
#SBATCH -J s6_realign
#SBATCH -A nesi00225         # Project Account
#SBATCH --time=15:00:00     # Walltime
#SBATCH --mem-per-cpu=31024  # memory/cpu (in MB)
#SBATCH --cpus-per-task=1   # 12 OpenMP Threads
#SBATCH --mail-user=murray.cadzow@otago.ac.nz
#SBATCH --mail-type=ALL
#SBATCH -C sb



# Murray Cadzow
# University of Otago
# 20 Oct 2015


export OPENBLAS_MAIN_FREE=1

#i=$SLURM_ARRAY_TASK_ID
sample=$1
i=$2
#echo slurm jobib = $SLURM_JOBID > $SLURM_SUBMIT_DIR/dirs.txt
#echo slurm submit dir = $SLURM_SUBMIT_DIR >> $SLURM_SUBMIT_DIR/dirs.txt
#echo slurm tmp dir = $TMP_DIR >> $SLURM_SUBMIT_DIR/dirs.txt


DBSNP=~/nesi00225/reference_files/resource_bundle2014/dbsnp_138.b37.vcf
MILLS=~/nesi00225/reference_files/resource_bundle2014/Mills_and_1000G_gold_standard.indels.b37.vcf
INDELS=~/nesi00225/reference_files/resource_bundle2014/1000G_phase1.indels.b37.vcf
REF=~/nesi00225/reference_files/hs37d5/hs37d5.fa

DIR=$SLURM_SUBMIT_DIR
module load GATK/3.4-46

if ! srun java -Xmx30g -jar $GATK \
	-T IndelRealigner \
	-R $REF \
	-I ${sample}_dedup_reads.bam \
	-o ${sample}_realigned_reads_${i}.bam \
	-targetIntervals ${sample}_output.intervals \
	-known ${MILLS} \
	-known ${INDELS} \
	-LOD 5.0 \
	-model USE_READS \
	-log ${sample}_realign${i}.log \
	-l INFO \
	-L ${i} ; then

	echo "realign failed"
	exit 1
fi
	 
sbatch -J s7_baserecal_chr${i} ~/nesi00225/nesi_gatk/s7_baserecal.sl $sample $i
