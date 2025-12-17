library(rtracklayer)
library(dplyr)

setwd('/Volumes/ifs/DCEG/Branches/LTG/Prokunina/CCLE and other RNA-seq Bam files/SH-SY5Y_short_read_RNA_seq_bams_hg38/REFERENC/')


gtf <- import('gencode.v39.annotation.gtf')      # Use your downloaded GTF file

genes_of_interest <- c("ABCA13", "ANKRD1", "EIF1B","ENTPD3","ZNF619","ZNF620","CAV1","CAV2")    # Replace with your gene list

# Subset exons for your genes
exons <- subset(gtf, type == "exon" & gene_name %in% genes_of_interest)

#exon_df <- as.data.frame(exons)[, c("seqnames", "start", "end", "gene_name", "exon_id", "exon_number")]
exon_df <- as.data.frame(exons)
# just get protein coding exon only
exon_df <- exon_df[!is.na(exon_df$ccdsid),]
exon_df <- exon_df[, c("seqnames", "start", "end", "gene_name","transcript_name", "exon_id", "exon_number")]
