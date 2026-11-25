*** Settings ***
Documentation       Lê as tarefas de um quadro do Trello app e gera uma planilha do Excel.
...                 Desafios extras: 1 (coluna "Extraído em") e 4 (falha clara se o quadro não existir).
Library             RPA.Browser.Selenium
Library             RPA.Tables
Library             RPA.Excel.Files
Library             DateTime
Task Teardown       Close All Browsers


*** Variables ***
${URL}              http://localhost:3000
${QUADRO}           Projeto RPA
@{COLUNAS}          Lista    Tarefa    Prazo    Status    Extraído em


*** Tasks ***
Exportar tarefas do quadro
    Abrir o quadro    ${QUADRO}
    ${tarefas}=    Coletar tarefas do quadro
    Salvar em Excel    ${tarefas}


*** Keywords ***
Abrir o quadro
    [Arguments]    ${nome}
    Open Available Browser    ${URL}
    ${quadro}=    Set Variable    xpath://div[@data-test-id="board-item"][.//h2[normalize-space()="${nome}"]]
    ${existe}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${quadro}    timeout=20s
    IF    not ${existe}
        Fail    Quadro "${nome}" não encontrado em ${URL}. Confira o nome do quadro e se o app está rodando.
    END
    Click Element    ${quadro}
    Wait Until Element Is Visible    css:[data-test-id="board-detail"]    timeout=20s
    Wait Until Element Is Visible    css:[data-test-id="list"]    timeout=20s
    Wait Until Page Does Not Contain    Loading cards    timeout=20s
    Capture Page Screenshot    ${OUTPUT DIR}${/}quadro.png

Coletar tarefas do quadro
    ${extraido_em}=    Get Current Date    result_format=%d/%m/%Y %H:%M:%S
    ${tabela}=    Create Table    columns=${COLUNAS}
    ${qtd_listas}=    Get Element Count    css:[data-test-id="list"]
    FOR    ${i}    IN RANGE    1    ${qtd_listas + 1}
        ${lista}=    Set Variable    xpath:(//div[@data-test-id="list"])[${i}]
        ${nome_lista}=    Get Value    ${lista}//input[@data-test-id="list-name"]
        ${qtd_cartoes}=    Get Element Count    ${lista}//div[@data-test-id="card"]
        FOR    ${j}    IN RANGE    1    ${qtd_cartoes + 1}
            ${cartao}=    Set Variable
            ...    xpath:((//div[@data-test-id="list"])[${i}]//div[@data-test-id="card"])[${j}]
            ${tarefa}=    Get Text    ${cartao}//div[@data-test-id="card-text"]
            ${prazo}=    Get Text    ${cartao}//div[@data-test-id="due-date"]
            ${concluida}=    Run Keyword And Return Status
            ...    Checkbox Should Be Selected    ${cartao}//input[@data-test-id="card-checkbox"]
            ${status}=    Set Variable If    ${concluida}    Concluída    Pendente
            ${linha}=    Create Dictionary
            ...    Lista=${nome_lista}    Tarefa=${tarefa}    Prazo=${prazo}    Status=${status}
            ...    Extraído em=${extraido_em}
            Add Table Row    ${tabela}    ${linha}
        END
    END
    RETURN    ${tabela}

Salvar em Excel
    [Arguments]    ${tabela}
    Create Workbook    ${OUTPUT DIR}${/}tarefas.xlsx    sheet_name=Tarefas
    Append Rows To Worksheet    ${tabela}    header=${TRUE}
    Save Workbook
