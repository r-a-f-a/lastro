# Lastro — Brand Guidelines v1.0

> Última atualização: 2026-10-14
> Status: Draft
> Fonte da ideia: `Catálogo de Dados Públicos — Plataforma de Transparência de Candidatos.md`

## Quick Reference

| Element | Value |
|---------|-------|
| Nome | Lastro |
| Tagline | Mostra, não julga. |
| Descritor | Fichas públicas de candidatos, cruzadas a partir de dados abertos oficiais. |
| Primary Color | #1F2A44 |
| Secondary Color | #0E7C7B |
| Accent Color | #B7791F |
| Primary Font | IBM Plex Sans |
| Heading Font | IBM Plex Serif |
| Voice | Factual, Sóbria, Rastreável, Acessível, Imparcial |

---

## 0. Nome e princípio da marca

**Lastro** é o que dá sustentação a uma afirmação. Em finanças, é a garantia por trás de um título; em linguagem comum, "ter lastro" é ter base. É exatamente a promessa do produto: nenhuma informação aparece sem fonte, data e grau de confiança.

Por que funciona:
- Palavra portuguesa, curta, sem conotação partidária e sem eco de "Ficha Limpa" (termo jurídico carregado).
- Descreve o método (ligação com base) e não um veredito (ranking, nota, limpo/sujo).
- Funciona como substantivo e como adjetivo informal: "esse dado tem lastro".

Ponto de atenção: o diretório do projeto chama-se `governai`. Um nome com "AI" sugere inferência automática, que é justamente o que o produto promete não fazer, e atrai questionamento em período eleitoral. Recomendação: manter "governai" como nome interno do repositório e usar Lastro como marca pública.

Alternativas, se Lastro não estiver disponível como domínio ou marca registrada: **Procedência**, **Vínculo Público**, **Ficha Aberta**.

### Princípio único

> Mostra, não julga.

Tudo na marca deriva daqui: a paleta sem cores de partido, a tipografia de documento, a voz que descreve em vez de qualificar, os badges de confiança no lugar de notas.

---

## 1. Color Palette

A paleta foge das cores que o eleitorado brasileiro associa a campos políticos: nada de vermelho dominante, nada de verde e amarelo, nada de azul vibrante. Base de tinta e papel, com um teal institucional e um âmbar de carimbo.

### Primary Colors

| Name | Hex | RGB | Usage |
|------|-----|-----|-------|
| Tinta | #1F2A44 | rgb(31,42,68) | Títulos, texto principal, cabeçalho, botão primário |
| Tinta Dark | #141C30 | rgb(20,28,48) | Hover do primário, rodapé |
| Tinta Light | #E8EBF2 | rgb(232,235,242) | Fundo de seção destacada, hover de linha de tabela |

### Secondary Colors

| Name | Hex | RGB | Usage |
|------|-----|-----|-------|
| Carimbo | #0E7C7B | rgb(14,124,123) | Links, ícones de fonte, foco, ações secundárias |
| Carimbo Dark | #0A5C5B | rgb(10,92,91) | Hover de links |
| Carimbo Light | #E0F2F1 | rgb(224,242,241) | Fundo de chip de fonte |

### Accent Colors

| Name | Hex | RGB | Usage |
|------|-----|-----|-------|
| Lacre | #B7791F | rgb(183,121,31) | Destaque editorial, marcador de "verifique", nunca para texto pequeno |
| Lacre Dark | #92400E | rgb(146,64,14) | Texto sobre fundo Lacre Light |
| Lacre Light | #FEF3C7 | rgb(254,243,199) | Fundo de badge de confiança média |

### Neutral Palette

| Name | Hex | RGB | Usage |
|------|-----|-----|-------|
| Papel | #FBFAF7 | rgb(251,250,247) | Fundo de página (branco levemente quente, como papel) |
| Branco | #FFFFFF | rgb(255,255,255) | Cards, fichas |
| Superfície | #F3F2EE | rgb(243,242,238) | Cabeçalho de tabela, áreas secundárias |
| Borda | #D9D7D0 | rgb(217,215,208) | Divisores, bordas de card |
| Texto Secundário | #5B6270 | rgb(91,98,112) | Legendas, datas de coleta, metadados |
| Texto Primário | #1F2A44 | rgb(31,42,68) | Corpo e títulos (igual a Tinta) |

