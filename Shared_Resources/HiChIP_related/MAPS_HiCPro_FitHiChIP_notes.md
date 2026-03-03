# Analysis Arima HiChIP data with default pipeline

### install in biowulf conda env
### the newer version of MAPS is located at https://github.com/HuMingLab/MAPS since Mar, 2023

login Biowulf and setup env,then activate conda

Clone the MAPS from github

`git clone https://github.com/HuMingLab/MAPS.git`

Create conda environment with python 

`conda create -n MAPS_env python=3.10`

Activate the conda environment

`conda activate MAPS_env`

Once activate the conda environment, start install tools

`mamba install -c bioconda deeptools`

`mamba install pandas`

`mamba install  pysam` 

`mamba install -c conda-forge -c bioconda pybedtools` 

`mamba  install -c bioconda macs2`

`mamba install R=4.2`

`$ R` then in R, install package

`install.packages("argparse")`

`install.packages("data.table")`

The error when running huge data, need VGAM older version ...

https://github.com/ijuric/MAPS/issues/29

```r
# in R 
packageurl <- "https://cran.r-project.org/src/contrib/Archive/VGAM/VGAM_1.1-3.tar.gz"

install.packages(packageurl, repos=NULL, type="source")
```


- As for other tools, it's already in Biowulf:

bedtools
	
 samtools
	
 HTSLIB
	
 bcftools
	
 bwa
	
`ml samtools bedtools bwa`

- Once installed, move the `Arima-MAPS_v2.0.sh`  from `MAPS/Arima_Genomics/` directory to `MAPS/bin/`
- It need **absolute pathway** for output for the command will have error. 
- for file name **abcd_**_R1.fastq.gz, the `-I`  inupt in command should  **abcd** 


```
# code example
# the newer version of folder in biowulf is:
# /data/leec20/HiChIP_arima_miseq_novaseq_project_091223

sh /data/leec20/HiChIP_Miseq_0320/MAPS/bin/Arima-MAPS_v2.0.sh\
 -C 1 -p broad -I /data/leec20/HiChIP_Miseq_0320/test_file/Arima-MAPS-test\
 -O /data/leec20/HiChIP_Miseq_0320/test_file/output\
 -o hg38 -b /fdb/igenomes/Homo_sapiens/UCSC/hg38/Sequence/BWAIndex/genome.fa -t 6 -f 1

```

**Note:**
-f 1/0 is design for `-f 0` is for shallow seq and `-f 1` is for Deep sequence

```
#!/bin/bash

source myconda
conda activate MAPS_new
ml samtools bedtools bwa

sh /data/leec20/HiChIP_arima_miseq_novaseq_project_091223/MAPS/bin/Arima-MAPS_v2.0.sh -C 1 -p broad -I /data/leec20/HiChIP_arima_miseq_novaseq_project_091223/ELENTA_fastqs/Sample-2 -O /data/leec20/HiChIP_arima_miseq_novaseq_project_091223/Elenta_Output -o hg38 -b /fdb/igenomes/Homo_sapiens/UCSC/hg38/Sequence/BWAIndex/genome.fa -t 6 -f 0

echo all Done

```

*************
*************
*************


# Alternative ways to analysis HiChIP 
## Using HiC-pro to generate the files for other downstream tools

- HiC-pro is most used tools https://github.com/nservant/HiC-Pro
- Biowulf has HiCpro (ver: 3.1.0_v2) https://hpc.nih.gov/apps/hicpro.html
- script location in Biowulf for HiC-pro utils: 
`/usr/local/apps/hicpro/3.1.0_v2/HiC-Pro_3.1.0/bin/utils/`
- to run the tools, first need to have **`config files`**, **`genome.size files`**, and **`enzyme digested file`**


- **config files**
	- Config files are located in https://github.com/nservant/HiC-Pro/blob/master/config-hicpro.txt
	- Copy and edit the configuration file `config-hicpro.txt` in your local folder.
	- Here's the example for Arima config files: 
	- **NOTE** need to change the cpu mem use, Bowtie path depend on hg19 or hg38, and the path of arima enzyme digest file, the genome.size file

