USE cuidadosamente;

/************** Inserciones para pruebas y seteo del sistema ********************/
/* seteo de usuario admin Sara */
insert into staff (
	st_nombre
    , st_paterno
    , st_puesto_id
    , st_departamento_id
    , st_login
    , st_password
    , st_correo
) values(
	'Sara'
    , 'Beneyto'
    , 3
    , 3
    , 'sara@cuidadosamente.com'
    , md5(CONCAT('sara@cuidadosamente.com', '12345678', (select cfg_valor FROM configuraciones WHERE cfg_id = 1)))
    , 'sara@cuidadosamente.com'
);

/* Seteo de sesión de usuario Admin Sara */
INSERT INTO validateSess (
    vs_st_id
    , vs_hash
    , vs_status
    , vs_activateat
) VALUES(
    1
    , '2eac05d3927bee279984fcfd02a2e8cd'
    , 1
    , NOW()
)

/** No insertar test de pruebas*/
INSERT INTO test_profile(
    t_usr_id
    , t_gender
    , t_birthdate
    , t_age
    , t_service
    , t_therapyBefore
    , t_health
    , t_sleep
    , t_emotion_freq
    , t_anxiety
    , t_relationship
    , t_relationship_freq
    , t_reference
) VALUES
(
    1
    , 2
    , '1987-04-11'
    , 30
    , 5
    , 0
    , 2
    , 3
    , 1
    , 1
    , 4
    , 1
    , 5
);

/* dummy de faqs */
INSERT INTO faq_question (
    fqq_st_id
    , fqq_question
) VALUES 
(1, '¿Para que sirve el inicio de sesión?')
, (1,'¿Cómo agendo una cita?')
, (1, '¿Puedo agendar todas mis sesiones el mismo día?')
, (1, '¿Con cuántas horas de anticipación puedo cancelar mi sesión?');

INSERT INTO faq_answers (
    fqa_st_id
    , fqa_q_id
    , fqa_answer
) VALUES
(1, 1, 'Para mantener seguros tus datos.')
, (1, 2, 'En la sección de agenda da clic en cualquier sección en blanco dentro del calendario.')
, (1, 3, 'Si')
, (1, 4, 'Puedes hacer la cancelación de tu sesión 12 horas antes de la hora de inicio.');

/*******************************************************************************/

INSERT INTO configuraciones (
	cfg_nombre
    , cfg_valor
) VALUES (
	'secret'
    , 'Uncarefully'
), (
    'hh_start'
    , '8:00:00'
), (
    'hh_end'
    , '20:00:00'
);

INSERT INTO departamentos(
	depto_nombre
    , depto_abreviatura
    , depto_responsable 
) VALUES(
	'admin'
    , 'admin'
    , 'cuidadosamente'
), (
	'paciente'
    , 'paciente'
    , 'cuidadosamente'
), (
    'terapia'
    , 'terapia'
    , 'cuidadosamente'
);

INSERT INTO puestos (puesto_descripcion)
VALUES ('admin'), ('paciente'), ('terapeuta');

INSERT INTO citas_status (
    cs_desc
    , cs_color
    , cs_badge
) VALUES
    ('Enviada', '#29ABE2', 'badge badge-enviado')
    , ('Agendada', '#8CC63F', 'badge badge-info')
    , ('Reprogramada', '#FBB03B', 'badge badge-reprogramado')
    , ('Cancelada', '#F15A24', 'badge badge-cancelado');

INSERT INTO citas_communication (
    cc_desc
) VALUES
    ('Chat')
    , ('Videoconferencia');

INSERT INTO civil_estado (
    ce_desc
) VALUES 
('Soltero')
, ('Casado')
, ('Divorciado')
, ('Unión libre')
, ('Otro');

INSERT INTO gender (
    g_desc
) VALUES 
('Femenino')
, ('Masculino')
, ('Otro');

INSERT INTO emotions (
    e_desc
) VALUES 
('Miedo')
, ('Culpa')
, ('Vergüenza')
, ('Frustración')
, ('Arrepentimiento')
, ('Celos')
, ('Inseguridad')
, ('Desinterés')
, ('Envídia')
, ('Dolor');

INSERT INTO frequency (
    f_desc
) VALUES
('Nunca')
, ('Varios días')
, ('La mitad de los días')
, ('Casí todos los días');

