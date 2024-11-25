#include <YSI_Coding\y_hooks>

new rifaid;

CMD:gerenciarrifas(playerid) {
    Carregar_Rifas();
    new String[2 * 150],
        linha[2 * 100];  

    format(String, sizeof(String), "ID\tNome\tDescrição\tPreco\tVagas Restantes/Totais\n");

    for (new i = 0; i < MAX_RIFAS; i++) {
        if (E_RIFA_INDEX[i][R_ITEM_ATIVA]) { 
            format(linha, sizeof(linha), "{9a9a9a}#%d\t{00bfff}%s\t{9a9a9a}%s\t{008000}%d\t{9a9a9a}%d/%d\n",
                i + 1, 
                E_RIFA_INDEX[i][R_ITEM_NOME],
                E_RIFA_INDEX[i][R_ITEM_DESC], 
                E_RIFA_INDEX[i][R_ITEM_VALOR], 
                E_RIFA_INDEX[i][R_ITEM_RESTANTES], 
                E_RIFA_INDEX[i][R_ITEM_VAGAS]);
            strcat(String, linha); 
        }
    }
    if (strlen(String) <= strlen("ID\tDescrição\tVagas Restantes/Totais\n")) {
        Dialog_Show(playerid, D_GERENCIAR_NULL, DIALOG_STYLE_MSGBOX, 
            "Gerenciar Rifas", 
            "Não há Rifas ativas para gerenciar.", 
            "Fechar", "");
        return 1;
    }

    Dialog_Show(playerid, D_GERENCIAR_RIFA, DIALOG_STYLE_TABLIST_HEADERS, 
        "Gerenciar Rifas", String, "Selecionar", "Fechar");
    return 1;
}


Dialog:D_GERENCIAR_RIFA(playerid, response, listitem, inputtext[]) {

    if (!response) return true;

    new options[2*375];

    rifaid = listitem;

    format(options, sizeof(options), 
        "Nome\tInformaçao\n\
        {ffffff}ID\t{9a9a9a}%d\n\
        {ffffff}Nome\t{9a9a9a}%s\n\
        {ffffff}Descrição \t{9a9a9a}%s\n\
        {ffffff}Valor \tR${9a9a9a}%d\n\
        {ffffff}Ativa \t{9a9a9a}%s\n\
        {ffffff}Sortear Rifa\t{9a9a9a}Clique para sortear\n\
        {ffffff}Ver Membros\t{9a9a9a}Clique para ver\n\
        {df5454}Excluir Rifa\tClique para Excluir", 
        E_RIFA_INDEX[listitem][R_ITEM_ID], 
        E_RIFA_INDEX[listitem][R_ITEM_NOME], 
        E_RIFA_INDEX[listitem][R_ITEM_DESC], 
        E_RIFA_INDEX[listitem][R_ITEM_VALOR],
        E_RIFA_INDEX[listitem][R_ITEM_ATIVA] ? "Sim" : "Nao"
    );
    Dialog_Show(playerid, D_GERENCIAR_DETALHES, DIALOG_STYLE_TABLIST_HEADERS, "Rifa", options, "Selecionar", "Cancelar");
    return true;
}
Dialog:D_GERENCIAR_DETALHES(playerid, response, listitem, inputtext[]) {

    if (!response) return true;

    switch (listitem) {
        case 0: {
            Dialog_Show(playerid, D_EDITAR_ID, DIALOG_STYLE_INPUT, "Editar ID da Rifa", "Digite o novo ID para esta rifa", "Salvar", "Cancelar");
        }
        case 1: {
            Dialog_Show(playerid, D_EDITAR_NOME, DIALOG_STYLE_INPUT, 
                "Editar Nome da Rifa", 
                "Digite o novo nome para esta rifa:", 
                "Salvar", "Cancelar");
        }
        case 2: {
            Dialog_Show(playerid, D_EDITAR_NOME, DIALOG_STYLE_INPUT, 
                "Editar Descriçao da Rifa", 
                "Digite a nova Descriçao para esta rifa:", 
                "Salvar", "Cancelar");
        }
        case 3: {
            Dialog_Show(playerid, D_EDITAR_NOME, DIALOG_STYLE_INPUT, 
                "Editar valor da Rifa", 
                "Digite o novo valor para esta rifa:", 
                "Salvar", "Cancelar");
        }
        case 4: {
            //...
        }
        case 5: {
            SortearRifa_Index(rifaid+1);     
        }
        case 6: {
            ExibirNomes_Rifas(playerid, rifaid);      
        }
        case 7: {
            ExcluirRifa_Index(playerid, rifaid);
        }
        default:{
            SendClientMessage(playerid, -1, "Opção inválida."), print("[DEBUG] UMA OPÇAO FOI ESCOLHIDA INVALIDA");
        }
    }
    return true;
}
CMD:sortear(playerid, params[]){
    new i;
    if(sscanf(params, "d", i)) return SendClientMessage(playerid, -1, "/sortear [id] da rifa");

    SortearRifa_Index(i);
    return 1;
}
CMD:excluir(playerid, params[]){
    new i;
    if(sscanf(params, "d", i)) return SendClientMessage(playerid, -1, "/sortear [id] da rifa");

    ExcluirRifa_Index(playerid, i);
    return 1;
}
CMD:skin(playerid){
    SetPlayerSkin(playerid, 216);
    return 1;
}