-- texto simples
SELECT producoes.nomeartigo || ' ' ||
       pesquisadores.nome || ' ' ||
       producoes.issn as document
FROM producoes
JOIN pesquisadores ON pesquisadores.pesquisadores_id = producoes.pesquisadores_id;

--convertendo para tsvector > busca textual simples
SELECT to_tsvector(producoes.nomeartigo) ||
       to_tsvector(pesquisadores.nome) ||
       to_tsvector(producoes.issn) as document
FROM producoes
JOIN pesquisadores ON pesquisadores.pesquisadores_id = producoes.pesquisadores_id;

--normalização do texto com to_tsvector
SELECT to_tsvector('Try not to become a man of success, but rather try to become a man of value');