CREATE TABLE jogadores (
    id_jogador SERIAL primary key,
    nickname VARCHAR(50) not null unique,
    email VARCHAR(100) not null unique,
    senha VARCHAR(100) NOT NULL,
    status VARCHAR(15) NOT NULL DEFAULT 'ativo',
    CONSTRAINT chk_status_jogador
        CHECK (status IN ('ativo', 'inativo', 'banido'))
);

CREATE TABLE modalidades (
    id_modalidade SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL UNIQUE,
    categoria VARCHAR(30) NOT NULL
);

CREATE TABLE partidas (
    id_partida SERIAL PRIMARY KEY,
    titulo VARCHAR(100) NOT NULL,
    id_jogador INT NOT NULL,
    id_modalidade INT NOT NULL,
    data_agendada TIMESTAMP NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'agendada',
    data_criacao TIMESTAMP,
    CONSTRAINT fk_partida_jogador
        FOREIGN KEY (id_jogador) REFERENCES jogadores(id_jogador),
    CONSTRAINT fk_partida_modalidade
        FOREIGN KEY (id_modalidade) REFERENCES modalidades(id_modalidade),
    CONSTRAINT chk_status_partida
        CHECK (status IN ('agendada', 'em andamento', 'finalizada', 'cancelada'))
);

CREATE TABLE historico_partidas (
	id_historico SERIAL PRIMARY KEY,
	id_partido INT NOT NULL,
	acao VARCHAR(100) NOT NULL,
	data_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (id_partida) REFERENCES partidas(id_partida)
);

BEGIN
    INSERT INTO historico_partidas (id_partido, acao)
    VALUES (NEW.id_partida, 'Partida cadastrada');
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_historico_partida
AFTER INSERT ON partidas
FOR EACHBEGIN
    INSERT INTO historico_partidas (id_partida, acao)
    VALUES (NEW.id_partida, 'Partida cadastrada');
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_historico_partida
AFTER INSERT ON partidas
FOR EACH ROW
EXECUTE FUNCTION fn_registrar_historico();

UPDATE partidas
SET data_criacao = CURRENT_TIMESTAMP
WHERE data_criacao IS NULL;

INSERT INTO historico_partidas (id_partida, acao)
SELECT p.id_partida, 'Partida cadastrada (dado inicial)'
FROM partidas AS p
WHERE NOT EXISTS (
    SELECT 1
    FROM historico_partidas AS h
    WHERE h.id_partida = p.id_partida
);

CREATE OR REPLACE VIEW vw_painel_principal AS
SELECT
    j.nickname,
    p.titulo AS titulo_partida,
    m.categoria,
    p.data_agendada,
    p.status
FROM partidas AS p
INNER JOIN jogadores AS j ON p.id_jogador = j.id_jogador
INNER JOIN modalidades AS m ON p.id_modalidade = m.id_modalidade;

CREATE OR REPLACE VIEW vw_cronograma_partidas AS
SELECT
    p.id_partida,
    p.titulo,
    p.data_agendada,
    p.status,
    (p.data_agendada::date - CURRENT_DATE) AS dias_restantes,
    j.nickname
FROM partidas AS p
INNER JOIN jogadores AS j ON p.id_jogador = j.id_jogador
ORDER BY p.data_agendada ASC;

SELECT * FROM vw_painel_principal;

SELECT * FROM vw_cronograma_partidas;

SELECT * FROM fn_buscar_jogadores('luna');
SELECT * FROM fn_buscar_jogadores('@email.com');

SELECT * FROM historico_partidas;
 ROW
EXECUTE FUNCTION fn_registrar_historico();

UPDATE partidas
SET data_criacao = CURRENT_TIMESTAMP
WHERE data_criacao IS NULL;

INSERT INTO historico_partidas (id_partida, acao)
SELECT p.id_partida, 'Partida cadastrada (dado inicial)'
FROM partidas AS p
WHERE NOT EXISTS (
    SELECT 1
    FROM historico_partidas AS h
    WHERE h.id_partida = p.id_partida
);

CREATE OR REPLACE VIEW vw_painel_principal AS
SELECT
    j.nickname,
    p.titulo AS titulo_partida,
    m.categoria,
    p.data_agendada,
    p.status
FROM partidas AS p
INNER JOIN jogadores AS j ON p.id_jogador = j.id_jogador
INNER JOIN modalidades AS m ON p.id_modalidade = m.id_modalidade;

CREATE OR REPLACE VIEW vw_cronograma_partidas AS
SELECT
    p.id_partida,
    p.titulo,
    p.data_agendada,
    p.status,
    (p.data_agendada::date - CURRENT_DATE) AS dias_restantes,
    j.nickname
FROM partidas AS p
INNER JOIN jogadores AS j ON p.id_jogador = j.id_jogador
ORDER BY p.data_agendada ASC;

SELECT * FROM vw_painel_principal;

SELECT * FROM vw_cronograma_partidas;

SELECT * FROM fn_buscar_jogadores('luna');
SELECT * FROM fn_buscar_jogadores('@email.com');

SELECT * FROM historico_partidas;