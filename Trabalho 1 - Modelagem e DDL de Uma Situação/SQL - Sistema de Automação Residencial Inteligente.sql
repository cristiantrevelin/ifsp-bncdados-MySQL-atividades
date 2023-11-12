-- sis_auto_res: sistema de automação residencial
-- criando o BD:
DROP DATABASE IF EXISTS sis_auto_res;
CREATE DATABASE IF NOT EXISTS sis_auto_res;
USE sis_auto_res;

-- criando tabelas para as Entidades:

CREATE TABLE area_residencia (
	ar_codigo			INT					NOT NULL,
	ar_nome				VARCHAR(50)			NOT NULL,
	ar_descricao		VARCHAR(150)		NULL,
    
    PRIMARY KEY (ar_codigo)
);

CREATE TABLE dispositivo (
	dp_codigo			INT  				NOT NULL,
    dp_nome				VARCHAR(50) 		NOT NULL,
    dp_descricao		VARCHAR(150) 		NULL,
    dp_tipo				ENUM ('Seguranca',
							'Ambiente',
							'Essencial',
							'Entretenimento',
							'Sensor',
							'Extra')		NOT NULL,
    dp_ativo			BOOLEAN				NOT NULL,
    
    PRIMARY KEY (dp_codigo)
);

CREATE TABLE termostato (
	tm_codigo			INT					NOT NULL,
    tm_temp_min			DECIMAL(3, 1)		NOT NULL,
    tm_temp_max			DECIMAL(3, 1)		NOT NULL,
	tm_modo_oper		ENUM ('Auto',
							'Aquecer', 
							'Resfriar')		DEFAULT 'Auto',
    
    PRIMARY KEY (tm_codigo),
    FOREIGN KEY (tm_codigo) REFERENCES dispositivo (dp_codigo)
);

CREATE TABLE lampada (
	lp_codigo			INT 				NOT NULL,
    lp_intensidade 		ENUM ('1', '2',
							'3', '4',
                            '5', '6',
                            '7')			NOT NULL,
    lp_red				TINYINT UNSIGNED	DEFAULT 255,
    lp_green			TINYINT UNSIGNED	DEFAULT 255,
    lp_blue 			TINYINT UNSIGNED	DEFAULT 255,
    lp_hora_lig			TIME 				NULL,
    lp_hora_deslig		TIME				NULL,
    
    PRIMARY KEY (lp_codigo),
    FOREIGN KEY (lp_codigo) REFERENCES dispositivo (dp_codigo)
);

CREATE TABLE camera_seguranca (
	cs_codigo			INT					NOT NULL,
	cs_modo_gravacao	ENUM ('Por Movimento',
							'Continuo')		NOT NULL,
	cs_modo_armazen		ENUM ('Local',
							'Nuvem')		DEFAULT 'Local',
    cs_modo_cobertura	ENUM ('Estatico',
							'Dinamico')		NOT NULL,
	
    PRIMARY KEY (cs_codigo),
    FOREIGN KEY (cs_codigo) REFERENCES dispositivo (dp_codigo)
);

CREATE TABLE sensor (
	sn_codigo			INT 				NOT NULL,
    sn_precisao			FLOAT 				NOT NULL,
    sn_freq_amost		TIME 				NOT NULL,
    sn_parametros		TEXT				NOT NULL,
    
    PRIMARY KEY (sn_codigo),
    FOREIGN KEY (sn_codigo) REFERENCES dispositivo (dp_codigo)
);

CREATE TABLE sensor_temperatura (
	st_codigo			INT					NOT NULL,
    st_temp_atual		DECIMAL(3, 1)		NULL,
    st_freq_calc_tv		INT					NOT NULL,
    
    PRIMARY KEY (st_codigo),
    FOREIGN KEY (st_codigo) REFERENCES sensor (sn_codigo)
);

CREATE TABLE sensor_fumaca (
	sf_codigo			INT 				NOT NULL,
    sf_fumaca_detec		BOOLEAN 			DEFAULT FALSE,
    sf_data_detec		DATETIME 			NULL,
    sf_dens_fumaca		FLOAT				NULL,
    
    PRIMARY KEY (sf_codigo),
    FOREIGN KEY (sf_codigo) REFERENCES sensor (sn_codigo)
);

