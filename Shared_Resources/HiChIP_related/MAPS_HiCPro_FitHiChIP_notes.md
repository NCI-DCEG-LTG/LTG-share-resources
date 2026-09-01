# HiChIP Data Analysis Pipelines (Arima)

This guide covers two pipelines for analyzing Arima HiChIP / PLAC-seq data, from FASTQs to called chromatin loops:

- **Pipeline 1 — Arima-MAPS v2.0**: best for **calling loops in a single condition**. Arima-tuned parameters, built-in QC tables and arc plots, and integrated MACS2 peak calling. It does **not** do differential analysis.
- **Pipeline 2 — HiC-Pro → FitHiChIP**: best for **comparing loops between two conditions** (the only branch with native differential loop calling), or when you already have HiC-Pro valid pairs.

> **Critical Arima note:** Arima-HiC+ uses a **dual restriction-enzyme** digest (`^GATC` + `G^ANTC`). A config that only uses single-enzyme DpnII settings (`GATCGATC` alone) is **wrong** for Arima and will under-count valid pairs. Both pipelines below handle this correctly.

---

## Pipeline 1: Arima-MAPS v2.0 (single condition)

### 1.1 Installation (Biowulf conda environment)

> The maintained MAPS fork is at <https://github.com/HuMingLab/MAPS> (since March 2023). Do **not** use the archived `ijuric/MAPS` repo.

Log in to Biowulf, set up and activate conda, then:

```bash
# Clone the maintained MAPS fork
git clone https://github.com/HuMingLab/MAPS.git

# Create and activate the conda environment
conda create -n MAPS_env python=3.10 -y
conda activate MAPS_env

# Install tools
mamba install -c bioconda deeptools -y
mamba install pandas pysam -y
mamba install -c conda-forge -c bioconda pybedtools -y
mamba install -c bioconda macs2 -y
mamba install R=4.2 -y
```

Then install the R packages:

```r
# in R
install.packages("argparse")
install.packages("data.table")
```

