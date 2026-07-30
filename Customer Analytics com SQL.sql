/*
--------------------------------------
 PROJETO
 Customer Analytics com SQ
--------------------------------------
*/

-- Análise Exploratória dos Dados (EDA)
/*
 ETAPA 0 — Conhecendo a base
Pergunta 1
Quantos registros existem na base?
*/
SELECT COUNT(*)
FROM vendas;
-- ------------------------
/* 
Pergunta 2
Quantos clientes diferentes existem?
*/
SELECT 
COUNT(distinct customer_id)
FROM vendas;
-- -------------------------
/*
Pergunta 3
Quantos produtos diferentes existem?
*/
SELECT 
COUNT(distinct stock_code)
FROM vendas;
-- ---------------------------
/*
Pergunta 4
Quantos países existem?
*/
SELECT 
COUNT(distinct country)
FROM vendas;
-- ------------------------------ 
/*
Pergunta 5
Qual é a primeira compra registrada?
*/
SELECT 
invoice_date
FROM vendas
ORDER BY invoice_date ASC
LIMIT 1;
-- -------------------------------
/*
Pergunta 6
Qual é a última compra registrada?
*/
SELECT 
invoice_date
FROM vendas
ORDER BY invoice_date DESC
LIMIT 1;
-- ------------------------------
/*
Pergunta 7
Existem clientes sem identificação?
*/
SELECT 
COUNT(*) AS clientes_sem_id
FROM vendas
WHERE customer_id IS NULL OR customer_id = '';
-- -----------------------------------
/*
Pergunta 8
Existem preços iguais a zero?
*/
SELECT 
COUNT(*)
FROM vendas
WHERE unit_price = 0;
-- --------------------------------------
/*
Pergunta 9
Existem quantidades negativas?
*/
SELECT
COUNT(*) as quantidade_negativa
FROM vendas
WHERE quantity < 0;

SELECT 
invoice, stock_code, description, quantity 
FROM vendas 
WHERE quantity < 0 
LIMIT 5;
-- -------------------------------
/*
Pergunta 10
Qual é o faturamento bruto da base?
*/
SELECT
SUM(quantity * unit_price) AS receita_total
FROM vendas
WHERE quantity > 0;

-- ------------------------------------
/* 
ANÁLISE 1 — Clientes que mais compram
Pergunta:
Quem realizou mais pedidos?
Objetivo:
Identificar clientes mais frequentes.
*/
SELECT
customer_id,
count(distinct invoice) AS total_pedido
FROM vendas
WHERE customer_id IS NOT NULL AND customer_id <> 0
GROUP BY customer_id
ORDER BY total_pedido DESC
LIMIT 1;
-- ----------------------------------
/*
ANÁLISE 2 — Clientes que mais gastam
Pergunta:
Quais clientes geram maior receita?
Objetivo:
Encontrar os clientes mais valiosos.
*/
SELECT
customer_id,
sum(quantity * unit_price) AS valor_gasto
FROM vendas
WHERE customer_id IS NOT NULL
AND customer_id <> 0
AND quantity > 0
GROUP BY customer_id
ORDER BY valor_gasto DESC
LIMIT 10;
-- ----------------------------------
/*
ANÁLISE 3 — Frequência x Receita
Pergunta:
Clientes que compram mais são os que mais gastam?
Objetivo:
Comparar comportamento dos clientes.
*/
SELECT
customer_id,
COUNT(distinct invoice) AS frequencia,
SUM(quantity * unit_price) AS receita
FROM vendas
WHERE customer_id IS NOT NULL
AND customer_id <> 0 
AND quantity > 0
GROUP BY customer_id
ORDER BY frequencia DESC; 
-- ORDER BY receita DESC; alternar para analisar se os clientes que mais compram são os mesmos que mais geram receita para a empresa. 

-- ----------------------------------
/*
ANÁLISE 4 — Ticket Médio por Cliente
Pergunta:
Qual o valor médio gasto por cada cliente?
Objetivo:
Identificar clientes premium.
*/
SELECT
customer_id,
SUM(quantity * unit_price) valor_gasto,
COUNT(distinct invoice) AS total_pedido,
SUM(quantity * unit_price) / COUNT(distinct invoice) AS ticket_medio
FROM vendas
WHERE customer_id IS NOT NULL
AND customer_id <> 0
AND quantity > 0
GROUP BY customer_id
ORDER BY ticket_medio DESC
LIMIT 10;

-- ------------------------------------
/*
ANÁLISE 5 — Clientes Inativos
Pergunta:
Quais clientes estão há mais tempo sem comprar?
Objetivo:
Encontrar oportunidades de reativação.
*/
SELECT
customer_id,
MAX(invoice_date) as ultima_compra -- Encontra a data mais recente de cada cliente
FROM vendas
WHERE customer_id IS NOT NULL AND customer_id <> 0
GROUP BY customer_id
ORDER BY ultima_compra ASC; -- Traz para o topo quem tem a última compra mais antiga

