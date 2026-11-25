# Atividade prática de RPA — entrega

## Arquivos

| Item pedido | Onde está |
| :-- | :-- |
| tarefas.robot (com os desafios 1 e 4) | `robo/tarefas.robot` |
| Planilha de uma execução aprovada | `robo/saida/tarefas.xlsx` |
| Log da execução aprovada | `robo/saida/log.html` |
| Captura de tela do quadro | `robo/saida/quadro.png` (o próprio robô tira) |
| Falha clara com quadro inexistente (desafio 4) | `robo/saida_falha/log.html` |
| Script que cadastra o quadro de exemplo pela API | `robo/semear_dados.sh` |

## Desafios feitos

1. **Hora da extração:** coluna "Extraído em" com `Get Current Date` (biblioteca DateTime).
4. **Exceções:** se o quadro não existir, o robô termina com
   `Quadro "X" não encontrado em http://localhost:3000. Confira o nome do quadro e se o app está rodando.`
   em vez de "element not found" (`Run Keyword And Return Status` + `Fail`).

## Como executar

Terminal 1 (app). O app **não sobe com Node 26** (uma dependência usa `SlowBuffer`, removido no Node 26); use o Node 22:

```sh
cd trelloapp
nvm use 22
npm start
```

Terminal 2 (robô):

```sh
cd robo
source .venv/bin/activate
./semear_dados.sh        # só na primeira vez, com o banco vazio
robot --outputdir saida tarefas.robot
```

O `.venv` usa Python 3.12 (o Python do macOS é 3.9, antigo demais para o rpaframework). Ele foi criado com `uv venv --python 3.12 .venv`.

## Parágrafo: o que quebraria o robô e como se proteger

O robô depende da tela, então quebraria se uma atualização do app mudasse ou removesse os atributos `data-test-id`, se trocasse a tag dos elementos (os XPaths usam `div` e `input`), se a lista deixasse de ser um campo de texto (aí `Get Value` passa a vir vazio), se mudasse o formato da data exibida ou a forma de marcar a conclusão, ou se os cartões passassem a carregar mais devagar ou sob demanda (rolagem infinita, paginação), fazendo o robô ler antes da hora. Também quebraria se o app passasse a exigir login. Para me proteger, eu usaria só seletores por `data-test-id`, sem depender de classes CSS nem de posição na tela, e deixaria os seletores num lugar só (seção Variables ou um arquivo de recursos), para corrigir uma vez quando o app mudar. Manteria as esperas explícitas e com timeout configurável, trataria os erros previsíveis com mensagens claras (como no desafio 4), e rodaria o robô contra cada versão nova do app antes de usá-lo de verdade, conferindo o número de linhas da planilha com o número de cartões. Quando o sistema oferece uma API estável, como este app oferece, ler pela API é mais rápido e menos frágil do que ler pela tela.

## Observação sobre as datas

O prazo na tela aparece **um dia antes** do gravado no banco (ex.: banco `2026-11-27`, tela `Nov 26 2026`). É do app: ele lê a data como meia-noite UTC e mostra no fuso local (UTC−3). O robô grava o que a tela mostra, como pede a atividade.
