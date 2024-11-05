#!/bin/bash
##End of Select Varitants for GATK4

set -eo pipefail
reference=/mnt/d/Joao/0.1.JV_Data/assembled_all_samples/SNPext/$1 #Ppyriforme-3728.supercontigs.fasta
prefix=$2 #Physcomitrium-pyriforme
#Make Samples list
#ls ../*-g.vcf > samples.list
# Combine and Jointly call GVCFs
/mnt/c/Users/Lagevol/Desktop/programas/gatk-4.5.0.0/gatk-4.5.0.0/gatk CombineGVCFs -R $reference --variant samples.list --output "$prefix".cohort.g.vcf
/mnt/c/Users/Lagevol/Desktop/programas/gatk-4.5.0.0/gatk-4.5.0.0/gatk GenotypeGVCFs -R $reference -V "$prefix".cohort.g.vcf -O "$prefix".cohort.unfiltered.vcf
# Keep only SNPs passing a hard filter
time /mnt/c/Users/Lagevol/Desktop/programas/gatk-4.5.0.0/gatk-4.5.0.0/gatk SelectVariants -V "$prefix".cohort.unfiltered.vcf -R $reference -select-type-to-include SNP -O "$prefix".SNPall.vcf
#time /mnt/c/Users/Lagevol/Desktop/programas/gatk-4.5.0.0/gatk-4.5.0.0/gatk VariantFiltration -R $reference -V "$prefix".SNPall.vcf --filter-name "hardfilter" -O "$prefix".snp.filtered.vcf --filter-expression "QD < 5.0 & FS > 60.0 & MQ < 40.0 & MQRankSum < -12.5 & ReadPosRankSum < -8.0"
time /mnt/c/Users/Lagevol/Desktop/programas/gatk-4.5.0.0/gatk-4.5.0.0/gatk VariantFiltration -R $reference -V "$prefix".SNPall.vcf --filter-name "hardfilter" -O "$prefix".snp.filtered.vcf --filter-expression "QD < 5.0 && FS > 60.0 && MQ < 40.0 && MQRankSum < -12.5 && ReadPosRankSum < -8.0"
time /mnt/c/Users/Lagevol/Desktop/programas/gatk-4.5.0.0/gatk-4.5.0.0/gatk SelectVariants -V "$prefix".snp.filtered.vcf -O "$prefix".snp.filtered.nocall.vcf --set-filtered-gt-to-nocall