-- ------------------------------------
/*
ANÁLISE 6 — Clientes por País
Pergunta:
Quais países possuem mais clientes?
Objetivo:
Identificar mercados consumidores.
*/
SELECT
country,
count(distinct customer_id) AS total_clientes
FROM vendas
WHERE customer_id IS NOT NULL AND customer_id <> 0
GROUP BY country
ORDER BY total_clientes DESC
LIMIT 10;
-- -----------------------------------
/*
ANÁLISE 7 — Receita por País
Pergunta:
Quais países geram maior faturamento?
Objetivo:
Descobrir mercados estratégicos.
*/
SELECT
country,
sum(quantity * unit_price) as faturamento
FROM vendas
WHERE quantity > 0
GROUP BY country
ORDER BY faturamento DESC
LIMIT 10;
-- ---------------------------------
/*
ANÁLISE 8 — Produtos Preferidos dos Clientes
Pergunta:
Quais produtos aparecem com maior frequência nas compras?
Objetivo:
Entender preferências dos consumidores.
*/
SELECT 
description,
count(*) as produto_comprado
FROM vendas 
WHERE quantity > 0
GROUP BY description
ORDER BY produto_comprado DESC
LIMIT 10;
-- -----------------------------------
/*
ANÁLISE 9 — Clientes VIP
Pergunta:
Quem merece entrar em um programa de fidelidade?
Objetivo:
Criar critérios para selecionar clientes VIP.
*/
SELECT 
    customer_id,
    SUM(quantity * unit_price) AS receita_total,
    COUNT(DISTINCT invoice) AS total_pedidos,
    -- Criando o critério do programa de fidelidade:
    CASE 
        WHEN SUM(quantity * unit_price) > 10000 OR COUNT(DISTINCT invoice) > 15 THEN 'VIP'
        ELSE 'Normal'
    END AS status_fidelidade
FROM vendas
WHERE customer_id IS NOT NULL
  AND customer_id <> 0
  AND quantity > 0
GROUP BY customer_id
ORDER BY receita_total DESC; -- Mantém ordenado por quem gasta mais para auditar o topo

-- -------------------------------------

/*
ANÁLISE 10 — Segmentação
Pergunta:
Como podemos dividir os clientes em grupos?
Objetivo:
Criar segmentos.
Exemplo:
Ouro
Prata
Bronze
*/
SELECT 
    customer_id,
    SUM(quantity * unit_price) AS receita_total,
    -- Criando a segmentação com base na receita:
    CASE 
    WHEN SUM(quantity * unit_price) >= 100000 THEN 'Diamante (Super VIP)'
    WHEN SUM(quantity * unit_price) >= 50000  THEN 'Ouro'
    WHEN SUM(quantity * unit_price) >= 10000  THEN 'Prata'
    ELSE 'Bronze'
    END AS segmento
FROM vendas
WHERE customer_id IS NOT NULL
  AND customer_id <> 0
  AND quantity > 0
GROUP BY customer_id
ORDER BY receita_total DESC;

-- ----------------------------------------
/*
ANÁLISE 11 — Clientes com maior potencial
Pergunta:
Quais clientes compram pouco, mas gastam muito?
Objetivo:
Identificar oportunidades de crescimento.
*/
SELECT 
customer_id,
SUM(quantity * unit_price) AS receita_total,
COUNT(DISTINCT invoice) AS total_pedidos
FROM vendas
WHERE customer_id IS NOT NULL
AND customer_id <> 0
AND quantity > 0
GROUP BY customer_id
-- Ordena pelo maior valor médio por pedido feito:
ORDER BY (SUM(quantity * unit_price) / COUNT(DISTINCT invoice)) DESC
LIMIT 50;
-- ------------------------------------------
/*
ANÁLISE 12 — Dashboard Executivo
Indicadores:
- Receita Total
- Número de Clientes
- Número de Pedidos
- Ticket Médio
- Produto mais vendido
- País com maior faturamento
- Cliente que mais gastou
- Cliente mais recorrente
*/
SELECT 
    SUM(quantity * unit_price) AS receita_total,
    COUNT(DISTINCT customer_id) AS numero_de_clientes,
    COUNT(DISTINCT invoice) AS numero_de_pedidos,
    SUM(quantity * unit_price) / COUNT(DISTINCT invoice) AS ticket_medio
FROM vendas
WHERE customer_id IS NOT NULL 
  AND customer_id <> 0 
  AND quantity > 0;
  
  -- ---------
SELECT
description, 
SUM(quantity) AS produto_mais_vendido
FROM vendas
WHERE quantity > 0
GROUP BY description
ORDER BY produto_mais_vendido
DESC LIMIT 1;

-- ------------
SELECT 
country, 
SUM(quantity * unit_price) AS faturamento
FROM vendas
WHERE quantity > 0
GROUP BY country
ORDER BY faturamento
DESC LIMIT 1;

-- ----------------
SELECT
customer_id,
SUM(quantity * unit_price) AS valor_gasto
FROM vendas
WHERE customer_id IS NOT NULL
AND customer_id <> 0
AND quantity > 0
GROUP BY customer_id
ORDER BY valor_gasto
DESC LIMIT 1;

-- ------------
SELECT
customer_id, 
COUNT(DISTINCT invoice) AS total_pedidos
FROM vendas
WHERE customer_id
IS NOT NULL
AND customer_id <> 0
AND quantity > 0
GROUP BY customer_id 
ORDER BY total_pedidos 
DESC LIMIT 1;


