#!/bin/bash
#SBATCH -J s6_realign
#SBATCH -A uoo00008         # Project Account
#SBATCH --time=00:01:00     # Walltime
#SBATCH --mem-per-cpu=1024  # memory/cpu (in MB)
#SBATCH --cpus-per-task=1   # 12 OpenMP Threads
#SBATCH --array=1-22

# Murray Cadzow
# University of Otago
# 20 Oct 2015


export OPENBLAS_MAIN_FREE=1

i=$SLURM_ARRAY_TASK_ID
#echo slurm jobib = $SLURM_JOBID > $SLURM_SUBMIT_DIR/dirs.txt
#echo slurm submit dir = $SLURM_SUBMIT_DIR >> $SLURM_SUBMIT_DIR/dirs.txt
#echo slurm tmp dir = $TMP_DIR >> $SLURM_SUBMIT_DIR/dirs.txt


DBSNP=~/Murray/Bioinformatics/Reference_Files/ALL.wgs.dbsnp.build135.snps.sites.vcf.gz
MILLS=~/Murray/Bioinformatics/Reference_Files/ALL.wgs.indels_mills_devine_hg19_leftAligned_collapsed_double_hit.indels.sites.vcf.gz
INDELS=~/Murray/Bioinformatics/Reference_Files/ALL.wgs.low_coverage_vqsr.20101123.indels.sites.vcf.gz
REF=~/Murray/Bioinformatics/Reference_Files/FASTA/hs37d5/hs37d5.fa


DIR=$SLURM_SUBMIT_DIR
module load GATK/3.4-46

echo "srun java -Xmx30g -jar $GATK \
	-T IndelRealigner \
	-R $REF \
	-I dedup_reads.bam \
	-o realigned_reads_${i}.bam \
	-targetIntervals output.intervals \
	-known ${MILLS} \
	-known ${INDELS} \
	-LOD 5.0 \
	-model USE_READS \
	-log realign${i}.log \
	-l INFO \
	-L ${i}"
	 

