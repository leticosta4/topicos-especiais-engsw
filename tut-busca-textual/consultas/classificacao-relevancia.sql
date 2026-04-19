--busca com pesos diferentes por área do documento e ordene por relevância

SELECT prod_id, nome_artigo
FROM (
    SELECT producoes.producoes_id as prod_id,
           producoes.nomeartigo as nome_artigo,
           setweight(to_tsvector(producoes.idioma::regconfig, producoes.nomeartigo), 'A') ||
           setweight(to_tsvector('simple', pesquisadores.nome), 'B') ||
           setweight(to_tsvector('simple', producoes.issn), 'C') as document
    FROM producoes
    JOIN pesquisadores ON pesquisadores.pesquisadores_id = producoes.pesquisadores_id
) p_search
WHERE p_search.document @@ to_tsquery('portuguese', 'dengue')
ORDER BY ts_rank(p_search.document, to_tsquery('portuguese', 'dengue')) DESC;


--calculo da relevancia pelo ts_rank com alguns exemplos simples

SELECT ts_rank(to_tsvector('This is an example of document'),
               to_tsquery('example | document')) as relevancy;

SELECT ts_rank(to_tsvector('This is an example of document'),
               to_tsquery('example')) as relevancy;

SELECT ts_rank(to_tsvector('This is an example of document'),
               to_tsquery('example | unkown')) as relevancy;

SELECT ts_rank(to_tsvector('This is an example of document'),
               to_tsquery('example & document')) as relevancy;

SELECT ts_rank(to_tsvector('This is an example of document'),
               to_tsquery('example & unknown')) as relevancy;