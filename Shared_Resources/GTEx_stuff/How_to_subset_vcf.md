## The goal: Dealing with subseting genotye vcf files

#### Tool used: bcftools, and the known chromosome region, need to know the vcf file is in hg19 or hg38

```
# extract region
# bcftools v1.2

ml bcftools/

bcftools view -r chr4:xxxx-xxxx GTEx.WGS.vcf.gz -Oz -o Subset.vcf.gz

```

- Once the subset vcf files is generated, it can be readed using `vcfR` in R package or other tools that deal with vcf file.
