#!/bin/bash
set -eo pipefail
#Script for generating statistics from the VCF output of 
prefix=$1

#Set an ID for each SNP so they can be filtered by name
bcftools annotate --set-id +"%CHROM:%POS" "$prefix".snp.filtered.nocall.vcf > "$prefix".snp.filtered.nodot.vcf
# Filter out SNPs that didn't pass the filter
#plink --vcf-filter --vcf "$prefix".snp.filtered.nodot.vcf --allow-extra-chr --recode  --make-bed --geno --const-fid --out "$prefix"
#Alternate for deleting all SNPs with missing data: 
/mnt/c/Users/Lagevol/Desktop/programas/plink_linux_x86_64_20231211/plink --vcf-filter --vcf "$prefix".snp.filtered.nodot.vcf --allow-extra-chr --recode  --make-bed --geno 0 --const-fid --out "$prefix"
/mnt/c/Users/Lagevol/Desktop/programas/plink_linux_x86_64_20231211/plink --indep 50 5 2 --file "$prefix" --allow-extra-chr --out "$prefix"
/mnt/c/Users/Lagevol/Desktop/programas/plink_linux_x86_64_20231211/plink --extract "$prefix".prune.in --out "$prefix"_pruned --file "$prefix" --make-bed --allow-extra-chr --recode
# Generate eigenvalues and loadings for 20 PCA axes
/mnt/c/Users/Lagevol/Desktop/programas/plink_linux_x86_64_20231211/plink --pca 20 --file "$prefix"_pruned --allow-extra-chr --out "$prefix"
# Generate basic stats (heterozygosity, inbreeding coefficient, allele frequencies)
/mnt/c/Users/Lagevol/Desktop/programas/plink_linux_x86_64_20231211/plink --freq --het 'small-sample' --ibc --file "$prefix"_pruned --allow-extra-chr -out "$prefix"_pruned
#Adicionei uma etapa extra para ter o output em VCF
/mnt/c/Users/Lagevol/Desktop/programas/plink_linux_x86_64_20231211/plink --bfile "$prefix"_pruned --recode vcf --out "$prefix"_pruned_vcf
