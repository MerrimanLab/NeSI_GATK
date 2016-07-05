#!/bin/bash
#SBATCH -J s5_indelTargetCreator
#SBATCH -A uoo00053         # Project Account
#SBATCH --time=15:00:00     # Walltime
#SBATCH --mem-per-cpu=4024  # memory/cpu (in MB)
#SBATCH --cpus-per-task=16 # 16 OpenMP Threads
#SBATCH --nodes=1
#SBATCH --mail-user=matt.bixley@otago.ac.nz
#SBATCH --mail-type=ALL
#SBATCH -C sb

# Murray Cadzow
# University of Otago
# 20 Oct 2015

# Matt Bixley
# University of Otago
# Jun 2016

sample=FR07921700
export OPENBLAS_MAIN_FREE=1

#echo slurm jobib = $SLURM_JOBID > $SLURM_SUBMIT_DIR/dirs.txt
#echo slurm submit dir = $SLURM_SUBMIT_DIR >> $SLURM_SUBMIT_DIR/dirs.txt
#echo slurm tmp dir = $TMP_DIR >> $SLURM_SUBMIT_DIR/dirs.txt

DBSNP=~/uoo00053/reference_files/dbsnp_138.b37.vcf
MILLS=~/uoo00053/reference_files/Mills_and_1000G_gold_standard.indels.b37.vcf
INDELS=~/uoo00053/reference_files/1000G_phase1.indels.b37.vcf
REF=~/uoo00053/reference_files/hs37d5/hs37d5.fa

#DIR=$SLURM_SUBMIT_DIR
DIR=~/uoo00053/working/
GATK=~/uoo00053/GATK3.6/GenomeAnalysisTK.jar
module load Java/1.8.0_5

#if ! srun java -Xmx30g -jar $GATK \
#	-T RealignerTargetCreator \
#	-R $REF \
#	-I ~/uoo00053/working/${sample}_dedup_reads.bam \
#	-o ~/uoo00053/working/${sample}_output.intervals \
#	-known ${MILLS} \
#	-known ${INDELS} \
#	-l INFO \
#	-nt 16 \
#	-log ${sample}_target.log ; then
#
#	echo "indel target creator failed"
#	exit 1
#fi
#for chr in {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,X,Y,MT}; do
contigs=$(cat contig_h37.txt)
for chr in ${contigs[@]}; do
	sbatch -J s6_realign_chr${chr} ~/NeSI_GATK/s6_realign.sl $sample $chr
	echo "job for chr $chr submitted"
	sleep 1 
done
