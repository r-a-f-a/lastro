-- Regras de cruzamento. Cada vínculo diz a regra, o grau e a evidência. Nome sozinho nunca liga.
-- grau: alta = chave exata (CNPJ, CPF completo); media = cpf6 + nome; possivel = nome + UF + partido, ou nome do autor.
CREATE OR REPLACE TABLE core.vinculo AS
WITH regras AS (

-- doador_fornecedor (alta): CNPJ que doou para a campanha e depois assinou contrato público.
SELECT 'candidatura' AS origem_tipo, r.sq_candidato::VARCHAR AS origem_id, 'empresa' AS destino_tipo, r.cpf_cnpj_doador AS destino_id,
       'doador_fornecedor' AS tipo, 'alta' AS grau, 'doador_fornecedor' AS regra, 'TSE + Portal da Transparência' AS fonte, c.coletado_em,
       'doou R$ ' || r.valor || ' em ' || r.data || '; contrato ' || c.nr_contrato || ' com ' || c.orgao || ' assinado em ' || c.assinado_em AS evidencia
FROM core.receita_campanha r
JOIN core.contrato c ON c.cpf_cnpj_contratado = r.cpf_cnpj_doador
WHERE length(r.cpf_cnpj_doador) = 14 AND c.assinado_em > r.data

UNION ALL
-- empresa_contrato (alta): CNPJ do estabelecimento é o contratado.
SELECT 'empresa', e.cnpj, 'contrato', c.nr_contrato, 'contratada', 'alta', 'empresa_contrato', 'Receita Federal + Portal da Transparência', c.coletado_em,
       'contrato ' || c.nr_contrato || ' com ' || c.orgao || ', R$ ' || coalesce(c.valor_final, c.valor_inicial)
FROM core.estabelecimento e JOIN core.contrato c ON c.cpf_cnpj_contratado = e.cnpj

UNION ALL
-- empresa_sancao (alta): CNPJ sancionado (CEIS, CNEP, CEPIM, TCU).
SELECT 'empresa', s.cpf_cnpj, 'sancao', s.cadastro || ':' || s.id_sancao, 'sancionada', 'alta', 'empresa_sancao', 'Portal da Transparência', s.coletado_em,
       s.cadastro || ': ' || s.categoria || coalesce(' por ' || s.orgao_sancionador, '')
FROM core.sancao s WHERE length(s.cpf_cnpj) = 14
UNION ALL
SELECT 'empresa', t.cpf_cnpj, 'sancao_tcu', t.lista || ':' || t.nr_processo, 'sancionada', 'alta', 'empresa_sancao', 'TCU', t.coletado_em,
       'TCU ' || t.lista || ', processo ' || t.nr_processo
FROM core.sancao_tcu t WHERE t.tipo_registro = 'CNPJ'

UNION ALL
-- pessoa_sancao_cpf (alta): CPF completo do candidato em lista do TCU ou do CEIS/CNEP.
SELECT 'pessoa', p.cpf, 'sancao_tcu', t.lista || ':' || t.nr_processo, 'sancionado', 'alta', 'pessoa_sancao_cpf', 'TSE + TCU', t.coletado_em,
       'TCU ' || t.lista || ', processo ' || t.nr_processo || coalesce(', trânsito em julgado ' || t.transito_em_julgado, '')
FROM core.pessoa p JOIN core.sancao_tcu t ON t.cpf_cnpj = p.cpf
UNION ALL
SELECT 'pessoa', p.cpf, 'sancao', s.cadastro || ':' || s.id_sancao, 'sancionado', 'alta', 'pessoa_sancao_cpf', 'TSE + Portal da Transparência', s.coletado_em,
       s.cadastro || ': ' || s.categoria || coalesce(' por ' || s.orgao_sancionador, '')
FROM core.pessoa p JOIN core.sancao s ON s.cpf_cnpj = p.cpf

UNION ALL
-- pessoa_mandato_cpf (alta): CPF do candidato é o CPF do parlamentar (Câmara, via cota parlamentar).
SELECT 'pessoa', p.cpf, 'mandato', m.casa || ':' || m.id_parlamentar || ':' || m.legislatura, 'mandato', 'alta', 'pessoa_mandato_cpf', 'TSE + Câmara', m.coletado_em,
       m.casa || ' legislatura ' || m.legislatura
FROM core.pessoa p JOIN core.mandato m ON m.cpf = p.cpf

UNION ALL
-- pessoa_socio (media): seis dígitos centrais do CPF mascarado pela Receita + nome normalizado.
SELECT 'pessoa', p.cpf, 'empresa', s.cnpj_basico, 'socio', 'media', 'pessoa_socio', 'TSE + Receita Federal', s.coletado_em,
       coalesce(s.qualificacao, 'sócio') || coalesce(' desde ' || s.entrada_em, '') || '; CPF ' || s.cpf_cnpj || ' e nome iguais'
FROM core.pessoa p JOIN core.socio s ON s.cpf6 = p.cpf6 AND s.nome_norm = p.nome_norm

UNION ALL
-- pessoa_sancao_cpf6 (media): CPF mascarado no CEAF + nome.
SELECT 'pessoa', p.cpf, 'sancao', s.cadastro || ':' || s.id_sancao, 'sancionado', 'media', 'pessoa_sancao_cpf6', 'TSE + Portal da Transparência', s.coletado_em,
       s.cadastro || ': ' || s.categoria || '; CPF mascarado e nome iguais'
FROM core.pessoa p JOIN core.sancao s ON s.cpf_cnpj LIKE '%*%' AND core.cpf6(s.cpf_cnpj) = p.cpf6 AND s.nome_norm = p.nome_norm

UNION ALL
-- pessoa_divida_cpf6 (media): CPF mascarado na dívida ativa da PGFN + nome.
SELECT 'pessoa', p.cpf, 'divida_ativa', d.nr_inscricao, 'divida_ativa', 'media', 'pessoa_divida_cpf6', 'TSE + PGFN', d.coletado_em,
       d.natureza || ', R$ ' || d.valor || ', ' || d.situacao || '; CPF mascarado e nome iguais'
FROM core.pessoa p JOIN core.divida_ativa d ON d.tipo_pessoa = 'Pessoa física' AND core.cpf6(d.cpf_cnpj) = p.cpf6 AND d.nome_norm = p.nome_norm

UNION ALL
-- pessoa_mandato_nome (possivel): eleito para a casa, mesmo nome, UF e partido, quando o mandato não tem CPF (Senado).
SELECT 'candidatura', c.sq_candidato::VARCHAR, 'mandato', m.casa || ':' || m.id_parlamentar || ':' || m.legislatura, 'mandato', 'possivel', 'pessoa_mandato_nome', 'TSE + ' || m.casa, m.coletado_em,
       'nome, UF e partido iguais; confira a fonte'
FROM core.candidatura c
JOIN core.mandato m ON m.cpf IS NULL AND m.nome_norm = c.nome_norm AND m.uf = c.uf AND m.partido = c.partido
WHERE c.resultado LIKE 'ELEITO%' AND ((c.cargo = 'SENADOR' AND m.casa = 'senado') OR (c.cargo = 'DEPUTADO FEDERAL' AND m.casa = 'camara'))

UNION ALL
-- autor_emenda (possivel): nome parlamentar do autor da emenda.
SELECT 'mandato', m.casa || ':' || m.id_parlamentar || ':' || m.legislatura, 'emenda', e.id_emenda, 'autor_emenda', 'possivel', 'autor_emenda', 'Portal da Transparência + ' || m.casa, e.coletado_em,
       'autor "' || e.autor || '" igual ao nome parlamentar; R$ ' || coalesce(e.valor_pago, 0) || ' pagos'
FROM core.emenda e JOIN core.mandato m ON core.nome_norm(m.nome) = e.autor_norm
)
SELECT row_number() OVER () AS vinculo_id, * FROM regras;
