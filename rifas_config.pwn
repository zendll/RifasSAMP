#include <YSI_Coding\y_hooks>

#define MAX_RIFAS 2
#define MAX_JOGADORES_POR_PAGINA 20
new page = 0;

enum RIFA_INDEX {
    R_ITEM_ID,
    R_ITEM_NOME[24],
    R_ITEM_DESC[35],
    R_ITEM_VALOR,
    R_ITEM_VAGAS,
    R_ITEM_RESTANTES,
    R_ITEM_ATIVA
};
new E_RIFA_INDEX[MAX_RIFAS][RIFA_INDEX];

#include "../modulos/rifa/rifa_gerenciamento.pwn"

//stocks
stock SortearRifa_Index(rifaID) {

    for (rifaID = 0; rifaID < MAX_RIFAS; rifaID++) {
        if (E_RIFA_INDEX[rifaID][R_ITEM_ATIVA] == 0) {
            continue; //
        }

        mysql_format(Conexao, query, sizeof(query), "SELECT Nome FROM rifa_participantes WHERE RifaID = %d", rifaID + 1);
        mysql_query(Conexao, query);

        new rows, randomIndex;
        cache_get_row_count(rows);
        
        if (rows <= 0) 
            continue;

        randomIndex = random(rows); 

        new win[MAX_PLAYER_NAME];
        cache_get_value_name(randomIndex, "Nome", win); 

        SendClientMessageToAll(-1, va_return("O vencedor da rifa {9a9a9a}%s foi: {00bfff}%s", E_RIFA_INDEX[rifaID][R_ITEM_NOME], win));

  
        E_RIFA_INDEX[rifaID][R_ITEM_ATIVA] = 0;
        mysql_format(Conexao, query, sizeof(query), "UPDATE rifas SET Ativa = 0 WHERE ID = %d", rifaID + 1);
        mysql_query(Conexao, query);

        Reset_Rifa(rifaID); 
        break;  
    }
    return 1;
}
stock ComprarVagaRifa(playerid, rifaIndex) {

    if (rifaIndex < 0 || rifaIndex >= MAX_RIFAS) 
        return SendClientMessage(playerid, -1, "ID de rifa inválido.");

    if (E_RIFA_INDEX[rifaIndex][R_ITEM_RESTANTES] <= 0) 
        return SendClientMessage(playerid, -1, "Não há mais vagas disponíveis para esta rifa.");
    

    new rifaID = rifaIndex + 1; 

    mysql_format(Conexao, query, sizeof(query),
        "INSERT INTO rifa_participantes (RifaID, Nome) VALUES (%d, '%s')",
        rifaID, PlayerName(playerid));
    mysql_query(Conexao, query);

    E_RIFA_INDEX[rifaIndex][R_ITEM_RESTANTES]--;

    mysql_format(Conexao, query, sizeof(query),
        "UPDATE rifas SET VagasRestantes = %d WHERE ID = %d",
        E_RIFA_INDEX[rifaIndex][R_ITEM_RESTANTES], rifaID);
    mysql_query(Conexao, query);

    SendClientMessage(playerid, -1, "Você comprou um ingresso para a rifa com sucesso.");
    printf("Jogador %s comprou um ingresso para a rifa ID %d (Index %d).", PlayerName(playerid), rifaID, rifaIndex);
    return 1;
}

stock ExcluirRifa_Index(RifaID_Index) {

    mysql_format(Conexao, query, sizeof(query), "DELETE FROM rifa_participantes WHERE RifaID = %d", RifaID_Index + 1);
    mysql_query(Conexao, query);

    mysql_format(Conexao, query, sizeof(query), "DELETE FROM rifas WHERE ID = %d", RifaID_Index + 1);
    mysql_query(Conexao, query);

   // Reset_Rifa(RifaID_Index);
    return 1;
}