INSERT INTO reference (
    r_desc
) VALUES
('Un amigo o falimiar')
, ('Mi doctor')
, ('Busqué en internet')
, ('Vi un anuncio')
, ('Redes sociales')
, ('En un artículo')
, ('Medios de comunicación (radio/tv)')
, ('Otro');

INSERT INTO nacionalidades (
    nacionalidad_desc
    , nacionalidad_abreviatura
) VALUES 
('AFG', 'Afganistán') ,
('ALA', 'Islas Åland') ,
('ALB', 'Albania') ,
('DEU', 'Alemania') ,
('AND', 'Andorra') ,
('AGO', 'Angola') ,
('AIA', 'Anguila') ,
('ATA', 'Antártida') ,
('ATG', 'Antigua y Barbuda') ,
('SAU', 'Arabia Saudita') ,
('DZA', 'Argelia') ,
('ARG', 'Argentina') ,
('ARM', 'Armenia') ,
('ABW', 'Aruba') ,
('AUS', 'Australia') ,
('AUT', 'Austria') ,
('AZE', 'Azerbaiyán') ,
('BHS', 'Bahamas (las)') ,
('BGD', 'Bangladés') ,
('BRB', 'Barbados') ,
('BHR', 'Baréin') ,
('BEL', 'Bélgica') ,
('BLZ', 'Belice') ,
('BEN', 'Benín') ,
('BMU', 'Bermudas') ,
('BLR', 'Bielorrusia') ,
('MMR', 'Myanmar') ,
('BOL', 'Bolivia, Estado Plurinacional de') ,
('BIH', 'Bosnia y Herzegovina') ,
('BWA', 'Botsuana') ,
('BRA', 'Brasil') ,
('BRN', 'Brunéi Darussalam') ,
('BGR', 'Bulgaria') ,
('BFA', 'Burkina Faso') ,
('BDI', 'Burundi') ,
('BTN', 'Bután') ,
('CPV', 'Cabo Verde') ,
('KHM', 'Camboya') ,
('CMR', 'Camerún') ,
('CAN', 'Canadá') ,
('QAT', 'Catar') ,
('BES', 'Bonaire, San Eustaquio y Saba') ,
('TCD', 'Chad') ,
('CHL', 'Chile') ,
('CHN', 'China') ,
('CYP', 'Chipre') ,
('COL', 'Colombia') ,
('COM', 'Comoras') ,
('PRK', 'Corea (la República Democrática Popular de)') ,
('KOR', 'Corea (la República de)') ,
('CIV', 'Côte d´Ivoire') ,
('CRI', 'Costa Rica') ,
('HRV', 'Croacia') ,
('CUB', 'Cuba') ,
('CUW', 'Curaçao') ,
('DNK', 'Dinamarca') ,
('DMA', 'Dominica') ,
('ECU', 'Ecuador') ,
('EGY', 'Egipto') ,
('SLV', 'El Salvador') ,
('ARE', 'Emiratos Árabes Unidos (Los)') ,
('ERI', 'Eritrea') ,
('SVK', 'Eslovaquia') ,
('SVN', 'Eslovenia') ,
('ESP', 'España') ,
('USA', 'Estados Unidos (los)') ,
('EST', 'Estonia') ,
('ETH', 'Etiopía') ,
('PHL', 'Filipinas (las)') ,
('FIN', 'Finlandia') ,
('FJI', 'Fiyi') ,
('FRA', 'Francia') ,
('GAB', 'Gabón') ,
('GMB', 'Gambia (La)') ,
('GEO', 'Georgia') ,
('GHA', 'Ghana') ,
('GIB', 'Gibraltar') ,
('GRD', 'Granada') ,
('GRC', 'Grecia') ,
('GRL', 'Groenlandia') ,
('GLP', 'Guadalupe') ,
('GUM', 'Guam') ,
('GTM', 'Guatemala') ,
('GUF', 'Guayana Francesa') ,
('GGY', 'Guernsey') ,
('GIN', 'Guinea') ,
('GNB', 'Guinea-Bisáu') ,
('GNQ', 'Guinea Ecuatorial') ,
('GUY', 'Guyana') ,
('HTI', 'Haití') ,
('HND', 'Honduras') ,
('HKG', 'Hong Kong') ,
('HUN', 'Hungría') ,
('IND', 'India') ,
('IDN', 'Indonesia') ,
('IRQ', 'Irak') ,
('IRN', 'Irán (la República Islámica de)') ,
('IRL', 'Irlanda') ,
('BVT', 'Isla Bouvet') ,
('IMN', 'Isla de Man') ,
('CXR', 'Isla de Navidad') ,
('NFK', 'Isla Norfolk') ,
('ISL', 'Islandia') ,
('CYM', 'Islas Caimán (las)') ,
('CCK', 'Islas Cocos (Keeling)') ,
('COK', 'Islas Cook (las)') ,
('FRO', 'Islas Feroe (las)') ,
('SGS', 'Georgia del sur y las islas sandwich del sur') ,
('HMD', 'Isla Heard e Islas McDonald') ,
('FLK', 'Islas Malvinas [Falkland] (las)') ,
('MNP', 'Islas Marianas del Norte (las)') ,
('MHL', 'Islas Marshall (las)') ,
('PCN', 'Pitcairn') ,
('SLB', 'Islas Salomón (las)') ,
('TCA', 'Islas Turcas y Caicos (las)') ,
('UMI', 'Islas de Ultramar Menores de Estados Unidos (las)') ,
('VGB', 'Islas Vírgenes (Británicas)') ,
('VIR', 'Islas Vírgenes (EE.UU.)') ,
('ISR', 'Israel') ,
('ITA', 'Italia') ,
('JAM', 'Jamaica') ,
('JPN', 'Japón') ,
('JEY', 'Jersey') ,
('JOR', 'Jordania') ,
('KAZ', 'Kazajistán') ,
('KEN', 'Kenia') ,
('KGZ', 'Kirguistán') ,
('KIR', 'Kiribati') ,
('KWT', 'Kuwait') ,
('LAO', 'Lao, (la) República Democrática Popular') ,
('LSO', 'Lesoto') ,
('LVA', 'Letonia') ,
('LBN', 'Líbano') ,
('LBR', 'Liberia') ,
('LBY', 'Libia') ,
('LIE', 'Liechtenstein') ,
('LTU', 'Lituania') ,
('LUX', 'Luxemburgo') ,
('MAC', 'Macao') ,
('MDG', 'Madagascar') ,
('MYS', 'Malasia') ,
('MWI', 'Malaui') ,
('MDV', 'Maldivas') ,
('MLI', 'Malí') ,
('MLT', 'Malta') ,
('MAR', 'Marruecos') ,
('MTQ', 'Martinica') ,
('MUS', 'Mauricio') ,
('MRT', 'Mauritania') ,
('MYT', 'Mayotte') ,
('MEX', 'México') ,
('FSM', 'Micronesia (los Estados Federados de)') ,
('MDA', 'Moldavia (la República de)') ,
('MCO', 'Mónaco') ,
('MNG', 'Mongolia') ,
('MNE', 'Montenegro') ,
('MSR', 'Montserrat') ,
('MOZ', 'Mozambique') ,
('NAM', 'Namibia') ,
('NRU', 'Nauru') ,
('NPL', 'Nepal') ,
('NIC', 'Nicaragua') ,
('NER', 'Níger (el)') ,
('NGA', 'Nigeria') ,
('NIU', 'Niue') ,
('NOR', 'Noruega') ,
('NCL', 'Nueva Caledonia') ,
('NZL', 'Nueva Zelanda') ,
('OMN', 'Omán') ,
('NLD', 'Países Bajos (los)') ,
('PAK', 'Pakistán') ,
('PLW', 'Palaos') ,
('PSE', 'Palestina, Estado de') ,
('PAN', 'Panamá') ,
('PNG', 'Papúa Nueva Guinea') ,
('PRY', 'Paraguay') ,
('PER', 'Perú') ,
('PYF', 'Polinesia Francesa') ,
('POL', 'Polonia') ,
('PRT', 'Portugal') ,
('PRI', 'Puerto Rico') ,
('GBR', 'Reino Unido (el)') ,
('CAF', 'República Centroafricana (la)') ,
('CZE', 'República Checa (la)') ,
('MKD', 'Macedonia (la antigua República Yugoslava de)') ,
('COG', 'Congo') ,
('COD', 'Congo (la República Democrática del)') ,
('DOM', 'República Dominicana (la)') ,
('REU', 'Reunión') ,
('RWA', 'Ruanda') ,
('ROU', 'Rumania') ,
('RUS', 'Rusia, (la) Federación de') ,
('ESH', 'Sahara Occidental') ,
('WSM', 'Samoa') ,
('ASM', 'Samoa Americana') ,
('BLM', 'San Bartolomé') ,
('KNA', 'San Cristóbal y Nieves') ,
('SMR', 'San Marino') ,
('MAF', 'San Martín (parte francesa)') ,
('SPM', 'San Pedro y Miquelón') ,
('VCT', 'San Vicente y las Granadinas') ,
('SHN', 'Santa Helena, Ascensión y Tristán de Acuña') ,
('LCA', 'Santa Lucía') ,
('STP', 'Santo Tomé y Príncipe') ,
('SEN', 'Senegal') ,
('SRB', 'Serbia') ,
('SYC', 'Seychelles') ,
('SLE', 'Sierra leona') ,
('SGP', 'Singapur') ,
('SXM', 'Sint Maarten (parte holandesa)') ,
('SYR', 'Siria, (la) República Árabe') ,
('SOM', 'Somalia') ,
('LKA', 'Sri Lanka') ,
('SWZ', 'Suazilandia') ,
('ZAF', 'Sudáfrica') ,
('SDN', 'Sudán (el)') ,
('SSD', 'Sudán del Sur') ,
('SWE', 'Suecia') ,
('CHE', 'Suiza') ,
('SUR', 'Surinam') ,
('SJM', 'Svalbard y Jan Mayen') ,
('THA', 'Tailandia') ,
('TWN', 'Taiwán (Provincia de China)') ,
('TZA', 'Tanzania, República Unida de') ,
('TJK', 'Tayikistán') ,
('IOT', 'Territorio Británico del Océano Índico (el)') ,
('ATF', 'Territorios Australes Franceses (los)') ,
('TLS', 'Timor-Leste') ,
('TGO', 'Togo') ,
('TKL', 'Tokelau') ,
('TON', 'Tonga') ,
('TTO', 'Trinidad y Tobago') ,
('TUN', 'Túnez') ,
('TKM', 'Turkmenistán') ,
('TUR', 'Turquía') ,
('TUV', 'Tuvalu') ,
('UKR', 'Ucrania') ,
('UGA', 'Uganda') ,
('URY', 'Uruguay') ,
('UZB', 'Uzbekistán') ,
('VUT', 'Vanuatu') ,
('VAT', 'Santa Sede[Estado de la Ciudad del Vaticano] (la)') ,
('VEN', 'Venezuela, República Bolivariana de') ,
('VNM', 'Viet Nam') ,
('WLF', 'Wallis y Futuna') ,
('YEM', 'Yemen') ,
('DJI', 'Yibuti') ,
('ZMB', 'Zambia') ,
('ZWE', 'Zimbabue') ,
('ZZZ', 'Países no declarados');


