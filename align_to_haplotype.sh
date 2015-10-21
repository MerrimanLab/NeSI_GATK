#!/bin/bash
# You can use chain jobs to create dependencies between jobs.
# This is often the case if a job relies on the result of one
# or more preceding jobs.
# Chain jobs can also be used if the runtime limit of the
# batch queues is not sufficient for your job.
# SLURM has an option -d or "--dependency" that allows to
# specify that a job is only allowed to start if another job finished.
# Here is an example how a chain job can looks like, the example submits 3 jobs
# (Pre-Processing Job, MPI job and finally the Post-Processing Job)
# that will be executed on after each other


# Murray Cadzow
# University of Otago
# 20 Oct 2015

sample=$1

# start first part of workflow where full genome has to be used
TASKS="s1_align.sl s2_sortSam.sl s3_markdup.sl s4_index.sl s5_indelTarget.sl"
DEPENDENCY=""
for TASK in $TASKS ; do
    JOB_CMD="sbatch"
    if [ -n "$DEPENDENCY" ] ; then
        JOB_CMD="$JOB_CMD --dependency afterok:$DEPENDENCY"
    fi
    JOB_CMD="$JOB_CMD $TASK $sample"
    echo -n "Running command: $JOB_CMD "
    OUT=`$JOB_CMD`
    echo "Result: $OUT"
    DEPENDENCY=`echo $OUT | awk '{print $4}'`
done

LAST_GENOME_DEPENDENCY=$DEPENDENCY

#run by chromosome
for chr in $(seq 1 22); do
TASKS="s6_realign.sl s7_baserecal.sl s8_applyrecal.sl s9_haplotypecaller.sl"
	DEPENDENCY=$LAST_GENOME_DEPENDENCY
	for TASK in $TASKS ; do
    	JOB_CMD="sbatch"
    	if [ -n "$DEPENDENCY" ] ; then
        	JOB_CMD="$JOB_CMD --dependency afterok:$DEPENDENCY"
    	fi
    	JOB_CMD="$JOB_CMD $TASK $sample $chr"
    	echo -n "Running command: $JOB_CMD  "
    	OUT=`$JOB_CMD`
    	echo "Result: $OUT"
    	DEPENDENCY=`echo $OUT | awk '{print $4}'`
	done
done
