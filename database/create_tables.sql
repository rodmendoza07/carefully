-- MySQL Script generated by MySQL Workbench
-- Thu Dec 21 14:13:04 2017
-- Model: New Model    Version: 1.0
-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- -----------------------------------------------------
-- Schema database
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `cuidadosamente` ;

-- -----------------------------------------------------
-- Schema database
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `cuidadosamente` DEFAULT CHARACTER SET utf8 ;
SHOW WARNINGS;
USE `cuidadosamente` ;

-- -----------------------------------------------------
-- Table `nacionalidades`
-- -----------------------------------------------------
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

-- -----------------------------------------------------
-- Table `departamentos`
-- -----------------------------------------------------
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

-- -----------------------------------------------------
-- Table `puestos`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `puestos` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `puestos` (
  `puesto_id` INT NOT NULL AUTO_INCREMENT,
  `puesto_descripcion` VARCHAR(45) NOT NULL DEFAULT '',
  `puesto_estatus` TINYINT NOT NULL DEFAULT 1,
  PRIMARY KEY (`puesto_id`))
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `usuarios`
-- -----------------------------------------------------
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

-- -----------------------------------------------------
-- Table `estudios`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `estudios` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `estudios` (
  `estudios_id` INT NOT NULL AUTO_INCREMENT,
  `estudios_nombre` VARCHAR(45) NOT NULL DEFAULT '',
  `estudios_fecha_alta` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `estudios_usr_id_alta` INT NOT NULL DEFAULT 0,
  `estudios_fecha_actualizacion` DATETIME NULL,
  `estudios_usr_id_actualizacion` INT NOT NULL DEFAULT 0,
  `estudios_estatus` TINYINT NOT NULL DEFAULT 1,
  PRIMARY KEY (`estudios_id`))
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `curricula`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `curricula` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `curricula` (
  `curricula_id` INT NOT NULL AUTO_INCREMENT,
  `usr_id` INT NOT NULL DEFAULT 0,
  `estudios_id` INT NOT NULL DEFAULT 0,
  `curricula_institucion` VARCHAR(100) NOT NULL DEFAULT '',
  `curricula_inicial` VARCHAR(6) NOT NULL DEFAULT '',
  `curricula_final` VARCHAR(6) NOT NULL DEFAULT '',
  `curricula_fecha_alta` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `curricula_usr_id_alta` INT NOT NULL DEFAULT 0,
  `curricula_fecha_actualizacion` INT NULL,
  `curricula_usr_id_actualizacion` INT NOT NULL DEFAULT 0,
  `curricula_estatus` TINYINT NOT NULL DEFAULT 1,
  PRIMARY KEY (`curricula_id`))
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `experienciaProfesional`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `experienciaProfesional` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `experienciaProfesional` (
  `expProf_id` INT NOT NULL AUTO_INCREMENT,
  `expProf_usr_id` INT NULL DEFAULT 0,
  `expProf_institucion` VARCHAR(100) NOT NULL DEFAULT '',
  `expProf_inicio` VARCHAR(6) NOT NULL DEFAULT '',
  `expProf_fin` VARCHAR(6) NOT NULL DEFAULT '',
  `expProf_descripcion` VARCHAR(1000) NOT NULL DEFAULT '',
  `expProf_jefe` VARCHAR(45) NOT NULL DEFAULT '',
  `expProf_telefono` VARCHAR(20) NOT NULL DEFAULT '',
  `expProf_fecha_alta` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expProf_usr_id_alta` INT NOT NULL DEFAULT 0,
  `expProf_fecha_actualizacion` DATETIME NULL,
  `expProf_usr_id_actualizacion` INT NOT NULL DEFAULT 0,
  `expProf_estatus` INT NOT NULL DEFAULT 1,
  PRIMARY KEY (`expProf_id`))
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `menus`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `menus` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `menus` (
  `menu_id` INT NOT NULL AUTO_INCREMENT,
  `menu_descripcion` VARCHAR(45) NOT NULL DEFAULT '',
  `menu_parent` INT NOT NULL DEFAULT 0,
  `menu_url` VARCHAR(100) NOT NULL DEFAULT '',
  `menu_estatus` TINYINT NOT NULL DEFAULT 1,
  PRIMARY KEY (`menu_id`))
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `nivelesUsuario`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `nivelesUsuario` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `nivelesUsuario` (
  `nivelUsr_id` INT NOT NULL AUTO_INCREMENT,
  `nivelUsr_descripcion` VARCHAR(45) NOT NULL DEFAULT '',
  `nivelUsr_estatus` TINYINT NOT NULL DEFAULT 1,
  `nivelUsr_fecha_alta` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `nivelUsr_usr_id_alta` INT NOT NULL DEFAULT 0,
  `nivelUsr_fecha_cancelacion` DATETIME NULL,
  `nivelUsr_usr_id_cancelacion` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`nivelUsr_id`))
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `accesos`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `accesos` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `accesos` (
  `acceso_id` INT NOT NULL AUTO_INCREMENT,
  `nivel_usr` INT NOT NULL DEFAULT 0,
  `menu_id` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`acceso_id`))
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `conceptosEC`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `conceptosEC` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `conceptosEC` (
  `concepto_id` INT NOT NULL AUTO_INCREMENT,
  `concepto_descripcion` VARCHAR(45) NOT NULL DEFAULT '',
  `concepto_abreviatura` VARCHAR(5) NOT NULL DEFAULT '',
  `concepto_naturaleza` INT NOT NULL DEFAULT 0,
  `concepto_estatus` TINYINT NOT NULL DEFAULT 1,
  PRIMARY KEY (`concepto_id`))
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `horariosDoctores`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `horariosDoctores` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `horariosDoctores` (
  `horario_id` INT NOT NULL AUTO_INCREMENT,
  `horario_dia` INT NOT NULL DEFAULT 0,
  `horario_inicia` VARCHAR(5) NOT NULL DEFAULT '',
  `horario_termina` VARCHAR(5) NOT NULL DEFAULT '',
  `horario_estatus` TINYINT NOT NULL DEFAULT 1,
  `horario_fecha_alta` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `horario_usr_id_alta` INT NOT NULL DEFAULT 0,
  `horario_fecha_cancelacion` DATETIME NULL,
  `horario_usr_id_cancelacion` INT NULL DEFAULT 0,
  PRIMARY KEY (`horario_id`))
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `tiposPago`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `tiposPago` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `tiposPago` (
  `tipoPago_id` INT NOT NULL AUTO_INCREMENT,
  `tipoPago_descripcion` VARCHAR(45) NOT NULL DEFAULT '',
  `tipoPago_abreviatura` VARCHAR(10) NOT NULL DEFAULT '',
  `tipoPago_estatus` TINYINT NOT NULL DEFAULT 1,
  `tipoPago_fecha_alta` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tipoPago_usr_id_alta` INT NOT NULL DEFAULT 0,
  `tipoPago_fecha_cancelacion` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  `tipoPago_usr_id_cancelacion` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`tipoPago_id`))
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `configuraciones`
-- -----------------------------------------------------
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

