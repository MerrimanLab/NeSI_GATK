#!/bin/bash
#SBATCH -J s3_merge_bams
#SBATCH -A nesi00319         # Project Account
#SBATCH --time=15:59:00     # Walltime
#SBATCH --mem-per-cpu=13002  # memory/cpu (in MB)
#SBATCH --cpus-per-task=2   # 12 OpenMP Threads
#SBATCH --nodes=1
#SBATCH -C sb
#SBATCH --mail-user=murray.cadzow@otago.ac.nz
#SBATCH --mail-type=FAIL,TIME_LIMIT_90

# Murray Cadzow
# University of Otago
# 20 Oct 2015

# Matt Bixley
# University of Otago
# Jun 2016
echo merge_bam start $(date "+%H:%M:%S %d-%m-%Y")

DIR=$1
sample=$2
export OPENBLAS_MAIN_FREE=1
source ~/NeSI_GATK/gatk_references.sh

module load picard/2.1.0
rm $DIR/input/*fastq.gz
rm $DIR/temp/*.fastq.gz
ls $DIR/temp/${sample}_sorted*.bam > temp/sorted_bams.txt

if ! srun java -Xmx19g -jar $EBROOTPICARD/picard.jar MergeSamFiles $(sed 's/^/I=/g' < temp/sorted_bams.txt | tr '\n' ' ') \
                                                            OUTPUT=$DIR/temp/${sample}_gathered.bam \
                                                            USE_THREADING=true \
                                                            CREATE_INDEX=true \
                                                            SORT_ORDER=coordinate ; then
	echo "merge bam failed"
	echo "merge bam failed" >> $DIR/final/failed.txt
	exit 1
fi

Ncontigs=$(cat ~/NeSI_GATK/contigs_h37.txt | wc -l)

JOBID=$(sbatch --array=1-$Ncontigs ~/NeSI_GATK/s4_markdup.sl $DIR $sample)

JOBID2_1=$(sbatch -d afterok:$(echo $JOBID |awk '{print $4}') -J s5_baserecal_1 --array=1-24 ~/NeSI_GATK/s5_baserecal.sl $DIR $sample)
JOBID2_2=$(sbatch -d afterok:$(echo $JOBID |awk '{print $4}') -J s5_baserecal_2 --array=25-$Ncontigs --time=3:00:00 ~/NeSI_GATK/s5_baserecal.sl $DIR $sample)

JOBID3_1=$(sbatch -d afterok:$(echo $JOBID2_1 | awk '{print $4}') -J s6_applyrecal_1 --array=1-24 ~/NeSI_GATK/s6_applyrecal.sl $DIR $sample)
JOBID3_2=$(sbatch -d afterok:$(echo $JOBID2_2 | awk '{print $4}') -J s6_applyrecal_2 --array=25-$Ncontigs --time=3:00:00 ~/NeSI_GATK/s6_applyrecal.sl $DIR $sample)

JOBID4_1=$(sbatch -d afterok:$(echo $JOBID3_1 | awk '{print $4}') -J s7_haplotypecaller_1 --array=1-24 ~/NeSI_GATK/s7_haplotypecaller.sl $DIR $sample)
JOBID4_2=$(sbatch -d afterok:$(echo $JOBID3_2 | awk '{print $4}') --time=3:00:00 --mem-per-cpu=4048 -J s7_haplotypecaller_2 --array=25-$Ncontigs ~/NeSI_GATK/s7_haplotypecaller.sl $DIR $sample)

JOBID5=$(sbatch -d afterok:$(echo $JOBID4_1 | awk '{print $4}'),after:$(echo $JOBID4_2 | awk '{print $4}') ~/NeSI_GATK/s8_finish.sl $DIR)


echo markdup $(echo $JOBID | awk '{print $4}') >> $DIR/jobs.txt
echo baserecal_1 $(echo $JOBID2_1 | awk '{print $4}') >> $DIR/jobs.txt
echo baserecal_2 $(echo $JOBID2_2 | awk '{print $4}') >> $DIR/jobs.txt
echo applyrecal_1 $(echo $JOBID3_1 | awk '{print $4}') >> $DIR/jobs.txt
echo applyrecal_2 $(echo $JOBID3_2 | awk '{print $4}') >> $DIR/jobs.txt
echo haplotypecaller_1 $(echo $JOBID4_1 | awk '{print $4}') >> $DIR/jobs.txt
echo haplotypecaller_2 $(echo $JOBID4_2 | awk '{print $4}') >> $DIR/jobs.txt
echo finish $(echo $JOBID5 | awk '{print $4}') >> $DIR/jobs.txt



rm $DIR/temp/${sample}_aligned_reads_*.ba[mi]
rm $DIR/temp/${sample}_sorted_*.ba[mi] 
echo merge_bam finish $(date "+%H:%M:%S %d-%m-%Y")

