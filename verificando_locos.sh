#!/bin/bash

# Caminho para a pasta onde estão os arquivos e a lista
diretorio="/caminho/para/a/pasta"

# Lê os nomes da lista e armazena em um array
mapfile -t nomes < "$diretorio/lista_locos.txt"

# Lista todos os arquivos no diretório (sem caminhos completos)
arquivos=($(ls -A1 $diretorio))

# Prepara o arquivo de saída, limpando-o se já existir
> "$diretorio/locos_faltantes.txt"

# Loop para verificar cada nome na lista de nomes
for nome in "${nomes[@]}"; do
    # Presume-se que o nome não foi encontrado
    encontrado=0
    for arquivo in "${arquivos[@]}"; do
        if [[ "$nome" == "$arquivo" ]]; then
            encontrado=1
            break
        fi
    done

    # Se o nome não foi encontrado em nenhum arquivo, imprime o nome e salva no arquivo
    if [[ $encontrado -eq 0 ]]; then
        echo "$nome" >> "$diretorio/locosfaltantes.txt"
    fi
done
