#!/bin/bash

# Defina o caminho do arquivo locosfaltantes.txt
lista="locos_faltantes.txt"

# Loop para ler cada linha do arquivo lista
while IFS= read -r arquivo; do
    # Procurar o arquivo nos diretórios presentes na pasta anterior
    encontrado=$(find ../ -name "$arquivo" -print -quit)
    if [ -n "$encontrado" ]; then
        # Se o arquivo for encontrado, copie-o para a pasta atual
        cp "$encontrado" ./
    else
        # Se o arquivo não for encontrado, exiba uma mensagem
        echo "Arquivo $arquivo não encontrado nos diretórios acima."
    fi
done < "$lista"

