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

/* Puestos */
DROP TABLE IF EXISTS `puestos` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `puestos` (
  `puesto_id` INT NOT NULL AUTO_INCREMENT,
  `puesto_descripcion` VARCHAR(45) NOT NULL DEFAULT '',
  `puesto_estatus` TINYINT NOT NULL DEFAULT 1,
  PRIMARY KEY (`puesto_id`))
ENGINE = InnoDB;

SHOW WARNINGS;

/* Departamentos */

DROP TABLE IF EXISTS `departamentos` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `departamentos` (
  `depto_id` INT NOT NULL AUTO_INCREMENT,
  `depto_nombre` VARCHAR(45) NOT NULL DEFAULT '',
  `depto_abreviatura` VARCHAR(5) NOT NULL DEFAULT '',
  `depto_responsable` INT NOT NULL DEFAULT 0,
  `depto_fecha_alta` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `depto_usr_id_alta` INT NOT NULL DEFAULT 0,
  `depto_fecha_actualizacion` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  `depto_usr_id_actualizacion` INT NOT NULL DEFAULT 0,
  `depto_estatus` TINYINT NULL DEFAULT 1,
  PRIMARY KEY (`depto_id`))
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE UNIQUE INDEX `depto_id_UNIQUE` ON `departamentos` (`depto_id` ASC);

SHOW WARNINGS;

/* Nacionalidades */
DROP TABLE IF EXISTS `nacionalidades` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `nacionalidades` (
  `nacionalidad_id` INT NOT NULL AUTO_INCREMENT,
  `nacionalidad_desc` VARCHAR(45) NOT NULL DEFAULT '',
  `nacionalidad_abreviatura` VARCHAR(45) NOT NULL DEFAULT '',
  `nacionalidad_estatus` TINYINT NOT NULL DEFAULT 1,
  PRIMARY KEY (`nacionalidad_id`))
ENGINE = InnoDB;

SHOW WARNINGS;

/* Bitacora del paciente */

DROP TABLE IF EXISTS `bitacoraPaciente` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `bitacoraPaciente` (
  `bp_id` INT NOT NULL AUTO_INCREMENT,
  `bp_usr_id` INT NOT NULL DEFAULT 0,
  `bp_famHist` TEXT NOT NULL DEFAULT '',
  `bp_dynFam` TEXT NOT NULL DEFAULT '',
  `bp_reazons` TEXT NOT NULL DEFAULT '',
  `bp_actualProblem` TEXT NOT NULL DEFAULT '',
  `bp_medicalAspects` TEXT NOT NULL DEFAULT '',
  `bp_pshicological` TEXT NOT NULL DEFAULT '',
  `bp_trauma` TEXT NOT NULL DEFAULT '',
  `bp_socialProfile` TEXT NOT NULL DEFAULT '',
  PRIMARY KEY (`bp_id`))
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE UNIQUE INDEX `bp_id_UNIQUE` ON `bitacoraPaciente` (`bp_id` ASC);

SHOW WARNINGS;

/*faqs preguntas*/
DROP TABLE IF EXISTS `faq_question` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `faq_question` (
  `fqq_id` INT NOT NULL AUTO_INCREMENT,
  `fqq_st_id` INT NOT NULL DEFAULT 0,
  `fqq_question` TEXT NOT NULL DEFAULT '',
  `fqq_createat` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fqq_updateat` DATETIME,
  `fqq_st_id_update` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`fqq_id`))
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE UNIQUE INDEX `fqq_id_UNIQUE` ON `faq_question` (`fqq_id` ASC);

SHOW WARNINGS;

/* faqs respuestas */
DROP TABLE IF EXISTS `faq_answers` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `faq_answers` (
  `fqa_id` INT NOT NULL AUTO_INCREMENT,
  `fqa_st_id` INT NOT NULL DEFAULT 0,
  `fqa_q_id` INT NOT NULL DEFAULT 0,
  `fqa_answer` TEXT NOT NULL DEFAULT '',
  `fqa_createat` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fqa_updateat` DATETIME,
  `fqa_st_id_update` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`fqa_id`))
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE UNIQUE INDEX `fqa_id_UNIQUE` ON `faq_answers` (`fqa_id` ASC);

SHOW WARNINGS;

/*faqs tags para busqueda*/
DROP TABLE IF EXISTS `faq_tags` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `faq_tags` (
  `fqt_id` INT NOT NULL AUTO_INCREMENT,
  `fqt_st_id` INT NOT NULL DEFAULT 0,
  `fqt_q_id` INT NOT NULL DEFAULT 0,
  `fqt_tag` VARCHAR(50), 
  `fqt_createat` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fqt_updateat` DATETIME,
  `fqt_st_id_update` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`fqt_id`))
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE UNIQUE INDEX `fqt_id_UNIQUE` ON `faq_tags` (`fqt_id` ASC);

SHOW WARNINGS;

/* Soporte a pacientes */

DROP TABLE IF EXISTS `supportUsr` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `supportUsr` (
  `spu_id` INT NOT NULL AUTO_INCREMENT,
  `spu_usr_id` INT NOT NULL DEFAULT 0,
  `spu_status` INT NOT NULL DEFAULT 0,
  `spu_subject` VARCHAR(200), 
  `spu_createat` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `spu_updateat` DATETIME,
  `spu_supportId` INT NOT NULL DEFAULT 0,
  `spu_desc` TEXT NOT NULL DEFAULT '',
  PRIMARY KEY (`spu_id`))
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE UNIQUE INDEX `spu_id_UNIQUE` ON `supportUsr` (`spu_id` ASC);

SHOW WARNINGS;

/* Soporte al terapeuta */

DROP TABLE IF EXISTS `supportStaff` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `supportStaff` (
  `sps_id` INT NOT NULL AUTO_INCREMENT,
  `sps_usr_id` INT NOT NULL DEFAULT 0,
  `sps_status` INT NOT NULL DEFAULT 0,
  `sps_subject` VARCHAR(200), 
  `sps_createat` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `sps_updateat` DATETIME,
  `sps_supportId` INT NOT NULL DEFAULT 0,
  `sps_desc` TEXT NOT NULL DEFAULT '',
  PRIMARY KEY (`sps_id`))
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE UNIQUE INDEX `sps_id_UNIQUE` ON `supportStaff` (`sps_id` ASC);

SHOW WARNINGS;

/* Catalogo de estados soporte */

DROP TABLE IF EXISTS `supportStatus` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `supportStatus` (
  `spe_id` INT NOT NULL AUTO_INCREMENT,
  `spe_createat` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `spe_desc` VARCHAR(50) NOT NULL DEFAULT '',
  `spe_badge` VARCHAR(50) NOT NULL DEFAULT '',
  PRIMARY KEY (`spe_id`))
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE UNIQUE INDEX `spe_id_UNIQUE` ON `supportStatus` (`spe_id` ASC);

SHOW WARNINGS;