INSERT INTO supportStatus (
    spe_desc
    , spe_badge
) VALUES
('Resuelto', 'badge badge-success')
, ('En proceso', 'badge badge-enviado')
, ('Pendiente', 'badge badge-warning');

INSERT INTO faq_category (
    fqc_view
    , fqc_desc
) VALUES
(1, 'Agenda')
, (1, 'Mi Terapia')
, (1, 'Mi Terapeuta')
, (1, 'Mi Perfil')
, (1, 'Crédito')
, (1, 'Soporte')
, (2, 'Agenda')
, (2, 'Mi Terapia')
, (2, 'Mi Perfil')
, (2, 'Expedientes')
, (2, 'Soporte');

INSERT INTO faq_question (
    fqq_st_id
    , fqq_question
    , fqq_cat
) VALUES 
(1, '¿Cómo agendo una cita?', 1)
, (1, '¿Cómo sé que mi terapeuta confirmó nuestra cita?', 1)
, (1, '¿Cómo interpreto los colores de las citas visibles en mi agenda?', 1)
, (1, '¿Qué ocurre si mi terapeuta no confirma la cita solicitada?', 1)
, (1, '¿Qué motivos tiene mi terapeuta para cancelar su sesión?', 1)
, (1, '¿Qué pasa si mi sesión es aceptada?', 1)
, (1, '¿Cómo cancelo una cita?', 1)
, (1, '¿Qué hago si me equivoco agendadndo una cita?', 1)
, (1, '¿Qúe pasa si cancelo mi cita despueés de las 12h?', 1)
, (1, '¿Cuál es el huso horario de la agenda?', 1)
, (1, '¿Cuántas citas puedo agendar de una vez?', 1)
, (1, '¿Puedo agendar todas mis citas en un mismo día?', 1)
, (1, '¿Qué puedo encontrar aquí?¿Para qué sirve?', 2)
, (1, '¿Qué es esto?', 3)
, (1, '¿Qué puedo encontrar en MI PERFIL?', 4)
, (1, '¿Tengo que rellenar todos los datos personales?', 4)
, (1, '¿Quién puede acceder a mi información?', 4)
, (1, '¿Qué es la historia clínica?', 4)
, (1, 'Si deseo cambiar de terapeuta, ¿Se pierde mi información?', 4)
, (1, '¿Cómo cambio mis datos de información?', 4)
, (1, '¿Qué puedo hacer aquí?', 5)
, (1, '¿Cómo consigo un código de descuento?', 5)
, (1, '¿Cómo canjeo mi código?', 5)
, (1, '¿Qué puedo hacer aquí?', 6)
, (1, '¿Cuánto tiempo tardan en resolver mi problema?', 6)
, (1, '¿Quién puede agendar las sesiones?', 7)
, (1, '¿Tengo que confirmar la sesión al paciente para que quede aceptada?', 7)
, (1, '¿Qué ocurre si deseo cancelar o rechazar una sesión?', 7)
, (1, '¿Cómo interpreto los colores de las citas visibles en mi agenda?', 7)
, (1, '¿Qué ocurre al aceptar la sesión?', 7)
, (1, '¿Qué pasa si mi paciente cancela su cita?', 7)
, (1, '¿Cuál es el Huso horario de la agenda?', 7)
, (1, '¿Cuántas citas puede agendar mi paciente de una vez?', 7)
, (1, '¿Pueden agendar todas las citas en un mismo día?', 7)
, (1, '¿Qué puedo encontrar aquí?', 8)
, (1, '¿Para qué sirve?', 9)
, (1, '¿Qué información debe recoger el expediente?', 10)
, (1, '¿Debo rellenar todos los campos?', 10)
, (1, '¿Cuándo puedo transferir o derivar un paciente?', 10)
, (1, '¿Mi paciente puede elegir ser transferido?', 10)
, (1, 'Sí me derivan un paciente, ¿Qué información tendré de él?', 10)
, (1, '¿Qué puedo hacer aquí?', 11)
, (1, '¿Cuánto tiempo tardan en resolver mi problema?', 11);

