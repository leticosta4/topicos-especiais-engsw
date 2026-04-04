CREATE EXTENSION pg_trgm;


--testando a similaridade entre palavras
SELECT similarity('pesquisa', 'pesquiza');
SELECT similarity('pesquisa', 'pesquise');
SELECT similarity('pesquisa', 'unrelated');


-- visão materializada com todos os lexemas únicos dos documentos
CREATE MATERIALIZED VIEW unique_lexeme AS
SELECT word FROM ts_stat(
'SELECT to_tsvector(''simple'', producoes.nomeartigo) ||
        to_tsvector(''simple'', pesquisadores.nome) ||
        to_tsvector(''simple'', producoes.issn)
FROM producoes
JOIN pesquisadores ON pesquisadores.pesquisadores_id = producoes.pesquisadores_id');


-- índice de trigram na visão de lexemas únicos
CREATE INDEX words_idx ON unique_lexeme USING gin(word gin_trgm_ops);

--atualizar a visao de lexemas
REFRESH MATERIALIZED VIEW unique_lexeme;


--buscando o lexema mais próximo de uma palavra com erro de ortografia
SELECT word
FROM unique_lexeme
WHERE similarity(word, 'pesquiza') > 0.5
ORDER BY word <-> 'pesquiza'
LIMIT 1;