-- -----------------------------------------------------
-- Table `citasEstatus`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `citasEstatus` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `citasEstatus` (
  `citaEstatus_id` INT NOT NULL AUTO_INCREMENT,
  `citaEstatus_nombre` VARCHAR(45) NOT NULL DEFAULT '',
  `citaEstatus_abreviatura` VARCHAR(5) NOT NULL DEFAULT '',
  `citaEstatus_estatus` TINYINT NOT NULL DEFAULT 1,
  PRIMARY KEY (`citaEstatus_id`))
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `citas`
-- -----------------------------------------------------
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
  `cita_fecha_update` DATETIME NULL,
  `cita_fecha_cancelacion` DATETIME NULL,
  `cita_usr_id_cancelacion` INT NOT NULL DEFAULT 0,
  `cita_title` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`cita_id`))
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `estadoCuenta`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `estadoCuenta` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `estadoCuenta` (
  `ec_id` INT NOT NULL AUTO_INCREMENT,
  `ec_paciente_id` INT NOT NULL DEFAULT 0,
  `ec_concepto_id` INT NOT NULL DEFAULT 0,
  `ec_referencia` VARCHAR(45) NOT NULL DEFAULT '',
  `ec_importe` DECIMAL(18,2) NOT NULL DEFAULT 0,
  `ec_fecha` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ec_usr_id_alta` INT NOT NULL DEFAULT 0,
  `ec_estatus` TINYINT NOT NULL DEFAULT 1,
  `ec_fecha_cancelacion` DATETIME NULL,
  `ec_usr_id_cancelacion` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`ec_id`))
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `expedientePaciente`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `expedientePaciente` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `expedientePaciente` (
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

-- -----------------------------------------------------
-- Table `expedientePacienteConceptos`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `expedientePacienteConceptos` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `expedientePacienteConceptos` (
  `expPC_id` INT NOT NULL AUTO_INCREMENT,
  `expPC_nombre` VARCHAR(45) NOT NULL DEFAULT '',
  `expPC_estatus` TINYINT NOT NULL DEFAULT 1,
  `expPC_fecha_alta` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expPC_usr_id_alta` INT NOT NULL DEFAULT 0,
  `expPC_fecha_cancelacion` DATETIME NULL,
  `expPC_usr_id_cancelacion` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`expPC_id`))
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `expedientePacienteDetalle`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `expedientePacienteDetalle` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `expedientePacienteDetalle` (
  `expPD_id` INT NOT NULL AUTO_INCREMENT,
  `expP_id` INT NOT NULL DEFAULT 0,
  `expPC_id` INT NOT NULL DEFAULT 0,
  /*`expPD_comentario` MEDIUMTEXT NOT NULL DEFAULT '',*/
  `expPD_estatus` TINYINT NOT NULL DEFAULT 1,
  `expPD_fecha_alta` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expPD_usr_id_alta` INT NOT NULL DEFAULT 0,
  `expPD_fecha_cancelacion` DATETIME NULL,
  `expPD_usr_id_cancelacion` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`expPD_id`))
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `pagosDetalle`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `pagosDetalle` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `pagosDetalle` (
  `pagoD_id` INT NOT NULL AUTO_INCREMENT,
  `pagoD_fecha` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `pagoD_ec_id` INT NOT NULL DEFAULT 0,
  `pagoD_tipoPago_id` INT NOT NULL DEFAULT 0,
  `pagoD_autorizacion` VARCHAR(45) NOT NULL DEFAULT '',
  `pagoD_fecha_alta` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `pagoD_usr_id_alta` INT NOT NULL DEFAULT 0,
  `pagoD_fecha_cancelacion` DATETIME NULL,
  `pagoD_usr_id_cancelacion` INT NOT NULL DEFAULT 0,
  `pagoD_estatus` TINYINT NOT NULL DEFAULT 1,
  PRIMARY KEY (`pagoD_id`))
ENGINE = InnoDB;

SHOW WARNINGS;

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

DROP TABLE IF EXISTS `newPwd` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `newPwd` (
  `np_id` INT NOT NULL AUTO_INCREMENT,
  `np_createat` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `np_usr_id` INT NOT NULL DEFAULT 0,
  `np_hash` VARCHAR(50) NOT NULL DEFAULT '',
  `np_status` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`np_id`))
ENGINE = InnoDB;

SHOW WARNINGS;

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

DROP TABLE IF EXISTS `available_hours` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `available_hours` (
  `hh_id` INT NOT NULL AUTO_INCREMENT,
  `hh_start` TIME,
  `hh_end` TIME,
  `hh_status` INT NOT NULL DEFAULT 1,
  PRIMARY KEY (`hh_id`))
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE UNIQUE INDEX `hh_id_UNIQUE` ON `available_hours` (`hh_id` ASC);

SHOW WARNINGS;

DROP TABLE IF EXISTS `citas_status` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `citas_status` (
  `cs_id` INT NOT NULL AUTO_INCREMENT,
  `cs_desc` VARCHAR(40) NOT NULL DEFAULT '',
  `cs_createat` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `cs_status` INT NOT NULL DEFAULT 1,
  `cs_color` VARCHAR(10) NOT NULL DEFAULT '',
  PRIMARY KEY (`cs_id`))
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE UNIQUE INDEX `cs_id_UNIQUE` ON `citas_status` (`cs_id` ASC);

SHOW WARNINGS;

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

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
