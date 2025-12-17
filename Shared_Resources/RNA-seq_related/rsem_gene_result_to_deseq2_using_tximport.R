# From RSEM to Deseq2 using tximport 
# Date 08052025
# CHL
# From DeSeq2 tut: 
# https://bioconductor.org/packages/devel/bioc/vignettes/DESeq2/inst/doc/DESeq2.html#transcript-abundance-files-and-tximport-tximeta
#If you have performed transcript quantification (with Salmon, kallisto, RSEM, etc.)
#you could import the data with tximport, which produces a list, and then you can use DESeqDataSetFromTximport().


library(DESeq2)
library(dplyr)
library(tximport)
library(BSgenome.Hsapiens.UCSC.hg38)
library(EnsDb.Hsapiens.v86)

setwd('/Volumes/ifs/DCEG/Branches/LTG/Prokunina/CCLE and other RNA-seq Bam files/SH-SY5Y_short_read_RNA_seq_bams_hg38/SY5Y_rsem/')

edb <- EnsDb.Hsapiens.v86

tx2gene <- AnnotationDbi::select(
  edb,
  keys(edb, keytype="TXNAME"),
  columns = c("TXNAME", "GENEID"),
  keytype = "TXNAME"
)  

names(tx2gene) <- c('transcript_id','gene_id','TXID')

lff <- list.files('.',pattern = "genes")
# like SetName()
names(lff) <- gsub(".genes.results$", "", basename(lff))
# check lff to see name match with quant.sf or not

# tximport 

txi <- tximport(
  lff,
  type    = "rsem",
  txIn = F,
  txOut = F)


# from Deseq2 authour 9 years ago... change 0 to 1 
txi$length[txi$length == 0] <- 1

# bad_anyzero <- apply(txi$length, 1, function(x) any(x == 0))
# # 2. subset IN-PLACE so countsFromAbundance, abundance, etc. stay intact
# txi$counts    <- txi$counts   [!bad_anyzero, , drop=FALSE]
# txi$abundance <- txi$abundance[!bad_anyzero, , drop=FALSE]
# txi$length    <- txi$length   [!bad_anyzero, , drop=FALSE]

# 3. rebuild your colData (ensure rownames match colnames of txi$counts)
coldata <- data.frame(
  treatment = factor(rep(c("RA","DMSO"), each=3)),
  row.names  = colnames(txi$counts)
)

# 4. now this will pass without error
dds <- DESeqDataSetFromTximport(txi, colData=coldata, design=~treatment)


# check to see if it match
colData(dds)

smallestGroupSize <- 3
keep <- rowSums(counts(dds) >= 10) >= smallestGroupSize
dds <- dds[keep,]

# Now can do dds stuff...
dds <- DESeq(dds)
res <- results(dds)
res
# check names
resultsNames(dds)
# check and order res
resOrdered <- res[order(res$pvalue),]
# summ
summary(res)
# subset sig
resSig <- subset(resOrdered, padj < 0.05) %>% data.frame()

# plot PCA to check 
vsd <- vst(dds, blind=FALSE)
plotPCA(vsd,intgroup=c("treatment"))


# The way to get normalized count 
norm_counts <- counts(dds, normalized = TRUE)



# 1. Extract the unique Ensembl gene IDs you have
gene_ids <- rownames(resSig)
gene_ids <- gsub('\\.[0-9]+','',gene_ids)

gene_map <- ensembldb::select(
  edb,
  keys    = gene_ids,
  keytype = "GENEID",
  columns = c("GENEID","GENENAME")
)
# 3. Turn that into a named vector for lookup
symb <- setNames(gene_map$GENENAME, gene_map$GENEID)
# set name 
rownames(resSig) <- gsub('\\.[0-9]+','',rownames(resSig))

# assign new column
resSig$ID <- rownames(resSig)

# note: this is is not best approach as in will duplicaiton in some gene symbol.
# need to think about other approach
resSig$gene_symbol  <- ifelse(is.na(symb[gene_ids]),
                             gene_ids,symb[gene_ids])



