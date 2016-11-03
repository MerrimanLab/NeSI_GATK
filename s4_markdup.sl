#!/bin/bash
#SBATCH -J s4_MarkDup
#SBATCH -A nesi00319         # Project Account
#SBATCH --time=05:59:00     # Walltime
#SBATCH --mem-per-cpu=24000  # memory/cpu (in MB)
#SBATCH --cpus-per-task=1   # 12 OpenMP Threads
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
echo markdup start $(date "+%H:%M:%S %d-%m-%Y")

DIR=$1
sample=$2
chr=$(cat ~/NeSI_GATK/contigs_h37.txt | awk -v line=${SLURM_ARRAY_TASK_ID} '{if(NR == line){print}}')
export OPENBLAS_MAIN_FREE=1
source ~/NeSI_GATK/gatk_references.sh
module load SAMtools/1.2-goolf-1.5.14
module load picard/2.1.0

if ! srun samtools view -bh $DIR/temp/${sample}_gathered.bam $chr > $DIR/temp/$chr.bam ; then
    echo "contig bam creation failed"
    echo "contig bam creation failed" >> $DIR/final/failed.txt
    exit 1
fi



if ! srun java -Xmx19g -jar $EBROOTPICARD/picard.jar MarkDuplicates \
                                                        INPUT=$DIR/temp/${chr}.bam \
                                                        OUTPUT=$DIR/temp/${sample}_dedup_reads_${chr}.bam \
                                                        METRICS_FILE=$DIR/logs/metrics.txt \
                                                        CREATE_INDEX=true \
                                                        TMP_DIR=$DIR ; then
	echo "markdup failed"
	echo "markdup failed" >> $DIR/final/failed.txt
	exit 1
fi
JOBID=$(sbatch ~/NeSI_GATK/s4_index.sl $DIR $sample)
echo index $(echo $JOBID | awk '{print $4'}) >> $DIR/jobs.txt
rm $DIR/temp/${chr}.bam 

Ncontigs=$(cat ~/NeSI_GATK/contigs_h37.txt | wc -l)
JOBID=$(sbatch -J s7_baserecal --array=1-$Ncontigs ~/NeSI_GATK/s7_baserecal.sl $DIR $sample)
JOBID2=$(sbatch -d $(echo $JOBID | awk '{print $4}') -J s8_applyrecal --array=1-$Ncontigs ~/NeSI_GATK/s8_applyrecal.sl $DIR $sample)
JOBID3=$(sbatch -d $(echo $JOBID2 | awk '{print $4}') -J s9_haplotypecaller --array=1-$Ncontigs ~/NeSI_GATK/s9_haplotypecaller.sl $DIR $sample)
JOBID4=$(sbatch -d $(echo $JOBID3 | awk '{print $4}') ~/NeSI_GATK/s10_finish.sl $DIR)

echo baserecal $(echo $JOBID | awk '{print $4}') >> $DIR/jobs.txt
echo applyrecal $(echo $JOBID2 | awk '{print $4}') >> $DIR/jobs.txt
echo haplotypecaller $(echo $JOBID3 | awk '{print $4}') >> $DIR/jobs.txt
echo finish $(echo $JOBID4 | awk '{print $4}') >> $DIR/jobs.txt



echo markdup finish $(date "+%H:%M:%S %d-%m-%Y")

