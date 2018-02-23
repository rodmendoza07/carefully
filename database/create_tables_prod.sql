/* Usuarios */
DROP TABLE IF EXISTS `usuarios` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `usuarios` (
  `usr_id` INT NOT NULL AUTO_INCREMENT,
  `usr_nombre` VARCHAR(45) NOT NULL DEFAULT '',
  `usr_paterno` VARCHAR(45) NOT NULL DEFAULT '',
  `usr_materno` VARCHAR(45) NOT NULL DEFAULT '',
  `usr_departamento_id` INT NOT NULL DEFAULT 0,
  `usr_puesto_id` INT NOT NULL DEFAULT 0,
  `usr_nivelUsr_id` INT NOT NULL DEFAULT 0,
  `usr_login` VARCHAR(45) NOT NULL DEFAULT '',
  `usr_password` VARCHAR(45) NOT NULL DEFAULT '',
  `usr_nacionalidad_id` INT NULL,
  `usr_correo` VARCHAR(100) NOT NULL UNIQUE DEFAULT '',
  `usr_casa` VARCHAR(15) NOT NULL DEFAULT '55-0000-0000',
  `usr_movil` VARCHAR(15) NOT NULL DEFAULT '55-0000-0000',
  `usr_estatus` TINYINT NOT NULL DEFAULT 1,
  `usr_fecha_alta` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `usr_usr_id_alta` INT NOT NULL DEFAULT 0,
  `usr_fecha_actualizacion` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  `usr_usr_id_actualizacion` INT NOT NULL,
  `usr_fecha_cancelacion` DATETIME NULL,
  `usr_usr_id_cancelacion` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`usr_id`))
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE UNIQUE INDEX `usr_id_UNIQUE` ON `usuarios` (`usr_id` ASC);

SHOW WARNINGS;

/* Staff */
DROP TABLE IF EXISTS `staff` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `staff` (
  `st_id` INT NOT NULL AUTO_INCREMENT,
  `st_nombre` VARCHAR(45) NOT NULL DEFAULT '',
  `st_paterno` VARCHAR(45) NOT NULL DEFAULT '',
  `st_materno` VARCHAR(45) NOT NULL DEFAULT '',
  `st_departamento_id` INT NOT NULL DEFAULT 0,
  `st_puesto_id` INT NOT NULL DEFAULT 0,
  `st_nivelUsr_id` INT NOT NULL DEFAULT 0,
  `st_login` VARCHAR(45) NOT NULL DEFAULT '',
  `st_password` VARCHAR(45) NOT NULL DEFAULT '',
  `st_nacionalidad_id` INT NULL,
  `st_correo` VARCHAR(100) NOT NULL UNIQUE DEFAULT '',
  `st_casa` VARCHAR(15) NOT NULL DEFAULT '55-0000-0000',
  `st_movil` VARCHAR(15) NOT NULL DEFAULT '55-0000-0000',
  `st_estatus` TINYINT NOT NULL DEFAULT 1,
  `st_fecha_alta` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `st_usr_id_alta` INT NOT NULL DEFAULT 0,
  `st_fecha_actualizacion` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  `st_usr_id_actualizacion` INT NOT NULL DEFAULT 0,
  `st_fecha_cancelacion` DATETIME NULL,
  `st_usr_id_cancelacion` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`st_id`))
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE UNIQUE INDEX `st_id_UNIQUE` ON `staff` (`st_id` ASC);

SHOW WARNINGS;

/* Configuraciones */
DROP TABLE IF EXISTS `configuraciones` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `configuraciones` (
  `cfg_id` INT NOT NULL AUTO_INCREMENT,
  `cfg_nombre` VARCHAR(45) NOT NULL DEFAULT '',
  `cfg_valor` VARCHAR(100) NOT NULL DEFAULT '',
  `cfg_estatus` TINYINT NOT NULL DEFAULT 1 COMMENT 'Configuraciones generales de la aplicación:\n\nInicio de Consultas\nTermino de Consultar\n\nCorreo de Envió de mails etc',
  `cfg_fecha_alta` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `cfg_usr_id_alta` INT NOT NULL DEFAULT 0,
  `cfg_fecha_cancelacion` DATETIME NULL,
  `cfg_usr_id_cancelacion` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`cfg_id`))
ENGINE = InnoDB;

SHOW WARNINGS;