### Semantic Colors (UI)

Só para estados da interface. Nunca para qualificar um candidato.

| State | Hex | Usage |
|-------|-----|-------|
| Success | #15803D | Ação concluída (ex.: correção enviada) |
| Warning | #B45309 | Fonte desatualizada, endpoint instável |
| Error | #B91C1C | Erro de sistema, campo inválido |
| Info | #0E7C7B | Avisos informativos |

### Confidence Scale (dado, não UI)

É o componente mais importante da identidade. Toda ligação feita por chave exata, CPF mascarado ou nome aparece com um destes badges.

| Nível | Fundo | Texto | Borda | Rótulo |
|-------|-------|-------|-------|--------|
| Alta | #DCFCE7 | #14532D | sólida | "Confiança alta · chave exata" |
| Média | #FEF3C7 | #78350F | sólida | "Confiança média · CPF parcial + nome" |
| Possível | #F3F2EE | #374151 | tracejada | "Possível vínculo · só por nome" |

Regras:
- Vermelho nunca indica confiança baixa nem "tem processo". Vermelho é só erro de sistema.
- Status jurídico (em andamento, transitado em julgado, absolvido, arquivado) usa chips neutros em Superfície + Texto Primário. A diferenciação é o texto, não a cor.
- Ausência de registro não é verde. Mostra-se em Texto Secundário: "Nenhum registro nas fontes consultadas em DD/MM/AAAA".

### Accessibility

