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

INSERT INTO available_hours (
    hh_start
    , hh_end
) VALUES (
    '8:00:00'
    , '20:00:00'
);

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
