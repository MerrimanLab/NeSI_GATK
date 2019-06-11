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
echo gatherrecal start $(date "+%H:%M:%S %d-%m-%Y")

export OPENBLAS_MAIN_FREE=1

DIR=$1
sample=$2
chr=$(cat ~/uoo02378/NeSI_GATK/contigs_h37.txt | awk -v line=${SLURM_ARRAY_TASK_ID} '{if(NR == line){print}}')

source ~/uoo02378/NeSI_GATK/gatk_references.sh

Ncontigs=$(cat ~/uoo02378/NeSI_GATK/contigs_h37.txt | wc -l)


module load GATK/4.0.11.0-gimkl-2017a

ls $DIR/temp/${sample}_recal_data_*.csv > $DIR/temp/reports.list
	
if ! srun java -Xmx30g -jar $EBROOTGATK/gatk-package-4.0.11.0-local.jar \
	GatherBQSRReports \
	-I $DIR/temp/reports.list \
	-O $DIR/final/${sample}_baserecal_reads_gathered.table \
	--verbosity INFO ; then

	echo "gather reports failed"
	echo 'gather reports failed' >> $DIR/final/failed.txt
	exit 1
fi
#rm $DIR/temp/${sample}_dedup_reads_${chr}.ba*
echo gather reports finish $(date "+%H:%M:%S %d-%m-%Y")

#JOBID3_1=$(sbatch -A uoo02378 -J s7_applyrecal_1 --array=1-24 ~/uoo02378/NeSI_GATK/s7_applyrecal.sl $DIR $sample)
#JOBID3_2=$(sbatch -A uoo02378 -J s7_applyrecal_2 --array=25-$Ncontigs --time=3:00:00 ~/uoo02378/NeSI_GATK/s7_applyrecal.sl $DIR $sample)

