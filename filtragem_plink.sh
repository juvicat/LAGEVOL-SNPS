#!/bin/bash
set -eo pipefail

prefix=$1 

# Geração de uma nomenclatura única para cada SNP
bcftools annotate --set-id +"%CHROM:%POS" "$prefix".snp.filtered.nocall.vcf > "$prefix".snp.filtered.nodot.vcf

# Filtragem
# Dados faltantes e desequilíbrio de ligação: 
/mnt/c/Users/Lagevol/Desktop/programas/plink_linux_x86_64_20231211/plink --vcf-filter --vcf "$prefix".snp.filtered.nodot.vcf --allow-extra-chr --recode  --make-bed --geno 0 --const-fid --out "$prefix"
/mnt/c/Users/Lagevol/Desktop/programas/plink_linux_x86_64_20231211/plink --indep 50 5 2 --file "$prefix" --allow-extra-chr --out "$prefix"
/mnt/c/Users/Lagevol/Desktop/programas/plink_linux_x86_64_20231211/plink --extract "$prefix".prune.in --out "$prefix"_pruned --file "$prefix" --make-bed --allow-extra-chr --recode

# Geração de valores individuais para PCAs de 20 eixos:
plink --pca 20 --file "$prefix"_pruned --allow-extra-chr --out "$prefix"

# Geração de estatísticas:
plink --freq --het 'small-sample' --ibc --file "$prefix"_pruned --allow-extra-chr -out "$prefix"_pruned
