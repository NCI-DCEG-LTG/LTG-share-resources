
# Date:08122025
# Transfer raw count to TPM
# This script needs revise 

# read raw count
dff <- read.delim('~/Desktop/chr15_CHRNA5_bladder_project/Max_and_Auth_C5_smoking_paper/raw_count_A549_UMUC3/Partek_Smoking_UMUC3_Filter_features_Filtered_counts.txt')

# 1. Extract counts matrix
counts <- as.matrix(dff[, 12:20])   # columns with counts
rownames(counts) <- dff$gene_name # or gene_id if you prefer unique IDs

# 2. Extract gene lengths in base pairs
gene_lengths <- dff$Length  # bp

# 3. Convert counts → RPK
rpk <- counts / (gene_lengths / 1000)   # kb

# 4. Calculate scale factors per sample
scale_factors <- colSums(rpk)

# 5. Convert RPK → TPM
tpm <- t( t(rpk) / scale_factors ) * 1e6

# 6. (Optional) Put back into a data frame
tpm_df <- as.data.frame(tpm)
tpm_df <- cbind(dff[, 1:11], tpm_df) # keep annotation columns
