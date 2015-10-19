#!/bin/bash
#SBATCH -J s5_indelTargetCreator
#SBATCH -A uoo00008         # Project Account
#SBATCH --time=00:01:00     # Walltime
#SBATCH --mem-per-cpu=1024  # memory/cpu (in MB)
#SBATCH --cpus-per-task=1   # 12 OpenMP Threads
#SBATCH --nodes=1
export OPENBLAS_MAIN_FREE=1

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
	-T RealignerTargetCreator \
	-R $reference_fasta \
	-I dedup_reads.bam \
	-o output.intervals \
	-known ${MILLS} \
	-known ${INDELS} \
	-l INFO \
	-nt 12 \
	-log target.log "
	 

