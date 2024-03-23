#!/bin/bash


if [ $# -ne 1 ]; then
    echo "Usage: $0 <email>"
    exit 1
fi
email=$1

chave=~/.ssh/aws-machine

if [ -f "$chave" ]; then
    echo "A chave '$chave' já existe. Deseja sobrescrevê-la? (s/n)"
    read resposta
    if [ "$resposta" != "s" ]; then
        echo "Operação cancelada."
        exit 0
    fi
fi


ssh-keygen -t rsa -b 2048 -C "$email" -f "$chave"

if [ $? -eq 0 ]; then
    echo "Chave gerada com sucesso em '$chave'."
else
    echo "Erro ao gerar a chave."
fi
