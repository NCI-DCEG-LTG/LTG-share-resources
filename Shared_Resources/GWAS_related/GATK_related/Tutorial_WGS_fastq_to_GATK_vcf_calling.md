# Goal: 
- The complete pipeline of variant calling from DCGE course

https://nci-iteb.github.io/tumor_epidemiology_approaches/sessions/session_4/practical

- start from WGS fastqs to end of the vcf file


# Data and HPC requirement:
- Input: WGS fastq files
- Ref: GATK reference in Biowulf


# Code:

1. alignment, QC, and deduplication.

  - Need to modify the code to mathc fastq location etc.
  - Input: fastqs, output: aligned.removed.duplcates.bam, and bqsr.report file 
    
```
#!/bin/bash

#### Data preprocess for somatic short variant discovery using GATK workflow ###

module load samtools
module load bwa
module load fastp
module load GATK/4.3.0.0
module load picard/2.27.3

GATK_Bundle=/fdb/GATK_resource_bundle/hg38-v0
GENOME=$GATK_Bundle/Homo_sapiens_assembly38.fasta

SAMPLE=$1
INDIR=$2
DIR=$3
logs=$DIR/logs
read1=$INDIR/${SAMPLE}_R1.fastq.gz
read2=$INDIR/${SAMPLE}_R2.fastq.gz
id=$SAMPLE
lb=$id
sm=$id

SECONDS=0

echo -e "sample:$SAMPLE\nindir:$INDIR\noutdir:$DIR"

if [ ! -d "$DIR" ]; then
        mkdir -p $DIR
fi
if [ ! -d "$logs" ]; then
        mkdir -p $logs
fi
### Perform adaptor trimming on fastq files ###
fastp -i $read1 -I $read2 \
      --stdout --thread 2 \
      -j ${logs}/fastp-${SAMPLE}.json \
      -h ${logs}/fastp-${SAMPLE}.html \
      2> ${logs}/fastp-${SAMPLE}.log | \
bwa mem -M -t 8 \
      -R "@RG\tID:$id\tPL:ILLUMINA\tLB:$lb\tSM:$sm" \
      $GENOME - 2> ${logs}/bwa-${SAMPLE}.log | \
samtools sort -T /lscratch/$SLURM_JOB_ID/ -m 2G -@ 4 -O BAM \
      -o $DIR/${SAMPLE}_sort.bam  2> ${logs}/samtools-${SAMPLE}.log

###/lscratch/$SLURM_JOBID
duration=$SECONDS
echo "Alignment completed. $(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."

### Duplicate marking in coordinate-sorted raw BAM files ###
java -Xmx2g -jar $PICARDJARPATH/picard.jar MarkDuplicates \
     -I $DIR/${SAMPLE}_sort.bam \
    -O /dev/stdout \
    -M marked_dup_metrics.txt 2> ${logs}/markdup-${SAMPLE}.log \
|java -Xmx2g -jar $PICARDJARPATH/picard.jar SortSam \
      -I /dev/stdin -O $DIR/${SAMPLE}_markdup_sorted.bam \
      -SORT_ORDER coordinate 2>> ${logs}/markdup-${SAMPLE}.log

duration=$SECONDS
echo "Duplicate marking completed. $(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."

DBSNP=/fdb/GATK_resource_bundle/hg38/dbsnp_138.hg38.vcf.gz
INDEL=/fdb/GATK_resource_bundle/hg38-v0/Homo_sapiens_assembly38.known_indels.vcf.gz
GOLD_INDEL=/fdb/GATK_resource_bundle/hg38-v0/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz

### Recaliberating base quality score #############################
# The first tool BaseRecalibrator builds the recalibration model.
# As we calculate the mismatched bases, we exclude the loci known to vary in the population,
# which requires the input of known variants resource. And this is specified by the option –known-sites.
# The second tool, ApplyBQSR ,adjusts the score based on the model.
####################################################################


gatk --java-options "-Djava.io.tmpdir=/lscratch/$SLURM_JOBID -Xms6G -Xmx6G -XX:ParallelGCThreads=2" BaseRecalibrator \
  -I $DIR/${SAMPLE}_markdup_sorted.bam \
  -R $GENOME \
  -O  $DIR/${SAMPLE}_markdup_bqsr.report \
  --known-sites $DBSNP \
  --known-sites $INDEL \
  --known-sites $GOLD_INDEL \
  > ${logs}/BQSR-${SAMPLE}.log 2>&1

gatk --java-options "-Djava.io.tmpdir=/lscratch/$SLURM_JOBID -Xms6G -Xmx6G -XX:ParallelGCThreads=2" ApplyBQSR \
  -I $DIR/${SAMPLE}_markdup_sorted.bam  \
  -R $GENOME \
  --bqsr-recal-file  $DIR/${SAMPLE}_markdup_bqsr.report \
  -O  $DIR/${SAMPLE}_markdup_bqsr.bam \
  >> ${logs}/BQSR-${SAMPLE}.log 2>&1

duration=$SECONDS
echo "Base recaliration completed. $(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."


```


