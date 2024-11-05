#!/bin/bash
set -eo pipefail

## Usage: bash variantcall.sh Sporobolus_cryptandrus_ref.fasta GUMOseq-0188
## Where .fasta is reference sequence + ' ' + samplename 

# while read name; do bash variantcall.sh Arrojadoa_rhodantha_theunisseniana_Botupora_L83A1.cat_supercontigs.fasta $name; done < SNPe_rhodantha_namelist.txt
# bash variantcall.sh Arrojadoa_rhodantha_theunisseniana_Botupora_L83A1.cat_supercontigs.fasta Arrojadoa_rhodantha_aureispina_RiachoSantana_L69A8

# Set variables
reference=/mnt/d/Joao/0.1.JV_Data/assembled_all_samples/referencias/*/$1
prefix=/mnt/d/Joao/0.1.JV_Data/assembled_all_samples/$2 
#read1fn="$prefix.R1.paired.fastq"
#read2fn="$prefix.R2.paired.fastq" 
read1fn="/mnt/d/Joao/0.1.JV_Data/trimmed/$2_R1_trimmed.fastq"
read2fn="/mnt/d/Joao/0.1.JV_Data/trimmed/$2_R2_trimmed.fastq"

cd $prefix
if [ ! -f ../*.dict ]
then /mnt/c/Users/Lagevol/Desktop/programas/gatk-4.5.0.0/gatk-4.5.0.0/gatk CreateSequenceDictionary -R $reference
fi 

bwa index $reference
samtools faidx $reference

#Align read files to reference sequence and map
bwa mem $reference $read1fn $read2fn | samtools view -bS - | samtools sort - -o "$prefix.sorted.bam"
 /mnt/c/Users/Lagevol/Desktop/programas/gatk-4.5.0.0/gatk-4.5.0.0/gatk FastqToSam -F1 $read1fn -F2 $read2fn -O $prefix.unmapped.bam -SM $prefix.sorted.bam

#Replace read groups to mapped and unmapped bam files using library prep and sequencing information
 /mnt/c/Users/Lagevol/Desktop/programas/gatk-4.5.0.0/gatk-4.5.0.0/gatk AddOrReplaceReadGroups -I  $prefix.sorted.bam -O $prefix.sorted-RG.bam -RGID 2 -RGLB lib1 -RGPL illumina -RGPU unit1 -RGSM $prefix
 /mnt/c/Users/Lagevol/Desktop/programas/gatk-4.5.0.0/gatk-4.5.0.0/gatk AddOrReplaceReadGroups -I  $prefix.unmapped.bam -O $prefix.unmapped-RG.bam -RGID 2 -RGLB lib1 -RGPL illumina -RGPU unit1 -RGSM $prefix

#Combine mapped and unmapped BAM files
 /mnt/c/Users/Lagevol/Desktop/programas/gatk-4.5.0.0/gatk-4.5.0.0/gatk MergeBamAlignment --ALIGNED_BAM $prefix.sorted-RG.bam --UNMAPPED_BAM $prefix.unmapped-RG.bam -O $prefix.merged.bam -R $reference

#Remove duplicate sequences
 /mnt/c/Users/Lagevol/Desktop/programas/gatk-4.5.0.0/gatk-4.5.0.0/gatk MarkDuplicates -I $prefix.merged.bam -O $prefix.marked.bam -M $prefix.metrics.txt
samtools index $prefix.marked.bam

#Create GVCF 
 /mnt/c/Users/Lagevol/Desktop/programas/gatk-4.5.0.0/gatk-4.5.0.0/gatk HaplotypeCaller -I $prefix.marked.bam -O $prefix-g.vcf -ERC GVCF -R $reference

#Remove intermediate files
rm $prefix.sorted.bam $prefix.unmapped.bam $prefix.merged.bam $prefix.unmapped-RG.bam $prefix.sorted-RG.bam