CREATE TABLE sensor_movimento (
	sm_codigo			INT					NOT NULL,
	sm_data_detec		DATETIME 			NULL,
    sm_num_mov			INT 				DEFAULT 0,
	
    PRIMARY KEY (sm_codigo),
    FOREIGN KEY (sm_codigo) REFERENCES sensor (sn_codigo)
);

CREATE TABLE usuario (
	us_codigo			INT 				NOT NULL,
    us_nome				VARCHAR(50) 		NOT NULL UNIQUE,
    us_senha 			VARCHAR(20) 		NOT NULL,
    us_email 			VARCHAR(50) 		NULL,
    us_telefone 		CHAR(17) 			NOT NULL UNIQUE,
    
    PRIMARY KEY (us_codigo)
);

CREATE TABLE regra_automacao (
	ra_codigo			INT             	NOT NULL,
    ra_descricao 		VARCHAR(150) 		NOT NULL,
    ra_ativa 			BOOLEAN 			NOT NULL,
    ra_config_controle 	TEXT 				NOT NULL,
    ra_gatilhos 		TEXT 				NOT NULL,
    
    PRIMARY KEY (ra_codigo)
);

-- criando tabelas para os Relacionamentos (e Composições):

CREATE TABLE localizacao_dispositivo (
	ldp_codigo_dp 		INT 				NOT NULL,
    ldp_codigo_ar 		INT 				NOT NULL,
    
    PRIMARY KEY (ldp_codigo_dp),
    FOREIGN KEY (ldp_codigo_dp) REFERENCES dispositivo (dp_codigo),
    FOREIGN KEY (ldp_codigo_ar) REFERENCES area_residencia (ar_codigo)
);

CREATE TABLE grupo_dispositivos (
	gdp_codigo			INT 				NOT NULL,
	gdp_nome 			VARCHAR(50) 		NOT NULL UNIQUE,
    gdp_descricao 		VARCHAR(150)   		NULL,
    
    PRIMARY KEY (gdp_codigo)
);

CREATE TABLE agrupamento_dispositivos (
	agdp_codigo_dp		INT					NOT NULL,
    agdp_codigo_gdp 	INT 				NOT NULL,
    
    PRIMARY KEY (agdp_codigo_dp, agdp_codigo_gdp),
    FOREIGN KEY (agdp_codigo_dp) REFERENCES dispositivo (dp_codigo),
    FOREIGN KEY (agdp_codigo_gdp) REFERENCES grupo_dispositivos (gdp_codigo)
);

CREATE TABLE vinculo_sensor_dispositivo (
	vsndp_codigo_sn		INT 				NOT NULL,
    vsndp_codigo_dp 	INT 				NOT NULL,
    
    PRIMARY KEY (vsndp_codigo_sn, vsndp_codigo_dp),
    FOREIGN KEY (vsndp_codigo_sn) REFERENCES sensor (sn_codigo),
    FOREIGN KEY (vsndp_codigo_dp) REFERENCES dispositivo (dp_codigo)
);

CREATE TABLE configuracao_dispositivo (
	cdp_codigo 			INT 				NOT NULL,
	cdp_nome 			VARCHAR(50) 		NOT NULL,
	cdp_data 			DATETIME 			NOT NULL,
    cdp_descricao 		TEXT 				NOT NULL,
    
    PRIMARY KEY (cdp_codigo)
);

CREATE TABLE dispositivo_configurado (
	dpc_codigo_us 		INT 				NOT NULL,
    dpc_codigo_dp 		INT  				NOT NULL,
    dpc_codigo_cdp 		INT 				NOT NULL,
    
    PRIMARY KEY (dpc_codigo_dp),
    FOREIGN KEY (dpc_codigo_us) REFERENCES usuario (us_codigo),
    FOREIGN KEY (dpc_codigo_dp) REFERENCES dispositivo (dp_codigo),
    FOREIGN KEY (dpc_codigo_cdp) REFERENCES configuracao_dispositivo (cdp_codigo)
);

CREATE TABLE configuracao_dispositivo_restaurada (
	cdpr_data 			DATETIME  			NOT NULL,
    cdpr_codigo_cdp 	INT 				NOT NULL,
    cdpr_codigo_us 		INT 				NOT NULL,
    
    FOREIGN KEY (cdpr_codigo_cdp) REFERENCES configuracao_dispositivo (cdp_codigo),
    FOREIGN KEY (cdpr_codigo_us) REFERENCES usuario (us_codigo)
);