/* Expediente Paciente */
DROP TABLE IF EXISTS `expedientepaciente` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `expedientepaciente` (
  `expP_id` INT NOT NULL AUTO_INCREMENT,
  `expP_fecha_alta` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expP_doctor_id` INT NOT NULL DEFAULT 0,
  `expP_paciente_id` INT NOT NULL DEFAULT 0,
  `expP_estatus` TINYINT NOT NULL DEFAULT 1,
  /*`expP_fecha_alta` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,*/
  `expP_usr_id_alta` INT NOT NULL DEFAULT 0,
  `expP_fecha_cancelacion` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  `expP_usr_id_cancelacion` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`expP_id`))
ENGINE = InnoDB;

SHOW WARNINGS;

/* Sesiones validas */
DROP TABLE IF EXISTS `validateSess` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `validateSess` (
  `vs_id` INT NOT NULL AUTO_INCREMENT,
  `vs_createat` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `vs_usr_id` INT NOT NULL DEFAULT 0,
  `vs_st_id` INT NOT NULL DEFAULT 0,
  `vs_hash` VARCHAR(50) NOT NULL DEFAULT '',
  `vs_status` INT NOT NULL DEFAULT 0,
  `vs_activateat` DATETIME NULL,
  PRIMARY KEY (`vs_id`))
ENGINE = InnoDB;

SHOW WARNINGS;

/* Token validos */
DROP TABLE IF EXISTS `validtokens` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `validtokens` (
  `vt_id` INT NOT NULL AUTO_INCREMENT,
  `vt_createat` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `vt_usr_id` INT NOT NULL DEFAULT 0,
  `vt_st_id` INT NOT NULL DEFAULT 0,
  `vt_hash` VARCHAR(50) NOT NULL DEFAULT '',
  `vt_status` INT NOT NULL DEFAULT 1,
  PRIMARY KEY (`vt_id`))
ENGINE = InnoDB;

SHOW WARNINGS;

/* Citas */
DROP TABLE IF EXISTS `citas` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `citas` (
  `cita_id` INT NOT NULL AUTO_INCREMENT,
  `cita_fecha_start` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `cita_fecha_end` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `cita_paciente_id` INT NOT NULL DEFAULT 0,
  `cita_doctor_id` INT NOT NULL DEFAULT 0,
  `cita_estatus` TINYINT NOT NULL DEFAULT 1,
  `cita_fecha_alta` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `cita_usr_id_alta` INT NOT NULL DEFAULT 0,
  `cita_doctor_id_alta` INT NOT NULL DEFAULT 0,
  `cita_usr_id_update` INT NOT NULL DEFAULT 0,
  `cita_st_update` INT NOT NULL DEFAULT 0,
  `cita_fecha_update` DATETIME NULL,
  `cita_fecha_cancelacion` DATETIME NULL,
  `cita_usr_id_cancelacion` INT NOT NULL DEFAULT 0,
  `cita_st_id_cancelacion` INT NOT NULL DEFAULT 0,
  `cita_title` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`cita_id`))
ENGINE = InnoDB;

SHOW WARNINGS;

/* Tipos de citas */
DROP TABLE IF EXISTS `citas_communication` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `citas_communication` (
  `cc_id` INT NOT NULL AUTO_INCREMENT,
  `cc_desc` VARCHAR(40) NOT NULL DEFAULT '',
  `cc_createat` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `cc_status` INT NOT NULL DEFAULT 1,
  PRIMARY KEY (`cc_id`))
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE UNIQUE INDEX `cc_id_UNIQUE` ON `citas_communication` (`cc_id` ASC);

SHOW WARNINGS;

/* Validación de citas */
DROP TABLE IF EXISTS `citas_validation` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `citas_validation` (
  `cv_id` INT NOT NULL AUTO_INCREMENT,
  `cv_c_id` INT NOT NULL DEFAULT 0,
  `cv_createat` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `cv_validat` DATETIME,
  `cv_status` TINYINT NOT NULL DEFAULT 0,
  `cv_status_view` TINYINT NOT NULL DEFAULT 0,
  `cv_usr_id` INT NOT NULL DEFAULT 0,
  `cv_st_id` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`cv_id`))
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE UNIQUE INDEX `cv_id_UNIQUE` ON `citas_validation` (`cv_id` ASC);

SHOW WARNINGS;

/* Estados de la cita */
DROP TABLE IF EXISTS `citas_status` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `citas_status` (
  `cs_id` INT NOT NULL AUTO_INCREMENT,
  `cs_desc` VARCHAR(40) NOT NULL DEFAULT '',
  `cs_createat` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `cs_status` INT NOT NULL DEFAULT 1,
  `cs_color` VARCHAR(10) NOT NULL DEFAULT '',
  `cs_badge` VARCHAR(45) NOT NULL DEFAULT '',
  PRIMARY KEY (`cs_id`))
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE UNIQUE INDEX `cs_id_UNIQUE` ON `citas_status` (`cs_id` ASC);

SHOW WARNINGS;

/* Test */
DROP TABLE IF EXISTS `test_profile` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `test_profile` (
  `t_id` INT NOT NULL AUTO_INCREMENT,
  `t_usr_id` INT NOT NULL DEFAULT 0,
  `t_gender` INT NOT NULL DEFAULT 0,
  `t_birthdate` DATETIME,
  `t_age` INT NOT NULL DEFAULT 0,
  `t_service` INT NOT NULL DEFAULT 0,
  `t_therapyBefore` INT NOT NULL DEFAULT 0,
  `t_health` INT NOT NULL DEFAULT 0,
  `t_sleep` INT NOT NULL DEFAULT 0,
  `t_emotion_freq` INT NOT NULL DEFAULT 0,
  `t_anxiety` INT NOT NULL DEFAULT 0,
  `t_relationship` INT NOT NULL DEFAULT 0,
  `t_relationship_freq` INT NOT NULL DEFAULT 0,
  `t_reference` INT NOT NULL DEFAULT 0,
  `t_civilState` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`t_id`))
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE UNIQUE INDEX `t_id_UNIQUE` ON `test_profile` (`t_id` ASC);

SHOW WARNINGS;

/* Estado civil */
DROP TABLE IF EXISTS `civil_estado` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `civil_estado` (
  `ce_id` INT NOT NULL AUTO_INCREMENT,
  `ce_desc` VARCHAR(45) NOT NULL DEFAULT '',
  `ce_createat` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ce_status` INT NOT NULL DEFAULT 1,
  PRIMARY KEY (`ce_id`))
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE UNIQUE INDEX `ce_id_UNIQUE` ON `civil_estado` (`ce_id` ASC);

