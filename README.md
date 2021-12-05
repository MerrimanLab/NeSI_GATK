# NeSI_GATK

[![DOI](https://zenodo.org/badge/44510166.svg)](https://zenodo.org/badge/latestdoi/44510166)

An implementation of the [GATK best practices](https://software.broadinstitute.org/gatk/best-practices/bp_3step.php?case=GermShortWGS) for whole (human) genome sequence variant calling that will run on the NeSI PAN cluster


need to have pigz installed (path is currently hard coded in s0_split.sl)


Designed on GATK best practices for GATK 3.4 using GRCh37 of the human genome.

Updated for GATK 3.6 (AUG 2016)

Updated for GATK 4.1.3 (SEP 2020)
- Removed need for globus to run pipeline
    
The redesign of the pipeline removed the python control script because NeSI updated their platform and now provided sufficient disk quota to no longer need to manage batches. The new workflow is copy data to NeSI (globus) -> process it all -> copy it all back (globus)

to run:
```bash
start_sample.sh <sample_directory> <sample_fastq_prefix> <sample_name>
```
