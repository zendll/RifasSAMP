#include <YSI_Coding\y_hooks>

#include "../modulos/rifa/rifas_config.pwn" //gerenciamento geral das rifas

hook OnGameModeInit(){
    Carregar_Rifas();
    return 1;
}

//comandos
CMD:criarrifa(playerid, params[]) {

    new itemID, 
        valor, 
        vagas, 
        descricao[35],
        nome[35],
        at;

    if (sscanf(params, "ds[35]s[35]ddd", itemID, nome, descricao, valor, vagas, at)) 
        return SendClientMessage(playerid, -1, "/criarrifa [ID do item] [Nome do Item] [Descrição] [Valor] [Vagas] [Ativa 1 = SIM  0 = NAO]");
    
    if (vagas <= 0)
        return SendClientMessage(playerid, -1, "O valor deve ser maior que 0 (zero)");

    mysql_format(Conexao, query, sizeof(query),
        "INSERT INTO `rifas` (`ItemID`, `Nome`, `Descricao`, `Valor`, `VagasTotais`, `VagasRestantes`, `Ativa`) \
        VALUES (%d, '%s', '%s', %d, %d, %d, %d)", 
        itemID, nome, descricao, valor, vagas, vagas, at);
    mysql_query(Conexao, query);

    SendClientMessage(playerid, -1, "Rifa criada com sucesso!");
    return 1;
}
CMD:verrifas(playerid) {

    Carregar_Rifas();  
    new gs_buffer[400], linha[256];
    format(gs_buffer, sizeof(gs_buffer), "ID\tNome\tDescrição\tValor\tVagas Restantes/Totais\n");

    for (new i = 0; i < MAX_RIFAS; i++) {
        if (E_RIFA_INDEX[i][R_ITEM_ATIVA]) {
           
            format(linha, sizeof(linha), "{9a9a9a}#%d\t%s\t%s\tR$%d\t%d/%d\n", 
                i + 1, 
                E_RIFA_INDEX[i][R_ITEM_NOME], 
                E_RIFA_INDEX[i][R_ITEM_DESC], 
                E_RIFA_INDEX[i][R_ITEM_VALOR], 
                E_RIFA_INDEX[i][R_ITEM_RESTANTES], 
                E_RIFA_INDEX[i][R_ITEM_VAGAS]);

            strcat(gs_buffer, linha);
        }
    }
    if (strlen(gs_buffer) <= strlen("ID\tDescrição\tValor\tVagas Restantes/Totais\n")) 
        return ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "Rifas", "Não há Rifas ativas no momento.", "Fechar", "");
         
    Dialog_Show(playerid, D_VER_RIFA, DIALOG_STYLE_TABLIST_HEADERS, "Rifas Ativas", gs_buffer, "Comprar", "Fechar");
    return 1;
}
Dialog:D_VER_RIFA(playerid, response, listitem, inputtext[]) {
    if (!response) return true;

    if (listitem < 0 || listitem >= MAX_RIFAS) return SendClientMessage(playerid, -1, "Rifa inválida ou não ativa."), print("ERRO ENCONTRADO DIALOG D_VER_RIFA");
    ComprarVagaRifa(playerid, listitem);
    return 1;
}



