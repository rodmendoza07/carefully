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
    , '0:00:00'
), (
    'hh_end'
    , '23:59:59'
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
VALUES 
    ('admin')
    , ('paciente')
    , ('terapeuta')
    , ('supervisor')
    , ('soporte');

INSERT INTO citas_status (
    cs_desc
    , cs_color
    , cs_badge
) VALUES
    ('Enviada', '#29ABE2', 'badge badge-enviado')
    , ('Agendada', '#8CC63F', 'badge badge-info')
    , ('Reprogramada', '#FBB03B', 'badge badge-reprogramado')
    , ('Cancelada', '#F15A24', 'badge badge-cancelado')
    , ('Fecha bloqueada', '#B3B3B3', 'badge badge-bloqueado')
    , ('Fecha desbloqueada', '#27C24C', 'badge badge-success');

INSERT INTO citas_communication (
    cc_desc
) VALUES
    ('Chat')
    , ('Videoconferencia')
    , ('No disponible');

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
    nacionalidad_abreviatura
    , nacionalidad_desc
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
('BOL', 'Bolivia') ,
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
('PRK', 'Corea del Norte') ,
('KOR', 'Corea del Sur') ,
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
('ARE', 'Emiratos Árabes Unidos') ,
('ERI', 'Eritrea') ,
('SVK', 'Eslovaquia') ,
('SVN', 'Eslovenia') ,
('ESP', 'España') ,
('USA', 'Estados Unidos') ,
('EST', 'Estonia') ,
('ETH', 'Etiopía') ,
('PHL', 'Filipinas') ,
('FIN', 'Finlandia') ,
('FJI', 'Fiyi') ,
('FRA', 'Francia') ,
('GAB', 'Gabón') ,
('GMB', 'Gambia') ,
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
('IRN', 'Irán') ,
('IRL', 'Irlanda') ,
('BVT', 'Isla Bouvet') ,
('IMN', 'Isla de Man') ,
('CXR', 'Isla de Navidad') ,
('NFK', 'Isla Norfolk') ,
('ISL', 'Islandia') ,
('CYM', 'Islas Caimán') ,
('CCK', 'Islas Cocos (Keeling)') ,
('COK', 'Islas Cook') ,
('FRO', 'Islas Feroe') ,
('HMD', 'Isla Heard e Islas McDonald') ,
('FLK', 'Islas Malvinas [Falkland]') ,
('MNP', 'Islas Marianas del Norte') ,
('MHL', 'Islas Marshall') ,
('PCN', 'Pitcairn') ,
('SLB', 'Islas Salomón') ,
('TCA', 'Islas Turcas y Caicos') ,
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
('LAO', 'Lao') ,
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
('FSM', 'Micronesia') ,
('MDA', 'Moldavia') ,
('MCO', 'Mónaco') ,
('MNG', 'Mongolia') ,
('MNE', 'Montenegro') ,
('MSR', 'Montserrat') ,
('MOZ', 'Mozambique') ,
('NAM', 'Namibia') ,
('NRU', 'Nauru') ,
('NPL', 'Nepal') ,
('NIC', 'Nicaragua') ,
('NER', 'Níger') ,
('NGA', 'Nigeria') ,
('NIU', 'Niue') ,
('NOR', 'Noruega') ,
('NCL', 'Nueva Caledonia') ,
('NZL', 'Nueva Zelanda') ,
('OMN', 'Omán') ,
('NLD', 'Países Bajos') ,
('PAK', 'Pakistán') ,
('PLW', 'Palaos') ,
('PSE', 'Palestina') ,
('PAN', 'Panamá') ,
('PNG', 'Papúa Nueva Guinea') ,
('PRY', 'Paraguay') ,
('PER', 'Perú') ,
('PYF', 'Polinesia Francesa') ,
('POL', 'Polonia') ,
('PRT', 'Portugal') ,
('PRI', 'Puerto Rico') ,
('GBR', 'Reino Unido') ,
('CAF', 'República Centroafricana') ,
('CZE', 'República Checa') ,
('MKD', 'Macedonia') ,
('COG', 'Congo') ,
('COD', 'Congo (República Democrática)') ,
('DOM', 'República Dominicana') ,
('REU', 'Reunión') ,
('RWA', 'Ruanda') ,
('ROU', 'Rumania') ,
('RUS', 'Rusia') ,
('ESH', 'Sahara Occidental') ,
('WSM', 'Samoa') ,
('ASM', 'Samoa Americana') ,
('BLM', 'San Bartolomé') ,
('KNA', 'San Cristóbal y Nieves') ,
('SMR', 'San Marino') ,
('MAF', 'San Martín') ,
('SPM', 'San Pedro y Miquelón') ,
('VCT', 'San Vicente y las Granadinas') ,
('LCA', 'Santa Lucía') ,
('STP', 'Santo Tomé y Príncipe') ,
('SEN', 'Senegal') ,
('SRB', 'Serbia') ,
('SYC', 'Seychelles') ,
('SLE', 'Sierra leona') ,
('SGP', 'Singapur') ,
('SXM', 'Sint Maarten') ,
('SYR', 'Siria') ,
('SOM', 'Somalia') ,
('LKA', 'Sri Lanka') ,
('SWZ', 'Suazilandia') ,
('ZAF', 'Sudáfrica') ,
('SDN', 'Sudán') ,
('SSD', 'Sudán del Sur') ,
('SWE', 'Suecia') ,
('CHE', 'Suiza') ,
('SUR', 'Surinam') ,
('SJM', 'Svalbard y Jan Mayen') ,
('THA', 'Tailandia') ,
('TWN', 'Taiwán') ,
('TZA', 'Tanzania') ,
('TJK', 'Tayikistán') ,
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
('VAT', 'Santa Sede [Vaticano]') ,
('VEN', 'Venezuela') ,
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
(1, 'AGENDA')
, (1, 'MI TERAPIA')
, (1, 'MI TERAPEUTA')
, (1, 'MI PERFIL')
, (1, 'CRÉDITO')
, (1, 'SOPORTE')
, (2, 'AGENDA')
, (2, 'MI TERAPIA')
, (2, 'MI PERFIL')
, (2, 'EXPEDIENTES')
, (2, 'SOPORTE');

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
, (1, '¿Qúe pasa si cancelo mi cita después de las 12h?', 1)
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
(1, 1, '<div class="text-justify font-faqs">Debes hacer click en el horario de tu preferencia, confirmar el medio de contacto mediante el que deseas tomar tu sesión (Videollamada o chat) y hacer click en aceptar. Inmediatamente tu terapeuta recibirá tu solicitud. Debes esperar que tu solicitud sea aceptada por tu terapeuta para que tu cita quede confirmada. Este proceso puede tardar unos minutos.</div>', 1)
, (1, 2, '<div class="text-justify font-faqs">Al iniciar sesión podrás observar una campanita arriba a la derecha, junto a tu nombre de usuario, ahí es donde te llegarán las notificaciones tanto de aceptación como de rechazo de tu solicitud de sesión.<br><br>También puedes observar tu AGENDA, en la que podrás visualizar el estatus de tu sesión. (Puedes interpretarlo con la leyenda visible en la parte inferior derecha).<br><br>Además de las anteriores también puedes saber el estatus de tu sesión en la sección de MI TERAPIA dónde aparece al detalle la información de tus sesiones</div>.', 1)
, (1, 3, '<div class="text-justify font-faqs">En la parte baja izquierda de tu AGENDA puedes observar una leyenda con la interpretación de los colores de tus sesiones.<br><br><ul><li><span class="text-default">Color gris:</span><label>&nbsp;&nbsp;Espacio No disponible</label></li><li><span class="text-agendado">Color verde:</span><label>&nbsp;&nbsp;Sesión agendada</label></li><li><span class="text-enviado">Color azul:</span><label>&nbsp;&nbsp;Sesión enviada</label></li><li><span class="text-reprogramado">Color naranja:</span><label>&nbsp;&nbsp;Sesión reprogramada</label></li><li><span class="text-cancelado">Color rojo:</span><label>&nbsp;&nbsp;Sesión cancelada</label></li></ul></div>', 1)
, (1, 4, '<div class="text-justity font-faqs">Tu terapeuta puede elegir no aceptar la cita solicitada. En ese caso, deberás programar una nueva cita. (Ver pregunta 2 para más información)</div>',1)
, (1, 5, '<div class="text-justify font-faqs">Los motivos por los que tu terapeuta puede cancelar tu sesión son siempre personales y de importancia. Y todos quedan registrados en su expediente. Si observas que tu terapeuta cancela repetitivamente las citas háznoslo saber en el siguiente correo:  XX@cuidadosamente.com</div>',1)
, (1, 6, '<div class="text-justify font-faqs">Solo deberás conectarte el día de tu cita, 5 min antes de tu sesión y empezar con tu terapia.</div>', 1)
, (1, 7, '<div class="text-justify font-faqs">Muy sencillo, solo debes hacer click en la agenda, encima de tu cita y cambiar la opción de “agendada” por “cancelar”. Recuerda que sólo puedes cancelar tu cita 12 horas antes de tu sesión, en caso contrario, no podrás recuperar tu sesión.</div>', 1)
, (1, 8, '<div class="text-justify font-faqs">Cada vez que agendas una cita cuentas con 15 minutos desde la hora en que la agendaste para modificarla de manera inmediata, si deseas cancelar o modificar tu sesión después de este periodo, debes asegurarte que no rebasas las 12 horas previas a tu cita.</div>',1)
, (1, 9, '<div class="text-justify font-faqs">Una vez agendes tu cita, debes tomar en cuenta que solo podrás cancelarla 12 horas antes del horario de tu sesión, de lo contrario no la podrás recuperar.</div>', 1)
, (1, 10, '<div class="text-justify font-faqs">Recuerda que el horario que elijes para tu sesión en la AGENDA siempre corresponde al huso horario de la CDMX, por lo que si agendas tu cita a las 10.00 am, tu cita será a las 10.00am de la Ciudad de México. Si estás en otro estado o país, deberás tomar en cuenta la diferencia horaria.</div>', 1)
, (1, 11, '<div class="text-justify font-faqs">Puedes agendar tantas citas como hayas pagado, sin embargo, te recomendamos estar muy al pendiente porque los horarios de tu terapeuta pueden variar cada semana y las citas pueden ser reprogramadas.</div>', 1)
, (1, 12, '<div class="text-justify font-faqs">Sí, siempre que tu terapeuta tenga el espacio disponible. Sin embargo esto no es recomendable en la mayoría de los tratamientos.</div>', 1)
, (1, 13, '<div class="text-justify font-faqs">Mi TERAPIA recoge información de tus sesiones para que lleves un registro de las mismas. Tanto de las sesiones que ya recibiste, como las que están agendadas y próximas a tomar. Podrás observar fecha de tu sesión, horario elegido, nombre de tu terapeuta y el estatus de tu cita.</div>', 2)
, (1, 14, '<div class="text-justify font-faqs">MI TERAPEUTA recoge un resumen de la información profesional de tu especialista. Su  nombre,  nacionalidad, estudios, experiencia profesional y una breve presentación para que lo conozcas un poco más.</div>', 3)
, (1, 15, '<div class="text-justify font-faqs">En esta sección se recogen los datos que rellenaste en el cuestionario inicial. Además podrás  completar o modificar la información que quieras que tu terapeuta reciba sobre tus datos personales.</div>', 4)
, (1, 16, '<div class="text-justify font-faqs">No es obligatorio, pero si necesario que rellenes algunos datos personales básicos para que tu terapeuta tenga la información mínima necesaria sobre ti. Entre más información rellenes, mayor información tendrá y en consecuencia más sabrá de ti y de tu problema.</div>', 4)
, (1, 17, '<div class="text-justify font-faqs">Solo tú y tu terapeuta.</div>', 4)
, (1, 18, '<div class="text-justify font-faqs">Es la información de tu caso que tu terapeuta comparte contigo. Además de ésta información tu terapeuta elabora un expediente mucho más complejo y completo para poder dar seguimiento a tu caso.</div>', 4)
, (1, 19, '<div class="text-justify font-faqs">Para nada, tanto en el caso de derivaciones, como si quisieras cambiar de terapeuta, toda tu información personal y clínica se envía al nuevo terapeuta, para que esté completamente informado y al día con tu progreso.</div>', 4)
, (1, 20, '<div class="text-justify font-faqs">Muy sencillo, en la sección de mi perfil solo debes hacer click en "editar" y ahí podrás modificar tu información en el caso de que existiera algún error en la misma.</div>', 4)
, (1, 21, '<div class="text-justify font-faqs">En esta sección puedes visualizar toda la información referente a los pagos realizados, fecha, hora, descripción de pago, así como el número de sesiones y el monto total del cargo.<br><br>También puedes comprar sesiones y canjear códigos de descuento.</div>', 5)
, (1, 22, '<div class="text-justify font-faqs">Los códigos de descuento los puedes conseguir a través de ofertas que llegan a tu correo, promociones en nuestras redes sociales o compras de regalos que puedes encontrar en la sección de “Regala felicidad”</div>', 5)
, (1, 23, '<div class="text-justify font-faqs">Solamente tienes que dirigirte a la sección de CRÉDITO e introducir tu código en el recuadro de la izquierda, posteriormente solo debes hacer click en Canjear.</div>', 5)
, (1, 24, '<div class="text-justify font-faqs">En el caso que existiera algún problema en el funcionamiento de tu sesión puedes reportarlo en esta sección, así mismo puedes consultar los reportes que ya hayas realizado y el estatus de los mismos.</div>', 6)
, (1, 25, '<div class="text-justify font-faqs">Esto dependerá del tipo de problema, sin embargo suele realizarse a la brevedad. En caso de que hayas enviado un reporte y tu problema no haya sido resuelto, puedes enviarnos un correo a soporte@cuidadosamnete.com</div>', 6)
, (1, 26, '<div class="text-justify font-faqs">Las sesiones deben ser elegidas por el paciente dentro del horario que tú señales para su efecto.</div>', 7)
, (1, 27, '<div class="text-justify font-faqs">Así es, una vez el paciente agende su cita, te llegará una solicitud o notificación que podrás visualizar en la campanita de arriba a la derecha. Podrás aceptar o rechazar la sesión. Recuerda que no puedes rechazar la sesión sin justificación previa.</div>', 7)
, (1, 28, '<div class="text-justify font-faqs">Sólo puedes cancelar o rechazar una sesión si tienes una justificación de peso para hacerlo. Recuerda que como máximo podrás cancelar 3 sesiones al año, por lo que se te recomienda elegir bien los horarios que pones a disposición para tus citas y así  evitar cancelaciones.</div>', 7)
, (1, 29, '<div class="text-justify font-faqs">En la parte baja izquierda de tu AGENDA puedes observar una leyenda con la interpretación de los colores de tus sesiones.<br><br><ul><li><span class="text-default">Color gris:</span><label>&nbsp;&nbsp;Espacio No disponible</label></li><li><span class="text-agendado">Color verde:</span><label>&nbsp;&nbsp;Sesión agendada</label></li><li><span class="text-enviado">Color azul:</span><label>&nbsp;&nbsp;Sesión enviada</label></li><li><span class="text-reprogramado">Color naranja:</span><label>&nbsp;&nbsp;Sesión reprogramada</label></li><li><span class="text-cancelado">Color rojo:</span><label>&nbsp;&nbsp;Sesión cancelada</label></li></ul></div>', 7)
, (1, 30, '<div class="text-justify font-faqs">Sólo deberás conectarte el día de tu cita, 5-10 min antes de tu sesión y empezar con tu terapia.</div>', 7)
, (1, 31, '<div class="text-justify font-faqs">Una vez tu paciente agende su cita, sólo podrá cancelarla hasta 12 horas antes del horario de vuestra sesión, de lo contrario, la sesión se dará por recibida.</div>', 7)
, (1, 32, '<div class="text-justify font-faqs">Recuerda que el horario de la agenda siempre corresponde al huso horario de la CDMX, por lo que si tu cita es a las 10.00 am,  deberás estar preparada a las 9.50  am de la Ciudad de México. Si estás en otro estado o país, deberás tomar en cuenta la diferencia horaria.</div>', 7)
, (1, 33, '<div class="text-justify font-faqs">Tu paciente puede agendar tantas citas como haya pagado, sin embargo, te recomendamos asesorarle en la periodicidad de sus citas.</div>', 7)
, (1, 34, '<div class="text-justify font-faqs">Sí, siempre que tu tengas el espacio disponible. Sin embargo, te recomendamos asesorarle en la periodicidad de sus citas.</div>', 7)
, (1, 35, '<div class="text-justify font-faqs">Mi TERAPIA recoge información de tus sesiones para que lleves un registro de las mismas. Tanto de las sesiones que ya recibieron tus pacientes, como las que están agendadas y próximas a tomar. Podrás observar fecha de tus sesiones, horario elegido por tus pacientes, los nombres de nombre de los mismos y el estatus de tus citas.</div>', 8)
, (1, 36, '<div class="text-justify font-faqs">Ésta sección recoge un resumen de tu información personal y profesional. Tu nombre,  nacionalidad, estudios, experiencia profesional y una breve presentación que deberás realizar para que tus pacientes te conozcan mejor.</div>', 9)
, (1, 37, '<div class="text-justify font-faqs">Si, ya que es necesario que tu paciente tenga la mayor información posible sobre tu carrera profesional y experiencia. Te recomendamos no poner información personal. Todo lo que escribas será validado antes de ser publicado por nuestro administrador.</div>', 9)
, (1, 38, '<div class="text-justify font-faqs">El informe clínico del paciente recogerá información general sobre el caso y la problemática del mismo, así como su funcionamiento, aspectos médicos y perfil social entre otros.</div>', 10)
, (1, 39, '<div class="text-justify font-faqs">Sí. Durante las dos primeras sesiones deberás rellenar la información básica de tu paciente. A lo largo del tratamiento irás completando con mayor información relevante.</div>', 10)
, (1, 40, '<div class="text-justify font-faqs">Sólo podrás hacerlo en el caso de que no exista evolución o avance en la problemática del paciente, y siempre con previo aviso y consentimiento de Cuidadosamente.</div>', 10)
, (1, 41, '<div class="text-justify font-faqs">Sí. Tu paciente puede decidir cambiar de terapeuta en el caso de que no se sienta cómodo en sus sesiones.</div>', 10)
, (1, 42, '<div class="text-justify font-faqs">Cuando un paciente es derivado toda su información personal y clínica se envía al nuevo terapeuta, para que esté completamente informado y al día con su problemática y avance. Por lo tanto tendrás toda la información que necesites para retomar el caso.</div>', 10)
, (1, 43, '<div class="text-justify font-faqs">En el caso que existiera algún problema en el funcionamiento de tu sesión puedes reportarlo en esta sección, así mismo puedes consultar los reportes que ya hayas realizado y el estatus de los mismos.</div>', 11)
, (1, 44, '<div class="text-justify font-faqs">Esto dependerá del tipo de problema, sin embargo suele realizarse a la brevedad. En caso de que hayas enviado un reporte y tu problema no haya sido resuelto, puedes enviarnos un correo a soporte@cuidadosamnete.com</div>', 11);

INSERT INTO menus (
    menu_descripcion
    , menu_parent
    , menu_url
) VALUES (
    'Pacientes' /*1*/
    , 0
    , 'patients'
), (
    'Baja de pacientes'/*2*/
    , 1
    , 'downpatient'
), (
    'Terapeutas' /*3*/
    , 0
    , 'therapist'
), (
    'Nuevo' /*4*/
    , 3
    , 'newTherapist'
), (
    'Modificar' /*5*/
    , 3
    , 'modifyTherapist'
), (
    'Soporte Técnico' /*6*/
    , 0
    , 'supportC'
); 

INSERT INTO accesos (
    nivel_usr
    , menu_id
), VALUES
    (1, 1)
    , (1, 2)
    , (1, 3)
    , (1, 4)
    , (1, 5)
    , (1, 6)
    , (4, 3)
    , (4, 4)
    , (4, 5)
    , (5, 6);