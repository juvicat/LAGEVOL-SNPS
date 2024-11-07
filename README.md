# Geração de matriz de SNPs a partir de dados genômicos
O presente repositório tem como objetivo a geração de uma matriz de SNPs a partir de dados genômicos obtidos via *target-enrichment sequencing* com o painel Cactaceae591 (Romeiro-Brito et al. 2022). Os programas e comandos necessários devem ser executados no sistema operacional Linux (ou no Subsistema Linux para Windows), através da interface Bash. Este tutorial considera que você já possui seus dados genômicos trimados e montados em seus respectivos locos. Para mais detalhes, consulte [Processamento de Dados Genômicos e Inferências Filogenéticas](https://github.com/juvicat/LAGEVOL_FILOGENIAS.git) 1 e 2. 

Base do repositório: Os *scripts* utilizados foram adaptados do repositório [HybSeq-SNP-Extraction](https://github.com/lindsawi/HybSeq-SNP-Extraction.git), publicado por Madeline Slimp e Matthew Johnson. Os processos aqui descritos foram adotados no projeto de iniciação científica "Filogenia multilocos de Arrojadoa Britton & Rose, cacto endêmico do leste do Brasil", desenvolvido sob orientação do professor Dr. Evandro M. Moraes no Laboratório de Diversidade Genética e Evolução (LaGEvol, UFSCar campus Sorocaba).

## Organização dos arquivos de entrada
Com as sequências montadas em seus respectivos locos pelo *Hybpiper*, é possível remover os locos parálogos, caso estes tenham sido identificados. Você pode criar um arquivo de lista com o nome desses locos (`paralogs_list.txt`) e movê-los para uma pasta separada (`paralogs`):
```
mkdir paralogs
while read -r paralog_locus; do  mv "$paralog_locus" paralogs/; done < paralogs_list.txt
```

Os SNPSs serão chamados a partir da maior sequência recuperada para cada loco, representadas por um arquivo `.fasta` armazenado nas pastas com sufixo `supercontig.fasta`. É possível copiar estes arquivos para uma única pasta:

```
mkdir supercontigs
cp nome_da_amostra/{OG,phyc,ppc}*/nome_da_amostra/sequences/intron/*_supercontig.fasta /supercontigs
```

Os nomes de cada sequência nos arquivos `.fasta` precisam ser padronizados com o nome do seu respectivo loco:

```
for i in *.fas; do awk '{if( NR==1)print ">"FILENAME;else print}' "$i" > "$i.fasta"; done
```

## Montagem do arquivo de referência
Um arquivo de referência é necessário para alinhar as sequências antes da extração de SNPs, e é possível usar as sequências de uma amostra para essa finalidade. É recomendável que a escolha da amostra a ser usada como referência seja baseada nas estatísticas geradas durante a montagem dos locos, como a amostra com menor número de locos faltantes ou com os locos com maior número de pares de base. 

É possível também adicionar locos que não estão presentes no seu aqrquivo de referência, a partir de amostras que possuem estes locos. Para isso, crie uma lista com o nome de todos os locos disponíveis para sua amostragem (`lista_locos.txt`) e utilize o script `verificando_locos.sh` para detectar os faltantes na sua referência:
```
bash verificando_locos.sh
```
Este script gera uma lista com os locos faltantes, que pode ser usada para copiar estes locos a partir de outras amostras. Esta adição pode ser feita manualmente ou com o script `mover_locos_faltantes.txt` que irá copiar o loco da primeira amostra encontrada que possuí-lo. 
```
bash mover_locos_faltantes.txt
```
Uma vez que todos os locos da referência estejam reunidos eles precisam ser concatenados em um único arquivo:
```
cat *_supercontig.fasta > referencia.cat_supercontigs.fasta
```

## Chamada de SNPs 
Para a chamada de variantes (SNPs e indels) usaremos o GATK (https://github.com/broadinstitute/gatk.git). Inicialmente, usaremos o script `chamada_variantes.sh` para gerar um arquivo no formato GVCF para cada espécie trabalhada. Este script precisa ser adaptado para o ambiente em que será executado, conforme instruções no arquivo. 

Para espécies com uma amostra:
```
bash chamada_variantes.sh referencia.cat_supercontigs.fasta nome_da_espécie
```
Para espécies com mais de uma amostra (a *flag* `nohup` executa o script em segundo plano):
```
nohup bash chamada_variantes.sh referencia.cat_supercontigs.fasta nome_da_espécie &> variantcall.log &
```

O script `juntar_GVCFs.sh` é utilizado para unir os arquivos GVCF e e realizar uma filtragem inicial de SNPs, além de remover os outros tipos de variantes:
```
bash juntar_GVCFs.sh referencia.cat_supercontigs.fasta nome_do_taxon
```
Os outputs gerados por esse script serão: `nome_do_taxon.SNPall.gvcf` (contém todos os SNPs e indels), `nome_do_taxon.snp.filtered.gvcf` (contém todos os SNPs, sem os indels) e `nome_do_taxon.snp.filtered.nocall.gvcf` (apenas SNPs que passaram pelo filtro estabelecido). 

## Filtragem de SNPs 
É interessante que uma segunda filtragem seja aplicada a matriz de SNPs, com o programa plink (https://github.com/insilico/plink.git). Parâmetros para o desequilíbrio de ligação (`--indep`) e para porcentagem de dados faltantes (`--geno`) podem ser estabelecidos editando o script `filtragem_plink.sh`.
```
bash filtragem_plink.sh nome_do_taxon
```

Por fim, o mesmo programa é utilizado para gerar um arquivo VCF a partir dos arquivos de saída do script:
```
plink --allow-extra-chr --bfile nome_do_taxon_pruned --recode vcf --out nome_do_taxon_pruned_vcf
```
