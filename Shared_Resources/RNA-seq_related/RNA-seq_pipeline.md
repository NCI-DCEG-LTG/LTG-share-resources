# RNA-seq Pipeline

## Goal

Generate:

- aligned **BAM** files from FASTQ files
- **gene-level** and **isoform-level TPM** values

**Last updated:** 2026-04-28

---

## Reference Files

### Annotation

The annotation GTF file was downloaded from [GENCODE v39](https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_39/gencode.v39.annotation.gtf.gz).

From the GENCODE website:

> It contains the comprehensive gene annotation on the reference chromosomes only.  
> This is the main annotation file for most users.

**Note:** This pipeline uses **GENCODE v39** for consistency with the current reference setup.

### Reference Genome

The reference genome was downloaded from the [GATK reference bundle](https://console.cloud.google.com/storage/browser/gcp-public-data--broad-references/Homo_sapiens_assembly38_noALT_noHLA_noDecoy/v0?pageState=(%22StorageObjectListTable%22:(%22f%22:%22%255B%255D%22))).

File used:

`gcp-public-data--broad-references/Homo_sapiens_assembly38_noALT_noHLA_noDecoy/v0/Homo_sapiens_assembly38_noALT_noHLA_noDecoy.fasta`

A UCSC reference can also be used if needed.

---

# Workflow A: STAR + RSEM for BAM + TPM

Use this workflow when you need both:

- a retained **genome-coordinate BAM** file
- **gene-level** and **isoform-level TPM**

This is the recommended workflow when aligned BAM files are a required deliverable.

## Inputs and Requirements

- paired-end FASTQ files
- STAR genome index
- RSEM reference

## Environment

- CCAD
- Biowulf

---

## Step 1. Build the STAR Genome Index

Set `--sjdbOverhang` to **read length - 1** during genome generation.

Examples:

- 2 x 101 bp reads -> `--sjdbOverhang 100`
- 2 x 150 bp reads -> `--sjdbOverhang 149`

```bash
#!/bin/bash

ml star/2.7.10b

STAR --runMode genomeGenerate \
  --genomeDir STAR_genome_GRCh38_noALT_noHLA_noDecoy_ref \
  --genomeFastaFiles Homo_sapiens_assembly38_noALT_noHLA_noDecoy.fasta \
  --sjdbGTFfile gencode.v39.annotation.gtf \
  --sjdbOverhang 100 \
  --runThreadN 10
```

---

## Step 2. Align Reads with STAR

This example assumes:

- FASTQ files are named `sample1_R1.fastq.gz` and `sample1_R2.fastq.gz`
- the STAR index directory is `STAR_genome_GRCh38_noALT_noHLA_noDecoy_ref`

```bash
#!/bin/bash

ml star/2.7.10b

ANNO=gencode.v39.annotation.gtf

fastqR1=sample1_R1.fastq.gz
fastqR2=sample1_R2.fastq.gz

STAR \
  --runThreadN 24 \
  --genomeDir STAR_genome_GRCh38_noALT_noHLA_noDecoy_ref \
  --readFilesIn ${fastqR1} ${fastqR2} \
  --outFileNamePrefix Align_results_hg38/sample1. \
  --readFilesCommand zcat \
  --sjdbGTFfile ${ANNO} \
  --quantMode TranscriptomeSAM GeneCounts \
  --outSAMtype BAM SortedByCoordinate \
  --twopassMode Basic
```

## Output from STAR

This STAR command produces:

- `Aligned.sortedByCoord.out.bam`  
  A coordinate-sorted genomic BAM file

- `Aligned.toTranscriptome.out.bam`  
  A transcriptome BAM file that can be used as input for RSEM

- `ReadsPerGene.out.tab`  
  Gene count output from STAR

## Notes

- `--twopassMode Basic` improves splice junction detection.
- `--quantMode TranscriptomeSAM GeneCounts` is needed if you want to pass the transcriptome BAM to RSEM.
- The genomic BAM from STAR is the main alignment BAM for downstream visualization and genome-based QC.

---

## Step 3. Build the RSEM Reference

Use the same genome FASTA and annotation GTF that were used to build the STAR reference whenever possible.

```bash
rsem-prepare-reference \
  --gtf gencode.v39.annotation.gtf \
  --star \
  --num-threads 8 \
  Homo_sapiens_assembly38_noALT_noHLA_noDecoy.fasta \
  RSEM_REF/hg38_gencode39
```

## Notes

- `--star` builds STAR-compatible reference files for RSEM.
- The final argument is the **reference prefix**. Use the same prefix later in `rsem-calculate-expression`.

---

## Step 4. Run RSEM Using the STAR Transcriptome BAM

```bash
rsem-calculate-expression \
  --num-threads 8 \
  --paired-end \
  --estimate-rspd \
  --fragment-length-max 1000 \
  --no-bam-output \
  --bam Align_results_hg38/sample1.Aligned.toTranscriptome.out.bam \
  RSEM_REF/hg38_gencode39 \
  RSEM_results/sample1
```

## Output from RSEM

Typical output files include:

- `sample1.genes.results`
- `sample1.isoforms.results`

These contain expected counts, TPM, FPKM, and other expression estimates.

## Why this workflow is recommended for BAM + TPM

This workflow keeps the analysis goals separated clearly:

- **STAR** generates the retained genome BAM
- **RSEM** calculates gene and isoform expression from the transcriptome BAM

This is usually easier to explain, maintain, and troubleshoot than trying to do everything in one step.

---

## Optional Note on Duplicate Marking

Duplicate marking is **not always recommended as a default step for RNA-seq quantification**.

Highly expressed transcripts can produce many identical fragments naturally, so duplicate marking may remove or flag biologically valid reads. Only add duplicate marking if you have a clear project-specific reason, such as:

- a required QC metric
- a protocol-specific analysis need
- a downstream tool that explicitly expects it

If duplicate marking is required, document clearly why it is being done.

Example:

```bash
picard MarkDuplicates \
  -I Align_results_hg38/sample1.Aligned.sortedByCoord.out.bam \
  -O Align_results_hg38/sample1.Aligned.sortedByCoord.markdup.bam \
  -PROGRAM_RECORD_ID null \
  -MAX_RECORDS_IN_RAM 500000 \
  -SORTING_COLLECTION_SIZE_RATIO 0.25 \
  -M Align_results_hg38/sample1.markdup_metrics.txt \
  -ASSUME_SORT_ORDER coordinate \
  -TAGGING_POLICY DontTag \
  -OPTICAL_DUPLICATE_PIXEL_DISTANCE 100
```

---

# Workflow B: RSEM Directly from FASTQ for TPM

Use this workflow when the main goal is **expression quantification** and you do **not** need a retained genomic BAM as a primary deliverable.

This is the simpler workflow for generating TPM directly from FASTQ files.

## Important Notes

- RSEM can run directly from FASTQ files using STAR internally.
- This is a straightforward workflow for **gene-level** and **isoform-level TPM**.
- If you use `--no-bam-output`, RSEM will **not retain BAM files**.
- If a genome-coordinate BAM is required, Workflow A is usually the better choice.

---

## Step 1. Build the RSEM Reference

```bash
rsem-prepare-reference \
  --gtf gencode.v39.annotation.gtf \
  --star \
  --num-threads 8 \
  Homo_sapiens_assembly38_noALT_noHLA_noDecoy.fasta \
  RSEM_REF/hg38_gencode39
```

---

## Step 2. Run RSEM Directly from FASTQ Files

```bash
rsem-calculate-expression \
  --star \
  --paired-end \
  --strandedness reverse \
  --no-bam-output \
  -p 6 \
  --star-gzipped-read-file \
  fastqs/SHSY5Y_S01_U1_R1.fastq.gz fastqs/SHSY5Y_S01_U1_R2.fastq.gz \
  RSEM_REF/hg38_gencode39 \
  SY5Y_rsem/test
```

## Why this workflow is simpler

This approach starts directly from FASTQ files and performs alignment plus expression estimation inside RSEM, so there are fewer moving parts than the STAR + RSEM workflow.

It is a good choice when the main deliverables are:

- `*.genes.results`
- `*.isoforms.results`
- TPM and expected count tables

---

## Important Warning About BAM Output

The example above includes:

```bash
--no-bam-output
```

That means this workflow **does not save BAM files**.

So this is a good workflow for:

- quantification only
- gene TPM
- isoform TPM

It is **not** the best workflow if your project requires a retained genomic BAM for IGV, splice inspection, or other genome-based downstream analysis.

---

## If You Want RSEM to Retain BAM Output

Remove `--no-bam-output`.

Example:

```bash
rsem-calculate-expression \
  --star \
  --paired-end \
  --strandedness reverse \
  -p 6 \
  --star-gzipped-read-file \
  fastqs/sample_R1.fastq.gz fastqs/sample_R2.fastq.gz \
  RSEM_REF/hg38_gencode39 \
  sample_rsem
```

If you also want genome BAM output from RSEM, use options such as `--output-genome-bam` and coordinate sorting as needed.

Example:

```bash
rsem-calculate-expression \
  --star \
  --paired-end \
  --strandedness reverse \
  --output-genome-bam \
  --sort-bam-by-coordinate \
  -p 6 \
  --star-gzipped-read-file \
  fastqs/sample_R1.fastq.gz fastqs/sample_R2.fastq.gz \
  RSEM_REF/hg38_gencode39 \
  sample_rsem
```

Even so, if the genomic BAM is an important final deliverable, Workflow A is usually clearer and easier to maintain.

---

## Strandedness Note

Set `--strandedness` according to the library preparation protocol:

- `none` for unstranded libraries
- `forward` for forward-stranded libraries
- `reverse` for reverse-stranded libraries

Do not hard-code `reverse` unless it matches the actual library design.

---

# Gene- and Isoform-Level TPM Merging with tximport

Below are example R scripts for summarizing and merging TPM matrices.

## For RSEM Output

```r
library(dplyr)
library(tximport)
library(BSgenome.Hsapiens.UCSC.hg38)
library(EnsDb.Hsapiens.v86)
library(xlsx)

setwd('/Volumes/ifs/DCEG/Branches/LTG/Prokunina/RNA-seq/RNAseq_Normal_Urothelial_05152025/Noraml_rsem/')

edb <- EnsDb.Hsapiens.v86

tx2gene <- AnnotationDbi::select(
  edb,
  keys(edb, keytype = "TXNAME"),
  columns = c("TXNAME", "GENEID"),
  keytype = "TXNAME"
)

names(tx2gene) <- c('transcript_id', 'gene_id', 'TXID')

lff <- list.files('.', pattern = ".genes.results")

# Set sample names
names(lff) <- gsub(".genes.results", "", basename(lff))

# Import gene-level TPM
txi <- tximport(
  lff,
  type = "rsem",
  txIn = FALSE,
  txOut = FALSE
)

gene_tpm <- txi$abundance

# Extract Ensembl gene IDs
gene_ids <- rownames(gene_tpm)
gene_ids <- gsub('\\.[0-9]+', '', gene_ids)

gene_map <- ensembldb::select(
  edb,
  keys = gene_ids,
  keytype = "GENEID",
  columns = c("GENEID", "GENENAME")
)

# Create gene symbol lookup
symb <- setNames(gene_map$GENENAME, gene_map$GENEID)

gene_tpm <- as.data.frame(gene_tpm)
rownames(gene_tpm) <- gene_ids

gene_tpm <- gene_tpm %>%
  mutate(GENEID = rownames(gene_tpm), .before = names(gene_tpm)[1])

# Add gene symbols as a separate column
gene_tpm <- gene_tpm %>%
  mutate(
    GENESYMBOL = ifelse(is.na(symb[gene_ids]), gene_ids, symb[gene_ids]),
    .before = names(gene_tpm)[1]
  )

# Match names with sample IDs
id <- readxl::read_xls('/Volumes/ifs/DCEG/Projects/DataDelivery/Prokunina/TP0325-RS7-Urothelial-Samples-RNA-seq/TP0325-RS7_QC-SUMMARY.xls')
id <- data.frame(id)

id$Vial.Label <- gsub(' ', '_', id$Vial.Label)
id$Vial.Label <- gsub("_RNA$", "", id$Vial.Label)

# Clean column names
names(gene_tpm) <- gsub('Sample_', '', names(gene_tpm))

# Create mapping from CGR sample ID to vial label
id_map <- setNames(id$Vial.Label, id$CGR.Sample.ID)

# Replace column names using the mapping
colnames(gene_tpm) <- ifelse(
  colnames(gene_tpm) %in% names(id_map),
  id_map[colnames(gene_tpm)],
  colnames(gene_tpm)
)

# Save output
write.csv(gene_tpm, '../Sample_rsem_TPM.csv', row.names = FALSE, quote = FALSE)
```

---

## Example for Isoform-Level TPM from RSEM

```r
library(tximport)

setwd('/path/to/rsem_results/')

lff <- list.files('.', pattern = ".isoforms.results")
names(lff) <- gsub(".isoforms.results", "", basename(lff))

txi_iso <- tximport(
  lff,
  type = "rsem",
  txIn = TRUE,
  txOut = TRUE
)

isoform_tpm <- txi_iso$abundance
isoform_tpm <- as.data.frame(isoform_tpm)

write.csv(isoform_tpm, 'Sample_rsem_isoform_TPM.csv', row.names = TRUE, quote = FALSE)
```

---

# Summary

## Recommended workflow choices

### Workflow A: STAR + RSEM for BAM + TPM

Use this workflow when you need:

- retained genomic BAM files
- transcriptome BAM for RSEM
- gene-level TPM
- isoform-level TPM

### Workflow B: RSEM Directly from FASTQ for TPM

Use this workflow when you need:

- a simpler pipeline
- gene-level TPM
- isoform-level TPM
- fewer processing steps

but do **not** require a retained genomic BAM as a primary deliverable.

