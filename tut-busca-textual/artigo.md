# 🔍 Full Text Search no PostgreSQL

Como atividade do componente curricular **Tópicos Especiais em Engenharia de Software**, do curso de Sistemas de Informação, foram implementadas e validadas algumas consultas como prática de busca textual usando apenas um banco de dados PostgreSQL.

---

## Contexto

O banco de dados trabalhado contém **pesquisadores e suas produções acadêmicas**, com duas tabelas principais: `pesquisadores` (com nome e ID Lattes) e `producoes` (com título do artigo, ISSN e ano de publicação).

Desafio: como buscar artigos por palavras-chave de forma inteligente, sem instalar nenhuma ferramenta externa?

---

## Recursos nativos do PostgreSQL

A resposta para a pergunta acima pode ser encontrada explorando o próprio banco utilizado, já que o PostgreSQL possui suporte completo a Full Text Search (FTS), cobrindo todos esses recursos:

- ✅ **Stemming** — buscar "pesquisar" encontra documentos com "pesquisa", "pesquisando", etc.
- ✅ **Suporte a português** — dicionário nativo para o idioma, ignorando stop words como "de", "com", "para"
- ✅ **Remoção de acentos** — com a extensão `unaccent`, "ciência" e "ciencia" viram a mesma coisa
- ✅ **Ranking por relevância** — resultados ordenados por quão relevante é o documento para a busca
- ✅ **Pesos por campo** — o título do artigo vale mais que o nome do autor na hora de rankear
- ✅ **Busca fuzzy** — com a extensão `pg_trgm`, erros de ortografia são tolerados
- ✅ **Indexação com GIN** — performance mesmo com grandes volumes de dados

---

## Implementação 

### Construção do "documento" de busca
Uma combinação dos campos relevantes é convertida para o tipo `tsvector`, que é o formato interno do PostgreSQL para busca textual:
```sql
SELECT to_tsvector(producoes.idioma::regconfig, producoes.nomeartigo) ||
       to_tsvector('simple', pesquisadores.nome) ||
       to_tsvector('simple', producoes.issn) as document
FROM producoes
JOIN pesquisadores ON pesquisadores.pesquisadores_id = producoes.pesquisadores_id;
```

### Atruibuição de pesos
Em seguida, foram atribuídos **pesos diferentes** para cada parte do documento — o título do artigo recebeu peso `A` (mais importante), o nome do pesquisador peso `B`, e o ISSN peso `C`:
```sql
setweight(to_tsvector(producoes.idioma::regconfig, producoes.nomeartigo), 'A') ||
setweight(to_tsvector('simple', pesquisadores.nome), 'B') ||
setweight(to_tsvector('simple', producoes.issn), 'C')
```

### Materialização
Para evitar recalcular esse documento a cada consulta, ele foi armazenado em uma **visão materializada** com um índice GIN por cima — o que torna as buscas muito mais rápidas:
```sql
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

CREATE INDEX idx_fts_search ON search_index USING gin(document);
```

### Busca final
```sql
SELECT producoes_id, nomeartigo, nome, anoartigo
FROM search_index
WHERE document @@ to_tsquery('portuguese', 'palavra_buscada')
ORDER BY ts_rank(document, to_tsquery('portuguese', 'palavra_buscada')) DESC;
```

Uma busca ranqueada por relevância, com suporte completo ao português, rodando direto no banco, sem dependências extra.

---

## Conclusão

Antes de adicionar uma nova ferramenta a stack — como o Elasticsearch, por exemplo — vale a pena verificar o que o banco de dados já usado é capaz de fazer, reaproveitando recursos e evitando exageros que podem afetar a performance geral da ferramenta ou técnica sendo desenvolvida. No caso do PostgreSQL, como mostrado nessa atividade prática, foi possível atingir este resultado consumindo alguns recursos nativos para a FTS. 