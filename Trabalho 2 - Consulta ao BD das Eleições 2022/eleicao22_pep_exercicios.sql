-- 1) Apresente todos os municípios com a quantidade total de seções de votação de cada um.

SELECT mn_nome 'Município', COUNT(pv_secao) 'Quantidade de Seções'
FROM PontoVotacao INNER JOIN Municipio ON (mn_cod = pv_mn_cod)
GROUP BY mn_cod;

-- 2) Apresente, em ordem alfabética, o nome de todos os candidatos que participaram do segundo turno das
-- eleições, ignorando votos nulos ou em branco.

SELECT DISTINCT ca_nome 'Candidato'
FROM Candidato INNER JOIN Votacao ON (ca_num = vt_ca_num)
               INNER JOIN Eleicao ON (el_cod = vt_el_cod)
WHERE (el_turno = 2) AND (ca_nome != 'Nulo' AND ca_nome != 'Branco')
ORDER BY ca_nome ASC;

-- 3) Exiba o nome, a sigla e a quantidade de votos recebidos, do partido que recebeu menos votos durante as
-- eleições.

SELECT pa_nome 'Partido', pa_sigla 'Sigla', SUM(vt_quant) AS qnt_votos
FROM Votacao INNER JOIN Partido ON (pa_cod = vt_pa_cod)
GROUP BY pa_cod
ORDER BY qnt_votos ASC
LIMIT 1;

-- 4) Mostre todos os candidatos ao cargo de presidente, do mais para o menos votado, com a quantidade de votos
-- recebida por cada um em cada turno, na seção 7, do município de Presidente Epitácio.

SELECT ca_nome 'Candidato', vt_quant 'Quantidade de Votos', el_turno 'Turno'
FROM Candidato INNER JOIN Votacao ON (ca_num = vt_ca_num)
			   INNER JOIN Eleicao ON (el_cod = vt_el_cod)
               INNER JOIN PontoVotacao ON (pv_cod = vt_pv_cod)
               INNER JOIN Municipio ON (mn_cod = pv_mn_cod)
               INNER JOIN Cargo ON (cr_cod = vt_cr_cod)
WHERE (mn_nome = 'PRESIDENTE EPITÁCIO') AND (pv_secao = 7) AND (cr_desc = 'Presidente')
ORDER BY vt_quant DESC;

-- 5) Apresente as 5 primeiras seções que possuiram o maior número de abstenção de votos, no primeiro turno das
-- eleições, no município de Presidente Prudente. Mostre também o local de votação de cada seção, a quantidade de
-- abstenções e a quantidade de pessoas que compareceram à votação.

SELECT pv_secao 'Seção', pv_num_local 'Local de Votação',
	   pv_abst_1t 'Abstenções', (pv_aptos - pv_abst_1t) AS 'Compareceram'
FROM PontoVotacao INNER JOIN Municipio ON (mn_cod = pv_mn_cod)
WHERE (mn_nome = 'PRESIDENTE PRUDENTE')
ORDER BY pv_abst_1t DESC
LIMIT 5;

-- 6) Exiba a sigla dos partidos que obtiveram mais de 500 votos de legenda para o cargo de deputado estadual,
-- juntamente com a quantidade de votos, ordenando de forma crescente.

SELECT pa_sigla 'Partido', SUM(vt_quant) AS qnt_votos
FROM Votacao INNER JOIN Partido ON (pa_cod = vt_pa_cod)
			 INNER JOIN TipoVoto ON (tv_cod = vt_tv_cod)
             INNER JOIN Cargo ON (cr_cod = vt_cr_cod)
WHERE (tv_desc = 'Legenda') AND (cr_desc = 'Deputado Estadual')
GROUP BY pa_cod
HAVING (qnt_votos > 500)
ORDER BY qnt_votos ASC;

-- 7) Apresente, para cada município, o percentual de pessoas que votaram no Fernando Haddad e que possuíam 
-- biometria, mas não foram habilitados por ela. Ordene por ordem decrescente.

SELECT mn_nome 'Município', ((SUM(pv_nbio_1t) + SUM(pv_nbio_2t)) / SUM(vt_quant)) * 100 AS percentual
FROM Votacao INNER JOIN PontoVotacao ON (pv_cod = vt_pv_cod)
			 INNER JOIN Municipio ON (mn_cod = pv_mn_cod)
             INNER JOIN Candidato ON (ca_num = vt_ca_num)
WHERE (ca_nome = 'FERNANDO HADDAD')
GROUP BY mn_cod
ORDER BY percentual DESC;

-- 8) Apresente quantas seções registraram mais de 10 votos brancos no segundo turno das eleições, para cada
-- local de votação de cada município. Ordene pelo nome dos municípios e pela quantidade de seções contabilizadas
-- em cada local, do local com mais seções contabilizadas para o com menos.

SELECT mn_nome 'Município', pv_num_local 'Número do Local', COUNT(pv_secao) AS qnt_secoes
FROM Votacao INNER JOIN TipoVoto ON (tv_cod = vt_tv_cod)
			 INNER JOIN PontoVotacao ON (pv_cod = vt_pv_cod)
             INNER JOIN Municipio ON (mn_cod = pv_mn_cod)
             INNER JOIN Eleicao ON (el_cod = vt_el_cod)
WHERE (tv_desc = 'Branco') AND (vt_quant > 10) AND (el_turno = 2)
GROUP BY pv_num_local, mn_cod
ORDER BY mn_nome ASC, qnt_secoes DESC;

-- 9) Mostre o nome dos 10 candidatos menos votados à vaga de deputado federal, do partido PSOL ou do PT, que
-- receberam mais de 45 votos no município de Presidente Epitácio. Mostre também a sigla do partido de cada
-- candidato.

SELECT ca_nome 'Candidato', pa_sigla 'Partido'
FROM Votacao INNER JOIN PontoVotacao ON (pv_cod = vt_pv_cod)
			 INNER JOIN Municipio ON (mn_cod = pv_mn_cod)
             INNER JOIN Candidato ON (ca_num = vt_ca_num)
             INNER JOIN Cargo ON (cr_cod = vt_cr_cod)
             INNER JOIN Partido ON (pa_cod = vt_pa_cod)
WHERE (mn_nome = 'PRESIDENTE EPITÁCIO') AND (cr_desc = 'Deputado Federal') AND (pa_sigla = 'PT' OR pa_sigla = 'PSOL')
GROUP BY ca_num, pa_cod
HAVING (SUM(vt_quant) > 45)
ORDER BY SUM(vt_quant) ASC
LIMIT 10;

-- 10) Apresente os três primeiros candidatos mais votados à presidência, que não passaram para o segundo turno
-- das eleições, com a quantidade de votos e a sigla de seus respectivos partidos. Desconsidere votos nulos e
-- em branco.

SELECT ca_nome 'Candidato', SUM(vt_quant) AS votos, pa_sigla 'Partido'
FROM Candidato INNER JOIN Votacao ON (ca_num = vt_ca_num)
			   INNER JOIN Cargo ON (cr_cod = vt_cr_cod)
               INNER JOIN Eleicao ON (el_cod = vt_el_cod)
               INNER JOIN TipoVoto ON (tv_cod = vt_tv_cod)
               INNER JOIN Partido ON (pa_cod = vt_pa_cod)
WHERE (el_turno = 1) AND (cr_desc = 'Presidente') AND (tv_desc != 'Nulo') AND (tv_desc != 'Branco')
GROUP BY ca_num, pa_cod
ORDER BY votos DESC
LIMIT 3
OFFSET 2;
