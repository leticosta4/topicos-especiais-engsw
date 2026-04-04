-- diferenca entre os idiomas
SELECT to_tsvector('english', 'We are running');
SELECT to_tsvector('portuguese', 'Nós estamos correndo');

ALTER TABLE producoes ADD idioma text NOT NULL DEFAULT('portugues');


--reconstruindo o documento usando a coluna de idioma (com ::regconfig)
SELECT to_tsvector(producoes.idioma::regconfig, producoes.nomeartigo) ||
       to_tsvector('simple', pesquisadores.nome) ||
       to_tsvector('simple', producoes.issn) as document
FROM producoes
JOIN pesquisadores ON pesquisadores.pesquisadores_id = producoes.pesquisadores_id;

--Veja o dicionário simple (não ignora stop words e não aplica stemming — ideal para nomes e ISSNs):
SELECT to_tsvector('simple', 'We are running');