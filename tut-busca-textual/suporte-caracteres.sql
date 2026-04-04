CREATE EXTENSION unaccent;

SELECT unaccent('èéêë'); --testando a remoção de acentos

CREATE TEXT SEARCH CONFIGURATION pt ( COPY = portuguese );

--criando a configuração de busca textual para portuges sem acentos
ALTER TEXT SEARCH CONFIGURATION pt ALTER MAPPING
FOR hword, hword_part, word WITH unaccent, portuguese_stem;

--comparando resultado com e sem a nova configuração
SELECT to_tsvector('portuguese', 'pesquisa científica brasileira');
SELECT to_tsvector('pt', 'pesquisa científica brasileira');

-- a configuração pt deve funcionar com o equivalente a aplicar unaccent manualmente
SELECT to_tsvector('portuguese', unaccent('pesquisa científica brasileira'));


SELECT to_tsvector('pt', 'Óptica') @@ to_tsquery('optica') as result;