| Par | Contraste | Nível |
|-----|-----------|-------|
| Tinta sobre Papel | 13.7:1 | AAA |
| Carimbo sobre Branco | 5.0:1 | AA |
| Texto Secundário sobre Papel | 5.9:1 | AA |
| Lacre Dark sobre Lacre Light | 6.4:1 | AA |
| Badges de confiança (texto sobre fundo) | 8.1:1 a 9.2:1 | AAA |
| Lacre (#B7791F) sobre Branco | 3.6:1 | só para texto grande ou ícones |

Todo elemento interativo cumpre WCAG 2.1 AA. Badges de confiança nunca dependem só de cor: carregam texto e, no caso de "Possível", borda tracejada.

### Proibido

- Combinações verde + amarelo.
- Vermelho como cor de marca ou de destaque.
- Gradientes de cor de partido (vermelho→azul etc.).

---

## 2. Typography

Uma só família para parecer um documento oficial, não um dashboard de startup. IBM Plex é open source (OFL), tem serifa, sans e mono desenhadas juntas, e numerais tabulares para CPF, CNPJ, valores e datas.

### Font Stack

```css
--font-heading: 'IBM Plex Serif', Georgia, 'Times New Roman', serif;
--font-body: 'IBM Plex Sans', system-ui, -apple-system, sans-serif;
--font-mono: 'IBM Plex Mono', 'JetBrains Mono', monospace;
```

### Type Scale

| Element | Size (Desktop) | Size (Mobile) | Weight | Line Height | Família |
|---------|----------------|---------------|--------|-------------|---------|
| H1 (nome do candidato) | 40px | 30px | 600 | 1.15 | Serif |
| H2 (eixo da ficha) | 28px | 24px | 600 | 1.25 | Serif |
| H3 (fonte / bloco) | 20px | 18px | 600 | 1.3 | Sans |
| Body | 16px | 16px | 400 | 1.55 | Sans |
| Body Large (lead) | 18px | 17px | 400 | 1.6 | Sans |
| Small (metadados) | 14px | 14px | 400 | 1.5 | Sans |
| Caption (data de coleta, fonte) | 12px | 12px | 500 | 1.4 | Sans, caixa alta, tracking 0.04em |
| Identificadores (CPF, CNPJ, nº CNJ, valores) | 14px | 14px | 400 | 1.5 | Mono, `font-variant-numeric: tabular-nums` |

### Regras

- Números em tabela sempre em Mono com alinhamento à direita.
- Serifa só em H1 e H2. O resto é Sans para leitura densa.
- Sem itálico decorativo. Itálico só para títulos de leis e nomes de bases ("Lei 14.133/2021").
- Sem caixa alta em títulos; caixa alta só em captions curtos.

### Font Loading

```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Serif:wght@600&family=IBM+Plex+Sans:wght@400;500;600&family=IBM+Plex+Mono:wght@400&display=swap" rel="stylesheet">
```

---

## 3. Logo

### Conceito

O símbolo é um **vínculo com lastro**: dois pontos ligados por um traço, sendo o ponto inferior preenchido (o dado verificado, a fonte) e o superior vazado (a afirmação que ele sustenta). Lido como letra, forma um "l" minúsculo com base. Lido como diagrama, é a menor aresta possível de um grafo de relações.

```
   ○        ← afirmação (vazado)
   │        ← vínculo
   ●        ← fonte (preenchido)
```

Wordmark: "lastro" em IBM Plex Serif 600, minúsculas, tracking -0.01em, cor Tinta. Em versão mono, símbolo e wordmark na mesma cor.

### Variants

| Variant | File | Use Case |
|---------|------|----------|
| Full Horizontal | logo-full-horizontal.svg | Cabeçalho do site, documentos, assinatura de e-mail |
| Stacked | logo-stacked.svg | Compartilhamento social quadrado, capa de relatório |
| Icon Only | logo-icon.svg | Favicon, app, avatar de redes |
| Monochrome | logo-mono.svg | Impressão em uma cor, marcas d'água em PDF exportado |

### Cores do logo

| Contexto | Símbolo | Wordmark |
|----------|---------|----------|
| Sobre Papel/Branco | ponto cheio Carimbo, traço e ponto vazado Tinta | Tinta |
| Sobre Tinta | ponto cheio Carimbo Light, resto Branco | Branco |
| Mono | tudo Tinta ou tudo Branco | idem |

### Clear Space

Mínimo: a altura do símbolo em todos os lados.

### Minimum Size

| Context | Minimum Width |
|---------|---------------|
| Digital - Full Logo | 96px |
| Digital - Icon | 20px |
| Print - Full Logo | 30mm |
| Print - Icon | 8mm |

### Don'ts

- Não rotacionar, inclinar ou distorcer.
- Não usar cores fora da paleta; nunca vermelho, verde ou amarelo.
- Não aplicar sombra, brilho ou gradiente.
- Não colocar o logo ao lado de brasão, bandeira ou logo de partido: a marca não é oficial nem partidária.
- Não usar o símbolo como badge de confiança dentro da ficha; são elementos distintos.

---

## 4. Voice & Tone

### Brand Personality

| Trait | Description |
|-------|-------------|
| **Factual** | Descreve o que a fonte registra. Verbo no indicativo, sujeito explícito. |
| **Sóbria** | Sem adjetivos de intensidade, sem exclamação, sem urgência. |
| **Rastreável** | Toda afirmação carrega fonte e data. Sem fonte, não publica. |
| **Acessível** | Explica a sigla na primeira vez (CEAP, AIJE, PNCP). Linguagem de cidadão, não de tribunal. |
| **Imparcial** | Trata todo candidato com a mesma estrutura de ficha. O leitor conclui; a plataforma não. |

### Voice Chart

| Trait | We Are | We Are Not |
|-------|--------|------------|
| Factual | "A Receita Federal registra Fulano como sócio da empresa X desde 2019." | "Fulano tem uma empresa suspeita." |
| Sóbria | "3 contratos com a prefeitura, R$ 1,2 mi pagos." | "Contratos milionários explodem!" |
| Rastreável | "Fonte: Portal da Transparência, consultado em 12/10/2026." | "Segundo dados oficiais." |
| Acessível | "AIJE é a ação que investiga abuso de poder na eleição." | "Responde a AIJE nos termos do art. 22 da LC 64/90." |
| Imparcial | "Possível vínculo. Confira a fonte." | "Mais um da velha política." |

### Tone by Context

| Context | Tone | Example |
|---------|------|---------|
| Ficha do candidato | Neutro, telegráfico, com status e data | "Processo nº 0001234-56.2024.6.26.0000 · Em andamento · TRE-SP · consultado em 10/10/2026" |
| Vínculo com confiança média ou baixa | Explícito sobre o limite | "Possível vínculo: nome e seis dígitos centrais do CPF coincidem. Pode ser homônimo. Confira a fonte." |
| Ausência de registro | Preciso sobre o que foi consultado | "Nenhum registro no CEIS, CNEP e TCU em 10/10/2026." Nunca "ficha limpa". |
| Fonte fora do ar | Transparente sobre a falha | "O portal do TSE não respondeu. Mostrando dados coletados em 03/10/2026." |
| Marketing / landing | Direto, benefício claro, sem promessa de veredito | "Quem é, o que fez, que dinheiro público circula ao redor. Com fonte." |
| Contestação do candidato | Cordial, procedimental | "Recebemos sua solicitação de correção. Respondemos em até 10 dias úteis com a fonte revisada." |
| Período eleitoral | Sem comparativos ordenados | Fichas lado a lado com a mesma estrutura; nunca "melhor", "pior", "nota", "top 10". |
| Documentação / API | Instrucional, curto | "Rode a ingestão do eixo 1 antes do eixo 3; o cruzamento por CNPJ depende dele." |

### Prohibited Terms

| Avoid | Reason |
|-------|--------|
| suspeito, laranja, esquema, fantasma | Inferência de culpa; risco LGPD e de difamação |
| corrupto, ficha suja, bandido | Juízo de valor |
| ficha limpa (como adjetivo) | Termo jurídico específico; ausência de registro não é atestado |
| ranking, nota, score do candidato, top 10 | Convida questionamento no TSE; o score é do vínculo, não da pessoa |
| melhor/pior candidato | Juízo de valor |
| descobrimos, revelamos, exclusivo | Linguagem de furo; os dados são públicos |
| inteligência artificial detectou | Sugere inferência automática sem fonte |
| alertas, red flag, suspeição | Qualifica; prefira "critério de atenção" só em texto técnico interno |
| 100% confiável, dados oficiais garantidos | As fontes mudam; a confiança é por vínculo |

### Required Patterns

| Situação | Padrão obrigatório |
|----------|--------------------|
| Qualquer dado exibido | `Fonte: [órgão/base] · consultado em DD/MM/AAAA` |
| Vínculo por CPF mascarado ou nome | Badge de confiança + frase "Confira a fonte" |
| Processo ou sanção | Status visível: em andamento / transitado em julgado / absolvido / arquivado |
| Bens declarados | "Valor autodeclarado em [ano], sem atualização de mercado" |
| Terceiros (sócios, doadores não candidatos) | CPF sempre mascarado; exibir só o necessário ao vínculo |
| Rodapé de toda ficha | Link "Solicitar correção" |

### Sample Rewrites

| Before | After |
|--------|-------|
| "Candidato tem empresa que recebeu milhões do governo." | "A Receita Federal registra o candidato como sócio da empresa X (desde 2019). A empresa tem 4 contratos no PNCP com a União, R$ 2,3 mi pagos. Fonte: Receita Federal e PNCP, consultados em 10/10/2026." |
| "Doador suspeito também é fornecedor." | "A empresa Y doou R$ 50 mil à campanha (TSE, 2022) e aparece como fornecedora de 2 contratos da Câmara Municipal em 2023 (PNCP). Confiança alta: CNPJ exato." |
| "Fulano está limpo." | "Nenhum registro em CEIS, CNEP, TCU e PGFN para este CPF em 10/10/2026." |

---

## 5. Imagery Guidelines

A marca não usa rosto de político, bandeira, brasão, martelo de juiz ou algema. O assunto visual é o dado e a sua ligação, não a pessoa.

### Photography Style

- **Assuntos:** espaços públicos vazios ou em uso comum (plenário sem sessão, praça, fachada de prefeitura, arquivo público), mãos folheando documentos, telas com tabelas.
- **Iluminação:** natural, difusa, sem dramatização.
- **Tratamento:** dessaturação leve, temperatura neutra para quente; nunca filtro vermelho ou azul.
- **Composição:** limpa, com espaço negativo à esquerda ou acima para texto.

### Illustrations

- Estilo: diagramas de grafo com nós e arestas, linha fina, flat, sem gradiente.
- Cores: Tinta para nós e arestas; Carimbo para o nó de origem (fonte); Lacre para o nó em destaque.
- Arestas de confiança média/baixa: tracejadas, exatamente como na UI.
- Peso de linha: 1.5px. Nós: círculos de 8px a 16px.

### Icons

- Estilo: outlined, grade de 24px, traço 1.5px, cantos 2px.
- Biblioteca base: Lucide (open source, consistente com o traço).
- Ícones semânticos fixos: documento (fonte), elo (vínculo), relógio (data de coleta), balança (processo), prédio (empresa/órgão), pin (território).

### Visual Don'ts

| Avoid | Reason |
|-------|--------|
| Foto de candidato na ficha como hero | Personaliza o julgamento; usar só a foto oficial do TSE em tamanho de avatar |
| Bandeira, verde e amarelo, brasão | Sugere oficialidade ou nacionalismo |
| Martelo, algema, lupa sobre dinheiro | Iconografia de culpa |
| Gráficos de barras comparando candidatos por "nota" | Ranking implícito |
| Robô, cérebro, "IA" visual | Sugere inferência automática |

---

## 6. Design Components

### Buttons

| Type | Background | Text | Border | Border Radius |
|------|------------|------|--------|---------------|
| Primary | #1F2A44 | #FFFFFF | none | 6px |
| Secondary | Transparent | #0E7C7B | 1px #0E7C7B | 6px |
| Tertiary | Transparent | #5B6270 | none | 6px |

### Componentes próprios da marca

| Componente | Spec |
|------------|------|
| Chip de fonte | Fundo Carimbo Light, texto Carimbo Dark 12px, ícone documento, link para a fonte original |
| Badge de confiança | Ver tabela "Confidence Scale"; altura 22px, radius 4px, texto 12px 500 |
| Chip de status jurídico | Fundo Superfície, texto Tinta, borda Borda; 12px, caixa alta |
| Carimbo de data | Mono 12px, Texto Secundário: `consultado em 10/10/2026` |
| Ficha | Card Branco, borda 1px Borda, radius 8px, padding 24px; cabeçalho com nome (H1), cargo, partido, UF e sequencial TSE em Mono |
| Linha de vínculo | Origem → aresta → destino, com badge de confiança sobre a aresta |

### Spacing Scale

| Token | Value | Usage |
|-------|-------|-------|
| xs | 4px | Entre badge e texto |
| sm | 8px | Dentro de chips |
| md | 16px | Padding padrão |
| lg | 24px | Padding de ficha |
| xl | 32px | Entre blocos de um eixo |
| 2xl | 48px | Entre eixos |

### Border Radius

| Element | Radius |
|---------|--------|
| Buttons | 6px |
| Cards / Fichas | 8px |
| Inputs | 6px |
| Modals | 12px |
| Chips / Badges | 4px |

Raios pequenos de propósito: o produto deve lembrar documento, não app de consumo.

---

## 7. Messaging Framework

### Mission

Ligamos dados abertos oficiais em fichas por candidato para que qualquer pessoa verifique, pela fonte, quem é, o que fez e que dinheiro público circula ao seu redor.

### Vision

Um país em que votar informado custa cinco minutos, não um pedido de Lei de Acesso à Informação.

### Value Proposition

Para eleitores, jornalistas e organizações cívicas que precisam entender um candidato além da propaganda, Lastro é um catálogo público de fichas de candidatos que cruza TSE, Receita Federal, Câmara, Senado, Portal da Transparência, PNCP, TCU e tribunais em uma só página por pessoa. Diferente de rankings e sites de notas, não damos veredito: mostramos o vínculo, o grau de confiança e a fonte, e oferecemos canal de correção.

### Positioning Statement

Lastro é a ficha pública de candidatos para quem quer checar, e não ser convencido, porque toda linha da ficha leva à fonte oficial com data de consulta e grau de confiança.

### Primary Message

Quem é, o que fez, que dinheiro público circula ao redor. Com fonte.

### Supporting Messages

| Message | Audience Need | Proof Point |
|---------|---------------|-------------|
| Tudo vem de dados abertos oficiais, nada de vazamento ou opinião. | Confiar sem precisar confiar em nós | Mais de 30 fontes oficiais em 5 eixos (TSE, Receita, Câmara, Senado, Portal da Transparência, PNCP, TCU, PGFN, CNJ, SICONFI, IBGE) |
| O cruzamento é o diferencial: candidato → empresa → contrato público → doação de campanha. | Ver o que bases isoladas escondem | Chaves CPF, CNPJ, sequencial TSE, id Câmara/Senado e código IBGE ligadas em um grafo |
| Cada vínculo diz o quanto confiar nele. | Não ser enganado por homônimo | Score obrigatório: alta (chave exata), média (CPF parcial + nome), possível (só nome) |
| Mostramos status, não culpa. | Justiça com quem é citado | Status processual sempre visível; termos de julgamento proibidos; canal de correção em toda ficha |
| Fichas comparáveis, não notas. | Comparar sem ranking | Mesma estrutura de ficha para qualquer candidato, de vereador a presidente |

### Elevator Pitches

**10 segundos:**
Lastro é a ficha pública de qualquer candidato: perfil, mandato, empresas, contratos e sanções, cruzados de dados abertos oficiais, com fonte em cada linha.

**30 segundos:**
Tudo o que importa sobre um candidato já é público, mas está espalhado em dezenas de portais que não conversam entre si. Lastro ingere essas bases e liga as pontas por CPF, CNPJ e sequencial do TSE: o candidato, as empresas de que é sócio, os contratos que elas têm com o governo, quem doou para a campanha e se virou fornecedor depois. Nada de nota ou ranking: cada vínculo mostra a fonte, a data e o grau de confiança.

**60 segundos:**
Pitch de 30 segundos + "Começamos pelos deputados e senadores, onde quatro passos de ingestão já fecham o ciclo doador → fornecedor → contrato, o caso de maior impacto público. A camada de integridade vem do TCU, CGU e PGFN; a de território, do SICONFI e IBGE, para prefeitos e governadores. Reaproveitamos Base dos Dados, Querido Diário e Serenata de Amor para não refazer a limpeza que a comunidade cívica já fez. E tratamos LGPD como produto, não como rodapé: CPF de terceiros mascarado, finalidade documentada e correção em dez dias úteis."

### Message by Audience

| Audience | Pain Point | Key Message | CTA |
|----------|------------|-------------|-----|
| Eleitor | Só conhece o candidato pela propaganda | Em cinco minutos, a ficha completa com fonte | "Buscar candidato" |
| Jornalista de dados | Gasta dias cruzando CSV do TSE com a Receita | O cruzamento já está feito, com chave e confiança; exporte e cite a fonte | "Explorar o grafo" / "Baixar dados" |
| ONG / pesquisador | Precisa de método auditável | Pipeline aberto, data lake com arquivo bruto e data de coleta em todo registro | "Ver metodologia" |
| Candidato / assessoria | Teme erro ou homônimo | Canal de correção com prazo e resposta com fonte revisada | "Solicitar correção" |
| Imprensa institucional / TSE | Preocupação com ranking em período eleitoral | Fichas comparáveis, nunca notas; linguagem sem juízo de valor | "Ler política editorial" |

---

## 8. AI Image Generation

### Base Prompt Template

Sempre prefixar:

```
Editorial civic-data illustration, flat vector, thin 1.5px lines, no gradients. Palette: deep ink navy #1F2A44, teal #0E7C7B, amber #B7791F, warm paper background #FBFAF7. Subject: abstract graph of nodes and edges linking documents, buildings and a person silhouette (no face). Calm, sober, archival mood. No flags, no red, no green-yellow, no gavel, no handcuffs, no robots, no politicians' faces.
```

### Style Keywords

| Category | Keywords |
|----------|----------|
| **Lighting** | flat, even, paper-like |
| **Mood** | sober, archival, trustworthy, calm |
| **Composition** | generous negative space, left-aligned subject, grid |
| **Treatment** | low saturation, warm neutral, high legibility |
| **Aesthetic** | civic infrastructure, public document, data journalism |

### Visual Don'ts

| Avoid | Reason |
|-------|--------|
| Rostos de políticos reais | Personaliza e expõe |
| Vermelho, verde e amarelo | Leitura partidária |
| Lupa sobre dinheiro, martelo, algema | Iconografia de culpa |
| Robô, cérebro, circuito | Sugere inferência automática |
| Gráficos de ranking | Nota implícita |

### Example Prompts

**Hero Banner:**
```
[Base prompt] Wide banner: on the left, a single filled teal node at the base connected upward by a thin navy line to a hollow node, growing into a small graph of documents (TSE, CNPJ, contracts) on the right. Lots of empty paper-colored space top-left for a headline.
```

**Social Media Post:**
```
[Base prompt] Square: a candidate card (blank name field) with three small badges below it, one solid green-tinted, one amber-tinted, one dashed gray, and a small "source" chip with a document icon. Centered, minimal.
```

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-10-14 | Guia inicial derivado do catálogo de dados públicos |