Pin **VGAM to 1.1-3** (required to avoid a crash on large/merged datasets — see [1.5 Troubleshooting](#15-troubleshooting-vgam-error-on-large-datasets)):

```r
# in R
packageurl <- "https://cran.r-project.org/src/contrib/Archive/VGAM/VGAM_1.1-3.tar.gz"
install.packages(packageurl, repos = NULL, type = "source")
```

The other required tools are already available on Biowulf as modules:

```bash
ml samtools bedtools bwa
```

Finally, move the Arima script into the MAPS `bin/` directory:

```bash
cp MAPS/Arima_Genomics/Arima-MAPS_v2.0.sh MAPS/bin/
```

### 1.2 Running Arima-MAPS — two input rules

- The output directory (`-O`) **must be an absolute path** — a relative path will error out.
- For a file named `abcd_R1.fastq.gz`, the `-I` input is the **prefix up to `_R1`**, i.e. `abcd` (full path + prefix, no `_R1`).

### 1.3 Key flags

| Flag | Meaning |
|------|---------|
| `-C` | `0` = use a provided ChIP peak file (then `-m <peak.bed>` is required); `1` = call peaks with MACS2 (then `-p broad\|narrow` is required) |
| `-p` | Peak type for MACS2: `broad` for H3K4me3/H3K27ac, `narrow` for CTCF |
| `-I` | Absolute path + file prefix up to `_R1` |
| `-O` | Output directory (**!!!!!absolute path!!!!!!**) |
| `-o` | Organism: `hg19`, `hg38`, `mm9`, or `mm10` |
| `-b` | Absolute path to the reference `.fa` (the BWA index is derived from it) |
| `-t` | Threads: 4–8 for shallow, 12–20 for deep sequencing |
| `-f` | **Patterned-flowcell flag**: `1` = deep/patterned flowcell (e.g. NovaSeq), `0` = shallow/non-patterned. It is used for optical/PCR duplicate rates — it is *not* literally "shallow vs. deep". |

### 1.4 Example run

```bash
# Example: deep sequencing, MACS2 broad peaks, hg38.
# Paths are Biowulf examples — edit them for your setup.
sh /data/leec20/HiChIP_Miseq_0320/MAPS/bin/Arima-MAPS_v2.0.sh \
  -C 1 -p broad \
  -I /data/leec20/HiChIP_Miseq_0320/test_file/Arima-MAPS-test \
  -O /data/leec20/HiChIP_Miseq_0320/test_file/output \
  -o hg38 \
  -b /fdb/igenomes/Homo_sapiens/UCSC/hg38/Sequence/BWAIndex/genome.fa \
  -t 6 -f 1
```

Example batch script:

```bash
#!/bin/bash
source myconda
conda activate MAPS_env
ml samtools bedtools bwa

sh /data/leec20/HiChIP_arima_miseq_novaseq_project_091223/MAPS/bin/Arima-MAPS_v2.0.sh \
  -C 1 -p broad \
  -I /data/leec20/HiChIP_arima_miseq_novaseq_project_091223/ELENTA_fastqs/Sample-2 \
  -O /data/leec20/HiChIP_arima_miseq_novaseq_project_091223/Elenta_Output \
  -o hg38 \
  -b /fdb/igenomes/Homo_sapiens/UCSC/hg38/Sequence/BWAIndex/genome.fa \
  -t 6 -f 0

echo "all done"
```

### 1.5 Troubleshooting: VGAM error on large datasets

On large/merged datasets, MAPS can crash with a `pospoisson_regression -> vglm` error ("missing value where TRUE/FALSE needed"). This is caused by **VGAM 1.1-4**; fix it by pinning **VGAM 1.1-3** (see <https://github.com/ijuric/MAPS/issues/29>):

```r
packageurl <- "https://cran.r-project.org/src/contrib/Archive/VGAM/VGAM_1.1-3.tar.gz"
install.packages(packageurl, repos = NULL, type = "source")
```

> **Note:** newer VGAM versions do **not** reliably fix this, so keep the 1.1-3 pin as the default. If it still fails on 1.1-3, the cause is that specific (very large/merged) dataset, not the VGAM version.

---

## Pipeline 2: HiC-Pro → FitHiChIP (two conditions / differential)

Use this branch when you want to **compare loops between two conditions**, or when you already have HiC-Pro valid pairs.

### 2.1 HiC-Pro setup

HiC-Pro (<https://github.com/nservant/HiC-Pro>) needs three things: a **config file**, a **chrom.sizes file**, and an **enzyme-digested BED file**.

- Biowulf has HiC-Pro installed (ver. 3.1.0_v2): <https://hpc.nih.gov/apps/hicpro.html>
- HiC-Pro utilities on Biowulf: `/usr/local/apps/hicpro/3.1.0_v2/HiC-Pro_3.1.0/bin/utils/`

#### Step 0: Arima 5′ read trimming (Arima-HiC+ only)

> **Skip this step if your library was not made with the Arima-HiC+ kit.** Trimming non-Arima reads would just discard 5 real bases.

The Arima library prep leaves a ~5 bp overhang at the 5′ end of each read, so Arima recommends trimming 5 bp from the 5′ end of **both** R1 and R2 before mapping (this improves alignment/mapping quality):

```bash
zcat PREFIX_R1.fastq.gz | awk '{ if(NR%2==0) {print substr($1,6)} else {print} }' | gzip > PREFIX_trimmed_R1.fastq.gz
zcat PREFIX_R2.fastq.gz | awk '{ if(NR%2==0) {print substr($1,6)} else {print} }' | gzip > PREFIX_trimmed_R2.fastq.gz
```

Then point HiC-Pro at the `*_trimmed_*.fastq.gz` files. (Arima-MAPS in Pipeline 1 handles this internally, so no trimming is needed there.)

#### Step 1: Config file

Copy the template `config-hicpro.txt` (<https://github.com/nservant/HiC-Pro/blob/master/config-hicpro.txt>) into your local folder and edit it. Below is a working Arima example.

> **Edit before running:** CPU/memory, the Bowtie2 index path (depends on hg19/hg38), the Arima digest BED path, and the chrom.sizes path. **Do not change `LIGATION_SITE`** — it is Arima-specific.

```
#########################################################################
## Paths and Settings - Do not edit !
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
BOWTIE2_LOCAL_OPTIONS = --very-sensitive -L 20 --score-min L,-0.6,-0.2 --end-to-end --reorder

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
## Digestion Hi-C — values per the Arima guide:
## https://discovery.arimagenomics.com/wp-content/files/Arima-HiC-Kit-User-Guide-A160509-v2.pdf
## Do NOT change LIGATION_SITE. GENOME_FRAGMENT must be produced by:
##   digest_genome.py -r ^GATC G^ANTC -o arima_<build>_digest.bed <genome>.fa
#######################################################################

GENOME_FRAGMENT = /data/leec20/hichip_CHiC_project/HiC_pro/arima_hg19_hicpro_digest.bed
LIGATION_SITE = GATCGATC,GANTGATC,GANTANTC,GATCANTC
MIN_FRAG_SIZE = 10
MAX_FRAG_SIZE = 100000
MIN_INSERT_SIZE = 100
MAX_INSERT_SIZE = 1000

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

#### Step 2: chrom.sizes file

Quote from the HiC-Pro GitHub:

> "A table file of chromosomes' sizes. This file can be easily found on the UCSC genome browser. Of note, pay attention to the contigs or scaffolds, and be aware that HiC-Pro will generate a map per chromosome pair. For model organisms such as human or mouse, which are well annotated, we usually recommend removing all scaffolds."

Download from UCSC and keep only the canonical chromosomes (chr1–22, X, Y for human):

- hg38: <https://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/hg38.chrom.sizes>
- hg19: <https://hgdownload.soe.ucsc.edu/goldenPath/hg19/bigZips/hg19.chrom.sizes>

#### Step 3: Arima digest BED

Because Arima uses a dual-enzyme digest, generate the restriction-fragment BED with **both** motifs (see <https://github.com/nservant/HiC-Pro/issues/202> and the HiC-Pro FAQ):

```bash
digest_genome.py -r ^GATC G^ANTC -o arima_hg19_digest.bed /fdb/igenomes/Homo_sapiens/UCSC/hg19/Sequence/Bowtie2Index/genome.fa
```

Then point `GENOME_FRAGMENT` in the config at the resulting BED.

### 2.2 HiC-Pro output

After the run finishes, the output folder structure is described at <https://github.com/nf-core/hic/blob/master/docs/output.md>.

The key output for downstream tools is the valid-pairs file:

```
<HICPRODIR>/hic_results/data/<sample>/<sample>.allValidPairs
```

### 2.3 FitHiChIP loop calling

FitHiChIP (<https://ay-lab.github.io/FitHiChIP/html/index.html>) calls significant chromatin loops from HiC-Pro output and is the tool that enables **differential loop analysis**.

#### Installation

You can install FitHiChIP with conda, but because the Biowulf module is not always up to date, the alternative is to clone it directly from GitHub.

First set up conda on Biowulf (<https://hpc.nih.gov/docs/diy_installation/conda.html>), then:

```bash
# 1. One-time: interactive node + miniforge
sinteractive --mem=20g --gres=lscratch:20
module load mamba_install
mamba_install        # installs to /data/$USER/conda, makes ~/bin/myconda
source myconda

# 2. One-time: create a minimal env (macs/hicpro/R/ucsc are Biowulf modules)
mamba create -n fithichip -y python=3.10

# 3. One-time: clone FitHiChIP
cd /data/$USER
git clone https://github.com/ay-lab/FitHiChIP.git
```

Biowulf also has FitHiChIP installed as a module: <https://hpc.nih.gov/apps/FitHiChIP.html>

#### Inputs

FitHiChIP requires:

- HiC-Pro valid pairs (`.allValidPairs`)
- A ChIP-seq peak file
- A chromosome-sizes file
- A config file

#### Step 1: Start from the HiC-Pro output

Provide the valid pairs via the `ValidPairs=` option. The file can be plain text or gzipped. It is usually:

```
${HICPRODIR}/hic_results/data/rawdata/rawdata.allValidPairs
```

where `${HICPRODIR}` is the HiC-Pro output directory.

#### Step 2: Config file and ChIP-seq track

There are four config templates (in the folder you git-cloned), corresponding to (Loose | Stringent) × (coverage | ICE) bias:

| Config file | Model |
|-------------|-------|
| `configfile_BiasCorrection_CoverageBias` | FitHiChIP(L) + coverage bias |
| `configfile_BiasCorrection_ICEBias` | FitHiChIP(L) + ICE bias |
| `configfile_P2P_BiasCorrection_CoverageBias` | FitHiChIP(S) + coverage bias |
| `configfile_P2P_BiasCorrection_ICEBias` | FitHiChIP(S) + ICE bias |

- **FitHiChIP(L)** (loose, peak-to-all) for low/moderate depth; **FitHiChIP(S)** (stringent, peak-to-peak) for very high depth. This is a depth-dependent choice, not a quality ranking.
- **Coverage bias** (`BiasType=1`) is the default used in the paper; **ICE bias** (`BiasType=2`) is the alternative.

For a quick overview of these settings, see the Dovetail guide: <https://dovetail-analysis.readthedocs.io/en/latest/hichip/loop_calling.html#resolution>

#### How to get the ChIP-seq peaks

**Option A — download public ChIP-seq peaks from ENCODE.**
For example, search ENCODE for cell line GM12878, H3K27ac ChIP-seq, hg38, `bed narrowPeak` format (see <https://github.com/ay-lab/FitHiChIP/issues/67>).

> :bell: **Double-check that the genome build (hg19/hg38) of the peak file matches your HiC-Pro alignment.**

**Option B — infer peaks from the HiChIP data itself.**
The script `PeakInferHiChIP.sh` (in the `Imp_Scripts` folder) uses MACS2 to infer peaks from the HiC-Pro output. It requires `ml macs`. Parameters:

```
-H  HiCProDir      Directory containing the HiC-Pro reads (.ValidPairs, .DEPairs, .REPairs, .SCPairs)
-D  OutDir         Output directory for the peaks (default: current directory)
-R  refGenomeStr   'hs' for human (default), 'mm' for mouse
-M  MACS2ParamStr  MACS2 parameters (default: "--nomodel --extsize 147 -q 0.01")
-L  ReadLength     Read length of the HiC-Pro reads (default 75)
```

Example:

```bash
# Set -L to your read length
sh $FITHICHIP_SRC/Imp_Scripts/PeakInferHiChIP.sh -H $i/ -D ./output_peaks/sample1_output -R hs -L $readlength
```

The script uses all DE, SC, RE, and validpairs reads from HiC-Pro to infer peaks. The `MACS2_ExtSize` folder in the output directory contains the MACS2 peaks. Use the resulting `xxx.narrowPeak` file as the ChIP-seq input for FitHiChIP.

> Loading `ml hicpro` is required when using ICE bias normalization on Biowulf.
> A good explanation of loop calling: <https://hichip.readthedocs.io/en/latest/loops.html>

#### Step 3: Run FitHiChIP

On Biowulf, once the modules are loaded:

```bash
ml fithichip
ml macs
ml hicpro

cp -r $FITHICHIP_SRC/* .
./FitHiChIP_HiCPro.sh -C configfile_test
```

Example batch script (using the git-cloned copy):

```bash
#!/bin/bash
source myconda
conda activate fithichip   # the env created above

ml macs/2.2.7.1
ml hicpro/3.1.0_v2
ml R/4.5.2
ml ucsc

/data/$USER/FitHiChIP/FitHiChIP_HiCPro.sh -C configfile_P2P_BiasCorrection_CoverageBias_PDC_1 && echo "done"
```

#### Output

The main result is `xxx.interactions_FitHiC_Q0.01_MergeNearContacts_IGV.bedpe`. The **score column is `-log10(FDR)`**.

### 2.4 Differential loop analysis (two conditions)

To compare loops between two conditions, run FitHiChIP **per sample/replicate first**, then feed the **all-interactions** file (`PREFIX.interactions_FitHiC.bed` — every contact plus its significance, *not* only the significant loops) into a differential framework.

- **Recommended: DiffHiChIP** (Bhattacharyya et al., *Cell Reports Methods* 2025, <https://doi.org/10.1016/j.crmeth.2025.101214>) — the most comprehensive option (edgeR GLM with IHW correction and distance-stratified decay modeling, which improves power for long-range loops). It takes the FitHiChIP `*.interactions_FitHiC.bed` files as input.
- **Legacy option:** the built-in FitHiChIP differential module (`Differential_Analysis_Script.sh`).
- **Alternative:** HiC-DC+ (Bioconductor) does significant-loop calling *and* differential analysis in one package.

### 2.5 Troubleshooting

- **Replicates:** put all replicate FASTQs in the same folder and run HiC-Pro once — this is the preferred way to handle replicates.
- **samtools "too many open files" error** during the HiC-Pro sort: raise the open-file limit (`ulimit -n`). See <https://github.com/nservant/HiC-Pro/issues/392>.
