#!/bin/sh
# Cadastra o quadro "Projeto RPA" (3 listas, 8 cartões, 2 concluídos) pela API do app.
set -e
API=${API:-http://localhost:3000/api}
post() { curl -sf -X "$1" -H 'Content-Type: application/json' -H 'Accept: application/json' -d "$3" "$API$2"; }
id() { python3 -c 'import sys,json;print(json.load(sys.stdin)["id"])'; }

B=$(post POST /boards '{"name":"Projeto RPA"}' | id)
for lista in "A fazer" "Fazendo" "Feito"; do
  post POST /lists "{\"boardId\":$B,\"name\":\"$lista\"}" | id
done > /tmp/listas.$$
L1=$(sed -n 1p /tmp/listas.$$); L2=$(sed -n 2p /tmp/listas.$$); L3=$(sed -n 3p /tmp/listas.$$); rm /tmp/listas.$$

card() { post POST /cards "{\"boardId\":$B,\"listId\":$1,\"name\":\"$2\"}" | id; }
card $L1 "Revisão do relatório" >/dev/null
card $L1 "Levantar requisitos" >/dev/null
card $L1 "Reunião com o cliente" >/dev/null
P=$(card $L2 "Modelar o banco")
card $L2 "Configuração do ambiente" >/dev/null
C1=$(card $L3 "Criar o repositório")
C2=$(card $L3 "Definição do escopo")
card $L3 "Instalação do Python" >/dev/null

post PATCH /cards/$C1 '{"completed":true}' >/dev/null
post PATCH /cards/$C2 '{"completed":true}' >/dev/null
post PATCH /cards/$P '{"deadline":"2026-12-15"}' >/dev/null
echo "Quadro $B criado."
