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

DIR=$1
sample=$2
export OPENBLAS_MAIN_FREE=1
source ~/NeSI_GATK/gatk_references.sh


module load GATK/3.6-Java-1.8.0_40

if ! srun java -Xmx30g -jar $EBROOTGATK/GenomeAnalysisTK.jar \
	-T RealignerTargetCreator \
	-R $REF \
	-I $DIR/temp/${sample}_dedup_reads.bam \
	-o $DIR/temp/${sample}_output.intervals \
	-known ${MILLS} \
	-known ${INDELS} \
	-l INFO \
	-nt 16 \
	-log $DIR/logs/${sample}_target.log ; then

	echo "indel target creator failed"
	exit 1
fi
#for chr in {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,X,Y,MT}; do
contigs=$(cat contigs_h37.txt)
for chr in ${contigs[@]}; do
	sbatch -J s6_realign_chr${chr} ~/NeSI_GATK/s6_realign.sl $sample $chr
	echo "job for chr $chr submitted"
	sleep 1 
done