INSERT INTO faq_answers (
    fqa_st_id
    , fqa_q_id
    , fqa_answer
    , fqa_cat
) VALUES
(1, 1, '<div class="text-justify">Debes hacer click en el horario de tu preferencia, confirmar el medio de contacto mediante el que deseas tomar tu sesión (Videollamada o chat) y hacer click en aceptar. Inmediatamente tu terapeuta recibirá tu solicitud. Debes esperar que tu solicitud sea aceptada por tu terapeuta para que tu cita quede confirmada. Este proceso puede tardar unos minutos.</div>', 1)
, (1, 2, '<div class="text-justify">Al iniciar sesión podrás observar una campanita arriba a la derecha, junto a tu nombre de usuario, ahí es donde te llegarán las notificaciones tanto de aceptación como de rechazo de tu solicitud de sesión.<br><br>
También puedes observar tu AGENDA, en la que podrás visualizar el estatus de tu sesión. (Puedes interpretarlo con la leyenda visible en la parte inferior derecha).<br><br>
Además de las anteriores también puedes saber el estatus de tu sesión en la sección de MI TERAPIA dónde aparece al detalle la información de tus sesiones</div>.
', 1)
, (1, 3, '<div class="text-justify">En la parte baja izquierda de tu AGENDA puedes observar una leyenda con la interpretación de los colores de tus sesiones.<br><br><ul><li><span class="text-default">Color gris:</span><label>&nbsp;&nbsp;Espacio No disponible</label></li><li><span class="text-agendado">Color verde:</span><label>&nbsp;&nbsp;Sesión agendada</label></li><li><span class="text-enviado">Color azul:</span><label>&nbsp;&nbsp;Sesión enviada</label></li><li><span class="text-reprogramado">Color naranja:</span><label>&nbsp;&nbsp;Sesión reprogramada</label></li><li><span class="text-cancelado">Color rojo:</span><label>&nbsp;&nbsp;Sesión cancelada</label></li></ul></div>', 1)
, (1, 4, '<div class="text-justity">Tu terapeuta puede elegir no aceptar la cita solicitada. En ese caso, deberás programar una nueva cita. (Ver pregunta 2 para más información)</div>',1);