SHOW WARNINGS;

/* Catalogo Genero */
DROP TABLE IF EXISTS `gender` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `gender` (
  `g_id` INT NOT NULL AUTO_INCREMENT,
  `g_desc` VARCHAR(45) NOT NULL DEFAULT '',
  `g_createat` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `g_status` INT NOT NULL DEFAULT 1, 
  PRIMARY KEY (`g_id`))
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE UNIQUE INDEX `g_id_UNIQUE` ON `gender` (`g_id` ASC);

SHOW WARNINGS;

/* Catalogo emociones */
DROP TABLE IF EXISTS `emotions` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `emotions` (
  `e_id` INT NOT NULL AUTO_INCREMENT,
  `e_desc` VARCHAR(45) NOT NULL DEFAULT '',
  `e_createat` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `e_status` INT NOT NULL DEFAULT 1, 
  PRIMARY KEY (`e_id`))
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE UNIQUE INDEX `e_id_UNIQUE` ON `emotions` (`e_id` ASC);

SHOW WARNINGS;

/* Catalogo de frecuencia */
DROP TABLE IF EXISTS `frequency` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `frequency` (
  `f_id` INT NOT NULL AUTO_INCREMENT,
  `f_desc` VARCHAR(45) NOT NULL DEFAULT '',
  `f_createat` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `f_status` INT NOT NULL DEFAULT 1, 
  PRIMARY KEY (`f_id`))
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE UNIQUE INDEX `f_id_UNIQUE` ON `frequency` (`f_id` ASC);

SHOW WARNINGS;

/* Catalogo de referencias */
DROP TABLE IF EXISTS `reference` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `reference` (
  `r_id` INT NOT NULL AUTO_INCREMENT,
  `r_desc` VARCHAR(45) NOT NULL DEFAULT '',
  `r_createat` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `r_status` INT NOT NULL DEFAULT 1, 
  PRIMARY KEY (`r_id`))
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE UNIQUE INDEX `r_id_UNIQUE` ON `reference` (`r_id` ASC);

SHOW WARNINGS;

/* Detalle test de emociones */
DROP TABLE IF EXISTS `testD_emotions` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `testD_emotions` (
  `tde_id` INT NOT NULL AUTO_INCREMENT,
  `tde_emotion_id` INT NOT NULL DEFAULT 0,
  `tde_createat` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`tde_id`))
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE UNIQUE INDEX `tde_id_UNIQUE` ON `testD_emotions` (`tde_id` ASC);

SHOW WARNINGS;

/* Detalle test de medicamentos */
DROP TABLE IF EXISTS `testD_medicine` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `testD_medicine` (
  `tdm_id` INT NOT NULL AUTO_INCREMENT,
  `tdm_emotion_id` INT NOT NULL DEFAULT 0,
  `tdm_createat` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`tdm_id`))
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE UNIQUE INDEX `tdm_id_UNIQUE` ON `testD_medicine` (`tdm_id` ASC);

SHOW WARNINGS;

/* Detalle descripcion adicional en perfil de usuario */
DROP TABLE IF EXISTS `patientAddon` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `patientAddon` (
  `pa_id` INT NOT NULL AUTO_INCREMENT,
  `pa_usr_id` INT NOT NULL DEFAULT 0,
  `pa_addon` TEXT NOT NULL DEFAULT '',
  `pa_createat` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `pa_updateat` DATETIME,
  PRIMARY KEY (`pa_id`))
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE UNIQUE INDEX `pa_id_UNIQUE` ON `patientAddon` (`pa_id` ASC);

SHOW WARNINGS;