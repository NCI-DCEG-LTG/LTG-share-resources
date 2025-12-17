### How to use API to slice BAM files in TCGA 


- First setup the token

- use code below, the API can alos slice **multiple** region at once.
- the BAMs can use other stuff for downstrem analyisis

```

token=$(<gdc-token-text-file.txt)

# use "&" to get multiple regions
curl --header "X-Auth-Token: $token"\
 'https://api.gdc.cancer.gov/slicing/view/2912e314-f6a7-4f4a-94ac-20db2c8f793b?region=chr1&region=chr2:10000&region=chr3:10000-20000'\
  --output get_regions_slice.bam

```

