#!/bin/bash
#SBATCH -J s8_printReads
#SBATCH -A uoo00008         # Project Account
#SBATCH --time=15:00:00     # Walltime
#SBATCH --mem-per-cpu=31024  # memory/cpu (in MB)
#SBATCH --cpus-per-task=1   # 12 OpenMP Threads
#SBATCH --mail-user=murray.cadzow@otago.ac.nz
#SBATCH --mail-type=ALL


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


DBSNP=~/nesi00225/reference_files/resource_bundle2014/dbsnp_138.b37.vcf.gz
MILLS=~/nesi00225/reference_files/resource_bundle2014/Mills_and_1000G_gold_standard.indels.b37.vcf
INDELS=~/nesi00225/reference_files/resource_bundle2014/1000G_phase1.indels.b37.vcf
REF=~/nesi00225/reference_files/hs37d5/hs37d5.fa

DIR=$SLURM_SUBMIT_DIR
module load GATK/3.4-46

if ! srun java -Xmx30g -jar $GATK \
	-T PrintReads \
	-R $REF \
	-BQSR ${sample}_recal_data${i}.grp \
	-I ${sample}_realigned_reads_${i}.bam \
	-o ${sample}_baserecal_reads_${i}.bam \
	-l INFO \
	-log printreads${i}.log \
	-L ${i} ; then

	echo "print reads on chr $i failed"
	exit 1
fi
sbatch ~/nesi00225/nesi_gatk/s9_haplotypecaller.sl $sample $i