CREATE TABLE programacao_termostato (
	ptm_hora_inicio 	TIME 				NOT NULL,
    ptm_hora_fim		TIME 				NOT NULL,
    ptm_temp 			DECIMAL(3, 1) 		NOT NULL,
    ptm_ativa 			BOOLEAN 			NOT NULL,
    ptm_codigo_tm 		INT 				NOT NULL,
    ptm_codigo_us 		INT 				NOT NULL,
    
    FOREIGN KEY (ptm_codigo_tm) REFERENCES termostato (tm_codigo),
    FOREIGN KEY (ptm_codigo_us) REFERENCES usuario (us_codigo)
);

CREATE TABLE grupo_lampadas (
	glp_codigo 			INT 				NOT NULL,
    glp_nome 			VARCHAR(50) 		NOT NULL UNIQUE,
    glp_ativo 			BOOLEAN 			NOT NULL,
    glp_cenario_ilum 	ENUM ('Romantico',
							'Cinema',
                            'Festa',
                            'Aconchego',
                            'Quente',
                            'Frio')			NOT NULL,
	
    PRIMARY KEY (glp_codigo)
);

CREATE TABLE agrupamento_lampadas (
	aglp_codigo_lp	 	INT 				NOT NULL,
    aglp_codigo_glp 	INT 				NOT NULL,
    
    PRIMARY KEY (aglp_codigo_lp, aglp_codigo_glp),
    FOREIGN KEY (aglp_codigo_lp) REFERENCES lampada (lp_codigo),
    FOREIGN KEY (aglp_codigo_glp) REFERENCES grupo_lampadas (glp_codigo)
);

CREATE TABLE notificacao_sensor (
	nsn_data 			DATETIME 			NOT NULL,
    nsn_descricao 		VARCHAR(150) 		NOT NULL,
    nsn_codigo_sn 		INT 				NOT NULL,
    nsn_codigo_us 		INT 				NOT NULL,
    
    FOREIGN KEY (nsn_codigo_sn) REFERENCES sensor (sn_codigo),
    FOREIGN KEY (nsn_codigo_us) REFERENCES usuario (us_codigo)
);

CREATE TABLE programacao_sensor_movimento (
	psm_data_inicio_cp	DATE 				NOT NULL,
    psm_hora_ativ 		TIME 				NOT NULL,
    psm_hora_desativ	TIME 				NOT NULL,
    psm_ciclo_prog 		INT 				DEFAULT 1,
    psm_ativa 			BOOLEAN 			NOT NULL,
    psm_codigo_sm 		INT 				NOT NULL,
    psm_codigo_us 		INT 				NOT NULL,
    
    FOREIGN KEY (psm_codigo_sm) REFERENCES sensor_movimento (sm_codigo),
    FOREIGN KEY (psm_codigo_us) REFERENCES usuario (us_codigo)
);

CREATE TABLE regra_automacao_definida (
	rad_codigo_ra 		INT 				NOT NULL,
    rad_codigo_us 		INT 				NOT NULL,
    
    PRIMARY KEY (rad_codigo_ra),
    FOREIGN KEY (rad_codigo_ra) REFERENCES regra_automacao (ra_codigo),
    FOREIGN KEY (rad_codigo_us) REFERENCES usuario (us_codigo)
);

CREATE TABLE evento_controle (
	ec_prioridade 		INT 				NOT NULL,
    ec_codigo_ra 		INT 				NOT NULL,
    ec_codigo_gdp 		INT 				NOT NULL,
    
    PRIMARY KEY (ec_codigo_ra, ec_codigo_gdp),
    FOREIGN KEY (ec_codigo_ra) REFERENCES regra_automacao (ra_codigo),
    FOREIGN KEY (ec_codigo_gdp) REFERENCES grupo_dispositivos (gdp_codigo)
);

-- povoando as Tabelas:

INSERT INTO area_residencia (ar_codigo, ar_nome, ar_descricao)
VALUES
	(1, 'Sala de Estar', 'Primeira área da residência.'),
    (2, 'Sala de Jantar', NULL),
    (3, 'Cozinha', NULL),
    (4, 'Suite Principal', 'Suíte dos proprietários.'),
    (5, 'Suite 2', 'Suíte do filho.'),
    (6, 'Suite 3', 'Suíte de hóspedes.'),
    (7, 'Banheiro SP', 'Banheiro da suíte principal.'),
    (8, 'Banheiro S2', 'Banheiro da suíte do filho.'),
    (9, 'Banheiro S3', 'Banheiro da suíte de hóspedes.'),
    (10, 'Banheiro C', 'Banheiro de convidados.'),
    (11, 'Entrada', 'Área da entrada da residência.'),
    (12, 'Area de Churrasco', 'Área de churrasco e comemorações.');

INSERT INTO dispositivo (dp_codigo, dp_nome, dp_descricao, dp_tipo, dp_ativo)
VALUES
	(1, 'Fechadura 1SE', 'Fechadura da porta principal da sala de estar.', 'Seguranca', TRUE),
    (3, 'Controlador de Som 1AC', 'Controla a música da área de churrasco.', 'Entretenimento', FALSE),
    (10, 'Termostato 1SE', 'Termostato de ambiente da sala de estar.', 'Ambiente', TRUE),
    (11, 'Termostato 1AC', 'Termostato do freezer 1 da área de churrasco.', 'Essencial', TRUE),
    (12, 'Termostato 1BSP', 'Termostato da banheira aquecida da suíte principal.', 'Essencial', TRUE),
    (20, 'Lampada 1SP', 'Lâmpada 1 da suíte principal.', 'Ambiente', TRUE),
    (21, 'Lampada 1E', 'Lâmpada 1 da entrada da residência.', 'Ambiente', TRUE),
    (22, 'Lampada 1S2', 'Lâmpada 1 da suíte do filho.', 'Ambiente', TRUE),
    (23, 'Lampada 1SE', 'Lâmpada 1 da sala de estar.', 'Ambiente', TRUE),
    (30, 'Camera de Seguranca 1E', NULL, 'Seguranca', TRUE),
    (31, 'Camera de Seguranca 2E', NULL, 'Seguranca', TRUE),
    (32, 'Camera de Seguranca 1SE', NULL, 'Seguranca', TRUE),
    (40, 'Sensor de Temperatura 1SE', 'Detecta se o termostato de ambiente está funcionando.', 'Sensor', TRUE),
    (41, 'Sensor de Temperatura 1AC', 'Detecta se o freezer 1 está abaixo da temperatura permitida.', 'Sensor', TRUE),
    (42, 'Sensor de Temperatura 1BSP', 'Detecta se a banheira aquecida está na temperatura correta.', 'Sensor', TRUE),
    (43, 'Sensor de Fumaca 1C', 'Detecta fumaça na cozinha.', 'Sensor', TRUE),
    (44, 'Sensor de Fumaca 1BC', 'Detecta fumaça no banheiro dos convidados.', 'Sensor', TRUE),
    (45, 'Sensor de Movimento 1SE', 'Detecta movimento na sala de estar.', 'Sensor', TRUE),
    (46, 'Sensor de Movimento 1E', 'Detecta movimento anormal na entrada da residência.', 'Sensor', FALSE);
    
INSERT INTO localizacao_dispositivo (ldp_codigo_dp, ldp_codigo_ar)
VALUES
	(1, 1),
    (3, 12),
    (10, 1),
    (11, 12),
    (12, 7),
    (20, 4),
    (21, 11),
    (22, 5),
    (23, 1),
    (30, 11),
    (31, 11),
    (32, 1),
    (40, 1),
    (41, 12),
    (42, 7),
    (43, 3),
    (44, 10),
    (45, 1),
    (46, 11);
    
INSERT INTO configuracao_dispositivo (cdp_codigo, cdp_nome, cdp_data, cdp_descricao)
VALUES
	(1, 'Configuração Fechadura 1SE - 1', '2023-06-20 12:00:17', 'ATIV=TRUE:SENHA=982KAm.-9'),
    (2, 'Configuração Termostato 1SE - 1', '2023-06-20 12:15:34', 'ATIV=TRUE:DEF=DEFAULT'),
    (3, 'Configuração Câmera de Segurança 1SE - 1', '2023-06-20 12:26:45', 'ATIV=TRUE:DEF=DEFAULT'),
    (4, 'Configuração Fechadura 1SE - 2', '2023-08-11 17:00:50', 'ATIV=TRUE:SENHA=123qwAS@'),
    (5, 'Configuração Câmera de Segurança 1SE - 2', '2023-10-30 14:26:00', 'ATIV=TRUE:DEF=EMERGENCY');

