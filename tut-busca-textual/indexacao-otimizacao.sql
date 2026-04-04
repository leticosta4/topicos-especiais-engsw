-- indice  GIN em produces para acelerar as buscas textuais
CREATE INDEX idx_fts_producoes ON producoes
USING gin(setweight(to_tsvector(idioma::regconfig, nomeartigo), 'A'));


--visão materializada com o documento completo ja pre-computado
CREATE MATERIALIZED VIEW search_index AS
SELECT producoes.producoes_id,
       producoes.nomeartigo,
       producoes.anoartigo,
       pesquisadores.nome,
       setweight(to_tsvector(producoes.idioma::regconfig, producoes.nomeartigo), 'A') ||
       setweight(to_tsvector('simple', pesquisadores.nome), 'B') ||
       setweight(to_tsvector('simple', producoes.issn), 'C') as document
FROM producoes
JOIN pesquisadores ON pesquisadores.pesquisadores_id = producoes.pesquisadores_id;


-- indice na versao materializada
CREATE INDEX idx_fts_search ON search_index USING gin(document);


--buscas diretamente na visão materializada (consulta muito mais simples e rápida)
SELECT producoes_id, nomeartigo, nome, anoartigo
FROM search_index
WHERE document @@ to_tsquery('portuguese', 'dengue')
ORDER BY ts_rank(document, to_tsquery('portuguese', 'dengue')) DESC;


REFRESH MATERIALIZED VIEW search_index;