2. Somatic short variant discovery using MuTect2

- Input: bam files processed using above code.

```
#!/bin/bash

#### Call somatic short variant discovery using MuTect2 and filtering ###

module load samtools
module load bwa
module load fastp
module load GATK/4.3.0.0
module load picard/2.27.3

GATK_Bundle=/fdb/GATK_resource_bundle/hg38-v0
GENOME=$GATK_Bundle/Homo_sapiens_assembly38.fasta
COMMONVAR=/data/classes/DCEG_Somatic_Workshop/Practical_session_4/Reference/small_exac_common_3.hg38.vcf.gz

NSAMPLE=$1
TSAMPLE=$2
PREFIX=$3
INDIR=$4
DIR=$5
logs=$DIR/logs

BAM_NORMAL=$INDIR/${NSAMPLE}_markdup_bqsr.bam
BAM_TUMOR=$INDIR/${TSAMPLE}_markdup_bqsr.bam
BASE_TUMOR=`samtools view -H $BAM_TUMOR |awk '$1~/^@RG/ {for (i=1;i<=NF;i++) {if ($i~/SM/) {split($i,aa,":"); print aa[2]}}}'|sort|uniq`
BASE_NORMAL=`samtools view -H $BAM_NORMAL | awk '$1~/^@RG/ {for (i=1;i<=NF;i++) {if ($i~/SM/) {split($i,aa,":"); print aa[2]}}}'|sort|uniq`

OUT_VCF=$DIR/${PREFIX}.vcf
OUT_FILTERED_VCF=$DIR/${PREFIX}_filtered.vcf
OUT_PASSED_VCF=$DIR/${PREFIX}_passed.vcf
OUT_STATS=$DIR/${PREFIX}.vcf.stats

SECONDS=0

if [ ! -d "$DIR" ]; then
        mkdir -p $DIR
fi
if [ ! -d "$logs" ]; then
        mkdir -p $logs
fi
### SNV and Indel calling  ###
gatk --java-options "-Djava.io.tmpdir=/lscratch/$SLURM_JOBID -Xms20G -Xmx20G -XX:ParallelGCThreads=1" Mutect2 \
  -R $GENOME \
  -I $BAM_NORMAL \
  -I $BAM_TUMOR \
  -normal $BASE_NORMAL \
  -tumor $BASE_TUMOR \
  -O $OUT_VCF \
  > ${logs}/Mutect2-${PREFIX}.log 2>&1

duration=$SECONDS
echo "MuTect2 completed. $(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."

### Filtering the MuTect2 variant calls ###
### Estimate cross-sample contamination  ###

gatk --java-options "-Xms10G -Xmx10G -XX:ParallelGCThreads=2" GetPileupSummaries \
   -I $BAM_TUMOR \
   -V $COMMONVAR \
   -L $COMMONVAR \
   -O $DIR/${TSAMPLE}_pileups.table \
   > ${logs}/VarFilter-${PREFIX}.log 2>&1

gatk --java-options "-Xms10G -Xmx10G -XX:ParallelGCThreads=2" GetPileupSummaries \
   -I $BAM_NORMAL \
   -V $COMMONVAR \
   -L $COMMONVAR \
   -O $DIR/${NSAMPLE}_pileups.table \
   >> ${logs}/VarFilter-${PREFIX}.log 2>&1

gatk --java-options "-Xms10G -Xmx10G -XX:ParallelGCThreads=2" CalculateContamination \
     -I $DIR/${TSAMPLE}_pileups.table \
     -matched $DIR/${NSAMPLE}_pileups.table \
     -tumor-segmentation $DIR/${TSAMPLE}_segments.table \
     -O $DIR/${TSAMPLE}_calculatecontamination.table \
     >> ${logs}/VarFilter-${PREFIX}.log 2>&1

### Filter variants  ###

gatk --java-options "-Djava.io.tmpdir=/lscratch/$SLURM_JOBID -Xms20G -Xmx20G -XX:ParallelGCThreads=2" FilterMutectCalls \
  -R $GENOME \
  --contamination-table $DIR/${TSAMPLE}_calculatecontamination.table \
  --stats $OUT_STATS \
  --tumor-segmentation $DIR/${TSAMPLE}_segments.table \
  -O $OUT_FILTERED_VCF \
  -V $OUT_VCF \
  >> ${logs}/VarFilter-${PREFIX}.log 2>&1
awk '($1 ~/^#/) || ($7 ~ /PASS/) {print}' $OUT_FILTERED_VCF >$OUT_PASSED_VCF

###/lscratch/$SLURM_JOBID
duration=$SECONDS
echo "Filtering completed. $(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."

```

