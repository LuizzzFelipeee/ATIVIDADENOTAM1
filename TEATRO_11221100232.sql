create schema teatro;
use teatro;

CREATE TABLE pecas_teatro (
    id_peca INT PRIMARY KEY AUTO_INCREMENT,
    nome_peca VARCHAR(100) NOT NULL,
    descricao TEXT,
    duracao INT,
    data_estreia DATETIME,
    diretor VARCHAR(100),
    elenco TEXT
);

DELIMITER $$

CREATE FUNCTION calcular_media_duracao(id_peca INT)
RETURNS FLOAT
BEGIN
    DECLARE media_duracao FLOAT;

    SELECT AVG(duracao) INTO media_duracao
    FROM pecas_teatro
    WHERE id_peca = id_peca;

    RETURN media_duracao;
END $$

DELIMITER ;


delimiter $$
CREATE FUNCTION verificar_disponibilidade(data_hora DATETIME)
RETURNS BOOLEAN
BEGIN
    DECLARE disponivel BOOLEAN;

    IF EXISTS (
        SELECT 1
        FROM pecas_teatro
        WHERE data_estreia = data_hora
    ) THEN
     
        SET disponivel = FALSE; -- Não disponível;
    ELSE
                              
        SET disponivel = TRUE; -- Disponível;
    END IF;

    RETURN disponivel;
END$$

delimiter ;



DELIMITER $$

CREATE PROCEDURE agendar_pecas(
    IN nome_peca VARCHAR(100),
    IN descricao TEXT,
    IN duracao INT,
    IN data_hora DATETIME,
    IN diretor VARCHAR(100),
    IN elenco TEXT
)
BEGIN
    DECLARE disponibilidade BOOLEAN;
    DECLARE media_duracao FLOAT;

    -- Verificar a disponibilidade
    SET disponibilidade = verificar_disponibilidade(data_hora);

    IF disponibilidade THEN
        -- Inserir a nova peça de teatro na tabela pecas_teatro
        INSERT INTO pecas_teatro (nome_peca, descricao, duracao, data_estreia, diretor, elenco)
        VALUES (nome_peca, descricao, duracao, data_hora, diretor, elenco);

        -- Calcular a média de duração usando a função calcular_media_duracao
        SET media_duracao = calcular_media_duracao(LAST_INSERT_ID());

        -- Imprimir as informações sobre a peça agendada, e incluir a média de duração
        SELECT 
            nome_peca AS 'Nome da Peça',
            descricao AS 'Descrição',
            duracao AS 'Duração (minutos)',
            data_hora AS 'Data e Hora',
            diretor AS 'Diretor',
            elenco AS 'Elenco',
            media_duracao AS 'Média de Duração (minutos)'
        FROM pecas_teatro
        WHERE id_peca = LAST_INSERT_ID();
    ELSE
        SELECT 'A data e hora escolhidas já estão ocupadas. Por favor, escolha outro horário.' AS mensagem;
    END IF;
END $$

DELIMITER ;

INSERT INTO pecas_teatro (nome_peca, descricao, duracao, data_estreia, diretor, elenco)
VALUES 
('Japones e o Coreano',
 'Uma tragédia escrita por Mário Godinho sobre dois jovens amantes cuja morte acaba unindo suas famílias em conflito.', 
 120, 
 '2024-09-15 19:00:00',
 'Marcos Palmeira', 
 'Marilia Soares, Stanley Castro'),
 
  
('O Rei e o Sapo',
 'Uma peça de teatro infantil, que mistura elementos da cultura popular com temas ficticios.',
 110,
 '2024-09-17 18:00:00', 
 'Eder Lippo', 
 'Luiz Augusto, Juliana Velloso'),
 
 
('O Corvo Negro',
 'Uma peça de teatro escrita por Jason Statham que explora as complexidades das relações humanas e as aspirações artísticas.',
 130,
 '2024-09-18 21:00:00',
 'Maicon Phellps',
 'Camargo Correia, Renato Putt');


CALL agendar_pecas(
    'O Vitorioso',
    'Uma peça de teatro escrita por Kelly Mattos sobre a vitoria de uma causa genetica.',
    140,
    '2024-09-15 19:00:00', -- Data e hora já estão ocupadas por 'Japones e o Coreano'
    'Daniel Ramos',
    'Renata Kill, Terry Bogard'
);


CALL agendar_pecas(
    'A Colheita do Ovos de Ouro',
    'Uma peça de teatro de Hugo Thill sobre o um homem próspero.',
    130,
    '2024-09-19 20:00:00', -- Data e horários disponíveis
    'Gustavo Gaiofato',
    'Merly Pereira, Osvaldo Assunção'
);