```
#########################################################################
## Paths and Settings  - Do not edit !
#########################################################################

TMP_DIR = tmp
LOGS_DIR = logs
BOWTIE2_OUTPUT_DIR = bowtie_results
MAPC_OUTPUT = hic_results
RAW_DIR = rawdata

#######################################################################
## SYSTEM - PBS - Start Editing Here !!
#######################################################################
N_CPU = 24
LOGFILE = hicpro_arima.hg19.log

JOB_NAME = arima_mai_test
JOB_MEM = 40G
JOB_WALLTIME = 24:00:00
JOB_QUEUE = norm
JOB_MAIL = 

#########################################################################
## Data
#########################################################################

PAIR1_EXT = _R1
PAIR2_EXT = _R2

#######################################################################
## Alignment options
#######################################################################

FORMAT = phred33
MIN_MAPQ = 30

BOWTIE2_IDX_PATH = /fdb/igenomes/Homo_sapiens/UCSC/hg19/Sequence/Bowtie2Index/
BOWTIE2_GLOBAL_OPTIONS = --very-sensitive -L 30 --score-min L,-0.6,-0.2 --end-to-end --reorder
BOWTIE2_LOCAL_OPTIONS =  --very-sensitive -L 20 --score-min L,-0.6,-0.2 --end-to-end --reorder

#######################################################################
## Annotation files
#######################################################################

REFERENCE_GENOME = genome
GENOME_SIZE = /data/leec20/hichip_CHiC_project/HiC_pro/hg19.chrom.sizes

#######################################################################
## Allele specific
#######################################################################

ALLELE_SPECIFIC_SNP = 

#######################################################################
## Digestion Hi-C
#######################################################################

GENOME_FRAGMENT = /data/leec20/hichip_CHiC_project/HiC_pro/arima_hg19_hicpro_digest.bed
LIGATION_SITE = GATCGATC,GANTGATC,GANTANTC,GATCANTC
MIN_FRAG_SIZE = 100
MAX_FRAG_SIZE = 100000
MIN_INSERT_SIZE = 100
MAX_INSERT_SIZE = 600

#######################################################################
## Hi-C processing
#######################################################################

MIN_CIS_DIST =
GET_ALL_INTERACTION_CLASSES = 1
GET_PROCESS_SAM = 1
RM_SINGLETON = 1
RM_MULTI = 1
RM_DUP = 1

#######################################################################
## Contact Maps
#######################################################################

BIN_SIZE = 2500 5000 10000 25000 500000 1000000
MATRIX_FORMAT = upper

#######################################################################
## ICE Normalization
#######################################################################
MAX_ITER = 100
FILTER_LOW_COUNT_PERC = 0.02
FILTER_HIGH_COUNT_PERC = 0
EPS = 0.1

```


- **genome.szie file**
	Quote from HiC-pro github:

	"A table file of chromosomes' size. This file can be easily find on the UCSC genome browser. Of note, pay attention to the contigs or scaffolds, and be aware that HiC-pro 	will generate a map per chromosomes pair. For model organisms such as Human or Mouse, which are well annotated, we usually recommand to remove all scaffolds."

	can download from UCSC, need to remove scafford etc. and just keep chr1 to chr22 and chrXY

	hg38: https://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/hg38.chrom.sizes

	hg19: https://hgdownload.soe.ucsc.edu/goldenPath/hg19/bigZips/hg19.chrom.sizes


- **enzyme digest file for Armia HiChIP kit**
	Since Arima use multiple enzyme digest, need to adjust the script. 

	According to github: https://github.com/nservant/HiC-Pro/issues/202 and https://github.com/nservant/HiC-Pro/blob/master/doc/FAQ.md
	The script look like this:
	`digest_genome.py -r ^GATC G^ANTC -o arima.digest.bed /fdb/igenomes/Homo_sapiens/UCSC/hg19/Sequence/Bowtie2Index/genome.fa`


---------



- **HiC-Pro output** 

After finished, the output folder look like:

https://github.com/nf-core/hic/blob/master/docs/output.md

---------

## FitHiChIP tool for loop calling base on HiC-pro output

FitHiChIP is another tool for HiChIP analysis, **it can do the differential loop analysis**. 
ref: https://ay-lab.github.io/FitHiChIP/html/index.html

**Installation**

- can install using conda
  
- Biowulf has `FitHiChIP` installed https://hpc.nih.gov/apps/FitHiChIP.html



