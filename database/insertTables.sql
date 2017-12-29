USE cuidadosamente;

INSERT INTO configuraciones (
	cfg_nombre
    , cfg_valor
) VALUES (
	'secret'
    , 'Uncarefully'
);

INSERT INTO depatamentos(
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

SELECT * FROM configuraciones;