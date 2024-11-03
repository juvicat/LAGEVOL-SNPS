# SNP-CALL
O presente repositório tem como objetivo a geração de uma matriz de SNPs a partir de dados genômicos obtidos via *target-enrichment sequencing* com o painel Cactaceae591 (Romeiro-Brito et al. 2022). Os programas e comandos necessários devem ser executados no sistema operacional Linux (ou no Subsistema Linux para Windows), através da interface Bash. 

Os *scripts* utilizados foram adaptados do repositório [HybSeq-SNP-Extraction](https://github.com/lindsawi/HybSeq-SNP-Extraction.git), de Madeline Slimp e Matthew Johnson.

Este tutorial considera que você já possui seus dados genômicos trimados e montados em seus respectivos locos. Para mais detalhes, consulte [Processamento de Dados Genômicos e Inferências Filogenéticas](https://github.com/juvicat/LAGEVOL_FILOGENIAS.git) 1 e 2. 
## Organização dos arquivos de entrada
Com as sequências montadas em seus respectivos locos pelo *Hybpiper*, é possível remover os locos parálogos, caso estes tenham sido identificados. Você pode criar um arquivo de lista com o nome desses locos (`paralogs_list.txt`) e movê-los para uma pasta separada (`paralogs`):
```
mkdir paralogs
while read -r paralog_locus; do  mv "$paralog_locus" paralogs/; done < paralogs_list.txt
```

Os SNPSs serão chamados a partir da maior sequência recuperada para cada loco, representadas por um arquivo .fasta armazenado nas pastas com sufixo `supercontig.fasta`. É possível copiar estes arquivos para uma única pasta:

```
mkdir supercontigs
cp nome_da_amostra/{OG,phyc,ppc}*/nome_da_amostra/sequences/intron/*_supercontig.fasta /supercontigs
```

Os nomes de cada sequência nos arquivos `.fasta` precisam ser padronizados com o nome do seu respectivo loco:

```
for i in *.fas; do awk '{if( NR==1)print ">"FILENAME;else print}' "$i" > "$i.fasta"; done
```

## Montagem do arquivo de referência

## Chamada de SNPs 

## Filtragem de SNPs 
