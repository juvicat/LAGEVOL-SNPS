#!/bin/bash
set -eo pipefail

# Definição de variáveis
reference=/caminho/para/arquivo/de/referencia/$1
prefix=/caminho/para/a/pasta/$2 
read1fn="/caminho/para/sequencias/trimadas/$2_R1_trimmed.fastq"
read2fn="/caminho/para/sequencias/trimadas/$2_R2_trimmed.fastq"

cd $prefix
if [ ! -f ../*.dict ]
then gatk CreateSequenceDictionary -R $reference
fi 

bwa index $reference
samtools faidx $reference

#Alinhamento das sequências trimadas à referência e mapeamento
bwa mem $reference $read1fn $read2fn | samtools view -bS - | samtools sort - -o "$prefix.sorted.bam"
gatk FastqToSam -F1 $read1fn -F2 $read2fn -O $prefix.unmapped.bam -SM $prefix.sorted.bam

#Substituição de read groups por arquivos BAM mapeados e não mapeados usando bibliotecas preparadas e informações do sequenciamento
gatk AddOrReplaceReadGroups -I  $prefix.sorted.bam -O $prefix.sorted-RG.bam -RGID 2 -RGLB lib1 -RGPL illumina -RGPU unit1 -RGSM $prefix
gatk AddOrReplaceReadGroups -I  $prefix.unmapped.bam -O $prefix.unmapped-RG.bam -RGID 2 -RGLB lib1 -RGPL illumina -RGPU unit1 -RGSM $prefix

#Combinação de arquivos BAM mapeados e não mapeados
gatk MergeBamAlignment --ALIGNED_BAM $prefix.sorted-RG.bam --UNMAPPED_BAM $prefix.unmapped-RG.bam -O $prefix.merged.bam -R $reference

#Remoção de sequências duplicadas
gatk MarkDuplicates -I $prefix.merged.bam -O $prefix.marked.bam -M $prefix.metrics.txt
samtools index $prefix.marked.bam

#Criação do arquivo GVCF 
gatk HaplotypeCaller -I $prefix.marked.bam -O $prefix-g.vcf -ERC GVCF -R $reference

#Remoção dos arquivos intermediários
rm $prefix.sorted.bam $prefix.unmapped.bam $prefix.merged.bam $prefix.unmapped-RG.bam $prefix.sorted-RG.bam
