#!/bin/bash

#Definição de variáveis
set -eo pipefail
reference=/caminho/para/arquivo/de/referencia/$1 
prefix=$2 #"Nome do gênero"

# Gerar lista de amostras
ls ../*-g.vcf > amostras.list

# União dos aqrquivos GVCF
gatk CombineGVCFs -R $reference --variant amostras.list --output "$prefix".cohort.g.vcf
gatk GenotypeGVCFs -R $reference -V "$prefix".cohort.g.vcf -O "$prefix".cohort.unfiltered.vcf

# Filtragem de SNPs e remoção de outros variantes
time gatk SelectVariants -V "$prefix".cohort.unfiltered.vcf -R $reference -select-type-to-include SNP -O "$prefix".SNPall.vcf
time gatk VariantFiltration -R $reference -V "$prefix".SNPall.vcf --filter-name "hardfilter" -O "$prefix".snp.filtered.vcf --filter-expression "QD < 5.0 && FS > 60.0 && MQ < 40.0 && MQRankSum < -12.5 && ReadPosRankSum < -8.0"
time gatk SelectVariants -V "$prefix".snp.filtered.vcf -O "$prefix".snp.filtered.nocall.vcf --set-filtered-gt-to-nocall