3. Annotation of somatic short variants using Funcotator and ANNOVAR.


### Funcotator
  
```
#!/bin/bash

#### Annotate VCF file with Funcotator ###

module load samtools
module load GATK/4.3.0.0

GATK_Bundle=/fdb/GATK_resource_bundle/hg38-v0
GENOME=$GATK_Bundle/Homo_sapiens_assembly38.fasta
FUNCOTATORDB=/fdb/GATK_resource_bundle/funcotator/funcotator_dataSources.v1.7.20200521s

PREFIX=$1
INDIR=$2
DIR=$3
logs=$DIR/logs
IN_VCF=$INDIR/${PREFIX}_passed.vcf
OUT_ANNOT_MAF=$DIR/${PREFIX}_funcotator.maf

if [ ! -d "$DIR" ]; then
        mkdir -p $DIR
fi
if [ ! -d "$logs" ]; then
        mkdir -p $logs
fi

SECONDS=0

gatk --java-options "-Xms10G -Xmx10G -XX:ParallelGCThreads=2" Funcotator -R $GENOME \
     -V $IN_VCF \
     -O $OUT_ANNOT_MAF \
     --output-file-format MAF \
     --data-sources-path $FUNCOTATORDB \
     --ref-version hg38

duration=$SECONDS
echo "Annotation completed. $(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."

```

### Now use ANNOVAR

converinput script: 

https://github.com/ronammar/Awesomeomics/blob/master/data/annovar_annotations/annovar/convert2annovar.pl



```
#!/bin/bash

#### Annotate VCF file with ANNOVAR ###
module load annovar/2020-06-08

PREFIX=$1
INDIR=$2
DIR=$3
logs=$DIR/logs
IN_VCF=$INDIR/${PREFIX}_passed.vcf

if [ ! -d "$DIR" ]; then
        mkdir -p $DIR
fi
if [ ! -d "$logs" ]; then
        mkdir -p $logs
fi

echo $IN_VCF
echo $INDIR
echo $DIR
SECONDS=0

cd $DIR
convert2annovar.pl -format vcf4 $IN_VCF -includeinfo >${PREFIX}.avinput
table_annovar.pl  ${PREFIX}.avinput $ANNOVAR_DATA/hg38 \
	-buildver hg38 -out ${PREFIX} -remove \
	-protocol refGene,cytoBand,exac03,avsnp147,dbnsfp30a -operation g,r,f,f,f \
	-nastring . -csvout -polish

duration=$SECONDS
echo "Annotation completed. $(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."

```

The output: 

xxx_funcotator.maf
xxx_multianno.csv


#### The dwonstreaming analysis 

##### Maftools in R 

```R

# install BiocManager if not already installed
if (!require("BiocManager"))
  install.packages("BiocManager")
# install maftools if not already installed
BiocManager::install("maftools")

library(maftools)

# All kinds of plots 
tcga_luad_maf <- read.maf(maf='tcga_luad_maf_final.gz')

plotmafSummary(maf = tcga_luad_maf, rmOutlier = TRUE, addStat = 'median', dashboard = TRUE, titvRaw = FALSE)

oncoplot(maf = tcga_luad_maf, top = 10)

lollipopPlot(maf=tcga_luad_maf, gene= 'TP53', AACol = 'HGVSp_Short', showMutationRate = TRUE, labelPos=c(175,245,273))

rainfallPlot(maf=brca, pointSize = 0.4, detectChangePoints = TRUE)

tcga_luad_mutload <- tcgaCompare(maf = tcga_luad_maf, cohortName = 'Example Data', logscale = TRUE, capture_size = 35.8)

somaticInteractions(maf = tcga_luad_maf, top = 10, pvalue = c(0.05,0.1),nShiftSymbols = 2)

somaticInteractions(maf = tcga_luad_maf, genes = c('KRAS','EGFR','ERBB4','NTRK3','NF1','PDGFRA','BRAF','ALK','ROS1','NRTK2'), pvalue = c(0.05,0.1), nShiftSymbols = 2)

OncogenicPathways(maf = tcga_luad_maf)

PlotOncogenicPathways(maf = tcga_luad_maf, pathways = "RTK-RAS")

PlotOncogenicPathways(maf = tcga_luad_maf, pathways = "TP53")




```