**How to run**

- reqirements:

```
- HiC-Pro validpair files
- Chip peak seq
- chromosme size file
- config file
```

**Step1. Start from HiC-Pro output**

Once finished running HiC-pro, use the output 

Using the ValidPairs= option, user can provide the valid pairs generated by HiC-pro pipeline.

The file can be either in simple text format, or can be gzipped.

Usually, name of the valid pairs file generated from HiC-pro pipeline is `${HICPRODIR}/hic_results/data/rawdata/rawdata.allValidPairs` where `${HICPRODIR}` is the directory containing HiC-pro output.




**Step2. Setting up configure file and Chip-seq track**

- 4 configure files flavor to select
  
```
- configfile_BiasCorrection_CoverageBias

FitHiChIP(L) with coverage bias regression

- configfile_BiasCorrection_ICEBias

FitHiChIP(L) with ICE bias regression

- configfile_P2P_BiasCorrection_CoverageBias

FitHiChIP(S) with coverage bias regression

- configfile_P2P_BiasCorrection_ICEBias

FitHiChIP(S) with ICE bias regression
```


**Example of config file setting** 

- A quick overview, ref from Dovetail: https://dovetail-analysis.readthedocs.io/en/latest/hichip/loop_calling.html#resolution

<img width="706" height="829" alt="Screenshot 2025-09-30 at 12 30 08 PM" src="https://github.com/user-attachments/assets/7a0fa9ce-f481-4bad-9204-ef57a88ea058" />


**how to  generated ChIP-peak:**

- Download public ChIP-seq data from ENCODE
  
  - Here's the example: https://github.com/ay-lab/FitHiChIP/issues/67
    
  - In ENCODE, for example, search cell line GM12878 with H3K27Ac ChIp-seq hg38 `bed narrowPeak` format.
    
  :bell: Need to dobule check the genome build is hg19 or hg38 to match your result! 

- inferring peaks from HiChIP data (for use in the HiChIP pipeline)
- need to load `ml macs` tool 

The script **PeakInferHiChIP.sh** within the folder **Imp_Scripts** is used to infer peaks from HiChIP data. The script can be used if HiC-pro pipeline is already executed on a given pair of reads (such as .fastq.gz read pairs). The script uses **macs2** package for inferring the peaks. Parameters associated with this script are as follows:

```
-H HiCProDir
 
Directory containing the reads generated by HiC-pro pipeline. Within this directory, files of the formats .ValidPairs, .DEPairs, .REPairs, and .SCPairs are present, which corresponds to different categories of reads generated by the HiC-pro pipeline.
 
-D OutDir
 
Directory to contain the output set of peaks. Default: current directory
 
-R refGenomeStr
 
Reference genome specific string used for MACS2. Default is 'hs' for human chromosome. For mouse, specify 'mm'.
 
-M MACS2ParamStr
 
String depicting the parameters for MACS2. Default: "--nomodel --extsize 147 -q 0.01"
 
-L ReadLength

Length of reads for the HiC-pro generated reads. Default 75

```

The script uses all of the DE, SC, RE and validpairs reads generated from the HiC-pro pipeline to infer peaks. The folder **MACS2_ExtSize** within the specified output directory contains the MACS2 generated peaks.

- use xxx.narrowpeak as Chip-seq input for Fithichip pipeline 

- HiC-pro is required to `ml hicpro` when using ICE bias normalization in Biowulf

- good exlpian:https://hichip.readthedocs.io/en/latest/loops.html

**Step3. Run the script**

First copy the fithichip scripts into your folder

```
ml fithichip
cp -r $FITHICHIP_SRC/*  .
```
Once the files are there, use the script to run

```
#!/bin/bash
ml fithichip

./FitHiChIP_HiCPro.sh -C configfile_test

```



**The results**
- The **xxx.interactions_FitHiC_Q0.01_MergeNearContacts_IGV.bedpe** column score is `-log10(fdr)`


**Notes**
	- dealing with replicates:  put all the fastqs of replicates in the same fastq folder, and run HiC-Pro is the preferable way.
	
	- Error: When encounting samtools error samtools sort: fail to open xxx.bam Too many open files.
	
	The link provide solution: https://github.com/nservant/HiC-Pro/issues/392
	












