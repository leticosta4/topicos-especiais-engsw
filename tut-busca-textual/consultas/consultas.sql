--teste do operador @@ pra ver se o texto tem certa palavra
SELECT to_tsvector('If you can dream it, you can do it') @@ 'dream';


--comparando ::tsquery com to_tsquery() para entender a normalização
SELECT 'impossible'::tsquery, to_tsquery('impossible');
SELECT 'dream'::tsquery, to_tsquery('dream');


-- to_tsquery() para busca correta
SELECT to_tsvector('It''s kind of fun to do the impossible') @@ to_tsquery('impossible');


-- uso de operadores booleanos com o to_tsquery()
SELECT to_tsvector('If the facts don''t fit the theory, change the facts') @@ to_tsquery('! fact'); -- nao
SELECT to_tsvector('If the facts don''t fit the theory, change the facts') @@ to_tsquery('theory & !fact');  -- e
SELECT to_tsvector('If the facts don''t fit the theory, change the facts.') @@ to_tsquery('fiction | theory'); -- ou
SELECT to_tsvector('If the facts don''t fit the theory, change the facts.') @@ to_tsquery('theo:*');  -- *


--busca nas tabelas
SELECT prod_id, nome_artigo
FROM (
    SELECT producoes.producoes_id as prod_id,
           producoes.nomeartigo as nome_artigo,
           to_tsvector(producoes.nomeartigo) ||
           to_tsvector(pesquisadores.nome) ||
           to_tsvector(producoes.issn) as document
    FROM producoes
    JOIN pesquisadores ON pesquisadores.pesquisadores_id = producoes.pesquisadores_id
) p_search
WHERE p_search.document @@ to_tsquery('ciência');