INSERT INTO grupo_dispositivos (gdp_codigo, gdp_nome, gdp_descricao)
VALUES
	(1, 'Grupo de Seguranca 1', 'Controla a segurança da residência, atuando contra ameaças de invasão.'),
    (2, 'Grupo Ambiente 1', 'Dispositivos que definem configurações de ambiente na sala de estar.'),
    (3, 'Grupo de Seguranca 2', 'Controla o comportamento de todas as câmeras de segurança.');
    
INSERT INTO agrupamento_dispositivos (agdp_codigo_dp, agdp_codigo_gdp)
VALUES
	(1, 1),
    (30, 1),
    (31, 1),
    (45, 1),
    (10, 2),
    (23, 2),
    (30, 3),
    (31, 3),
    (32, 3);

INSERT INTO termostato (tm_codigo, tm_temp_min, tm_temp_max, tm_modo_oper)
VALUES
	(10, 21.0, 26.5, 'Auto'),
    (11, -26.0, -18.0, 'Resfriar'),
    (12, 36.0, 42.0, 'Aquecer');
    
INSERT INTO lampada (lp_codigo, lp_intensidade, lp_red, lp_green, lp_blue, lp_hora_lig, lp_hora_deslig)
VALUES
	(20, 6, NULL, NULL, NULL, NULL, NULL),
    (21, 4, NULL, NULL, NULL, '19:00:00', '07:00:00'),
    (22, 5, 96, 12, 166, NULL, NULL),
    (23, 7, NULL, NULL, NULL, NULL, NULL);
    
INSERT INTO grupo_lampadas (glp_codigo, glp_nome, glp_ativo, glp_cenario_ilum)
VALUES
	(1, 'Todas as Lampadas - Festa', FALSE, 'Festa'),
    (2, 'Todas as Suítes - Frio', TRUE, 'Frio'),
    (3, 'Todas as Lampadas - Aconchego', TRUE, 'Aconchego');
    
INSERT INTO agrupamento_lampadas (aglp_codigo_lp, aglp_codigo_glp)
VALUES
	(20, 1),
    (21, 1),
    (22, 1),
    (23, 1),
    (20, 2),
    (22, 2),
    (20, 3),
    (21, 3),
    (22, 3),
    (23, 3);
    
INSERT INTO camera_seguranca (cs_codigo, cs_modo_gravacao, cs_modo_armazen, cs_modo_cobertura)
VALUES
	(30, 'Por Movimento', 'Nuvem', 'Estatico'),
    (31, 'Continuo', 'Nuvem', 'Dinamico'),
    (32, 'Por Movimento', 'Local', 'Estatico');
    
INSERT INTO sensor (sn_codigo, sn_precisao, sn_freq_amost, sn_parametros)
VALUES
	(40, 97.53, '00:00:05', 'TEMP_AT>25.5:|:TAX_VART>2.25:|:TEMP_AT<20.0'),
    (41, 98.99, '00:00:02', 'TEMP_AT>-18.0'),
    (42, 98.93, '00:00:02', 'TEMP_AT<36.0:|:TEMP_AT>42.0'),
    (43, 97.94, '00:00:09', 'FUMAC_DTC=TRUE:&:FUMAC_DNS>6.627'),
    (44, 98.04, '00:00:09', 'FUMAC_DTC=TRUE:&:FUMAC_DNS>=5.003'),
    (45, 99.01, '00:00:01', 'MOV>=1'),
    (46, 99.02, '00:00:01', 'MOV>5:&:DATA_DTC->DATA_CHECK=ATT');
    
INSERT INTO vinculo_sensor_dispositivo (vsndp_codigo_sn, vsndp_codigo_dp)
VALUES
	(40, 10),
    (45, 32),
	(46, 30),
    (46, 31);
    
