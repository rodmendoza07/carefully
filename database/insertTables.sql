USE cuidadosamente;

INSERT INTO configuraciones (
	cfg_nombre
    , cfg_valor
) VALUES (
	'secret'
    , 'Uncarefully'
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
) VALUES
    ('Enviada', '#29ABE2')
    , ('Agendada', '#8CC63F')
    , ('Reprogramada', '#FBB03B')
    , ('Cancelada', '#F15A24');

INSERT INTO citas_communication (
    cc_desc
) VALUES
    ('Chat')
    , ('Videoconferencia');

SELECT * FROM configuraciones;