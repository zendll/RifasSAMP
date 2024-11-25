CREATE TABLE `rifas` (
    `ID` INT AUTO_INCREMENT PRIMARY KEY,
    `ItemID` INT NOT NULL,
    `Nome` VARCHAR(35) NOT NULL,
    `Descricao` VARCHAR(35) NOT NULL,
    `Valor` INT NOT NULL,
    `VagasTotais` INT NOT NULL,
    `VagasRestantes` INT NOT NULL,
    `Ativa` INT NOT NULL 
);
CREATE TABLE `rifa_participantes` (
    `ID` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `RifaID` INT NOT NULL,
    `Nome` VARCHAR(32) NOT NULL
);