INSERT INTO sensor_temperatura (st_codigo, st_temp_atual, st_freq_calc_tv)
VALUES
	(40, NULL, 10),
    (41, NULL, 5),
    (42, NULL, 5);
    
INSERT INTO sensor_fumaca (sf_codigo, sf_fumaca_detec, sf_data_detec, sf_dens_fumaca)
VALUES
	(43, FALSE, NULL, NULL),
    (44, FALSE, NULL, NULL);
    
INSERT INTO sensor_movimento (sm_codigo, sm_data_detec, sm_num_mov)
VALUES
	(45, NULL, 0),
    (46, NULL, 0);
    
INSERT INTO usuario (us_codigo, us_nome, us_senha, us_email, us_telefone)
VALUES
	(1, 'Marcos', '123abcXZ-', 'marco_lamburg@hotmail.com', '+55(18)98984-2345'),
    (2, 'Katia', '9938bhn.O', NULL, '+55(18)97754-9890'),
    (3, 'Pedro', 'UWijsk293.', 'pedrinho_gamer@gmail.com', '+55(18)92203-4546');
    
INSERT INTO dispositivo_configurado (dpc_codigo_us, dpc_codigo_dp, dpc_codigo_cdp)
VALUES
	(2, 1, 4),
    (2, 10, 2),
    (1, 32, 5);
    
INSERT INTO configuracao_dispositivo_restaurada (cdpr_data, cdpr_codigo_cdp, cdpr_codigo_us)
VALUES
	('2023-11-15 17:12:46', 1, 2),
    ('2023-12-24 13:00:08', 3, 1);
    
INSERT INTO programacao_termostato (ptm_hora_inicio, ptm_hora_fim, ptm_temp, ptm_ativa, ptm_codigo_tm, ptm_codigo_us)
VALUES
	('19:00:00', '01:00:00', 26.0, TRUE, 10, 2),
    ('12:00:00', '19:00:00', 23.0, TRUE, 10, 1),
    ('20:00:00', '00:00:00', 40.0, FALSE, 12, 1);
    
INSERT INTO notificacao_sensor (nsn_data, nsn_descricao, nsn_codigo_sn, nsn_codigo_us)
VALUES
	('2023-07-12 03:22:03', 'MOVIMENTAÇÃO ANORMAL NA ENTRADA!', 46, 1),
    ('2023-07-12 03:46:29', 'MOVIMENTAÇÃO ANORMAL NA SALA DE ESTAR!', 45, 1),
    ('2023-09-07 17:12:08', 'FUMAÇA DETECTADA NA COZINHA!', 43, 1),
    ('2023-09-07 17:12:08', 'FUMAÇA DETECTADA NA COZINHA!', 43, 2);
    
INSERT INTO programacao_sensor_movimento (psm_data_inicio_cp, psm_hora_ativ, psm_hora_desativ, psm_ciclo_prog,
										  psm_ativa, psm_codigo_sm, psm_codigo_us)
VALUES
	('2023-06-20', '01:00:00', '05:00:00', NULL, TRUE, 45, 1),
    ('2023-12-15', '00:00:00', '23:59:59', 1, FALSE, 45, 2),
    ('2023-06-20', '01:00:00', '04:00:00', 1, TRUE, 46, 2);

INSERT INTO regra_automacao (ra_codigo, ra_descricao, ra_ativa, ra_config_controle, ra_gatilhos)
VALUES
	(10, 'Grupo de Segurança 1 - Bloquear', TRUE, 'FECHADURA?->LOCK:SENSOR_MOV?->ATIVO=TRUE', 'CAMERA?->DTC_MOV=SUSPECT'),
    (20, 'Grupo de Ambiente 1 - Definir Quente', TRUE, 'LAMPADA?->SET_INTS(5', 'TERMOSTATO?->DTC_TA>25'),
    (30, 'Grupo de Segurança 2 - Desativar', FALSE, 'CAMERA?->DESATIV', 'CAMERA?->ATIV=TRUE');

INSERT INTO regra_automacao_definida (rad_codigo_ra, rad_codigo_us)
VALUES
	(10, 1),
    (20, 2),
    (30, 1);

INSERT INTO evento_controle (ec_prioridade, ec_codigo_ra, ec_codigo_gdp)
VALUES
	(1, 10, 1),
    (1, 20, 2),
    (2, 30, 3);