stock Reset_Rifa(RifaID_Index) {

    if (RifaID_Index < 0 || RifaID_Index >= MAX_RIFAS) 
        return 0; 
  
    mysql_format(Conexao, query, sizeof(query), 
        "DELETE FROM rifa_participantes WHERE RifaID = %d", RifaID_Index + 1);
    mysql_query(Conexao, query);

    mysql_format(Conexao, query, sizeof(query), 
        "DELETE FROM rifas WHERE ID = %d", RifaID_Index + 1);
    mysql_query(Conexao, query);

    E_RIFA_INDEX[RifaID_Index][R_ITEM_ID] = 0;
    E_RIFA_INDEX[RifaID_Index][R_ITEM_NOME][0] = '\0'; 
    E_RIFA_INDEX[RifaID_Index][R_ITEM_DESC][0] = '\0'; 
    E_RIFA_INDEX[RifaID_Index][R_ITEM_VALOR] = 0;
    E_RIFA_INDEX[RifaID_Index][R_ITEM_VAGAS] = 0;
    E_RIFA_INDEX[RifaID_Index][R_ITEM_RESTANTES] = 0;
    E_RIFA_INDEX[RifaID_Index][R_ITEM_ATIVA] = 0; 

    Carregar_Rifas();

    printf("Rifa %d foi resetada e removida do banco de dados.", RifaID_Index);
    return 1;
}


stock ExibirNomes_Rifas(playerid, pageIndex) {

    mysql_format(Conexao, query, sizeof(query), "SELECT RifaID, COUNT(*) AS TotalRifas FROM rifa_participantes WHERE Nome = '%s' GROUP BY RifaID", PlayerName(playerid));
    mysql_query(Conexao, query);

    if (!cache_num_rows()) 
        return SendClientMessage(playerid, -1, "Você não comprou nenhuma rifa.");
    
    new rows = cache_num_rows();

    new totalPages = rows / MAX_JOGADORES_POR_PAGINA;
    if (rows % MAX_JOGADORES_POR_PAGINA > 0) {
        totalPages++;
    }
    if (pageIndex < 0) pageIndex = 0;
    if (pageIndex >= totalPages) pageIndex = totalPages - 1;

    new options[2 * 200];
    format(options, sizeof(options), "ID Rifa\tTotal de Rifas Compradas\n");

    new comeco = pageIndex * MAX_JOGADORES_POR_PAGINA;
    new fim = comeco + MAX_JOGADORES_POR_PAGINA;
    if (fim > rows) fim = rows;

    for (new i = comeco; i < fim; i++) {
        new rifaID, totalRifas;
        cache_get_value_int(i, "RifaID", rifaID);
        cache_get_value_int(i, "TotalRifas", totalRifas);
        format(options, sizeof(options), "%s{ffffff}Rifa #%d\t{9a9a9a}%d\n", options, rifaID, totalRifas);
    }
    new buttons[64] = "Selecionar";
    new navigation[128] = "";

    if (pageIndex > 0) {
        format(navigation, sizeof(navigation), "%s[<<] Voltar Página", navigation);
    }
    if (pageIndex + 1 < totalPages) {
        format(navigation, sizeof(navigation), "%s\n[>>] Próxima Página", navigation);
    }
    Dialog_Show(playerid, DIALOG_RIFAS_COMPRADAS, DIALOG_STYLE_TABLIST_HEADERS, "Rifas Compradas", options, buttons, navigation);

    return 1;
}



Dialog:DIALOG_RIFAS_COMPRADAS(playerid, response, listitem, inputtext[]) {
    if (!response) return true;

    if (listitem == 0) {
        page++;  
        ExibirNomes_Rifas(playerid, page); 
    }
    return true;
}

stock Carregar_Rifas() {

    mysql_query(Conexao, "SELECT * FROM `rifas` ORDER BY ID ASC");

    if (!cache_num_rows()) 
       return printf("Nenhuma rifa encontrada.");
        
    new rows = cache_num_rows(),
        rifaID;

    for (new i = 0; i < rows && i < MAX_RIFAS; i++) { 
        cache_get_value_int(i, "ID", rifaID);
        cache_get_value_int(i, "ItemID", E_RIFA_INDEX[i][R_ITEM_ID]);  
        cache_get_value_name(i, "Nome", E_RIFA_INDEX[i][R_ITEM_NOME], 35);
        cache_get_value_name(i, "Descricao", E_RIFA_INDEX[i][R_ITEM_DESC], 35);
        cache_get_value_int(i, "Valor", E_RIFA_INDEX[i][R_ITEM_VALOR]);
        cache_get_value_int(i, "Vagas", E_RIFA_INDEX[i][R_ITEM_VAGAS]);
        cache_get_value_int(i, "VagasRestantes", E_RIFA_INDEX[i][R_ITEM_RESTANTES]);
        cache_get_value_int(i, "Ativa", E_RIFA_INDEX[i][R_ITEM_ATIVA]);
    }
    return 1;
}

