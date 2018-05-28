-- phpMyAdmin SQL Dump
-- version 4.7.4
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 28-05-2018 a las 23:34:35
-- Versión del servidor: 10.1.29-MariaDB
-- Versión de PHP: 7.2.0

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `cuidadosamente`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_blockDoctorDates` (IN `shash` VARCHAR(35), IN `dateStart` DATETIME, IN `dateEnd` DATETIME, IN `optBloq` INT, IN `dateStartOld` DATETIME)  BEGIN
	DECLARE userId INT;
    DECLARE lastId INT;
    DECLARE firstId INT;
    DECLARE tmp_paciente INT;
    DECLARE tmp_citaId INT;
    DECLARE cDateStart INT;
    DECLARE cDateEnd INT;
    DECLARE statusUbk INT;
	DECLARE `_rollback` BOOL DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SET `_rollback` = 1;
		ROLLBACK;
        RESIGNAL;
    END;
    
    SET userId = (SELECT vt_st_id FROM validtokens WHERE vt_hash = shash AND vt_status = 1);
	SET userId = IFNULL(userId, -1);
    
    IF userId > 0 THEN
		IF optBloq = 1 THEN	
			DROP TEMPORARY TABLE IF EXISTS tmp_usrs;
		
			CREATE TEMPORARY TABLE tmp_usrs (
				id_usr INT NOT NULL AUTO_INCREMENT PRIMARY KEY
				, usr INT
			);
			
			INSERT INTO tmp_usrs(
				usr
			) SELECT
				expP_paciente_id
			FROM expedientepaciente
			WHERE expP_doctor_id = userId
				AND expP_estatus = 1;
			
			SET firstId = 1;
			SET lastId = (SELECT id_usr FROM tmp_usrs ORDER BY id_usr DESC LIMIT 1);
			SET cDateStart = (SELECT COUNT(*) FROM citas WHERE cita_doctor_id = userId AND cita_fecha_start BETWEEN dateStart AND dateEnd AND cita_estatus < 4);
			SET cDateEnd = (SELECT COUNT(*) FROM citas WHERE cita_doctor_id = userId AND cita_fecha_end BETWEEN dateStart AND dateEnd AND cita_estatus < 4);
			
			IF cDateStart = 0 OR cDateEnd = 0 THEN 
				
				WHILE firstId <= lastId DO
					SET tmp_paciente = (SELECT usr FROM tmp_usrs WHERE id_usr = firstId);
					START TRANSACTION;
					INSERT INTO citas (
						cita_fecha_start
						, cita_fecha_end
						, cita_paciente_id
						, cita_doctor_id
						, cita_title
						, cita_estatus
					) VALUES(
						dateStart
						, dateEnd
						, tmp_paciente
						, userId
						, 3
						, 5
					);
					IF `_rollback` THEN
						SIGNAL SQLSTATE '45000'
							SET message_text = 'Algo ha ido mal, intentalo más tarde.';
					ELSE
						COMMIT;
						SET firstId = firstId + 1;
					END IF;
				END WHILE;
			
				DROP TEMPORARY TABLE IF EXISTS tmp_usrs;
				SELECT 'OK' AS message;
			ELSE
				SIGNAL SQLSTATE '45000'
					SET message_text = 'No puedes bloquear las fechas con sesiones agendadas. Por favor selecciona fechas de bloqueo que no interfieran con tus sesiones.';
			END IF;
            
		ELSEIF optBloq = 2 THEN
            DROP TEMPORARY TABLE IF EXISTS tmp_dates;
            
			CREATE TEMPORARY TABLE tmp_dates (
				id_date INT NOT NULL AUTO_INCREMENT PRIMARY KEY
				, dates INT
			);
            
            INSERT INTO tmp_dates(
				dates
            ) SELECT
				cita_id
            FROM citas
			WHERE cita_doctor_id = userId
			AND cita_fecha_start = dateStartOld; 
            
            SET firstId = 1;
			SET lastId = (SELECT id_date FROM tmp_dates ORDER BY id_date DESC LIMIT 1);
			SET cDateStart = (SELECT COUNT(*) FROM citas WHERE cita_doctor_id = userId AND cita_fecha_start BETWEEN dateStart AND dateEnd AND cita_estatus < 4);
			SET cDateEnd = (SELECT COUNT(*) FROM citas WHERE cita_doctor_id = userId AND cita_fecha_end BETWEEN dateStart AND dateEnd AND cita_estatus < 4);
			
			IF cDateStart = 0 OR cDateEnd = 0 THEN 
				
                IF dateStart = '0000-00-00 00:00:00' THEN
					SET statusUbk = 6;
				ELSE
					SET statusUbk = 5;
                END IF;
				
				WHILE firstId <= lastId DO
					SET tmp_citaId = (SELECT dates FROM tmp_dates WHERE id_date = firstId);
					START TRANSACTION;
					
                    UPDATE citas SET
						cita_fecha_start = dateStart
                        , cita_fecha_end = dateEnd
                        , cita_fecha_update = NOW()
                        , cita_st_update =  userId
                        , cita_estatus = statusUbk
					WHERE cita_id = tmp_citaId;
                    
					IF `_rollback` THEN
						SIGNAL SQLSTATE '45000'
							SET message_text = 'Algo ha ido mal, intentalo más tarde.';
					ELSE
						COMMIT;
						SET firstId = firstId + 1;
					END IF;
				END WHILE;
			
				DROP TEMPORARY TABLE IF EXISTS tmp_dates;
				SELECT 'OK' AS message;
			ELSE
				SIGNAL SQLSTATE '45000'
					SET message_text = 'No puedes bloquear las fechas con sesiones agendadas. Por favor selecciona fechas de bloqueo que no interfieran con tus sesiones.';
			END IF;
        ELSE
			SIGNAL SQLSTATE '45000'
				SET message_text = 'Sin privilegios.';
        END IF;
    ELSE
		SIGNAL SQLSTATE '45000'
			SET message_text = 'Sin privilegios.';
    END IF;
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_checkNewDatesStaff` (IN `shash` VARCHAR(35), IN `opt` INT, IN `cId` INT, IN `cStatus` INT, IN `dStart` VARCHAR(20), IN `dEnd` VARCHAR(20))  BEGIN
	DECLARE userId INT;
    DECLARE ccStatus INT;
    DECLARE compareStart INT;
    DECLARE compareEnd INT;
    DECLARE pacienteId INT;
    DECLARE dates INT;
	DECLARE `_rollback` BOOL DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SET `_rollback` = 1;
		ROLLBACK;
        RESIGNAL;
    END;
    
    SET userId = (SELECT IFNULL(vt_st_id, 0) FROM validtokens WHERE vt_hash = shash AND vt_status = 1 AND vt_usr_id = 0);
	SET userId = IFNULL(userId, -1);
    
    IF opt = 1 THEN
		SELECT
			c.cita_id
            , c.cita_fecha_start
			, c.cita_fecha_end
			, cc.cc_desc
            , cst.cs_desc
            , cst.cs_badge
			, CONCAT(usr.usr_nombre, ' ', usr.usr_paterno) AS usrNombre
		FROM citas c
			INNER JOIN citas_communication cc ON (c.cita_title = cc.cc_id)
			INNER JOIN usuarios usr ON (c.cita_paciente_id = usr_id)
			INNER JOIN citas_validation cv ON (c.cita_id = cv.cv_c_id)
            INNER JOIN staff st ON (st.st_id = userId)
            INNER JOIN citas_status cst ON (c.cita_estatus = cst.cs_id)
		WHERE (cv.cv_status = 0 OR cv.cv_status_view = 0);
	
    ELSEIF opt = 2 THEN
		
        SET pacienteId = (SELECT cita_paciente_id FROM citas WHERE cita_id = cId);
        SET ccStatus = (SELECT COUNT(*) FROM citas_status WHERE cs_id = cStatus);
        
        IF cStatus > 0 THEN
        
			START TRANSACTION;
			
			UPDATE citas_validation SET
				cv_status = 1,
                cv_status_view = 1,
				cv_validat = CURRENT_TIMESTAMP,
				cv_st_id = userId
			WHERE cv_c_id = cId;
			
			IF cStatus = 4 THEN
				UPDATE citas SET
					cita_estatus = cStatus
					, cita_st_update = userId
                    , cita_st_id_cancelacion = userId
					, cita_fecha_update = CURRENT_TIMESTAMP
                    , cita_fecha_cancelacion = CURRENT_TIMESTAMP
				WHERE cita_id = cId;
			ELSEIF cStatus = 3 THEN 
				
				SET compareStart = (SELECT COUNT(*) FROM citas WHERE cita_paciente_id = pacienteId AND (cita_fecha_start BETWEEN dStart AND dEnd));
				SET compareEnd = (SELECT COUNT(*) FROM citas WHERE cita_paciente_id = pacienteId AND (cita_fecha_end BETWEEN dStart AND dEnd));
				SET dates = (SELECT DATEDIFF(dStart, dEnd));
			
				IF compareStart = 0 && compareEnd = 0 && dates = 0 THEN
                
					IF (SELECT COUNT(*) FROM available_hours WHERE (TIME(dStart) BETWEEN hh_start AND hh_end) AND hh_status = 1) > 0 && (SELECT COUNT(*) FROM available_hours WHERE (TIME(dEnd) BETWEEN hh_start AND hh_end) AND hh_status = 1) > 0 THEN
						IF dStart < dEnd THEN
							IF TIMEDIFF(dStart, dEnd) = '-00:50:00' THEN
								UPDATE citas SET
									cita_estatus = cStatus
									, cita_st_update = userId
									, cita_fecha_update = CURRENT_TIMESTAMP
									, cita_fecha_start = dStart
									, cita_fecha_end = dEnd
								WHERE cita_id = cId;
							ELSE
								SIGNAL SQLSTATE '45000'
									SET message_text = 'Horario inválido';
							END IF;
						ELSE
							SIGNAL SQLSTATE '45000'
								SET message_text = 'Horario inválido';
						END IF;
					ELSE
						SIGNAL SQLSTATE '45000'
							SET message_text = 'Horario inválido';
					END IF;
				ELSE
					SIGNAL SQLSTATE '45000'
						SET message_text = 'Horario inválido';
				END IF;
			ELSE
				UPDATE citas SET
					cita_estatus = cStatus
					, cita_st_update = userId
					, cita_fecha_update = CURRENT_TIMESTAMP
				WHERE cita_id = cId;
			End If;
			
			IF `_rollback` THEN
				SIGNAL SQLSTATE '45000'
					SET message_text = 'Algo ha ido mal, intentalo más tarde.';
			ELSE
				COMMIT;
                SELECT 'OK' AS msg;
			END IF;
		ELSE
			SIGNAL SQLSTATE '45000'
				SET message_text = 'Estatus no válido.';
        END IF;
    ELSE
		SIGNAL SQLSTATE '45000'
			SET message_text = 'Opción inválida';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_checkNewDatesUsr` (IN `shash` VARCHAR(35), IN `opt` INT, IN `cId` INT, IN `cStatus` INT, IN `dStart` VARCHAR(20), IN `dEnd` VARCHAR(20))  BEGIN
	DECLARE userId INT;
    DECLARE ccStatus INT;
    DECLARE compareStart INT;
    DECLARE compareEnd INT;
    DECLARE doctorId INT;
    DECLARE dates INT;
	DECLARE `_rollback` BOOL DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SET `_rollback` = 1;
		ROLLBACK;
        RESIGNAL;
    END;
    
    SET userId = (SELECT vt_usr_id FROM validtokens WHERE vt_hash = shash AND vt_status = 1);
    SET userId = IFNULL(userId, -1);
    
    IF opt = 1 THEN
		SELECT
			c.cita_id
            , c.cita_fecha_start
			, c.cita_fecha_end
			, cc.cc_desc
            , cst.cs_desc
            , cst.cs_badge
			, CONCAT(st.st_nombre, ' ', st.st_paterno) AS stNombre
		FROM citas c
			INNER JOIN citas_communication cc ON (c.cita_title = cc.cc_id)
			INNER JOIN staff st ON (c.cita_doctor_id = st_id)
			INNER JOIN citas_validation cv ON (c.cita_id = cv.cv_c_id)
            INNER JOIN citas_status cst ON (c.cita_estatus = cst.cs_id)
            INNER JOIN usuarios usr ON (usr.usr_id = userId)
		WHERE c.cita_doctor_id = userId
			AND cv.cv_status_view = 1;
	
    ELSEIF opt = 2 THEN
		
        SET doctorId = (SELECT cita_doctor_id FROM citas WHERE cita_id = cId);
        SET ccStatus = (SELECT COUNT(*) FROM citas_status WHERE cs_id = cStatus);
        
		IF cStatus > 0 THEN
		
			START TRANSACTION;
			
			UPDATE citas_validation SET
				cv_status = 0,
				cv_status_view = 0,
				cv_validat = CURRENT_TIMESTAMP,
				cv_usr_id = userId
			WHERE cv_c_id = cId;
			
			IF cStatus = 4 THEN
				UPDATE citas SET
					cita_estatus = cStatus
					, cita_usr_id_update = userId
					, cita_usr_id_cancelacion = userId
					, cita_fecha_update = CURRENT_TIMESTAMP
					, cita_fecha_cancelacion = CURRENT_TIMESTAMP
				WHERE cita_id = cId;
			ELSEIF cStatus = 3 THEN 
				
				SET compareStart = (SELECT COUNT(*) FROM citas WHERE cita_doctor_id = doctorId AND (cita_fecha_start BETWEEN dStart AND dEnd));
				SET compareEnd = (SELECT COUNT(*) FROM citas WHERE cita_doctor_id = doctorId AND (cita_fecha_end BETWEEN dStart AND dEnd));
				SET dates = (SELECT DATEDIFF(dStart, dEnd));
			
				IF compareStart = 0 && compareEnd = 0 && dates = 0 THEN
                
					IF (SELECT COUNT(*) FROM available_hours WHERE (TIME(dStart) BETWEEN hh_start AND hh_end) AND hh_status = 1) > 0 && (SELECT COUNT(*) FROM available_hours WHERE (TIME(dEnd) BETWEEN hh_start AND hh_end) AND hh_status = 1) > 0 THEN
						IF dStart < dEnd THEN
							IF TIMEDIFF(dStart, dEnd) = '-00:50:00' THEN
								UPDATE citas SET
									cita_estatus = cStatus
									, cita_usr_id_update = userId
									, cita_fecha_update = CURRENT_TIMESTAMP
									, cita_fecha_start = dStart
									, cita_fecha_end = dEnd
								WHERE cita_id = cId;
							ELSE
								SIGNAL SQLSTATE '45000'
									SET message_text = 'Horario inválido';
							END IF;
						ELSE
							SIGNAL SQLSTATE '45000'
								SET message_text = 'Horario inválido';
						END IF;
					ELSE
						SIGNAL SQLSTATE '45000'
							SET message_text = 'Horario inválido';
					END IF;
				ELSE
					SIGNAL SQLSTATE '45000'
						SET message_text = 'Horario inválido';
				END IF;
			ELSE
				UPDATE citas SET
					cita_estatus = cStatus
					, cita_usr_id_update = userId
					, cita_fecha_update = CURRENT_TIMESTAMP
				WHERE cita_id = cId;
			End If;
			
			IF `_rollback` THEN
				SIGNAL SQLSTATE '45000'
					SET message_text = 'Algo ha ido mal, intentalo más tarde.';
			ELSE
				COMMIT;
				SELECT 'OK' AS msg;
			END IF;
		ELSE
			SIGNAL SQLSTATE '45000'
				SET message_text = 'Estatus no válido.';
		END IF;
    ELSE
		SIGNAL SQLSTATE '45000'
			SET message_text = 'Opción inválida';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_editEventStaff` (IN `shash` VARCHAR(35), IN `dStart` DATETIME, IN `dEnd` DATETIME, IN `optEdit` INT, IN `dateStartOld` DATETIME)  BEGIN
	DECLARE userId INT;
    DECLARE cId INT;
    DECLARE statusUbk INT;
	DECLARE compareStart INT;
    DECLARE compareEnd INT;
    DECLARE dates INT;
    DECLARE pacienteId INT;
	DECLARE configStart VARCHAR(15);
	DECLARE configEnd VARCHAR(15);
	DECLARE `_rollback` BOOL DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SET `_rollback` = 1;
		ROLLBACK;
        RESIGNAL;
    END;
    
    SET userId = (SELECT vt_st_id FROM validtokens WHERE vt_hash = shash AND vt_status = 1);
	SET userId = IFNULL(userId, -1);
    
    IF userId > 0 THEN
    
		SET cId = (SELECT cita_id FROM citas WHERE cita_fecha_start = dateStartOld AND cita_estatus < 4);
    
		IF optEdit = 1 THEN	
            
            SET pacienteId = (SELECT cita_paciente_id FROM citas WHERE cita_id = cId);
            SET configStart = (SELECT cfg_valor FROM configuraciones WHERE cfg_nombre = 'hh_start' AND cfg_estatus = 1);
			SET configEnd = (SELECT cfg_valor FROM configuraciones WHERE cfg_nombre = 'hh_end' AND cfg_estatus = 1);
            SET compareStart = (SELECT COUNT(*) FROM citas WHERE cita_paciente_id = pacienteId AND (cita_fecha_start BETWEEN dStart AND dEnd) AND cita_id <> cId AND cita_estatus <> 4);
			SET compareEnd = (SELECT COUNT(*) FROM citas WHERE cita_paciente_id = pacienteId AND (cita_fecha_end BETWEEN dStart AND dEnd) AND cita_id <> cId AND cita_estatus <> 4);
			SET dates = (SELECT DATEDIFF(dStart, dEnd));
            
            IF compareStart = 0 && compareEnd = 0 && dates = 0 THEN
                
				IF (TIME(dStart) > TIME(configStart) AND TIME(dStart) < TIME(configEnd)) AND (TIME(dEnd) > TIME(configStart) AND TIME(dEnd) < TIME(configEnd)) THEN
					IF dStart < dEnd THEN
						IF TIMEDIFF(dStart, dEnd) = '-00:50:00' THEN
							START TRANSACTION;
							
                            select cId;
                            
							UPDATE citas_validation SET
								cv_status = 1,
								cv_status_view = 1,
								cv_validat = CURRENT_TIMESTAMP,
								cv_st_id = userId
							WHERE cv_c_id = cId;
                        
							UPDATE citas SET
								cita_estatus = 3
								, cita_st_update = userId
								, cita_fecha_update = CURRENT_TIMESTAMP
								, cita_fecha_start = dStart
								, cita_fecha_end = dEnd
							WHERE cita_id = cId;
                            
                            IF `_rollback` THEN
								SIGNAL SQLSTATE '45000'
									SET message_text = 'Algo ha ido mal, intentalo más tarde.';
							ELSE
								COMMIT;
								SELECT 'OK' AS msg;
							END IF;
						ELSE
							SIGNAL SQLSTATE '45000'
								SET message_text = 'Horario inválido1';
						END IF;
					ELSE
						SIGNAL SQLSTATE '45000'
							SET message_text = 'Horario inválido2';
					END IF;
				ELSE
					SIGNAL SQLSTATE '45000'
						SET message_text = 'Horario inválido3';
				END IF;
			ELSE
				SIGNAL SQLSTATE '45000'
					SET message_text = 'Horario inválido4';
			END IF;
            
        ELSEIF optEdit = 2 THEN
            
            START TRANSACTION;
			
			UPDATE citas_validation SET
				cv_status = 0,
                cv_status_view = 0,
				cv_validat = CURRENT_TIMESTAMP,
				cv_st_id = userId
			WHERE cv_c_id = cId;
            
			UPDATE citas SET
				cita_estatus = 4
				, cita_st_update = userId
				, cita_st_id_cancelacion = userId
				, cita_fecha_update = CURRENT_TIMESTAMP
				, cita_fecha_cancelacion = CURRENT_TIMESTAMP
			WHERE cita_id = cId;
            
            IF `_rollback` THEN
				SIGNAL SQLSTATE '45000'
					SET message_text = 'Algo ha ido mal, intentalo más tarde.';
			ELSE
				COMMIT;
                SELECT 'OK' AS msg;
			END IF;

        ELSE
			SIGNAL SQLSTATE '45000'
				SET message_text = 'Sin privilegios.';
        END IF;
    ELSE
		SIGNAL SQLSTATE '45000'
			SET message_text = 'Sin privilegios.';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getAllce` ()  BEGIN
	SELECT
		ce.ce_id
        , ce.ce_desc
	FROM civil_estado ce;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getAllDates` (IN `token_hash` VARCHAR(35))  BEGIN
	DECLARE userId INT;
	DECLARE `_rollback` BOOL DEFAULT 0;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		SET `_rollback` = 1;
		RESIGNAL;
	END;

	SET userId = (SELECT IFNULL(vt_usr_id, 0) FROM validtokens WHERE vt_hash = token_hash AND vt_status= 1);

	IF userId > 0 THEN
		SELECT
			c.cita_fecha_start
            , c.cita_fecha_end
            , c.cita_title
            , c.cita_estatus
            , cs.cs_desc
            , cc.cc_desc
            , cs.cs_color
		FROM citas c
			INNER JOIN citas_status cs ON (c.cita_estatus = cs.cs_id)
            INNER JOIN citas_communication cc ON (c.cita_title = cc.cc_id)
        WHERE cita_paciente_id = userId;
	ELSE
		SIGNAL SQLSTATE '45000'
			SET message_text = 'No existen citas.';
    END IF;
   
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getAllDatesStaff` (IN `token_hash` VARCHAR(35))  BEGIN
	DECLARE userId INT;
	DECLARE `_rollback` BOOL DEFAULT 0;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		SET `_rollback` = 1;
		RESIGNAL;
	END;

	SET userId = (SELECT IFNULL(vt_st_id, 0) FROM validtokens WHERE vt_hash = token_hash AND vt_status= 1);

	IF userId > 0 THEN
		SELECT
			/*COUNT(c.cita_title) AS dateNumber*/
			DISTINCT(c.cita_fecha_start)
            , c.cita_fecha_end
            , c.cita_title
            , c.cita_estatus
            , cs.cs_desc
            , cc.cc_desc
            , cs.cs_color
		FROM citas c
			INNER JOIN citas_status cs ON (c.cita_estatus = cs.cs_id)
            INNER JOIN citas_communication cc ON (c.cita_title = cc.cc_id)
        WHERE cita_doctor_id = userId;
	ELSE
		SIGNAL SQLSTATE '45000'
			SET message_text = 'Opción inválida.';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getAllFaqs` (IN `shash` VARCHAR(35), IN `typePerson` INT)  BEGIN
	DECLARE userId INT;
    DECLARE `_rollback` BOOL DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SET `_rollback` = 1;
		ROLLBACK;
        RESIGNAL;
    END;

    IF typePerson = 0 THEN
        SET userId = (SELECT vt_usr_id FROM validtokens WHERE vt_hash = shash AND vt_status = 1);
        SET userId = IFNULL(userId, -1);
        
        IF userId > 0 THEN
			SELECT
				q.fqq_id AS qId
				, q.fqq_question AS qQuestion
				, a.fqa_id AS aId
				, a.fqa_answer AS aAnswer
                , cat.fqc_desc AS cDesc
                , cat.fqc_id AS category
			FROM faq_question q
				INNER JOIN faq_answers a ON (q.fqq_id = a.fqa_q_id)
                INNER JOIN faq_category cat ON (q.fqq_cat = cat.fqc_id AND fqc_view = 1)
			ORDER BY q.fqq_id ASC;
        ELSE
			SIGNAL SQLSTATE '45000'
				SET message_text = 'Sin privilegios.';
        END IF;        
    ELSEIF typePerson = 1 THEN
		SET userId = (SELECT vt_st_id FROM validtokens WHERE vt_hash = shash AND vt_status = 1);
		SET userId = IFNULL(userId, -1);
        
        IF userId > 0 THEN
        SELECT
				q.fqq_id AS qId
				, q.fqq_question AS qQuestion
				, a.fqa_id AS aId
				, a.fqa_answer AS aAnswer
                , cat.fqc_desc AS cDesc
                , cat.fqc_id AS category
			FROM faq_question q
				INNER JOIN faq_answers a ON (q.fqq_id = a.fqa_q_id)
                INNER JOIN faq_category cat ON (q.fqq_cat = cat.fqc_id AND fqc_view = 2)
			ORDER BY q.fqq_id ASC;
        ELSE
			SIGNAL SQLSTATE '45000'
				SET message_text = 'Sin privilegios.';
        END IF;
    ELSE
        SIGNAL SQLSTATE '45000'
			SET message_text = 'Sin privilegios.';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getAllgender` ()  BEGIN
	SELECT
		g.g_id
        , g.g_desc
    FROM gender g;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getAllNations` ()  BEGIN
	SELECT
		n.nacionalidad_id
        , n.nacionalidad_desc
	FROM nacionalidades n;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getAllPatients` (IN `shash` VARCHAR(35))  BEGIN
	DECLARE userId INT;
    DECLARE `_rollback` BOOL DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SET `_rollback` = 1;
		ROLLBACK;
        RESIGNAL;
    END;
    
    SET userId = (SELECT IFNULL(vt_st_id, 0) FROM validtokens WHERE vt_hash = shash AND vt_status = 1 AND vt_usr_id = 0);
	SET userId = IFNULL(userId, -1);
    
    SELECT
		u.usr_id
		, CONCAT(u.usr_nombre, ' ', u.usr_paterno, ' ', u.usr_materno) AS patienName
		, CONCAT('<button class="btn btn-primary btn-pill editar" data-pId="', u.usr_id, '" data-pname="',u.usr_nombre,'" data-paterno="', u.usr_paterno,'" data-materno="', u.usr_materno,'">Editar</button>&nbsp;&nbsp;<button class="btn btn-warning btn-pill transferir" data-pId="', u.usr_id, '">Transferir</button>') AS btns
    FROM expedientepaciente e
		INNER JOIN usuarios u ON (e.expP_paciente_id = u.usr_id)
	WHERE e.expP_doctor_id = userId;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getAllTherapist` (IN `shash` VARCHAR(35))  BEGIN
	DECLARE userId INT;
    DECLARE `_rollback` BOOL DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SET `_rollback` = 1;
		ROLLBACK;
        RESIGNAL;
    END;
    
    SET userId = (SELECT vt_st_id FROM validtokens WHERE vt_hash = shash AND vt_status = 1);
	SET userId = IFNULL(userId, -1);
    
    IF userId > 0 THEN
		SELECT
			st_id AS tId
            , CONCAT(st_nombre, ' ', st_paterno, ' ', st_materno) AS nameComplete 
            , CASE
                WHEN st_estatus = 1 THEN '<span class="badge badge-info" style="font-size:18px;">Activo</span>'
                ELSE '<span class="badge badge-danger" style="font-size:18px;">Inactivo</span>'
            END AS tStatus
        FROM staff
        WHERE st_puesto_id = 3 
			AND st_departamento_id = 3;
    ELSE 	
		SIGNAL SQLSTATE '45000'
			SET message_text = 'Sin privilegios.';
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getAllTickets` (IN `shash` VARCHAR(45))  BEGIN
	DECLARE userId INT;
    DECLARE `_rollback` BOOL DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SET `_rollback` = 1;
		ROLLBACK;
        RESIGNAL;
    END;
	
    SET userId = (SELECT vt_st_id FROM validtokens WHERE vt_hash = shash AND vt_status = 1);
    SET userId = IFNULL(userId, -1);
    
    IF userId > 0 THEN
        (SELECT
            st.sps_id AS folioId
            , CONCAT(st.sps_id,'-st') AS folio
            , DATE_FORMAT(st.sps_createat, '%d/%m/%Y') AS dateS
            , DATE_FORMAT(st.sps_createat, '%h:%i %p') AS hours
            , st.sps_subject AS asunto
            , CONCAT('<span class="', ss.spe_badge,'" style="font-size:18px;">', ss.spe_desc, '</span>') AS estado
            , CONCAT(s.st_nombre, ' ', s.st_paterno, ' ', s.st_materno) AS nombre
            , s.st_correo AS userAccount
            , '<span class="badge badge-primary" style="font-size:18px;">Terapeuta</span>' AS typePerson
            , 'st' AS typeReport
		FROM supportStaff st
			INNER JOIN supportStatus ss ON (ss.spe_id = st.sps_status)
            INNER JOIN staff s ON (s.st_id = st.sps_usr_id))
        UNION
        (SELECT
            spu.spu_id AS folioId
            , CONCAT(spu.spu_id,'-usr') AS folio
            , DATE_FORMAT(spu.spu_createat, '%d/%m/%Y') AS dateS
            , DATE_FORMAT(spu.spu_createat, '%h:%i %p') AS hours
            , spu.spu_subject AS asunto
            , CONCAT('<span class="', ss.spe_badge,'" style="font-size:18px;">', ss.spe_desc, '</span>') AS estado
            , CONCAT(u.usr_nombre, ' ', u.usr_paterno, ' ', u.usr_materno) AS nombre
            , u.usr_correo AS userAccount
            , '<span class="badge badge-success" style="font-size:18px;">Paciente</span>' AS typePerson
            , 'usr' AS typeReport
        FROM supportUsr spu
            INNER JOIN supportStatus ss ON (ss.spe_id = spu.spu_status)
            INNER JOIN usuarios u ON (u.usr_id = spu.spu_usr_id));
    ELSE
        SIGNAL SQLSTATE '45000'
			SET message_text = 'Sin privilegios.';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getBitacoraPaciente` (IN `shash` VARCHAR(35), IN `usrId` INT)  BEGIN
	DECLARE userId INT;
    DECLARE `_rollback` BOOL DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SET `_rollback` = 1;
		ROLLBACK;
        RESIGNAL;
    END;
    
    SET userId = (SELECT IFNULL(vt_st_id, 0) FROM validtokens WHERE vt_hash = shash AND vt_status = 1 AND vt_usr_id = 0);
	SET userId = IFNULL(userId, -1);
    
    SELECT
		CONCAT(usr.usr_nombre, ' ', usr.usr_paterno, ' ', usr.usr_materno) AS patientName
        , bp.bp_famHist
        , bp.bp_dynFam
        , bp.bp_reazons
        , bp.bp_actualProblem
        , bp.bp_medicalAspects
        , bp.bp_pshicological
        , bp.bp_trauma
        , bp.bp_socialProfile
	FROM bitacoraPaciente bp
		INNER JOIN usuarios usr ON (usr.usr_id = bp.bp_usr_id)
	WHERE bp_usr_id = usrId;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getInfoUser` (IN `userName` VARCHAR(50), IN `passwd` VARCHAR(15))  BEGIN
    
    DECLARE passCompare VARCHAR(40);
	DECLARE userId INT;
    DECLARE validAccount INT;
    DECLARE sessToken VARCHAR(40);
    DECLARE previousToken INT;
    DECLARE typeUser TINYINT;
	DECLARE typeJob TINYINT;
    DECLARE `_rollback` BOOL DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SET `_rollback` = 1;
		ROLLBACK;
        RESIGNAL;
    END;
    
    SET userId = (SELECT IFNULL(usr_id, 0) FROM usuarios WHERE usr_correo = userName);
	SET typeUser = 0;
    SET userId = IFNULL(userId, 0);
    
    IF userId = 0 THEN
		SET userId = (SELECT IFNULL(st_id, 0) FROM staff WHERE st_correo = userName);
        SET typeUser = 1;
	END IF;
    
    IF userId > 0 THEN
		
        IF typeUser = 0 THEN
			SET validAccount = (SELECT COUNT(*) FROM validateSess WHERE vs_usr_id = userId AND vs_status = 1);
        ELSEIF typeUser = 1 THEN 
			SET validAccount = (SELECT COUNT(*) FROM validateSess WHERE vs_st_id = userId AND vs_status = 1);
        END IF;
        
        IF validAccount > 0 THEN
			SET passCompare = md5(CONCAT(userName, passwd, (SELECT cfg_valor FROM configuraciones WHERE cfg_id = 1)));
            
            IF (passCompare = (SELECT usr_password FROM usuarios WHERE usr_id = userId)) OR (passCompare = (SELECT st_password FROM staff WHERE st_id = userId)) THEN
                /*Sección token */
                
                SET sessToken = md5(CONCAT(DATE_FORMAT(NOW(), '%Y%c%d'),userName,passwd,(SELECT cfg_valor FROM configuraciones WHERE cfg_id =  1)));
                
                IF typeUser = 0 THEN
					SET previousToken = (SELECT COUNT(*) FROM validtokens WHERE vt_usr_id = userId);
                ELSEIF typeUser = 1 THEN
					SET previousToken = (SELECT COUNT(*) FROM validtokens WHERE vt_st_id = userId);
                END IF;
                
                IF previousToken > 0 AND typeUser = 0 THEN
                
                    UPDATE validtokens SET
						vt_status = 0
					WHERE vt_usr_id = userId;
                    
                    START TRANSACTION;
                    INSERT INTO validtokens (
						vt_usr_id
                        , vt_hash
                    ) VALUES (
						userId
                        , sessToken
                    );
                    IF `_rollback` THEN
						SIGNAL SQLSTATE '45000'
							SET message_text = 'Algo ha ido mal, intentalo más tarde.';
					ELSE
						COMMIT;
					END IF;
                    
                    
				ELSEIF previousToken <= 0 AND typeUser = 0 THEN
                
					START TRANSACTION;
					INSERT INTO validtokens (
						vt_usr_id
						, vt_hash
					) VALUES (
						userId
						, sessToken
					);
					IF `_rollback` THEN
						SIGNAL SQLSTATE '45000'
							SET message_text = 'Algo ha ido mal, intentalo más tarde.';
					ELSE
						COMMIT;
					END IF;
					
				END IF;
				IF previousToken > 0 AND typeUser = 1 THEN
                
					UPDATE validtokens SET
						vt_status = 0
					WHERE vt_st_id = userId;
                
                    START TRANSACTION;
                    INSERT INTO validtokens (
						vt_st_id
                        , vt_hash
                    ) VALUES (
						userId
                        , sessToken
                    );
                    IF `_rollback` THEN
						SIGNAL SQLSTATE '45000'
							SET message_text = 'Algo ha ido mal, intentalo más tarde.';
					ELSE
						COMMIT;
					END IF;
				ELSEIF previousToken <= 0 AND typeUser = 1 THEN
                
                    START TRANSACTION;
                    INSERT INTO validtokens (
						vt_st_id
                        , vt_hash
                    ) VALUES (
						userId
                        , sessToken
                    );
                    IF `_rollback` THEN
						SIGNAL SQLSTATE '45000'
							SET message_text = 'Algo ha ido mal, intentalo más tarde.';
					ELSE
						COMMIT;
					END IF;
                    
                END IF;
                /* Envia datos frontend */
				IF typeUser = 0 THEN 
					SELECT 
						sessToken as sessToken
						, usr_nombre
						, usr_paterno
                        , '../software/client' AS url
						, typeUser
                        , CONCAT(st.st_nombre, ' ', st.st_paterno, ' ', st. st_materno) AS therapist
					FROM usuarios usr
						INNER JOIN expedientepaciente expP ON (expP.expP_paciente_id = usr.usr_id)
                        INNER JOIN staff st ON (st.st_id = expP_doctor_id)
					WHERE usr_id = userId;
                ELSEIF typeUser = 1 THEN
					SET typeJob = (SELECT st_puesto_id FROM staff WHERE st_id = userId);
					IF typeJob = 1 || typeJob = 4 || typeJob = 5 THEN
						SELECT 
							sessToken as sessToken
							, st.st_nombre
							, st.st_paterno
							, '../admin' AS url
							, typeUser
							, '' AS therapist
							/*, accesos.menu_id
                            , menu.menu_parent
                            , menu.menu_descripcion*/
						FROM staff st
							/*INNER JOIN accesos accesos ON (st.st_puesto_id = accesos.nivel_usr)
                            INNER JOIN menus menu ON (accesos.menu_id = menu.menu_id AND menu_estatus = 1)*/
						WHERE st_id = userId;
					ELSE
						SELECT 
							sessToken as sessToken
							, st_nombre
							, st_paterno
							, '../software/staff' AS url
							, typeUser
							, '' AS therapist
						FROM staff
						WHERE st_id = userId;
					END IF;
                END IF;
			ELSE
				SIGNAL SQLSTATE '45000'
					SET message_text = 'Usuario y/o contraseña inválidos.';
			END IF;
		
        ELSE
			SIGNAL SQLSTATE '45000'
				SET message_text = 'Activa tu cuenta para iniciar sesión.';
		END IF;
	
    ELSE
		SIGNAL SQLSTATE '45000'
			SET message_text = 'Usuario y/o contraseña incorrectos.';
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getMyTherapyStaff` (IN `shash` VARCHAR(35))  BEGIN
	DECLARE userId INT;
    DECLARE `_rollback` BOOL DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SET `_rollback` = 1;
		ROLLBACK;
        RESIGNAL;
    END;
    
    SET userId = (SELECT vt_st_id FROM validtokens WHERE vt_hash = shash AND vt_status = 1);
    SET userId = IFNULL(userId, -1);
    
    IF userId > 0 THEN
		SELECT
			DATE_FORMAT(c.cita_fecha_start, '%d/%m/%Y') AS dia
            , CONCAT(DATE_FORMAT(c.cita_fecha_start, '%h:%i %p'), '-', DATE_FORMAT(c.cita_fecha_end, '%h:%i %p')) AS horario
            , CONCAT('<span class="',cs.cs_badge,'" style="font-size:18px;">', cs.cs_desc, '</span>') AS cs_desc
            , CONCAT(usr.usr_nombre, ' ', usr.usr_paterno, ' ', usr.usr_materno) AS patient
		FROM citas c
			INNER JOIN citas_status cs ON (c.cita_estatus = cs.cs_id)
            INNER JOIN citas_communication cc ON (c.cita_title = cc.cc_id)
            INNER JOIN usuarios usr ON (usr.usr_id = c.cita_paciente_id)
        WHERE c.cita_doctor_id = userId
			AND c.cita_estatus < 5;
	ELSE
		SIGNAL SQLSTATE '45000'
			SET message_text = 'Algo ha ido mal, intentelo más tarde.';
    END IF;
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getMyTherapyUsr` (IN `shash` VARCHAR(35))  BEGIN
	DECLARE userId INT;
    DECLARE `_rollback` BOOL DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SET `_rollback` = 1;
		ROLLBACK;
        RESIGNAL;
    END;
    
    SET userId = (SELECT vt_usr_id FROM validtokens WHERE vt_hash = shash AND vt_status = 1);
    SET userId = IFNULL(userId, -1);
    
    IF userId > 0 THEN
		SELECT
            DATE_FORMAT(c.cita_fecha_start, '%d/%m/%Y') AS dia
            , CONCAT(DATE_FORMAT(c.cita_fecha_start, '%h:%i %p'), '-', DATE_FORMAT(c.cita_fecha_end, '%h:%i %p')) AS horario
            , CONCAT('<span class="',cs.cs_badge,'" style="font-size:18px;">', cs.cs_desc, '</span>') AS cs_desc
            , CONCAT(st.st_nombre, ' ', st.st_paterno, ' ', st.st_materno) AS therapist
		FROM citas c
			INNER JOIN citas_status cs ON (c.cita_estatus = cs.cs_id)
            INNER JOIN citas_communication cc ON (c.cita_title = cc.cc_id)
            INNER JOIN staff st ON (st.st_id = c.cita_doctor_id)
        WHERE c.cita_paciente_id = userId
			AND c.cita_estatus < 5;
	ELSE
		SIGNAL SQLSTATE '45000'
			SET message_text = 'Algo ha ido mal, intentelo más tarde.';
    END IF; 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getNewPwd` (IN `opt` INT, IN `userMail` VARCHAR(50), IN `pwdNew` VARCHAR(15), IN `valHash_` VARCHAR(35))  BEGIN
	DECLARE eCounter INT;
    DECLARE typeUser INT;
    DECLARE userId INT;
    DECLARE pwdHash VARCHAR(35);
    DECLARE userEmail VARCHAR(50);
    DECLARE `_rollback` BOOL DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SET `_rollback` = 1;
		ROLLBACK;
        RESIGNAL;
    END;
    
    SET eCounter = (SELECT COUNT(*) FROM usuarios WHERE usr_correo = userMail);
	SET typeUser = 1;
    
	IF eCounter = 0 THEN
		SET eCounter = (SELECT COUNT(*) FROM staff WHERE st_correo = userMail);
        SET typeUser = 2;
    END IF;
    
   
    IF opt = -1 THEN
		
        IF typeUser = 1 THEN
			SET pwdHash = (SELECT md5(CONCAT(NOW(), userMail, (SELECT cfg_valor FROM configuraciones WHERE cfg_id = 1))));
			SET userId = (SELECT usr_id FROM usuarios WHERE usr_correo = userMail);
            
            START TRANSACTION;
			INSERT INTO newPwd (
				np_usr_id
				, np_hash
			) VALUES (
				userId
				, pwdHash
			);
			IF `_rollback` THEN
				SIGNAL SQLSTATE '45000'
					SET message_text = 'Algo ha ido mal, intentalo más tarde.';
			ELSE
				COMMIT;
                SELECT pwdHash;
			END IF;
            
        ELSEIF typeUser = 2 THEN
			SET pwdHash = (SELECT md5(CONCAT(NOW(), userMail, (SELECT cfg_valor FROM configuraciones WHERE cfg_id = 1))));
			SET userId = (SELECT st_id FROM staff WHERE st_correo = userMail);
            
            START TRANSACTION;
			INSERT INTO newPwd (
				np_st_id
				, np_hash
			) VALUES (
				userId
				, pwdHash
			);
			IF `_rollback` THEN
				SIGNAL SQLSTATE '45000'
					SET message_text = 'Algo ha ido mal, intentalo más tarde.';
			ELSE
				COMMIT;
                SELECT pwdHash;
			END IF;
            
		ELSE
			SIGNAL SQLSTATE '45000'
				SET message_text =  'Cuenta inválida.';
        END IF;
        
	ELSEIF opt = -2 THEN
                                    
		SET userId = (SELECT np_usr_id FROM newPwd WHERE np_hash = valHash_);
        
		IF userId = 0 THEN
			SET userId = (SELECT np_st_id FROM newPwd WHERE np_hash = valHash_);
            SET userEmail = (SELECT st_correo FROM staff WHERE st_id = userId);
            SET typeUSer = 2;
            
		ELSE
			SET userEmail = (SELECT usr_correo FROM usuarios WHERE usr_id = userId);
			SET typeUser = 1;
        END IF;
        
       IF typeUser = 1 THEN
            
            START TRANSACTION;
			UPDATE usuarios SET
				usr_password = md5(CONCAT(userEmail, pwdNew, (SELECT cfg_valor FROM configuraciones WHERE cfg_id = 1)))
                , usr_fecha_actualizacion = NOW()
			WHERE usr_id = userId;
			
			UPDATE newPwd SET
				np_status = 1
			WHERE np_hash = valHash_;
			
			IF `_rollback` THEN
				SIGNAL SQLSTATE '45000'
					SET message_text = 'Algo ha ido mal, intentalo más tarde.';
			ELSE
				COMMIT;
                SELECT 'OK' AS message;
			END IF;
		ELSEIF typeUser = 2 THEN
            
            START TRANSACTION;
			UPDATE staff SET
				st_password = md5(CONCAT(userEmail, pwdNew, (SELECT cfg_valor FROM configuraciones WHERE cfg_id = 1)))
                , st_fecha_actualizacion = NOW()
			WHERE st_id = userId;
			
			UPDATE newPwd SET
				np_status = 1
			WHERE np_hash = valHash_;
			
			IF `_rollback` THEN
				SIGNAL SQLSTATE '45000'
					SET message_text = 'Algo ha ido mal, intentalo más tarde.';
			ELSE
				COMMIT;
                SELECT 'OK' AS message;
			END IF;
            
        ELSE
			SIGNAL SQLSTATE '45000'
				SET message_text = 'Algo ha ido mal, intentalo más tarde.';
        END IF; 
	ELSE
		SIGNAL SQLSTATE '45000'
			SET message_text = 'Opción inválida.';
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getPatientDocNames` (IN `shash` VARCHAR(35), IN `typePerson` INT, IN `startDate` VARCHAR(100))  BEGIN
	DECLARE userId INT;
    DECLARE doctorId INT;
    DECLARE pacientId INT;
    DECLARE citaId INT;
    DECLARE `_rollback` BOOL DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SET `_rollback` = 1;
		ROLLBACK;
        RESIGNAL;
    END;
    
    SET userId = (SELECT vt_st_id FROM validtokens WHERE vt_hash = shash AND vt_status = 1);
	SET userId = IFNULL(userId, -1);
    
    IF typePerson = 0 THEN
        SET userId = (SELECT vt_usr_id FROM validtokens WHERE vt_hash = shash AND vt_status = 1);
        SET userId = IFNULL(userId, -1);
        
        IF userId > 0 THEN
			
            SET citaId = (SELECT cita_id FROM citas WHERE cita_fecha_start = startDate AND cita_estatus <> 5);
            SET doctorId = (SELECT cita_doctor_id FROM citas WHERE cita_id = citaId);
            
            SELECT
				CONCAT(st_nombre, ' ', sp_paterno, ' ', st_materno) AS perName
            FROM staff
            WHERE st_id = doctorId;
            
        ELSE
			SIGNAL SQLSTATE '45000'
				SET message_text = 'Sin privilegios.';
        END IF;        
        
    ELSEIF typePerson = 1 THEN
		SET userId = (SELECT vt_st_id FROM validtokens WHERE vt_hash = shash AND vt_status = 1);
		SET userId = IFNULL(userId, -1);
        
        IF userId > 0 THEN
			
			SET citaId = (SELECT cita_id FROM citas WHERE cita_fecha_start = startDate AND cita_estatus <> 5);
			SET pacientId = (SELECT cita_paciente_id FROM citas WHERE cita_id = citaId);
				
			SELECT
				CONCAT(usr_nombre, ' ', usr_paterno, ' ', usr_materno) AS perName
			FROM usuarios
			WHERE usr_id = pacientId;
        
        ELSE
			SIGNAL SQLSTATE '45000'
				SET message_text = 'Sin privilegios.';
        END IF;
    ELSE
        SIGNAL SQLSTATE '45000'
			SET message_text = 'Sin privilegios.';
    END IF;
        
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getProfileUsr` (IN `shash` VARCHAR(35))  BEGIN
	DECLARE userId INT;
    DECLARE `_rollback` BOOL DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SET `_rollback` = 1;
		ROLLBACK;
        RESIGNAL;
    END;
	
    SET userId = (SELECT vt_usr_id FROM validtokens WHERE vt_hash = shash AND vt_status = 1);
    SET userId = IFNULL(userId, -1);
    
    SELECT
		CONCAT(usr.usr_nombre) AS nombreUsuario
        , tp.t_gender AS idGender
        , gen.g_desc AS gender
        , usr.usr_nacionalidad_id AS idNac
        , na.nacionalidad_desc AS nacionalidad
        , tp.t_age AS age
        , tp.t_birthDate AS birthDate
        , tp.t_civilState AS idCs
        , ce.ce_desc AS civilState
        , usr.usr_movil AS phoneContact
        , usr.usr_correo AS email
        , IFNULL(pa.pa_addon, '') AS aditional
        , IFNULL(bp.bp_famHist, '') AS famHist
        , IFNULL(bp.bp_dynFam, '') AS dinamicaFamiliar
        , IFNULL(bp.bp_reazons, '') AS movitosConsulta
        , IFNULL(bp.bp_actualProblem, '') AS problematicaActual
        , IFNULL(bp.bp_medicalAspects, '') AS aspectosMedicos
        , IFNULL(bp.bp_pshicological, '') AS psicologicos
        , IFNULL(bp.bp_trauma, '') AS traumas
        , IFNULL(bp.bp_socialProfile, '') AS perfilSocial
    FROM test_profile tp
		INNER JOIN usuarios usr ON (usr.usr_id = tp.t_usr_id)
		LEFT JOIN gender gen ON (gen.g_id = tp.t_gender)
		LEFT JOIN nacionalidades na ON (na.nacionalidad_id = usr.usr_nacionalidad_id)
        LEFT JOIN patientAddon pa ON (pa.pa_usr_id = usr.usr_id)
        LEFT JOIN bitacoraPaciente bp ON (bp.bp_usr_id = usr.usr_id)
        LEFT JOIN civil_estado ce ON (ce.ce_id = tp.t_civilState)
	WHERE usr.usr_id = userId;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getThInfo` (IN `shash` VARCHAR(35), IN `stId` INT)  BEGIN
	DECLARE userId INT;
    DECLARE `_rollback` BOOL DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SET `_rollback` = 1;
		ROLLBACK;
        RESIGNAL;
    END;
    
    SET userId = (SELECT vt_st_id FROM validtokens WHERE vt_hash = shash AND vt_status = 1);
	SET userId = IFNULL(userId, -1);
    
    IF userId > 0 THEN
		SELECT
            st.st_id
            , st.st_nombre
            , st.st_paterno
            , st.st_materno
            , st.st_correo
            , pt.pt_perfil
        FROM staff st
            INNER JOIN perfilTerapeuta pt ON (st.st_id = pt.pt_st_id AND pt.pt_status = 1)
        WHERE st_id = stId;
    ELSE 	
		SIGNAL SQLSTATE '45000'
			SET message_text = 'Sin privilegios.';
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getTicketDetail` (IN `shash` VARCHAR(45), IN `ticketId` INT, IN `typeR` VARCHAR(5))  BEGIN
	DECLARE userId INT;
    DECLARE `_rollback` BOOL DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SET `_rollback` = 1;
		ROLLBACK;
        RESIGNAL;
    END;
	
    SET userId = (SELECT vt_st_id FROM validtokens WHERE vt_hash = shash AND vt_status = 1);
    SET userId = IFNULL(userId, -1);
    
    IF userId > 0 THEN

        IF typeR = 'st' THEN
            SELECT
                CONCAT(st.sps_id, '-',typeR) AS folio
                , DATE_FORMAT(st.sps_createat, '%d/%m/%Y') AS dateS
                , DATE_FORMAT(st.sps_createat, '%h:%i %p') AS hours
                , st.sps_subject AS asunto
                , CONCAT('<span class="', ss.spe_badge,'" style="font-size:18px;">', ss.spe_desc, '</span>') AS estado
                , CONCAT(s.st_nombre, ' ', s.st_paterno, ' ', s.st_materno) AS nombre
                , s.st_correo AS userAccount
                , st.sps_desc AS comment
            FROM supportStaff st
                INNER JOIN supportStatus ss ON (ss.spe_id = st.sps_status)
                INNER JOIN staff s ON (s.st_id = st.sps_usr_id)
            WHERE st.sps_id = ticketId;
        ELSEIF typeR = 'usr' THEN
            SELECT
                CONCAT(spu.spu_id, '-', typeR) AS folio
                , DATE_FORMAT(spu.spu_createat, '%d/%m/%Y') AS dateS
                , DATE_FORMAT(spu.spu_createat, '%h:%i %p') AS hours
                , spu.spu_subject AS asunto
                , CONCAT('<span class="', ss.spe_badge,'" style="font-size:18px;">', ss.spe_desc, '</span>') AS estado
                , CONCAT(u.usr_nombre, ' ', u.usr_paterno, ' ', u.usr_materno) AS nombre
                , u.usr_correo AS userAccount
                , spu.spu_desc AS comment
            FROM supportUsr spu
                INNER JOIN supportStatus ss ON (ss.spe_id = spu.spu_status)
                INNER JOIN usuarios u ON (u.usr_id = spu.spu_usr_id)
            WHERE spu.spu_id = ticketId;
        END IF;

    ELSE
        SIGNAL SQLSTATE '45000'
			SET message_text = 'Sin privilegios.';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_newUser` (IN `nombre` VARCHAR(40), IN `ap` VARCHAR(100), IN `correo` VARCHAR(50), IN `pwd` VARCHAR(15), IN `opt` INT)  BEGIN
	DECLARE	usrlevel int;
    DECLARE userId int;
    DECLARE userHash varchar(50);
    DECLARE passHash varchar(50);
    DECLARE usr_dept int;
    DECLARE usr_job int;
    DECLARE msgErr condition for sqlstate '10000';
    DECLARE `_rollback` BOOL DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	BEGIN
		SET `_rollback` = 1;
        ROLLBACK;
        RESIGNAL;
    END;
    DECLARE CONTINUE HANDLER FOR 1062
    BEGIN
		signal msgErr
			SET message_text = 'La cuenta ya está en uso';
    END;
    
	SET usrlevel = 1;
    SET passHash =  md5(CONCAT(correo,pwd,(SELECT cfg_valor FROM configuraciones WHERE cfg_id = 1)));
    
    IF opt = 1 THEN
		SET usr_dept = 2;
        SET usr_job = 2;
	END IF;
	IF opt = 2 THEN
		SET usr_dept = 3;
        SET usr_job = 3;
    END IF;
        
    START TRANSACTION;
	INSERT INTO usuarios (
		usr_nombre,
        usr_paterno,
        usr_nivelUsr_id,
        usr_login,
        usr_password,
        usr_correo,
        usr_departamento_id,
        usr_puesto_id
    ) VALUES(
		nombre,
        ap,
        usrlevel,
        correo,
        passHash,
        correo,
        usr_dept,
        usr_job
	);
    
    SET userId = (SELECT usr_id FROM usuarios WHERE usr_correo = correo);
    SET userHash = md5(CONCAT(convert(userId, char(50)), correo, nombre));
    
    INSERT INTO validateSess (
		vs_usr_id,
        vs_hash
    ) VALUES (
		userId,
        userHash
    );
    IF `_rollback` THEN
		SIGNAL SQLSTATE '45000'
			SET message_text = 'Algo ha ido mal, intentalo más tarde.';
	ELSE
		COMMIT;
        SELECT vs_hash FROM validateSess WHERE vs_usr_id = userId;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_reviewDate` (IN `shash` VARCHAR(35), IN `userType` INT, IN `cId` INT)  BEGIN
	DECLARE userId INT;
    DECLARE validId INT;
    DECLARE `_rollback` BOOL DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SET `_rollback` = 1;
		ROLLBACK;
        RESIGNAL;
    END;
    
    IF userType = 0 THEN
		
        SET userId = (SELECT vt_usr_id FROM validtokens WHERE vt_hash = shash AND vt_status = 1);
		SET userId = IFNULL(userId, -1);
        
        IF userId > 0 THEN
            
            SET validId = (SELECT cv_id FROM citas_validation WHERE cv_status = 1 AND cv_c_id = cId);
			SET validId = IFNULL(validId, -1);
            
            START TRANSACTION;
            
            UPDATE citas_validation SET
				cv_status_view = 2
                , cv_status = 2
                , cv_validat = NOW()
			WHERE cv_id = validId;
            
            IF ROW_COUNT() <= 0 THEN
				SIGNAL SQLSTATE '45000'
					SET message_text = 'Cita no encontrada.';
			END IF;
            
            IF `_rollback` THEN
				SIGNAL SQLSTATE '45000'
					SET message_text = 'Algo ha ido mal, intentalo más tarde.';
			ELSE
				COMMIT;
				SELECT 'OK' AS msg;
			END IF;
 
        ELSE 
			SIGNAL SQLSTATE '45000'
				SET message_text = 'Sin privilegios.';
        END IF;
        
        
    ELSEIF userType = 1 THEN
    
		SET userId = (SELECT vt_st_id FROM validtokens WHERE vt_hash = shash AND vt_status = 1);
		SET userId = IFNULL(userId, -1);
    
		IF userId > 0 THEN
			
            SET validId = (SELECT cv_id FROM citas_validation WHERE cv_status = 0 AND cv_c_id = cId);
			SET validId = IFNULL(validId, -1);
            
            START TRANSACTION;
            
            UPDATE citas_validation SET
				cv_status_view = 2
                , cv_status = 2
                , cv_validat = NOW()
			WHERE cv_id = validId;
            
            IF ROW_COUNT() <= 0 THEN
				SIGNAL SQLSTATE '45000'
					SET message_text = 'Algo ha ido mal, intentalo más tarde.';
			END IF;
            
            IF `_rollback` THEN
				SIGNAL SQLSTATE '45000'
					SET message_text = 'Algo ha ido mal, intentalo más tarde.';
			ELSE
				COMMIT;
				SELECT 'OK' AS msg;
			END IF;
            
        ELSE 
			SIGNAL SQLSTATE '45000'
				SET message_text = 'Sin privilegios.';
        END IF;
    
		
    ELSE
		SIGNAL SQLSTATE '45000'
			SET message_text = 'Estatus no válido.';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_setBanTherapiest` (IN `shash` VARCHAR(35), IN `sIdstaff` INT)  BEGIN
	DECLARE userId INT;
	DECLARE `_rollback` BOOL DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SET `_rollback` = 1;
		ROLLBACK;
        RESIGNAL;
    END;
    
    SET userId = (SELECT vt_st_id FROM validtokens WHERE vt_hash = shash AND vt_status = 1);
	SET userId = IFNULL(userId, -1);

    IF userId > 0 THEN
		START TRANSACTION;
        
        UPDATE staff SET
            st_estatus = 0
            , st_fecha_cancelacion = NOW()
            , st_usr_id_cancelacion = userId
        WHERE st_id = sIdstaff;

        IF `_rollback` THEN
			SIGNAL SQLSTATE '45000'
				SET message_text = 'Algo ha ido mal, intentalo más tarde.';
		ELSE
            COMMIT;
			SELECT 'OK' AS msg;
		END IF;
    ELSE 
		SIGNAL SQLSTATE '45000'
			SET message_text = 'Sin privilegios.';
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_setBitacoraPaciente` (IN `shash` VARCHAR(35), IN `usrId` INT, IN `histFam` TEXT, IN `dinFam` TEXT, IN `mc` TEXT, IN `hpa` TEXT, IN `am` TEXT, IN `psi` TEXT, IN `trauma` TEXT, IN `ps` TEXT)  BEGIN
	DECLARE userId INT;
    DECLARE expCount INT;
    DECLARE `_rollback` BOOL DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SET `_rollback` = 1;
		ROLLBACK;
        RESIGNAL;
    END;
    
    SET userId = (SELECT IFNULL(vt_st_id, 0) FROM validtokens WHERE vt_hash = shash AND vt_status = 1 AND vt_usr_id = 0);
	SET userId = IFNULL(userId, -1);
    
    SET expCount = (SELECT COUNT(*) FROM bitacoraPaciente);
    
    IF expCount = 0 THEN
		START TRANSACTION;
            INSERT INTO bitacoraPaciente (
				bp_usr_id
                , bp_famHist
                , bp_dynFam
                , bp_reazons
                , bp_actualProblem
                , bp_medicalAspects
                , bp_pshicological
                , bp_trauma
                , bp_socialProfile
            ) VALUES(
				usrId
                , histFam
                , dinFam
                , mc
                , hpa
                , am
                , psi
                , trauma
                , ps
            );
            
        IF `_rollback` THEN
			SIGNAL SQLSTATE '45000'
				SET message_text = 'Algo ha ido mal, intentalo más tarde.';
		ELSE
			COMMIT;
			SELECT 'OK' AS msg;
		END IF;
    ELSEIF expCount > 0 THEN
		
        START TRANSACTION;
        
        IF histFam != '' THEN
			UPDATE bitacoraPaciente SET 
				bp_famHist = histFam
			WHERE bp_usr_id = userId;
		END IF;
        
        IF dinFam != '' THEN
			UPDATE bitacoraPaciente SET 
				bp_dynFam = dinFam
			WHERE bp_usr_id = userId;
		END IF;
        
        IF mc != '' THEN
			UPDATE bitacoraPaciente SET 
				bp_reazons = mc
			WHERE bp_usr_id = userId;
		END IF;
        
        IF hpa != '' THEN
			UPDATE bitacoraPaciente SET 
				bp_actualProblem = hpa
			WHERE bp_usr_id = userId;
		END IF;
        
        IF am != '' THEN
			UPDATE bitacoraPaciente SET 
				bp_medicalAspects = am
			WHERE bp_usr_id = userId;
		END IF;
        
        IF psi != '' THEN
			UPDATE bitacoraPaciente SET 
				bp_pshicological = psi
			WHERE bp_usr_id = userId;
		END IF;
        
        IF trauma != '' THEN
			UPDATE bitacoraPaciente SET 
				bp_trauma = trauma
			WHERE bp_usr_id = userId;
		END IF;
        
        IF ps != '' THEN
			UPDATE bitacoraPaciente SET 
				bp_socialProfile = ps
			WHERE bp_usr_id = userId;
		END IF;

        IF `_rollback` THEN
			SIGNAL SQLSTATE '45000'
				SET message_text = 'Algo ha ido mal, intentalo más tarde.';
		ELSE
			COMMIT;
			SELECT 'OK' AS msg;
		END IF;
    ELSE
		SIGNAL SQLSTATE '45000'
			SET message_text = 'Opción inválida.';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_setEditStaff` (IN `shash` VARCHAR(35), IN `sIdstaff` INT, IN `sName` VARCHAR(100), IN `sFirstname` VARCHAR(100), IN `sLastname` VARCHAR(100), IN `sService` VARCHAR(20))  BEGIN
	DECLARE userId INT;
    DECLARE subss VARCHAR(5);
    DECLARE userHash VARCHAR(35);
	DECLARE `_rollback` BOOL DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SET `_rollback` = 1;
		ROLLBACK;
        RESIGNAL;
    END;
    
    SET userId = (SELECT vt_st_id FROM validtokens WHERE vt_hash = shash AND vt_status = 1);
	SET userId = IFNULL(userId, -1);

    IF userId > 0 THEN
		DROP TEMPORARY TABLE IF EXISTS tmp_jobsEdit;
		
		CREATE TEMPORARY TABLE tmp_jobsEdit (
			id INT NOT NULL AUTO_INCREMENT PRIMARY KEY
			, job INT
		);
        
        WHILE LENGTH(sService) > 0 DO
            INSERT INTO tmp_jobsEdit (
				job
            ) VALUES (
				SUBSTRING_INDEX(sService, ',', 1)
            );
            
            IF LENGTH(sService) = 1 THEN
				SET subss = SUBSTRING_INDEX(sService, ',', 1);
            ELSE
				SET subss = CONCAT(SUBSTRING_INDEX(sService, ',', 1), ',');
            END IF;
            
            SET sService = REPLACE(sService, subss, '');
        END WHILE;
    
		START TRANSACTION;
        
        UPDATE staff SET
            st_nombre = sName
            , st_paterno = sFirstname
            , st_materno = sLastname
            , st_fecha_actualizacion = NOW()
            , st_usr_id_actualizacion = userId
        WHERE st_id = sIdstaff;

        UPDATE perfilTerapeuta SET
            pt_status = 0
        WHERE pt_st_id = sIdstaff;

        INSERT INTO perfilTerapeuta (
			pt_st_id
            , pt_perfil
        ) SELECT
			sIdstaff
			, job
		FROM tmp_jobsEdit;

        IF `_rollback` THEN
            DROP TEMPORARY TABLE IF EXISTS tmp_jobsEdit;
			SIGNAL SQLSTATE '45000'
				SET message_text = 'Algo ha ido mal, intentalo más tarde.';
		ELSE
			DROP TEMPORARY TABLE IF EXISTS tmp_jobsEdit;
            COMMIT;
			SELECT 'OK' AS msg;
		END IF;
    ELSE 
        DROP TEMPORARY TABLE IF EXISTS tmp_jobsEdit;	
		SIGNAL SQLSTATE '45000'
			SET message_text = 'Sin privilegios.';
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_setNewDate` (IN `token_hash` VARCHAR(35), IN `dateStart` DATETIME, IN `dateEnd` DATETIME, IN `dateType` INT)  BEGIN
	DECLARE userId INT;
    DECLARE doctorId INT;
    DECLARE compareStart INT;
    DECLARE compareEnd INT;
    DECLARE dates INT;
    DECLARE lastIns INT;
	DECLARE configStart VARCHAR(15);
	DECLARE configEnd VARCHAR(15);
    DECLARE `_rollback` BOOL DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SET `_rollback` = 1;
		ROLLBACK;
        RESIGNAL;
    END;
    
    SET userId = (SELECT IFNULL(vt_usr_id, 0) FROM validtokens WHERE vt_hash = token_hash AND vt_status= 1);
    
    IF userId > 0 THEN
		
        SET doctorId = (SELECT expP_doctor_id FROM expedientepaciente WHERE expP_paciente_id = userId);
        SET compareStart = (SELECT COUNT(*) FROM citas WHERE cita_doctor_id = doctorId AND (cita_fecha_start BETWEEN dateStart AND dateEnd));
        SET compareEnd = (SELECT COUNT(*) FROM citas WHERE cita_doctor_id = doctorId AND (cita_fecha_end BETWEEN dateStart AND dateEnd));
        SET dates = (SELECT DATEDIFF(dateStart, dateEnd));
        
        IF compareStart = 0 && compareEnd = 0 && dates = 0 THEN
			
			SET configStart = (SELECT cfg_valor FROM configuraciones WHERE cfg_nombre = 'hh_start' AND cfg_estatus = 1);
			SET configEnd = (SELECT cfg_valor FROM configuraciones WHERE cfg_nombre = 'hh_end' AND cfg_estatus = 1);

			IF (TIME(dateStart) > TIME(configStart) AND TIME(dateStart) < TIME(configEnd)) AND (TIME(dateEnd) > TIME(configStart) AND TIME(dateEnd) < TIME(configEnd)) THEN
			/** IF (SELECT COUNT(*) FROM available_hours WHERE (TIME(dateStart) BETWEEN hh_start AND hh_end) AND hh_status = 1) > 0 && (SELECT COUNT(*) FROM available_hours WHERE (TIME(dateEnd) BETWEEN hh_start AND hh_end) AND hh_status = 1) > 0 THEN*/
				IF dateStart < dateEnd THEN
					IF TIMEDIFF(dateStart, dateEnd) = '-00:50:00' THEN
						START TRANSACTION;
                        INSERT INTO citas (
							cita_fecha_start
							, cita_fecha_end
							, cita_paciente_id
							, cita_doctor_id
							, cita_usr_id_alta
							, cita_title
						) VALUES (
							dateStart
							, dateEnd
							, userId
							, doctorId
							, userId
							, dateType
						);
                        
                        SET lastIns = (SELECT cita_id FROM citas WHERE cita_paciente_id = userId ORDER BY cita_id DESC LIMIT 1);
                        
                        INSERT INTO citas_validation (
							cv_c_id
                        ) VALUES(
							lastIns
                        );
						IF `_rollback` THEN
							SIGNAL SQLSTATE '45000'
								SET message_text = 'Algo ha ido mal, intentalo más tarde.';
						ELSE
							COMMIT;
							SELECT 'OK' AS message;
						END IF;
                    ELSE
						SIGNAL SQLSTATE '45000'
							SET message_text = 'Horario no disponible. Selecciona otro horario.';
                    END IF;
                ELSE
					SIGNAL SQLSTATE '45000'
						SET message_text = 'Horario no disponible. Selecciona otro horario.';
                END IF;
                
			ELSE
				SIGNAL SQLSTATE '45000'
					SET message_text = 'Horario no disponible. Selecciona otro horario.';
            END IF;
        ELSE
			SIGNAL SQLSTATE '45000'
				SET message_text = 'Horario no disponible. Selecciona otro horario.';
        END IF;
    ELSE
		SIGNAL SQLSTATE '45000'
			SET message_text = 'Algo ha ido mal, intentalo más tarde.';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_setNewStaff` (IN `shash` VARCHAR(35), IN `sName` VARCHAR(100), IN `sFirstname` VARCHAR(100), IN `sLastname` VARCHAR(100), IN `sEmail` VARCHAR(100), IN `sService` VARCHAR(20), IN `sDepartment` INT, IN `sJob` INT)  BEGIN
	DECLARE userId INT;
    DECLARE newStaff INT;
    DECLARE subss VARCHAR(5);
    DECLARE userHash VARCHAR(35);
	DECLARE `_rollback` BOOL DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SET `_rollback` = 1;
		ROLLBACK;
        RESIGNAL;
    END;
    
    SET userId = (SELECT vt_st_id FROM validtokens WHERE vt_hash = shash AND vt_status = 1);
	SET userId = IFNULL(userId, -1);
    
    IF (SELECT COUNT(*) FROM usuarios WHERE usr_correo = sEmail AND usr_estatus = 1) > 0 THEN
        SIGNAL SQLSTATE '45000'
			SET message_text = 'La cuenta ya está en uso.';
    END IF;

    IF userId > 0 THEN
		DROP TEMPORARY TABLE IF EXISTS tmp_jobs;
		
		CREATE TEMPORARY TABLE tmp_jobs (
			id INT NOT NULL AUTO_INCREMENT PRIMARY KEY
			, job INT
		);
        
        WHILE LENGTH(sService) > 0 DO
            INSERT INTO tmp_jobs (
				job
            ) VALUES (
				SUBSTRING_INDEX(sService, ',', 1)
            );
            
            IF LENGTH(sService) = 1 THEN
				SET subss = SUBSTRING_INDEX(sService, ',', 1);
            ELSE
				SET subss = CONCAT(SUBSTRING_INDEX(sService, ',', 1), ',');
            END IF;
            
            SET sService = REPLACE(sService, subss, '');
        END WHILE;
    
		START TRANSACTION;
        
        INSERT INTO staff (
			st_nombre
            , st_paterno
            , st_materno
            , st_departamento_id
            , st_puesto_id
            , st_login
            , st_correo
            , st_usr_id_alta
        ) VALUES (
			sName,
            sFirstname,
            sLastname,
            sDepartment,
            sJob,
            sEmail,
            sEmail,
            userId
        );
        
        SET newStaff = LAST_INSERT_ID();
        SET userHash = md5(CONCAT(convert(userId, char(50)), sEmail, sName));
        
        INSERT INTO perfilTerapeuta (
			pt_st_id
            , pt_perfil
        ) SELECT
			newStaff
			, job
		FROM tmp_jobs;
        
        INSERT INTO validateSess (
            vs_st_id,
            vs_hash
        ) VALUES (
            newStaff,
            userHash
        );

        IF `_rollback` THEN
            DROP TEMPORARY TABLE IF EXISTS tmp_jobsEdit;
			SIGNAL SQLSTATE '45000'
				SET message_text = 'Algo ha ido mal, intentalo más tarde.';
		ELSE
			DROP TEMPORARY TABLE IF EXISTS tmp_jobsEdit;
            COMMIT;
			SELECT 'OK' AS msg;
		END IF;
    ELSE 	
        DROP TEMPORARY TABLE IF EXISTS tmp_jobsEdit;
		SIGNAL SQLSTATE '45000'
			SET message_text = 'Sin privilegios.';
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_setProfileUsr` (IN `chash` VARCHAR(35), IN `opt` INT, IN `cName` VARCHAR(50), IN `gender` INT, IN `birthDate` DATETIME, IN `civilState` INT, IN `contactPhone` INT, IN `aditionalInfo` TEXT)  BEGIN
	DECLARE userId INT;
    DECLARE `_rollback` BOOL DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SET `_rollback` = 1;
		ROLLBACK;
        RESIGNAL;
    END;
    
    SET userId = (SELECT vt_usr_id FROM validtokens WHERE vt_hash = shash AND vt_status = 1);
    SET userId = IFNULL(userId, -1);
    
    IF opt = 1 THEN /*Información general*/
		select '';
    ELSEIF opt = 2 THEN  /*Información de contacto*/
		select '';
    ELSEIF opt = 3 THEN /* Información adicional*/
		select '';
	ELSEIF opt = 4 THEN /*Carga de imagen*/
		select '';
    ELSE
		select '';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_supportStaff` (IN `shash` VARCHAR(45), IN `subjectm` VARCHAR(200), IN `descriptionm` TEXT, IN `opt` INT)  BEGIN
	DECLARE userId INT;
    DECLARE `_rollback` BOOL DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SET `_rollback` = 1;
		ROLLBACK;
        RESIGNAL;
    END;
	
    SET userId = (SELECT vt_st_id FROM validtokens WHERE vt_hash = shash AND vt_status = 1);
    SET userId = IFNULL(userId, -1);
    
    IF opt = 1 THEN
		SELECT 
			st.sps_id AS folio
            , DATE_FORMAT(st.sps_createat, '%d/%m/%Y') AS dateS
            , DATE_FORMAT(st.sps_createat, '%h:%i %p') AS hours
            , st.sps_subject AS asunto
            , CONCAT('<span class="', ss.spe_badge,'" style="font-size:18px;">', ss.spe_desc, '</span>') AS estado
		FROM supportStaff st
			INNER JOIN supportStatus ss ON (ss.spe_id = st.sps_status)
        WHERE st.sps_usr_id = userId;
    ELSEIF opt = 2 THEN
		START TRANSACTION;
		
        INSERT INTO supportStaff (
			sps_usr_id
            , sps_status
            , sps_subject
            , sps_desc
        ) VALUES (
			userId
            , 3
            , subjectm
            , descriptionm
        );
        
        IF `_rollback` THEN
			SIGNAL SQLSTATE '45000'
				SET message_text = 'Algo ha ido mal, intentalo más tarde.';
		ELSE
			COMMIT;
			SELECT 'OK' AS msg;
		END IF;
    ELSE
		SIGNAL SQLSTATE '45000'
			SET message_text = 'Opción inválida.';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_supportUsr` (IN `shash` VARCHAR(45), IN `subjectm` VARCHAR(200), IN `descriptionm` TEXT, IN `opt` INT)  BEGIN
	DECLARE userId INT;
    DECLARE `_rollback` BOOL DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SET `_rollback` = 1;
		ROLLBACK;
        RESIGNAL;
    END;
	
    SET userId = (SELECT vt_usr_id FROM validtokens WHERE vt_hash = shash AND vt_status = 1);
    SET userId = IFNULL(userId, -1);
    
    IF opt = 1 THEN
		SELECT 
			su.spu_id AS folio
            , DATE_FORMAT(su.spu_createat, '%d/%m/%Y') AS dateS
            , DATE_FORMAT(su.spu_createat, '%h:%i %p') AS hours
            , su.spu_subject AS asunto
            , CONCAT('<span class="', ss.spe_badge,'" style="font-size:18px;">', ss.spe_desc, '</span>') AS estado
		FROM supportUsr su
			INNER JOIN supportStatus ss ON (ss.spe_id = su.spu_status)
        WHERE su.spu_usr_id = userId;
    ELSEIF opt = 2 THEN
		START TRANSACTION;
		
        INSERT INTO supportUsr (
			spu_usr_id
            , spu_status
            , spu_subject
            , spu_desc
        ) VALUES (
			userId
            , 3
            , subjectm
            , descriptionm
        );
        
        IF `_rollback` THEN
			SIGNAL SQLSTATE '45000'
				SET message_text = 'Algo ha ido mal, intentalo más tarde.';
		ELSE
			COMMIT;
			SELECT 'OK' AS msg;
		END IF;
    ELSE
		SIGNAL SQLSTATE '45000'
			SET message_text = 'Opción inválida.';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_validateAccount` (IN `codeAccount` VARCHAR(50))  BEGIN
	DECLARE msgErr condition for sqlstate '10001';
    DECLARE noRegister int;
    DECLARE registerallready int;
    DECLARE registerActivate int;
    
    SET noRegister = (SELECT COUNT(*) FROM validateSess WHERE vs_hash = codeAccount);
    SET registerallready = (SELECT COUNT(*) FROM validateSess WHERE vs_hash = codeAccount AND vs_status = 1);
    SET registerActivate = (SELECT COUNT(*) FROM validateSess WHERE vs_hash = codeAccount AND vs_status = 0);
    
	IF noRegister = 0 THEN
		signal msgErr
			SET message_text = 'Registrate para activar tu cuenta.';
    ELSEIF registerallready > 0 THEN
		signal msgErr
			SET message_text = 'Tu cuenta ya ha sido activada.';
	ELSEIF registerActivate > 0 THEN
		UPDATE validateSess SET
			vs_status = 1
            , vs_activateat = CURRENT_TIMESTAMP
		WHERE vs_hash = codeAccount;
        
        SELECT
			'activate' as estatus
            , vs_activateat
        FROM validateSess
        WHERE vs_hash = codeAccount;
	ELSE
		signal msgErr
			SET message_text = 'Error en la activación.';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_validateToken` (IN `sessToken` VARCHAR(40))  BEGIN
	DECLARE tcounter INT;
    DECLARE validDate INT;
    DECLARE msgErr condition for sqlstate '10000';
    
    SET tcounter = (SELECT COUNT(*) FROM validtokens WHERE vt_hash = sessToken AND vt_status = 1);
    
    IF tcounter > 0 THEN
		SET validDate = DATEDIFF((SELECT vt_createat FROM validtokens WHERE vt_hash = sessToken AND vt_status = 1), NOW());
        
        IF validDate = 0 THEN
			SELECT 'OK' as message;
        ELSE
			signal msgErr
			SET message_text = 'Sesión inválida.';
        END IF;
    ELSE
		signal msgErr
			SET message_text = 'Inicia sesión.';
    END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `accesos`
--

CREATE TABLE `accesos` (
  `acceso_id` int(11) NOT NULL,
  `nivel_usr` int(11) NOT NULL DEFAULT '0',
  `menu_id` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `accesos`
--

INSERT INTO `accesos` (`acceso_id`, `nivel_usr`, `menu_id`) VALUES
(1, 1, 1),
(2, 1, 2),
(3, 1, 3),
(4, 1, 4),
(5, 1, 5),
(6, 1, 6),
(7, 4, 3),
(8, 4, 4),
(9, 4, 5),
(10, 5, 6);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `bitacorapaciente`
--

CREATE TABLE `bitacorapaciente` (
  `bp_id` int(11) NOT NULL,
  `bp_usr_id` int(11) NOT NULL DEFAULT '0',
  `bp_famHist` text NOT NULL,
  `bp_dynFam` text NOT NULL,
  `bp_reazons` text NOT NULL,
  `bp_actualProblem` text NOT NULL,
  `bp_medicalAspects` text NOT NULL,
  `bp_pshicological` text NOT NULL,
  `bp_trauma` text NOT NULL,
  `bp_socialProfile` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `bitacorapaciente`
--

INSERT INTO `bitacorapaciente` (`bp_id`, `bp_usr_id`, `bp_famHist`, `bp_dynFam`, `bp_reazons`, `bp_actualProblem`, `bp_medicalAspects`, `bp_pshicological`, `bp_trauma`, `bp_socialProfile`) VALUES
(1, 1, 'DFfv', 'H', 'MC', 'PA', 'AM', 'PSICOLOGICdd', 'TRAUMAAa', 'PERFILLa');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `citas`
--

CREATE TABLE `citas` (
  `cita_id` int(11) NOT NULL,
  `cita_fecha_start` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `cita_fecha_end` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `cita_paciente_id` int(11) NOT NULL DEFAULT '0',
  `cita_doctor_id` int(11) NOT NULL DEFAULT '0',
  `cita_estatus` tinyint(4) NOT NULL DEFAULT '1',
  `cita_fecha_alta` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `cita_usr_id_alta` int(11) NOT NULL DEFAULT '0',
  `cita_doctor_id_alta` int(11) NOT NULL DEFAULT '0',
  `cita_usr_id_update` int(11) NOT NULL DEFAULT '0',
  `cita_st_update` int(11) NOT NULL DEFAULT '0',
  `cita_fecha_update` datetime DEFAULT NULL,
  `cita_fecha_cancelacion` datetime DEFAULT NULL,
  `cita_usr_id_cancelacion` int(11) NOT NULL DEFAULT '0',
  `cita_st_id_cancelacion` int(11) NOT NULL DEFAULT '0',
  `cita_title` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `citas`
--

INSERT INTO `citas` (`cita_id`, `cita_fecha_start`, `cita_fecha_end`, `cita_paciente_id`, `cita_doctor_id`, `cita_estatus`, `cita_fecha_alta`, `cita_usr_id_alta`, `cita_doctor_id_alta`, `cita_usr_id_update`, `cita_st_update`, `cita_fecha_update`, `cita_fecha_cancelacion`, `cita_usr_id_cancelacion`, `cita_st_id_cancelacion`, `cita_title`) VALUES
(1, '2018-03-24 20:10:00', '2018-03-24 21:00:00', 1, 1, 4, '2018-03-23 16:57:31', 1, 0, 0, 1, '2018-03-23 17:35:04', '2018-03-23 17:35:04', 0, 1, 1),
(2, '2018-03-24 02:00:00', '2018-03-24 02:50:00', 12, 1, 4, '2018-03-23 16:57:53', 12, 0, 0, 1, '2018-03-23 17:01:05', '2018-03-23 17:01:05', 0, 1, 1),
(3, '2018-03-24 20:10:00', '2018-03-24 21:00:00', 1, 1, 3, '2018-03-23 17:36:47', 1, 0, 0, 1, '2018-03-23 18:08:14', '2018-03-23 17:50:45', 0, 1, 1),
(4, '2018-03-23 19:00:00', '2018-03-23 19:50:00', 12, 1, 2, '2018-03-23 18:50:07', 12, 0, 0, 1, '2018-03-23 18:52:28', NULL, 0, 0, 2),
(5, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, 1, 6, '2018-03-23 18:54:58', 0, 0, 0, 1, '2018-03-23 18:55:57', NULL, 0, 0, 3),
(6, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 12, 1, 6, '2018-03-23 18:54:58', 0, 0, 0, 1, '2018-03-23 18:55:57', NULL, 0, 0, 3),
(7, '2018-03-29 00:00:00', '2018-03-31 15:00:00', 1, 1, 5, '2018-03-23 18:56:45', 0, 0, 0, 0, NULL, NULL, 0, 0, 3),
(8, '2018-03-29 00:00:00', '2018-03-31 15:00:00', 12, 1, 5, '2018-03-23 18:56:45', 0, 0, 0, 0, NULL, NULL, 0, 0, 3),
(9, '2018-03-31 15:30:00', '2018-03-31 16:20:00', 12, 1, 2, '2018-03-23 18:58:16', 12, 0, 0, 1, '2018-03-23 18:58:45', NULL, 0, 0, 1),
(10, '2018-04-03 13:00:00', '2018-04-03 13:50:00', 1, 1, 2, '2018-04-03 12:58:15', 1, 0, 0, 1, '2018-04-03 12:58:26', NULL, 0, 0, 1),
(11, '2018-04-03 20:00:59', '2018-04-03 20:50:59', 1, 1, 3, '2018-04-03 13:00:54', 1, 0, 0, 1, '2018-04-03 18:01:54', NULL, 0, 0, 1),
(12, '2018-04-10 18:00:00', '2018-04-11 00:00:00', 1, 1, 5, '2018-04-03 13:36:13', 0, 0, 0, 0, NULL, NULL, 0, 0, 3),
(13, '2018-04-10 18:00:00', '2018-04-11 00:00:00', 12, 1, 5, '2018-04-03 13:36:13', 0, 0, 0, 0, NULL, NULL, 0, 0, 3),
(14, '2018-04-03 18:00:00', '2018-04-03 19:00:00', 1, 1, 5, '2018-04-03 17:26:36', 0, 0, 0, 0, NULL, NULL, 0, 0, 3),
(15, '2018-04-03 18:00:00', '2018-04-03 19:00:00', 12, 1, 5, '2018-04-03 17:26:36', 0, 0, 0, 0, NULL, NULL, 0, 0, 3),
(16, '2018-04-03 20:00:00', '2018-04-03 20:50:00', 1, 1, 4, '2018-04-03 17:57:19', 1, 0, 0, 1, '2018-04-03 18:00:05', '2018-04-03 18:00:05', 0, 1, 1),
(17, '2018-04-04 21:05:59', '2018-04-04 21:55:59', 1, 1, 3, '2018-04-04 13:52:19', 1, 0, 0, 1, '2018-04-04 14:01:25', NULL, 0, 0, 1),
(18, '2018-04-05 18:15:00', '2018-04-05 19:15:00', 1, 1, 5, '2018-04-04 14:07:20', 0, 0, 0, 0, NULL, NULL, 0, 0, 3),
(19, '2018-04-05 18:15:00', '2018-04-05 19:15:00', 12, 1, 5, '2018-04-04 14:07:20', 0, 0, 0, 0, NULL, NULL, 0, 0, 3),
(20, '2018-04-05 18:15:00', '2018-04-05 19:15:00', 1, 1, 5, '2018-04-04 14:07:21', 0, 0, 0, 0, NULL, NULL, 0, 0, 3),
(21, '2018-04-05 18:15:00', '2018-04-05 19:15:00', 12, 1, 5, '2018-04-04 14:07:21', 0, 0, 0, 0, NULL, NULL, 0, 0, 3),
(22, '2018-04-05 22:00:00', '2018-04-05 23:00:00', 1, 1, 5, '2018-04-04 14:08:07', 0, 0, 0, 0, NULL, NULL, 0, 0, 3),
(23, '2018-04-05 22:00:00', '2018-04-05 23:00:00', 12, 1, 5, '2018-04-04 14:08:08', 0, 0, 0, 0, NULL, NULL, 0, 0, 3);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `citas_communication`
--

CREATE TABLE `citas_communication` (
  `cc_id` int(11) NOT NULL,
  `cc_desc` varchar(40) NOT NULL DEFAULT '',
  `cc_createat` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `cc_status` int(11) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `citas_communication`
--

INSERT INTO `citas_communication` (`cc_id`, `cc_desc`, `cc_createat`, `cc_status`) VALUES
(1, 'Chat', '2018-03-23 16:44:44', 1),
(2, 'Videoconferencia', '2018-03-23 16:44:44', 1),
(3, 'No disponible', '2018-03-23 16:44:44', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `citas_status`
--

CREATE TABLE `citas_status` (
  `cs_id` int(11) NOT NULL,
  `cs_desc` varchar(40) NOT NULL DEFAULT '',
  `cs_createat` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `cs_status` int(11) NOT NULL DEFAULT '1',
  `cs_color` varchar(10) NOT NULL DEFAULT '',
  `cs_badge` varchar(45) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `citas_status`
--

INSERT INTO `citas_status` (`cs_id`, `cs_desc`, `cs_createat`, `cs_status`, `cs_color`, `cs_badge`) VALUES
(1, 'Enviada', '2018-03-23 16:44:44', 1, '#29ABE2', 'badge badge-enviado'),
(2, 'Agendada', '2018-03-23 16:44:44', 1, '#8CC63F', 'badge badge-info'),
(3, 'Reprogramada', '2018-03-23 16:44:44', 1, '#FBB03B', 'badge badge-reprogramado'),
(4, 'Cancelada', '2018-03-23 16:44:44', 1, '#F15A24', 'badge badge-cancelado'),
(5, 'Fecha bloqueada', '2018-03-23 16:44:44', 1, '#B3B3B3', 'badge badge-bloqueado'),
(6, 'Fecha desbloqueada', '2018-03-23 16:44:44', 1, '#27C24C', 'badge badge-success');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `citas_validation`
--

CREATE TABLE `citas_validation` (
  `cv_id` int(11) NOT NULL,
  `cv_c_id` int(11) NOT NULL DEFAULT '0',
  `cv_createat` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `cv_validat` datetime DEFAULT NULL,
  `cv_status` tinyint(4) NOT NULL DEFAULT '0',
  `cv_status_view` tinyint(4) NOT NULL DEFAULT '0',
  `cv_usr_id` int(11) NOT NULL DEFAULT '0',
  `cv_st_id` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `citas_validation`
--

INSERT INTO `citas_validation` (`cv_id`, `cv_c_id`, `cv_createat`, `cv_validat`, `cv_status`, `cv_status_view`, `cv_usr_id`, `cv_st_id`) VALUES
(1, 1, '2018-03-23 16:57:31', '2018-03-23 17:36:40', 2, 2, 0, 1),
(2, 2, '2018-03-23 16:57:53', '2018-03-23 17:05:34', 2, 2, 0, 1),
(3, 3, '2018-03-23 17:36:47', '2018-04-03 12:57:57', 2, 2, 0, 1),
(4, 4, '2018-03-23 18:50:07', '2018-04-03 12:57:59', 2, 2, 0, 1),
(5, 9, '2018-03-23 18:58:16', '2018-04-03 12:57:58', 2, 2, 0, 1),
(6, 10, '2018-04-03 12:58:15', '2018-04-03 13:00:48', 2, 2, 0, 1),
(7, 11, '2018-04-03 13:00:54', '2018-04-04 13:49:34', 2, 2, 0, 1),
(8, 16, '2018-04-03 17:57:19', '2018-04-04 13:49:35', 2, 2, 0, 1),
(9, 17, '2018-04-04 13:52:19', '2018-04-04 14:02:44', 2, 2, 0, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `civil_estado`
--

CREATE TABLE `civil_estado` (
  `ce_id` int(11) NOT NULL,
  `ce_desc` varchar(45) NOT NULL DEFAULT '',
  `ce_createat` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ce_status` int(11) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `civil_estado`
--

INSERT INTO `civil_estado` (`ce_id`, `ce_desc`, `ce_createat`, `ce_status`) VALUES
(1, 'Soltero', '2018-02-24 12:25:12', 1),
(2, 'Casado', '2018-02-24 12:25:12', 1),
(3, 'Divorciado', '2018-02-24 12:25:12', 1),
(4, 'Unión libre', '2018-02-24 12:25:12', 1),
(5, 'Otro', '2018-02-24 12:25:12', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `configuraciones`
--

CREATE TABLE `configuraciones` (
  `cfg_id` int(11) NOT NULL,
  `cfg_nombre` varchar(45) NOT NULL DEFAULT '',
  `cfg_valor` varchar(100) NOT NULL DEFAULT '',
  `cfg_estatus` tinyint(4) NOT NULL DEFAULT '1' COMMENT 'Configuraciones generales de la aplicación:\n\nInicio de Consultas\nTermino de Consultar\n\nCorreo de Envió de mails etc',
  `cfg_fecha_alta` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `cfg_usr_id_alta` int(11) NOT NULL DEFAULT '0',
  `cfg_fecha_cancelacion` datetime DEFAULT NULL,
  `cfg_usr_id_cancelacion` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `configuraciones`
--

INSERT INTO `configuraciones` (`cfg_id`, `cfg_nombre`, `cfg_valor`, `cfg_estatus`, `cfg_fecha_alta`, `cfg_usr_id_alta`, `cfg_fecha_cancelacion`, `cfg_usr_id_cancelacion`) VALUES
(1, 'secret', 'Uncarefully', 1, '2018-03-23 14:18:00', 0, NULL, 0),
(2, 'hh_start', '0:00:00', 1, '2018-03-23 14:18:00', 0, NULL, 0),
(3, 'hh_end', '23:59:59', 1, '2018-03-23 14:18:00', 0, NULL, 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `departamentos`
--

CREATE TABLE `departamentos` (
  `depto_id` int(11) NOT NULL,
  `depto_nombre` varchar(45) NOT NULL DEFAULT '',
  `depto_abreviatura` varchar(5) NOT NULL DEFAULT '',
  `depto_responsable` int(11) NOT NULL DEFAULT '0',
  `depto_fecha_alta` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `depto_usr_id_alta` int(11) NOT NULL DEFAULT '0',
  `depto_fecha_actualizacion` datetime DEFAULT CURRENT_TIMESTAMP,
  `depto_usr_id_actualizacion` int(11) NOT NULL DEFAULT '0',
  `depto_estatus` tinyint(4) DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `departamentos`
--

INSERT INTO `departamentos` (`depto_id`, `depto_nombre`, `depto_abreviatura`, `depto_responsable`, `depto_fecha_alta`, `depto_usr_id_alta`, `depto_fecha_actualizacion`, `depto_usr_id_actualizacion`, `depto_estatus`) VALUES
(1, 'admin', 'admin', 0, '2018-02-24 12:25:11', 0, '2018-02-24 12:25:11', 0, 1),
(2, 'paciente', 'pacie', 0, '2018-02-24 12:25:11', 0, '2018-02-24 12:25:11', 0, 1),
(3, 'terapia', 'terap', 0, '2018-02-24 12:25:11', 0, '2018-02-24 12:25:11', 0, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `emotions`
--

CREATE TABLE `emotions` (
  `e_id` int(11) NOT NULL,
  `e_desc` varchar(45) NOT NULL DEFAULT '',
  `e_createat` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `e_status` int(11) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `emotions`
--

INSERT INTO `emotions` (`e_id`, `e_desc`, `e_createat`, `e_status`) VALUES
(1, 'Miedo', '2018-02-24 12:25:12', 1),
(2, 'Culpa', '2018-02-24 12:25:12', 1),
(3, 'Vergüenza', '2018-02-24 12:25:12', 1),
(4, 'Frustración', '2018-02-24 12:25:12', 1),
(5, 'Arrepentimiento', '2018-02-24 12:25:12', 1),
(6, 'Celos', '2018-02-24 12:25:12', 1),
(7, 'Inseguridad', '2018-02-24 12:25:12', 1),
(8, 'Desinterés', '2018-02-24 12:25:12', 1),
(9, 'Envídia', '2018-02-24 12:25:12', 1),
(10, 'Dolor', '2018-02-24 12:25:12', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `expedientepaciente`
--

CREATE TABLE `expedientepaciente` (
  `expP_id` int(11) NOT NULL,
  `expP_fecha_alta` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expP_doctor_id` int(11) NOT NULL DEFAULT '0',
  `expP_paciente_id` int(11) NOT NULL DEFAULT '0',
  `expP_estatus` tinyint(4) NOT NULL DEFAULT '1',
  `expP_usr_id_alta` int(11) NOT NULL DEFAULT '0',
  `expP_fecha_cancelacion` datetime DEFAULT CURRENT_TIMESTAMP,
  `expP_usr_id_cancelacion` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `expedientepaciente`
--

INSERT INTO `expedientepaciente` (`expP_id`, `expP_fecha_alta`, `expP_doctor_id`, `expP_paciente_id`, `expP_estatus`, `expP_usr_id_alta`, `expP_fecha_cancelacion`, `expP_usr_id_cancelacion`) VALUES
(1, '2018-02-09 08:16:39', 1, 1, 1, 0, '2018-02-09 08:16:39', 0),
(2, '2018-03-21 17:06:05', 1, 12, 1, 0, '2018-03-21 17:06:05', 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `faq_answers`
--

CREATE TABLE `faq_answers` (
  `fqa_id` int(11) NOT NULL,
  `fqa_st_id` int(11) NOT NULL DEFAULT '0',
  `fqa_q_id` int(11) NOT NULL DEFAULT '0',
  `fqa_cat` int(11) NOT NULL DEFAULT '0',
  `fqa_answer` text NOT NULL,
  `fqa_createat` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fqa_updateat` datetime DEFAULT NULL,
  `fqa_st_id_update` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `faq_answers`
--

INSERT INTO `faq_answers` (`fqa_id`, `fqa_st_id`, `fqa_q_id`, `fqa_cat`, `fqa_answer`, `fqa_createat`, `fqa_updateat`, `fqa_st_id_update`) VALUES
(1, 1, 1, 1, '<div class=\"text-justify font-faqs\">Debes hacer click en el horario de tu preferencia, confirmar el medio de contacto mediante el que deseas tomar tu sesión (Videollamada o chat) y hacer click en aceptar. Inmediatamente tu terapeuta recibirá tu solicitud. Debes esperar que tu solicitud sea aceptada por tu terapeuta para que tu cita quede confirmada. Este proceso puede tardar unos minutos.</div>', '2018-03-09 01:50:12', NULL, 0),
(2, 1, 2, 1, '<div class=\"text-justify font-faqs\">Al iniciar sesión podrás observar una campanita arriba a la derecha, junto a tu nombre de usuario, ahí es donde te llegarán las notificaciones tanto de aceptación como de rechazo de tu solicitud de sesión.<br><br>También puedes observar tu AGENDA, en la que podrás visualizar el estatus de tu sesión. (Puedes interpretarlo con la leyenda visible en la parte inferior derecha).<br><br>Además de las anteriores también puedes saber el estatus de tu sesión en la sección de MI TERAPIA dónde aparece al detalle la información de tus sesiones</div>.', '2018-03-09 01:50:12', NULL, 0),
(3, 1, 3, 1, '<div class=\"text-justify font-faqs\">En la parte baja izquierda de tu AGENDA puedes observar una leyenda con la interpretación de los colores de tus sesiones.<br><br><ul><li><span class=\"text-default\">Color gris:</span><label>&nbsp;&nbsp;Espacio No disponible</label></li><li><span class=\"text-agendado\">Color verde:</span><label>&nbsp;&nbsp;Sesión agendada</label></li><li><span class=\"text-enviado\">Color azul:</span><label>&nbsp;&nbsp;Sesión enviada</label></li><li><span class=\"text-reprogramado\">Color naranja:</span><label>&nbsp;&nbsp;Sesión reprogramada</label></li><li><span class=\"text-cancelado\">Color rojo:</span><label>&nbsp;&nbsp;Sesión cancelada</label></li></ul></div>', '2018-03-09 01:50:12', NULL, 0),
(4, 1, 4, 1, '<div class=\"text-justity font-faqs\">Tu terapeuta puede elegir no aceptar la cita solicitada. En ese caso, deberás programar una nueva cita. (Ver pregunta 2 para más información)</div>', '2018-03-09 01:50:12', NULL, 0),
(5, 1, 5, 1, '<div class=\"text-justify font-faqs\">Los motivos por los que tu terapeuta puede cancelar tu sesión son siempre personales y de importancia. Y todos quedan registrados en su expediente. Si observas que tu terapeuta cancela repetitivamente las citas háznoslo saber en el siguiente correo:  XX@cuidadosamente.com</div>', '2018-03-09 01:50:12', NULL, 0),
(6, 1, 6, 1, '<div class=\"text-justify font-faqs\">Solo deberás conectarte el día de tu cita, 5 min antes de tu sesión y empezar con tu terapia.</div>', '2018-03-09 01:50:12', NULL, 0),
(7, 1, 7, 1, '<div class=\"text-justify font-faqs\">Muy sencillo, solo debes hacer click en la agenda, encima de tu cita y cambiar la opción de “agendada” por “cancelar”. Recuerda que sólo puedes cancelar tu cita 12 horas antes de tu sesión, en caso contrario, no podrás recuperar tu sesión.</div>', '2018-03-09 01:50:12', NULL, 0),
(8, 1, 8, 1, '<div class=\"text-justify font-faqs\">Cada vez que agendas una cita cuentas con 15 minutos desde la hora en que la agendaste para modificarla de manera inmediata, si deseas cancelar o modificar tu sesión después de este periodo, debes asegurarte que no rebasas las 12 horas previas a tu cita.</div>', '2018-03-09 01:50:12', NULL, 0),
(9, 1, 9, 1, '<div class=\"text-justify font-faqs\">Una vez agendes tu cita, debes tomar en cuenta que solo podrás cancelarla 12 horas antes del horario de tu sesión, de lo contrario no la podrás recuperar.</div>', '2018-03-09 01:50:12', NULL, 0),
(10, 1, 10, 1, '<div class=\"text-justify font-faqs\">Recuerda que el horario que elijes para tu sesión en la AGENDA siempre corresponde al huso horario de la CDMX, por lo que si agendas tu cita a las 10.00 am, tu cita será a las 10.00am de la Ciudad de México. Si estás en otro estado o país, deberás tomar en cuenta la diferencia horaria.</div>', '2018-03-09 01:50:12', NULL, 0),
(11, 1, 11, 1, '<div class=\"text-justify font-faqs\">Puedes agendar tantas citas como hayas pagado, sin embargo, te recomendamos estar muy al pendiente porque los horarios de tu terapeuta pueden variar cada semana y las citas pueden ser reprogramadas.</div>', '2018-03-09 01:50:12', NULL, 0),
(12, 1, 12, 1, '<div class=\"text-justify font-faqs\">Sí, siempre que tu terapeuta tenga el espacio disponible. Sin embargo esto no es recomendable en la mayoría de los tratamientos.</div>', '2018-03-09 01:50:12', NULL, 0),
(13, 1, 13, 2, '<div class=\"text-justify font-faqs\">Mi TERAPIA recoge información de tus sesiones para que lleves un registro de las mismas. Tanto de las sesiones que ya recibiste, como las que están agendadas y próximas a tomar. Podrás observar fecha de tu sesión, horario elegido, nombre de tu terapeuta y el estatus de tu cita.</div>', '2018-03-09 01:50:12', NULL, 0),
(14, 1, 14, 3, '<div class=\"text-justify font-faqs\">MI TERAPEUTA recoge un resumen de la información profesional de tu especialista. Su  nombre,  nacionalidad, estudios, experiencia profesional y una breve presentación para que lo conozcas un poco más.</div>', '2018-03-09 01:50:12', NULL, 0),
(15, 1, 15, 4, '<div class=\"text-justify font-faqs\">En esta sección se recogen los datos que rellenaste en el cuestionario inicial. Además podrás  completar o modificar la información que quieras que tu terapeuta reciba sobre tus datos personales.</div>', '2018-03-09 01:50:12', NULL, 0),
(16, 1, 16, 4, '<div class=\"text-justify font-faqs\">No es obligatorio, pero si necesario que rellenes algunos datos personales básicos para que tu terapeuta tenga la información mínima necesaria sobre ti. Entre más información rellenes, mayor información tendrá y en consecuencia más sabrá de ti y de tu problema.</div>', '2018-03-09 01:50:12', NULL, 0),
(17, 1, 17, 4, '<div class=\"text-justify font-faqs\">Solo tú y tu terapeuta.</div>', '2018-03-09 01:50:12', NULL, 0),
(18, 1, 18, 4, '<div class=\"text-justify font-faqs\">Es la información de tu caso que tu terapeuta comparte contigo. Además de ésta información tu terapeuta elabora un expediente mucho más complejo y completo para poder dar seguimiento a tu caso.</div>', '2018-03-09 01:50:12', NULL, 0),
(19, 1, 19, 4, '<div class=\"text-justify font-faqs\">Para nada, tanto en el caso de derivaciones, como si quisieras cambiar de terapeuta, toda tu información personal y clínica se envía al nuevo terapeuta, para que esté completamente informado y al día con tu progreso.</div>', '2018-03-09 01:50:12', NULL, 0),
(20, 1, 20, 4, '<div class=\"text-justify font-faqs\">Muy sencillo, en la sección de mi perfil solo debes hacer click en \"editar\" y ahí podrás modificar tu información en el caso de que existiera algún error en la misma.</div>', '2018-03-09 01:50:12', NULL, 0),
(21, 1, 21, 5, '<div class=\"text-justify font-faqs\">En esta sección puedes visualizar toda la información referente a los pagos realizados, fecha, hora, descripción de pago, así como el número de sesiones y el monto total del cargo.<br><br>También puedes comprar sesiones y canjear códigos de descuento.</div>', '2018-03-09 01:50:12', NULL, 0),
(22, 1, 22, 5, '<div class=\"text-justify font-faqs\">Los códigos de descuento los puedes conseguir a través de ofertas que llegan a tu correo, promociones en nuestras redes sociales o compras de regalos que puedes encontrar en la sección de “Regala felicidad”</div>', '2018-03-09 01:50:12', NULL, 0),
(23, 1, 23, 5, '<div class=\"text-justify font-faqs\">Solamente tienes que dirigirte a la sección de CRÉDITO e introducir tu código en el recuadro de la izquierda, posteriormente solo debes hacer click en Canjear.</div>', '2018-03-09 01:50:12', NULL, 0),
(24, 1, 24, 6, '<div class=\"text-justify font-faqs\">En el caso que existiera algún problema en el funcionamiento de tu sesión puedes reportarlo en esta sección, así mismo puedes consultar los reportes que ya hayas realizado y el estatus de los mismos.</div>', '2018-03-09 01:50:12', NULL, 0),
(25, 1, 25, 6, '<div class=\"text-justify font-faqs\">Esto dependerá del tipo de problema, sin embargo suele realizarse a la brevedad. En caso de que hayas enviado un reporte y tu problema no haya sido resuelto, puedes enviarnos un correo a soporte@cuidadosamnete.com</div>', '2018-03-09 01:50:12', NULL, 0),
(26, 1, 26, 7, '<div class=\"text-justify font-faqs\">Las sesiones deben ser elegidas por el paciente dentro del horario que tú señales para su efecto.</div>', '2018-03-09 01:50:12', NULL, 0),
(27, 1, 27, 7, '<div class=\"text-justify font-faqs\">Así es, una vez el paciente agende su cita, te llegará una solicitud o notificación que podrás visualizar en la campanita de arriba a la derecha. Podrás aceptar o rechazar la sesión. Recuerda que no puedes rechazar la sesión sin justificación previa.</div>', '2018-03-09 01:50:12', NULL, 0),
(28, 1, 28, 7, '<div class=\"text-justify font-faqs\">Sólo puedes cancelar o rechazar una sesión si tienes una justificación de peso para hacerlo. Recuerda que como máximo podrás cancelar 3 sesiones al año, por lo que se te recomienda elegir bien los horarios que pones a disposición para tus citas y así  evitar cancelaciones.</div>', '2018-03-09 01:50:12', NULL, 0),
(29, 1, 29, 7, '<div class=\"text-justify font-faqs\">En la parte baja izquierda de tu AGENDA puedes observar una leyenda con la interpretación de los colores de tus sesiones.<br><br><ul><li><span class=\"text-default\">Color gris:</span><label>&nbsp;&nbsp;Espacio No disponible</label></li><li><span class=\"text-agendado\">Color verde:</span><label>&nbsp;&nbsp;Sesión agendada</label></li><li><span class=\"text-enviado\">Color azul:</span><label>&nbsp;&nbsp;Sesión enviada</label></li><li><span class=\"text-reprogramado\">Color naranja:</span><label>&nbsp;&nbsp;Sesión reprogramada</label></li><li><span class=\"text-cancelado\">Color rojo:</span><label>&nbsp;&nbsp;Sesión cancelada</label></li></ul></div>', '2018-03-09 01:50:12', NULL, 0),
(30, 1, 30, 7, '<div class=\"text-justify font-faqs\">Sólo deberás conectarte el día de tu cita, 5-10 min antes de tu sesión y empezar con tu terapia.</div>', '2018-03-09 01:50:12', NULL, 0),
(31, 1, 31, 7, '<div class=\"text-justify font-faqs\">Una vez tu paciente agende su cita, sólo podrá cancelarla hasta 12 horas antes del horario de vuestra sesión, de lo contrario, la sesión se dará por recibida.</div>', '2018-03-09 01:50:12', NULL, 0),
(32, 1, 32, 7, '<div class=\"text-justify font-faqs\">Recuerda que el horario de la agenda siempre corresponde al huso horario de la CDMX, por lo que si tu cita es a las 10.00 am,  deberás estar preparada a las 9.50  am de la Ciudad de México. Si estás en otro estado o país, deberás tomar en cuenta la diferencia horaria.</div>', '2018-03-09 01:50:12', NULL, 0),
(33, 1, 33, 7, '<div class=\"text-justify font-faqs\">Tu paciente puede agendar tantas citas como haya pagado, sin embargo, te recomendamos asesorarle en la periodicidad de sus citas.</div>', '2018-03-09 01:50:12', NULL, 0),
(34, 1, 34, 7, '<div class=\"text-justify font-faqs\">Sí, siempre que tu tengas el espacio disponible. Sin embargo, te recomendamos asesorarle en la periodicidad de sus citas.</div>', '2018-03-09 01:50:12', NULL, 0),
(35, 1, 35, 8, '<div class=\"text-justify font-faqs\">Mi TERAPIA recoge información de tus sesiones para que lleves un registro de las mismas. Tanto de las sesiones que ya recibieron tus pacientes, como las que están agendadas y próximas a tomar. Podrás observar fecha de tus sesiones, horario elegido por tus pacientes, los nombres de nombre de los mismos y el estatus de tus citas.</div>', '2018-03-09 01:50:12', NULL, 0),
(36, 1, 36, 9, '<div class=\"text-justify font-faqs\">Ésta sección recoge un resumen de tu información personal y profesional. Tu nombre,  nacionalidad, estudios, experiencia profesional y una breve presentación que deberás realizar para que tus pacientes te conozcan mejor.</div>', '2018-03-09 01:50:12', NULL, 0),
(37, 1, 37, 9, '<div class=\"text-justify font-faqs\">Si, ya que es necesario que tu paciente tenga la mayor información posible sobre tu carrera profesional y experiencia. Te recomendamos no poner información personal. Todo lo que escribas será validado antes de ser publicado por nuestro administrador.</div>', '2018-03-09 01:50:12', NULL, 0),
(38, 1, 38, 10, '<div class=\"text-justify font-faqs\">El informe clínico del paciente recogerá información general sobre el caso y la problemática del mismo, así como su funcionamiento, aspectos médicos y perfil social entre otros.</div>', '2018-03-09 01:50:12', NULL, 0),
(39, 1, 39, 10, '<div class=\"text-justify font-faqs\">Sí. Durante las dos primeras sesiones deberás rellenar la información básica de tu paciente. A lo largo del tratamiento irás completando con mayor información relevante.</div>', '2018-03-09 01:50:12', NULL, 0),
(40, 1, 40, 10, '<div class=\"text-justify font-faqs\">Sólo podrás hacerlo en el caso de que no exista evolución o avance en la problemática del paciente, y siempre con previo aviso y consentimiento de Cuidadosamente.</div>', '2018-03-09 01:50:12', NULL, 0),
(41, 1, 41, 10, '<div class=\"text-justify font-faqs\">Sí. Tu paciente puede decidir cambiar de terapeuta en el caso de que no se sienta cómodo en sus sesiones.</div>', '2018-03-09 01:50:12', NULL, 0),
(42, 1, 42, 10, '<div class=\"text-justify font-faqs\">Cuando un paciente es derivado toda su información personal y clínica se envía al nuevo terapeuta, para que esté completamente informado y al día con su problemática y avance. Por lo tanto tendrás toda la información que necesites para retomar el caso.</div>', '2018-03-09 01:50:12', NULL, 0),
(43, 1, 43, 11, '<div class=\"text-justify font-faqs\">En el caso que existiera algún problema en el funcionamiento de tu sesión puedes reportarlo en esta sección, así mismo puedes consultar los reportes que ya hayas realizado y el estatus de los mismos.</div>', '2018-03-09 01:50:12', NULL, 0),
(44, 1, 44, 11, '<div class=\"text-justify font-faqs\">Esto dependerá del tipo de problema, sin embargo suele realizarse a la brevedad. En caso de que hayas enviado un reporte y tu problema no haya sido resuelto, puedes enviarnos un correo a soporte@cuidadosamnete.com</div>', '2018-03-09 01:50:12', NULL, 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `faq_category`
--

CREATE TABLE `faq_category` (
  `fqc_id` int(11) NOT NULL,
  `fqc_view` int(11) NOT NULL DEFAULT '0',
  `fqc_desc` varchar(50) DEFAULT NULL,
  `fqc_createat` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `faq_category`
--

INSERT INTO `faq_category` (`fqc_id`, `fqc_view`, `fqc_desc`, `fqc_createat`) VALUES
(1, 1, 'AGENDA', '2018-03-12 17:26:33'),
(2, 1, 'MI TERAPIA', '2018-03-12 17:26:33'),
(3, 1, 'MI TERAPEUTA', '2018-03-12 17:26:33'),
(4, 1, 'MI PERFIL', '2018-03-12 17:26:33'),
(5, 1, 'CRÉDITO', '2018-03-12 17:26:33'),
(6, 1, 'SOPORTE', '2018-03-12 17:26:33'),
(7, 2, 'AGENDA', '2018-03-12 17:26:33'),
(8, 2, 'MI TERAPIA', '2018-03-12 17:26:33'),
(9, 2, 'MI PERFIL', '2018-03-12 17:26:33'),
(10, 2, 'EXPEDIENTES', '2018-03-12 17:26:33'),
(11, 2, 'SOPORTE', '2018-03-12 17:26:33');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `faq_question`
--

CREATE TABLE `faq_question` (
  `fqq_id` int(11) NOT NULL,
  `fqq_st_id` int(11) NOT NULL DEFAULT '0',
  `fqq_question` text NOT NULL,
  `fqq_cat` int(11) NOT NULL DEFAULT '0',
  `fqq_createat` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fqq_updateat` datetime DEFAULT NULL,
  `fqq_st_id_update` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `faq_question`
--

INSERT INTO `faq_question` (`fqq_id`, `fqq_st_id`, `fqq_question`, `fqq_cat`, `fqq_createat`, `fqq_updateat`, `fqq_st_id_update`) VALUES
(1, 1, '¿Cómo agendo una cita?', 1, '2018-03-05 21:29:55', NULL, 0),
(2, 1, '¿Cómo sé que mi terapeuta confirmó nuestra cita?', 1, '2018-03-05 21:29:55', NULL, 0),
(3, 1, '¿Cómo interpreto los colores de las citas visibles en mi agenda?', 1, '2018-03-05 21:29:55', NULL, 0),
(4, 1, '¿Qué ocurre si mi terapeuta no confirma la cita solicitada?', 1, '2018-03-05 21:29:55', NULL, 0),
(5, 1, '¿Qué motivos tiene mi terapeuta para cancelar su sesión?', 1, '2018-03-05 21:29:55', NULL, 0),
(6, 1, '¿Qué pasa si mi sesión es aceptada?', 1, '2018-03-05 21:29:55', NULL, 0),
(7, 1, '¿Cómo cancelo una cita?', 1, '2018-03-05 21:29:55', NULL, 0),
(8, 1, '¿Qué hago si me equivoco agendadndo una cita?', 1, '2018-03-05 21:29:55', NULL, 0),
(9, 1, '¿Qúe pasa si cancelo mi cita despueés de las 12h?', 1, '2018-03-05 21:29:55', NULL, 0),
(10, 1, '¿Cuál es el huso horario de la agenda?', 1, '2018-03-05 21:29:55', NULL, 0),
(11, 1, '¿Cuántas citas puedo agendar de una vez?', 1, '2018-03-05 21:29:55', NULL, 0),
(12, 1, '¿Puedo agendar todas mis citas en un mismo día?', 1, '2018-03-05 21:29:55', NULL, 0),
(13, 1, '¿Qué puedo encontrar aquí?¿Para qué sirve?', 2, '2018-03-05 21:29:55', NULL, 0),
(14, 1, '¿Qué es esto?', 3, '2018-03-05 21:29:55', NULL, 0),
(15, 1, '¿Qué puedo encontrar en MI PERFIL?', 4, '2018-03-05 21:29:55', NULL, 0),
(16, 1, '¿Tengo que rellenar todos los datos personales?', 4, '2018-03-05 21:29:55', NULL, 0),
(17, 1, '¿Quién puede acceder a mi información?', 4, '2018-03-05 21:29:55', NULL, 0),
(18, 1, '¿Qué es la historia clínica?', 4, '2018-03-05 21:29:55', NULL, 0),
(19, 1, 'Si deseo cambiar de terapeuta, ¿Se pierde mi información?', 4, '2018-03-05 21:29:55', NULL, 0),
(20, 1, '¿Cómo cambio mis datos de información?', 4, '2018-03-05 21:29:55', NULL, 0),
(21, 1, '¿Qué puedo hacer aquí?', 5, '2018-03-05 21:29:55', NULL, 0),
(22, 1, '¿Cómo consigo un código de descuento?', 5, '2018-03-05 21:29:55', NULL, 0),
(23, 1, '¿Cómo canjeo mi código?', 5, '2018-03-05 21:29:55', NULL, 0),
(24, 1, '¿Qué puedo hacer aquí?', 6, '2018-03-05 21:29:55', NULL, 0),
(25, 1, '¿Cuánto tiempo tardan en resolver mi problema?', 6, '2018-03-05 21:29:55', NULL, 0),
(26, 1, '¿Quién puede agendar las sesiones?', 7, '2018-03-05 21:29:55', NULL, 0),
(27, 1, '¿Tengo que confirmar la sesión al paciente para que quede aceptada?', 7, '2018-03-05 21:29:55', NULL, 0),
(28, 1, '¿Qué ocurre si deseo cancelar o rechazar una sesión?', 7, '2018-03-05 21:29:55', NULL, 0),
(29, 1, '¿Cómo interpreto los colores de las citas visibles en mi agenda?', 7, '2018-03-05 21:29:55', NULL, 0),
(30, 1, '¿Qué ocurre al aceptar la sesión?', 7, '2018-03-05 21:29:55', NULL, 0),
(31, 1, '¿Qué pasa si mi paciente cancela su cita?', 7, '2018-03-05 21:29:55', NULL, 0),
(32, 1, '¿Cuál es el Huso horario de la agenda?', 7, '2018-03-05 21:29:55', NULL, 0),
(33, 1, '¿Cuántas citas puede agendar mi paciente de una vez?', 7, '2018-03-05 21:29:55', NULL, 0),
(34, 1, '¿Pueden agendar todas las citas en un mismo día?', 7, '2018-03-05 21:29:55', NULL, 0),
(35, 1, '¿Qué puedo encontrar aquí?', 8, '2018-03-05 21:29:55', NULL, 0),
(36, 1, '¿Para qué sirve?', 9, '2018-03-05 21:29:55', NULL, 0),
(37, 1, '¿Qué información debe recoger el expediente?', 10, '2018-03-05 21:29:55', NULL, 0),
(38, 1, '¿Debo rellenar todos los campos?', 10, '2018-03-05 21:29:55', NULL, 0),
(39, 1, '¿Cuándo puedo transferir o derivar un paciente?', 10, '2018-03-05 21:29:55', NULL, 0),
(40, 1, '¿Mi paciente puede elegir ser transferido?', 10, '2018-03-05 21:29:55', NULL, 0),
(41, 1, 'Sí me derivan un paciente, ¿Qué información tendré de él?', 10, '2018-03-05 21:29:55', NULL, 0),
(42, 1, '¿Qué puedo hacer aquí?', 11, '2018-03-05 21:29:55', NULL, 0),
(43, 1, '¿Cuánto tiempo tardan en resolver mi problema?', 11, '2018-03-05 21:29:55', NULL, 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `faq_tags`
--

CREATE TABLE `faq_tags` (
  `fqt_id` int(11) NOT NULL,
  `fqt_st_id` int(11) NOT NULL DEFAULT '0',
  `fqt_q_id` int(11) NOT NULL DEFAULT '0',
  `fqt_tag` varchar(50) DEFAULT NULL,
  `fqt_createat` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fqt_updateat` datetime DEFAULT NULL,
  `fqt_st_id_update` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `frequency`
--

CREATE TABLE `frequency` (
  `f_id` int(11) NOT NULL,
  `f_desc` varchar(45) NOT NULL DEFAULT '',
  `f_createat` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `f_status` int(11) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `frequency`
--

INSERT INTO `frequency` (`f_id`, `f_desc`, `f_createat`, `f_status`) VALUES
(1, 'Nunca', '2018-02-24 12:25:12', 1),
(2, 'Varios días', '2018-02-24 12:25:12', 1),
(3, 'La mitad de los días', '2018-02-24 12:25:12', 1),
(4, 'Casí todos los días', '2018-02-24 12:25:12', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `gender`
--

CREATE TABLE `gender` (
  `g_id` int(11) NOT NULL,
  `g_desc` varchar(45) NOT NULL DEFAULT '',
  `g_createat` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `g_status` int(11) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `gender`
--

INSERT INTO `gender` (`g_id`, `g_desc`, `g_createat`, `g_status`) VALUES
(1, 'Femenino', '2018-02-24 12:25:12', 1),
(2, 'Masculino', '2018-02-24 12:25:12', 1),
(3, 'Otro', '2018-02-24 12:25:12', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `menus`
--

CREATE TABLE `menus` (
  `menu_id` int(11) NOT NULL,
  `menu_descripcion` varchar(45) NOT NULL DEFAULT '',
  `menu_parent` int(11) NOT NULL DEFAULT '0',
  `menu_url` varchar(100) NOT NULL DEFAULT '',
  `menu_estatus` tinyint(4) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `menus`
--

INSERT INTO `menus` (`menu_id`, `menu_descripcion`, `menu_parent`, `menu_url`, `menu_estatus`) VALUES
(1, 'Pacientes', 0, 'patients', 1),
(2, 'Baja de pacientes', 1, 'downpatient', 1),
(3, 'Terapeutas', 0, 'therapist', 1),
(4, 'Nuevo', 3, 'newTherapist', 1),
(5, 'Modificar', 3, 'modifyTherapist', 1),
(6, 'Soporte Técnico', 0, 'supportC', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `nacionalidades`
--

CREATE TABLE `nacionalidades` (
  `nacionalidad_id` int(11) NOT NULL,
  `nacionalidad_code` int(11) NOT NULL DEFAULT '0',
  `nacionalidad_desc` varchar(45) NOT NULL DEFAULT '',
  `nacionalidad_abreviatura` varchar(45) NOT NULL DEFAULT '',
  `nacionalidad_estatus` tinyint(4) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `nacionalidades`
--

INSERT INTO `nacionalidades` (`nacionalidad_id`, `nacionalidad_code`, `nacionalidad_desc`, `nacionalidad_abreviatura`, `nacionalidad_estatus`) VALUES
(1, 0, 'Afganistán', 'AFG', 1),
(2, 0, 'Islas Åland', 'ALA', 1),
(3, 0, 'Albania', 'ALB', 1),
(4, 0, 'Alemania', 'DEU', 1),
(5, 0, 'Andorra', 'AND', 1),
(6, 0, 'Angola', 'AGO', 1),
(7, 0, 'Anguila', 'AIA', 1),
(8, 0, 'Antártida', 'ATA', 1),
(9, 0, 'Antigua y Barbuda', 'ATG', 1),
(10, 0, 'Arabia Saudita', 'SAU', 1),
(11, 0, 'Argelia', 'DZA', 1),
(12, 0, 'Argentina', 'ARG', 1),
(13, 0, 'Armenia', 'ARM', 1),
(14, 0, 'Aruba', 'ABW', 1),
(15, 0, 'Australia', 'AUS', 1),
(16, 0, 'Austria', 'AUT', 1),
(17, 0, 'Azerbaiyán', 'AZE', 1),
(18, 0, 'Bahamas (las)', 'BHS', 1),
(19, 0, 'Bangladés', 'BGD', 1),
(20, 0, 'Barbados', 'BRB', 1),
(21, 0, 'Baréin', 'BHR', 1),
(22, 0, 'Bélgica', 'BEL', 1),
(23, 0, 'Belice', 'BLZ', 1),
(24, 0, 'Benín', 'BEN', 1),
(25, 0, 'Bermudas', 'BMU', 1),
(26, 0, 'Bielorrusia', 'BLR', 1),
(27, 0, 'Myanmar', 'MMR', 1),
(28, 0, 'Bolivia', 'BOL', 1),
(29, 0, 'Bosnia y Herzegovina', 'BIH', 1),
(30, 0, 'Botsuana', 'BWA', 1),
(31, 0, 'Brasil', 'BRA', 1),
(32, 0, 'Brunéi Darussalam', 'BRN', 1),
(33, 0, 'Bulgaria', 'BGR', 1),
(34, 0, 'Burkina Faso', 'BFA', 1),
(35, 0, 'Burundi', 'BDI', 1),
(36, 0, 'Bután', 'BTN', 1),
(37, 0, 'Cabo Verde', 'CPV', 1),
(38, 0, 'Camboya', 'KHM', 1),
(39, 0, 'Camerún', 'CMR', 1),
(40, 0, 'Canadá', 'CAN', 1),
(41, 0, 'Catar', 'QAT', 1),
(42, 0, 'Bonaire, San Eustaquio y Saba', 'BES', 1),
(43, 0, 'Chad', 'TCD', 1),
(44, 0, 'Chile', 'CHL', 1),
(45, 0, 'China', 'CHN', 1),
(46, 0, 'Chipre', 'CYP', 1),
(47, 0, 'Colombia', 'COL', 1),
(48, 0, 'Comoras', 'COM', 1),
(49, 0, 'Corea del Norte', 'PRK', 1),
(50, 0, 'Corea del Sur', 'KOR', 1),
(51, 0, 'Côte d´Ivoire', 'CIV', 1),
(52, 0, 'Costa Rica', 'CRI', 1),
(53, 0, 'Croacia', 'HRV', 1),
(54, 0, 'Cuba', 'CUB', 1),
(55, 0, 'Curaçao', 'CUW', 1),
(56, 0, 'Dinamarca', 'DNK', 1),
(57, 0, 'Dominica', 'DMA', 1),
(58, 0, 'Ecuador', 'ECU', 1),
(59, 0, 'Egipto', 'EGY', 1),
(60, 0, 'El Salvador', 'SLV', 1),
(61, 0, 'Emiratos Árabes Unidos', 'ARE', 1),
(62, 0, 'Eritrea', 'ERI', 1),
(63, 0, 'Eslovaquia', 'SVK', 1),
(64, 0, 'Eslovenia', 'SVN', 1),
(65, 0, 'España', 'ESP', 1),
(66, 0, 'Estados Unidos', 'USA', 1),
(67, 0, 'Estonia', 'EST', 1),
(68, 0, 'Etiopía', 'ETH', 1),
(69, 0, 'Filipinas', 'PHL', 1),
(70, 0, 'Finlandia', 'FIN', 1),
(71, 0, 'Fiyi', 'FJI', 1),
(72, 0, 'Francia', 'FRA', 1),
(73, 0, 'Gabón', 'GAB', 1),
(74, 0, 'Gambia', 'GMB', 1),
(75, 0, 'Georgia', 'GEO', 1),
(76, 0, 'Ghana', 'GHA', 1),
(77, 0, 'Gibraltar', 'GIB', 1),
(78, 0, 'Granada', 'GRD', 1),
(79, 0, 'Grecia', 'GRC', 1),
(80, 0, 'Groenlandia', 'GRL', 1),
(81, 0, 'Guadalupe', 'GLP', 1),
(82, 0, 'Guam', 'GUM', 1),
(83, 0, 'Guatemala', 'GTM', 1),
(84, 0, 'Guayana Francesa', 'GUF', 1),
(85, 0, 'Guernsey', 'GGY', 1),
(86, 0, 'Guinea', 'GIN', 1),
(87, 0, 'Guinea-Bisáu', 'GNB', 1),
(88, 0, 'Guinea Ecuatorial', 'GNQ', 1),
(89, 0, 'Guyana', 'GUY', 1),
(90, 0, 'Haití', 'HTI', 1),
(91, 0, 'Honduras', 'HND', 1),
(92, 0, 'Hong Kong', 'HKG', 1),
(93, 0, 'Hungría', 'HUN', 1),
(94, 0, 'India', 'IND', 1),
(95, 0, 'Indonesia', 'IDN', 1),
(96, 0, 'Irak', 'IRQ', 1),
(97, 0, 'Irán', 'IRN', 1),
(98, 0, 'Irlanda', 'IRL', 1),
(99, 0, 'Isla Bouvet', 'BVT', 1),
(100, 0, 'Isla de Man', 'IMN', 1),
(101, 0, 'Isla de Navidad', 'CXR', 1),
(102, 0, 'Isla Norfolk', 'NFK', 1),
(103, 0, 'Islandia', 'ISL', 1),
(104, 0, 'Islas Caimán', 'CYM', 1),
(105, 0, 'Islas Cocos (Keeling)', 'CCK', 1),
(106, 0, 'Islas Cook', 'COK', 1),
(107, 0, 'Islas Feroe', 'FRO', 1),
(108, 0, 'Isla Heard e Islas McDonald', 'HMD', 1),
(109, 0, 'Islas Malvinas [Falkland]', 'FLK', 1),
(110, 0, 'Islas Marianas del Norte', 'MNP', 1),
(111, 0, 'Islas Marshall', 'MHL', 1),
(112, 0, 'Pitcairn', 'PCN', 1),
(113, 0, 'Islas Salomón', 'SLB', 1),
(114, 0, 'Islas Turcas y Caicos', 'TCA', 1),
(115, 0, 'Islas Vírgenes (Británicas)', 'VGB', 1),
(116, 0, 'Islas Vírgenes (EE.UU.)', 'VIR', 1),
(117, 0, 'Israel', 'ISR', 1),
(118, 0, 'Italia', 'ITA', 1),
(119, 0, 'Jamaica', 'JAM', 1),
(120, 0, 'Japón', 'JPN', 1),
(121, 0, 'Jersey', 'JEY', 1),
(122, 0, 'Jordania', 'JOR', 1),
(123, 0, 'Kazajistán', 'KAZ', 1),
(124, 0, 'Kenia', 'KEN', 1),
(125, 0, 'Kirguistán', 'KGZ', 1),
(126, 0, 'Kiribati', 'KIR', 1),
(127, 0, 'Kuwait', 'KWT', 1),
(128, 0, 'Lao', 'LAO', 1),
(129, 0, 'Lesoto', 'LSO', 1),
(130, 0, 'Letonia', 'LVA', 1),
(131, 0, 'Líbano', 'LBN', 1),
(132, 0, 'Liberia', 'LBR', 1),
(133, 0, 'Libia', 'LBY', 1),
(134, 0, 'Liechtenstein', 'LIE', 1),
(135, 0, 'Lituania', 'LTU', 1),
(136, 0, 'Luxemburgo', 'LUX', 1),
(137, 0, 'Macao', 'MAC', 1),
(138, 0, 'Madagascar', 'MDG', 1),
(139, 0, 'Malasia', 'MYS', 1),
(140, 0, 'Malaui', 'MWI', 1),
(141, 0, 'Maldivas', 'MDV', 1),
(142, 0, 'Malí', 'MLI', 1),
(143, 0, 'Malta', 'MLT', 1),
(144, 0, 'Marruecos', 'MAR', 1),
(145, 0, 'Martinica', 'MTQ', 1),
(146, 0, 'Mauricio', 'MUS', 1),
(147, 0, 'Mauritania', 'MRT', 1),
(148, 0, 'Mayotte', 'MYT', 1),
(149, 0, 'México', 'MEX', 1),
(150, 0, 'Micronesia', 'FSM', 1),
(151, 0, 'Moldavia', 'MDA', 1),
(152, 0, 'Mónaco', 'MCO', 1),
(153, 0, 'Mongolia', 'MNG', 1),
(154, 0, 'Montenegro', 'MNE', 1),
(155, 0, 'Montserrat', 'MSR', 1),
(156, 0, 'Mozambique', 'MOZ', 1),
(157, 0, 'Namibia', 'NAM', 1),
(158, 0, 'Nauru', 'NRU', 1),
(159, 0, 'Nepal', 'NPL', 1),
(160, 0, 'Nicaragua', 'NIC', 1),
(161, 0, 'Níger', 'NER', 1),
(162, 0, 'Nigeria', 'NGA', 1),
(163, 0, 'Niue', 'NIU', 1),
(164, 0, 'Noruega', 'NOR', 1),
(165, 0, 'Nueva Caledonia', 'NCL', 1),
(166, 0, 'Nueva Zelanda', 'NZL', 1),
(167, 0, 'Omán', 'OMN', 1),
(168, 0, 'Países Bajos', 'NLD', 1),
(169, 0, 'Pakistán', 'PAK', 1),
(170, 0, 'Palaos', 'PLW', 1),
(171, 0, 'Palestina', 'PSE', 1),
(172, 0, 'Panamá', 'PAN', 1),
(173, 0, 'Papúa Nueva Guinea', 'PNG', 1),
(174, 0, 'Paraguay', 'PRY', 1),
(175, 0, 'Perú', 'PER', 1),
(176, 0, 'Polinesia Francesa', 'PYF', 1),
(177, 0, 'Polonia', 'POL', 1),
(178, 0, 'Portugal', 'PRT', 1),
(179, 0, 'Puerto Rico', 'PRI', 1),
(180, 0, 'Reino Unido', 'GBR', 1),
(181, 0, 'República Centroafricana', 'CAF', 1),
(182, 0, 'República Checa', 'CZE', 1),
(183, 0, 'Macedonia', 'MKD', 1),
(184, 0, 'Congo', 'COG', 1),
(185, 0, 'Congo (República Democrática)', 'COD', 1),
(186, 0, 'República Dominicana', 'DOM', 1),
(187, 0, 'Reunión', 'REU', 1),
(188, 0, 'Ruanda', 'RWA', 1),
(189, 0, 'Rumania', 'ROU', 1),
(190, 0, 'Rusia', 'RUS', 1),
(191, 0, 'Sahara Occidental', 'ESH', 1),
(192, 0, 'Samoa', 'WSM', 1),
(193, 0, 'Samoa Americana', 'ASM', 1),
(194, 0, 'San Bartolomé', 'BLM', 1),
(195, 0, 'San Cristóbal y Nieves', 'KNA', 1),
(196, 0, 'San Marino', 'SMR', 1),
(197, 0, 'San Martín', 'MAF', 1),
(198, 0, 'San Pedro y Miquelón', 'SPM', 1),
(199, 0, 'San Vicente y las Granadinas', 'VCT', 1),
(200, 0, 'Santa Lucía', 'LCA', 1),
(201, 0, 'Santo Tomé y Príncipe', 'STP', 1),
(202, 0, 'Senegal', 'SEN', 1),
(203, 0, 'Serbia', 'SRB', 1),
(204, 0, 'Seychelles', 'SYC', 1),
(205, 0, 'Sierra leona', 'SLE', 1),
(206, 0, 'Singapur', 'SGP', 1),
(207, 0, 'Sint Maarten', 'SXM', 1),
(208, 0, 'Siria', 'SYR', 1),
(209, 0, 'Somalia', 'SOM', 1),
(210, 0, 'Sri Lanka', 'LKA', 1),
(211, 0, 'Suazilandia', 'SWZ', 1),
(212, 0, 'Sudáfrica', 'ZAF', 1),
(213, 0, 'Sudán', 'SDN', 1),
(214, 0, 'Sudán del Sur', 'SSD', 1),
(215, 0, 'Suecia', 'SWE', 1),
(216, 0, 'Suiza', 'CHE', 1),
(217, 0, 'Surinam', 'SUR', 1),
(218, 0, 'Svalbard y Jan Mayen', 'SJM', 1),
(219, 0, 'Tailandia', 'THA', 1),
(220, 0, 'Taiwán', 'TWN', 1),
(221, 0, 'Tanzania', 'TZA', 1),
(222, 0, 'Tayikistán', 'TJK', 1),
(223, 0, 'Timor-Leste', 'TLS', 1),
(224, 0, 'Togo', 'TGO', 1),
(225, 0, 'Tokelau', 'TKL', 1),
(226, 0, 'Tonga', 'TON', 1),
(227, 0, 'Trinidad y Tobago', 'TTO', 1),
(228, 0, 'Túnez', 'TUN', 1),
(229, 0, 'Turkmenistán', 'TKM', 1),
(230, 0, 'Turquía', 'TUR', 1),
(231, 0, 'Tuvalu', 'TUV', 1),
(232, 0, 'Ucrania', 'UKR', 1),
(233, 0, 'Uganda', 'UGA', 1),
(234, 0, 'Uruguay', 'URY', 1),
(235, 0, 'Uzbekistán', 'UZB', 1),
(236, 0, 'Vanuatu', 'VUT', 1),
(237, 0, 'Santa Sede [Vaticano]', 'VAT', 1),
(238, 0, 'Venezuela', 'VEN', 1),
(239, 0, 'Viet Nam', 'VNM', 1),
(240, 0, 'Wallis y Futuna', 'WLF', 1),
(241, 0, 'Yemen', 'YEM', 1),
(242, 0, 'Yibuti', 'DJI', 1),
(243, 0, 'Zambia', 'ZMB', 1),
(244, 0, 'Zimbabue', 'ZWE', 1),
(245, 0, 'Países no declarados', 'ZZZ', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `newpwd`
--

CREATE TABLE `newpwd` (
  `np_id` int(11) NOT NULL,
  `np_createat` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `np_usr_id` int(11) NOT NULL DEFAULT '0',
  `np_st_id` int(11) NOT NULL DEFAULT '0',
  `np_hash` varchar(50) NOT NULL DEFAULT '',
  `np_status` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `newpwd`
--

INSERT INTO `newpwd` (`np_id`, `np_createat`, `np_usr_id`, `np_st_id`, `np_hash`, `np_status`) VALUES
(1, '2018-03-11 18:25:47', 0, 1, 'bf24cb22bf44e22a3e44ccc218ab9c04', 1),
(2, '2018-03-11 22:59:19', 1, 0, '993f1e7fd8ba7cebf56f041f09b9a5c2', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `patientaddon`
--

CREATE TABLE `patientaddon` (
  `pa_id` int(11) NOT NULL,
  `pa_usr_id` int(11) NOT NULL DEFAULT '0',
  `pa_addon` text NOT NULL,
  `pa_createat` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `pa_updateat` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `perfilterapeuta`
--

CREATE TABLE `perfilterapeuta` (
  `pt_id` int(11) NOT NULL,
  `pt_st_id` int(11) NOT NULL DEFAULT '0',
  `pt_perfil` int(11) NOT NULL DEFAULT '0',
  `pt_status` int(11) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `perfilterapeuta`
--

INSERT INTO `perfilterapeuta` (`pt_id`, `pt_st_id`, `pt_perfil`, `pt_status`) VALUES
(1, 3, 1, 1),
(2, 3, 2, 1),
(3, 3, 3, 1),
(4, 4, 1, 1),
(5, 4, 2, 1),
(6, 4, 3, 1),
(10, 5, 1, 0),
(11, 5, 2, 0),
(12, 5, 4, 0),
(13, 11, 1, 0),
(14, 11, 3, 0),
(15, 12, 1, 0),
(16, 12, 4, 0),
(18, 11, 1, 0),
(19, 11, 2, 0),
(20, 11, 3, 0),
(21, 11, 4, 0),
(25, 5, 1, 0),
(26, 5, 2, 0),
(27, 5, 3, 0),
(28, 5, 4, 0),
(32, 5, 3, 1),
(33, 5, 4, 1),
(35, 11, 1, 1),
(36, 11, 4, 1),
(38, 12, 4, 0),
(39, 12, 1, 1),
(40, 12, 4, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `prueba`
--

CREATE TABLE `prueba` (
  `id` int(11) NOT NULL,
  `fecha` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `prueba`
--

INSERT INTO `prueba` (`id`, `fecha`) VALUES
(1, '0000-00-00 00:00:00'),
(2, '2018-03-30 15:50:00');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `puestos`
--

CREATE TABLE `puestos` (
  `puesto_id` int(11) NOT NULL,
  `puesto_descripcion` varchar(45) NOT NULL DEFAULT '',
  `puesto_estatus` tinyint(4) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `puestos`
--

INSERT INTO `puestos` (`puesto_id`, `puesto_descripcion`, `puesto_estatus`) VALUES
(1, 'admin', 1),
(2, 'paciente', 1),
(3, 'terapeuta', 1),
(4, 'supervisor', 1),
(5, 'soporte', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `reference`
--

CREATE TABLE `reference` (
  `r_id` int(11) NOT NULL,
  `r_desc` varchar(45) NOT NULL DEFAULT '',
  `r_createat` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `r_status` int(11) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `reference`
--

INSERT INTO `reference` (`r_id`, `r_desc`, `r_createat`, `r_status`) VALUES
(1, 'Un amigo o falimiar', '2018-02-24 12:25:12', 1),
(2, 'Mi doctor', '2018-02-24 12:25:12', 1),
(3, 'Busqué en internet', '2018-02-24 12:25:12', 1),
(4, 'Vi un anuncio', '2018-02-24 12:25:12', 1),
(5, 'Redes sociales', '2018-02-24 12:25:12', 1),
(6, 'En un artículo', '2018-02-24 12:25:12', 1),
(7, 'Medios de comunicación (radio/tv)', '2018-02-24 12:25:12', 1),
(8, 'Otro', '2018-02-24 12:25:12', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `staff`
--

CREATE TABLE `staff` (
  `st_id` int(11) NOT NULL,
  `st_nombre` varchar(45) NOT NULL DEFAULT '',
  `st_paterno` varchar(45) NOT NULL DEFAULT '',
  `st_materno` varchar(45) NOT NULL DEFAULT '',
  `st_departamento_id` int(11) NOT NULL DEFAULT '0',
  `st_puesto_id` int(11) NOT NULL DEFAULT '0',
  `st_nivelUsr_id` int(11) NOT NULL DEFAULT '0',
  `st_login` varchar(45) NOT NULL DEFAULT '',
  `st_password` varchar(45) NOT NULL DEFAULT '',
  `st_nacionalidad_id` int(11) DEFAULT NULL,
  `st_correo` varchar(100) NOT NULL DEFAULT '',
  `st_casa` varchar(15) NOT NULL DEFAULT '55-0000-0000',
  `st_movil` varchar(15) NOT NULL DEFAULT '55-0000-0000',
  `st_estatus` tinyint(4) NOT NULL DEFAULT '1',
  `st_fecha_alta` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `st_usr_id_alta` int(11) NOT NULL DEFAULT '0',
  `st_fecha_actualizacion` datetime DEFAULT CURRENT_TIMESTAMP,
  `st_usr_id_actualizacion` int(11) NOT NULL DEFAULT '0',
  `st_fecha_cancelacion` datetime DEFAULT NULL,
  `st_usr_id_cancelacion` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `staff`
--

INSERT INTO `staff` (`st_id`, `st_nombre`, `st_paterno`, `st_materno`, `st_departamento_id`, `st_puesto_id`, `st_nivelUsr_id`, `st_login`, `st_password`, `st_nacionalidad_id`, `st_correo`, `st_casa`, `st_movil`, `st_estatus`, `st_fecha_alta`, `st_usr_id_alta`, `st_fecha_actualizacion`, `st_usr_id_actualizacion`, `st_fecha_cancelacion`, `st_usr_id_cancelacion`) VALUES
(1, 'Sara', 'Beneyto', '', 1, 1, 0, 'sara@cuidadosamente.com', '2eac05d3927bee279984fcfd02a2e8cd', NULL, 'sara@cuidadosamente.com', '55-0000-0000', '55-0000-0000', 1, '2018-04-26 13:15:41', 0, '2018-04-26 13:15:41', 0, NULL, 0),
(5, 'ava', 'badsfa', 'csdfasdfa', 3, 3, 0, 'd', '', NULL, 'd', '55-0000-0000', '55-0000-0000', 0, '2018-05-02 02:06:45', 1, '2018-05-02 14:17:03', 1, '2018-05-02 13:30:58', 1),
(11, 'luisasdfasdfasdf', 'mendozaasdfasdfadsfa', 'rodriguez', 3, 3, 0, 'lr.mendozar@me.com', '', NULL, 'lr.mendozar@me.com', '55-0000-0000', '55-0000-0000', 0, '2018-05-02 03:00:51', 1, '2018-05-02 14:17:22', 1, '2018-05-02 14:16:27', 1),
(12, 'rodrigo', 'mendoza', 'mercado', 3, 3, 0, 'lr.mendozar@icloud.com', '', NULL, 'lr.mendozar@icloud.com', '55-0000-0000', '55-0000-0000', 1, '2018-05-02 14:13:17', 1, '2018-05-02 18:58:25', 1, NULL, 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `supportstaff`
--

CREATE TABLE `supportstaff` (
  `sps_id` int(11) NOT NULL,
  `sps_usr_id` int(11) NOT NULL DEFAULT '0',
  `sps_status` int(11) NOT NULL DEFAULT '0',
  `sps_subject` varchar(200) DEFAULT NULL,
  `sps_createat` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `sps_updateat` datetime DEFAULT NULL,
  `sps_supportId` int(11) NOT NULL DEFAULT '0',
  `sps_desc` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `supportstaff`
--

INSERT INTO `supportstaff` (`sps_id`, `sps_usr_id`, `sps_status`, `sps_subject`, `sps_createat`, `sps_updateat`, `sps_supportId`, `sps_desc`) VALUES
(1, 1, 3, '', '2018-03-03 09:37:54', NULL, 0, ''),
(2, 1, 3, 'Solicitud de llamada Soporte TÃ©cnico', '2018-03-03 10:43:30', NULL, 0, 'Llamar al nÃºmero 5514889586'),
(3, 1, 3, 'Solicitud de llamada Soporte TÃ©cnico', '2018-03-03 10:44:31', NULL, 0, 'Llamar al nÃºmero 5514889586'),
(4, 1, 3, 'test1', '2018-03-03 10:47:19', NULL, 0, 'DespuÃ©s del telÃ©fono add'),
(5, 1, 3, 'Solicitud de llamada Soporte TÃ©cnico', '2018-04-03 11:14:19', NULL, 0, 'Llamar al nÃºmero 5514889586'),
(6, 1, 3, 'Solicitud de llamada Soporte TÃ©cnico', '2018-04-03 11:39:46', NULL, 0, 'Llamar al nÃºmero 1111'),
(7, 1, 3, 'Solicitud de llamada Soporte TÃ©cnico', '2018-04-03 11:47:47', NULL, 0, 'Llamar al nÃºmero 11'),
(8, 1, 3, 'Solicitud de llamada Soporte TÃ©cnico', '2018-04-03 11:48:20', NULL, 0, 'Llamar al nÃºmero 11'),
(9, 1, 3, 'Solicitud de llamada Soporte TÃ©cnico', '2018-04-03 11:52:13', NULL, 0, 'Llamar al nÃºmero 111'),
(10, 1, 3, 'Solicitud de llamada Soporte TÃ©cnico', '2018-04-03 11:52:47', NULL, 0, 'Llamar al nÃºmero 1'),
(11, 1, 3, 'Solicitud de llamada Soporte TÃ©cnico', '2018-04-03 11:53:04', NULL, 0, 'Llamar al nÃºmero 11'),
(12, 1, 3, 'Solicitud de llamada Soporte TÃ©cnico', '2018-04-04 14:28:03', NULL, 0, 'Llamar al nÃºmero 11'),
(13, 1, 3, 'no puedo agedar citas', '2018-04-04 14:30:37', NULL, 0, 'mi mouse no sirve');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `supportstatus`
--

CREATE TABLE `supportstatus` (
  `spe_id` int(11) NOT NULL,
  `spe_createat` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `spe_desc` varchar(50) NOT NULL DEFAULT '',
  `spe_badge` varchar(50) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `supportstatus`
--

INSERT INTO `supportstatus` (`spe_id`, `spe_createat`, `spe_desc`, `spe_badge`) VALUES
(1, '2018-03-02 02:53:03', 'Resuelto', 'badge badge-success'),
(2, '2018-03-02 02:53:03', 'En proceso', 'badge badge-enviado'),
(3, '2018-03-02 02:53:03', 'Pendiente', 'badge badge-warning');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `supportusr`
--

CREATE TABLE `supportusr` (
  `spu_id` int(11) NOT NULL,
  `spu_usr_id` int(11) NOT NULL DEFAULT '0',
  `spu_status` int(11) NOT NULL DEFAULT '0',
  `spu_subject` varchar(200) DEFAULT NULL,
  `spu_createat` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `spu_updateat` datetime DEFAULT NULL,
  `spu_supportId` int(11) NOT NULL DEFAULT '0',
  `spu_desc` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `supportusr`
--

INSERT INTO `supportusr` (`spu_id`, `spu_usr_id`, `spu_status`, `spu_subject`, `spu_createat`, `spu_updateat`, `spu_supportId`, `spu_desc`) VALUES
(1, 1, 3, 'asdfasdf', '2018-03-02 04:25:42', NULL, 0, 'asdfasdfasdf'),
(2, 1, 3, 'ticket2', '2018-03-02 04:29:57', NULL, 0, 'ticket2'),
(3, 1, 3, 'test3', '2018-03-02 04:36:33', NULL, 0, 'teskjkjk'),
(4, 1, 3, 'destroy', '2018-03-02 04:38:41', NULL, 0, 'destroy'),
(5, 1, 3, '', '2018-03-03 09:39:23', NULL, 0, ''),
(6, 1, 3, 'Solicitud de llamada Soporte TÃ©cnico', '2018-03-03 10:55:30', NULL, 0, 'Llamar al nÃºmero 123456'),
(7, 1, 3, 'Solicitud de llamada Soporte TÃ©cnico', '2018-03-03 10:57:09', NULL, 0, 'Llamar al nÃºmero 1234567890'),
(8, 1, 3, 'Esta es una prueba', '2018-03-12 17:23:31', NULL, 0, 'Prueba'),
(9, 1, 3, 'Solicitud de llamada Soporte TÃ©cnico', '2018-03-20 18:41:07', NULL, 0, 'Llamar al nÃºmero 5514889586'),
(10, 1, 3, 'no puedo ver agenda', '2018-03-23 19:18:12', NULL, 0, 'no puedo ver la agenda ayuda'),
(11, 1, 3, 'Solicitud de llamada Soporte TÃ©cnico', '2018-04-03 11:56:28', NULL, 0, 'Llamar al nÃºmero 1'),
(12, 1, 3, 'Solicitud de llamada Soporte TÃ©cnico', '2018-04-03 11:58:15', NULL, 0, 'Llamar al nÃºmero 1');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `testd_emotions`
--

CREATE TABLE `testd_emotions` (
  `tde_id` int(11) NOT NULL,
  `tde_emotion_id` int(11) NOT NULL DEFAULT '0',
  `tde_createat` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `testd_medicine`
--

CREATE TABLE `testd_medicine` (
  `tdm_id` int(11) NOT NULL,
  `tdm_emotion_id` int(11) NOT NULL DEFAULT '0',
  `tdm_createat` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `test_profile`
--

CREATE TABLE `test_profile` (
  `t_id` int(11) NOT NULL,
  `t_usr_id` int(11) NOT NULL DEFAULT '0',
  `t_gender` int(11) NOT NULL DEFAULT '0',
  `t_birthdate` datetime DEFAULT NULL,
  `t_age` int(11) NOT NULL DEFAULT '0',
  `t_service` int(11) NOT NULL DEFAULT '0',
  `t_therapyBefore` int(11) NOT NULL DEFAULT '0',
  `t_health` int(11) NOT NULL DEFAULT '0',
  `t_sleep` int(11) NOT NULL DEFAULT '0',
  `t_emotion_freq` int(11) NOT NULL DEFAULT '0',
  `t_anxiety` int(11) NOT NULL DEFAULT '0',
  `t_relationship` int(11) NOT NULL DEFAULT '0',
  `t_relationship_freq` int(11) NOT NULL DEFAULT '0',
  `t_reference` int(11) NOT NULL DEFAULT '0',
  `t_civilState` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `test_profile`
--

INSERT INTO `test_profile` (`t_id`, `t_usr_id`, `t_gender`, `t_birthdate`, `t_age`, `t_service`, `t_therapyBefore`, `t_health`, `t_sleep`, `t_emotion_freq`, `t_anxiety`, `t_relationship`, `t_relationship_freq`, `t_reference`, `t_civilState`) VALUES
(1, 1, 2, '1987-04-11 00:00:00', 30, 5, 0, 2, 3, 1, 1, 4, 1, 5, 2);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `usr_id` int(11) NOT NULL,
  `usr_nombre` varchar(45) NOT NULL DEFAULT '',
  `usr_paterno` varchar(45) NOT NULL DEFAULT '',
  `usr_materno` varchar(45) NOT NULL DEFAULT '',
  `usr_departamento_id` int(11) NOT NULL DEFAULT '0',
  `usr_puesto_id` int(11) NOT NULL DEFAULT '0',
  `usr_nivelUsr_id` int(11) NOT NULL DEFAULT '0',
  `usr_login` varchar(45) NOT NULL DEFAULT '',
  `usr_password` varchar(45) NOT NULL DEFAULT '',
  `usr_nacionalidad_id` int(11) DEFAULT NULL,
  `usr_correo` varchar(100) NOT NULL DEFAULT '',
  `usr_casa` varchar(15) NOT NULL DEFAULT '55-0000-0000',
  `usr_movil` varchar(15) NOT NULL DEFAULT '55-0000-0000',
  `usr_estatus` tinyint(4) NOT NULL DEFAULT '1',
  `usr_fecha_alta` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `usr_usr_id_alta` int(11) NOT NULL DEFAULT '0',
  `usr_fecha_actualizacion` datetime DEFAULT CURRENT_TIMESTAMP,
  `usr_usr_id_actualizacion` int(11) NOT NULL,
  `usr_fecha_cancelacion` datetime DEFAULT NULL,
  `usr_usr_id_cancelacion` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`usr_id`, `usr_nombre`, `usr_paterno`, `usr_materno`, `usr_departamento_id`, `usr_puesto_id`, `usr_nivelUsr_id`, `usr_login`, `usr_password`, `usr_nacionalidad_id`, `usr_correo`, `usr_casa`, `usr_movil`, `usr_estatus`, `usr_fecha_alta`, `usr_usr_id_alta`, `usr_fecha_actualizacion`, `usr_usr_id_actualizacion`, `usr_fecha_cancelacion`, `usr_usr_id_cancelacion`) VALUES
(1, 'Rodrigo', 'Mendoza', '', 2, 2, 1, 'lr.mendozar@gmail.com', 'e62180490b281461ebdf3e48e9f2c483', 1, 'lr.mendozar@gmail.com', '55-0000-0000', '55-0000-0000', 1, '2018-01-03 10:19:15', 0, '2018-03-12 00:58:07', 0, NULL, 0),
(2, 'Sara', 'Hernandez', '', 2, 2, 1, 'minks_stm@hotmail.com', '9dec735ba08a651fec7f382de088855f', NULL, 'minks_stm@hotmail.com', '55-0000-0000', '55-0000-0000', 1, '2018-01-03 14:41:26', 0, '2018-01-03 14:41:26', 0, NULL, 0),
(7, 'Sara', 'Perez', '', 2, 2, 1, 'Sbeneytoperez@hotmail.com', '944d645d5c4a425e703a56706825d3bf', NULL, 'Sbeneytoperez@hotmail.com', '55-0000-0000', '55-0000-0000', 1, '2018-01-10 09:53:27', 0, '2018-01-10 09:53:27', 0, NULL, 0),
(8, 'Sara', 'Beneyti', '', 2, 2, 1, 'Sbeneytoperez@hoymail.com', 'd7d883a61c703c7c80255686b0f9d196', NULL, 'Sbeneytoperez@hoymail.com', '55-0000-0000', '55-0000-0000', 1, '2018-01-14 09:45:03', 0, '2018-01-14 09:45:03', 0, NULL, 0),
(9, 'Mera', 'Perez', '', 2, 2, 1, 'Redpsicologosenlinea@hotmail.com', '4d98c4c7ccb2edde39b167a0da3af271', NULL, 'Redpsicologosenlinea@hotmail.com', '55-0000-0000', '55-0000-0000', 1, '2018-01-14 09:46:32', 0, '2018-01-14 09:46:32', 0, NULL, 0),
(11, 'SARA', 'beneyto', '', 2, 2, 1, 'terapiacuidadosamente@gmail.com', 'd2ed2f285b1526c248cbe5738ade5bfa', NULL, 'terapiacuidadosamente@gmail.com', '55-0000-0000', '55-0000-0000', 1, '2018-02-12 13:20:25', 0, '2018-02-12 13:20:25', 0, NULL, 0),
(12, 'juan', 'carlos', '', 2, 2, 1, 'jccarrerap@hotmail.com', '10f76a2b1f05ad8205c200b278bb1354', NULL, 'jccarrerap@hotmail.com', '55-0000-0000', '55-0000-0000', 1, '2018-02-16 19:20:26', 0, '2018-02-16 19:20:26', 0, NULL, 0),
(13, 'Marco', 'Garcia', '', 2, 2, 1, 'morozc0@hotmail.com', '4ec2377ab8ba4d53f28fd59d6bd2ee4c', NULL, 'morozc0@hotmail.com', '55-0000-0000', '55-0000-0000', 1, '2018-02-19 10:35:55', 0, '2018-02-19 10:35:55', 0, NULL, 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `validatesess`
--

CREATE TABLE `validatesess` (
  `vs_id` int(11) NOT NULL,
  `vs_createat` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `vs_usr_id` int(11) NOT NULL DEFAULT '0',
  `vs_st_id` int(11) NOT NULL DEFAULT '0',
  `vs_hash` varchar(50) NOT NULL DEFAULT '',
  `vs_status` int(11) NOT NULL DEFAULT '0',
  `vs_activateat` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `validatesess`
--

INSERT INTO `validatesess` (`vs_id`, `vs_createat`, `vs_usr_id`, `vs_st_id`, `vs_hash`, `vs_status`, `vs_activateat`) VALUES
(1, '2018-02-09 07:42:38', 0, 1, '2eac05d3927bee279984fcfd02a2e8cd', 1, '2018-02-09 07:42:38'),
(2, '2018-01-03 10:19:15', 1, 0, '3af4bba3f827cc3bf3600c0f5004890b', 1, '2018-01-03 10:30:10'),
(3, '2018-01-03 14:41:26', 2, 0, 'ed85d60091593abad6643415e15d8020', 1, '2018-01-03 14:43:14'),
(4, '2018-01-07 12:30:05', 3, 0, 'ab25996bad7be8761a0895582f61e9e7', 0, NULL),
(5, '2018-01-08 10:59:13', 6, 0, '903be725b766ba5772c4f2a2fb93b8f8', 0, NULL),
(6, '2018-01-10 09:53:27', 7, 0, 'bacfd286d93786558a0591a05a6a3fe6', 1, '2018-01-10 10:00:16'),
(7, '2018-01-14 09:45:03', 8, 0, '809ff83708dbae671e11878f3e33418b', 0, NULL),
(8, '2018-01-14 09:46:32', 9, 0, '2f8f8614c813fbf0d88a99a6056cafca', 0, NULL),
(9, '2018-02-12 13:20:25', 11, 0, 'ba1c348d88a63eef809473b4bb71a73d', 1, '2018-02-12 13:21:49'),
(10, '2018-02-16 19:20:26', 12, 0, '0d9e86b90c7e8ff3c5a997f6479fb667', 1, '2018-02-16 19:21:43'),
(11, '2018-02-19 10:35:55', 13, 0, 'f4620228dfe155ff8cc4c3b81f49a127', 1, '2018-02-19 10:38:19'),
(12, '2018-04-26 12:50:20', 0, 4, 'd7eb924da766ece564754594edc947d8', 1, '2018-04-26 12:50:20'),
(13, '2018-04-26 13:15:41', 0, 1, '2eac05d3927bee279984fcfd02a2e8cd', 1, '2018-04-26 13:15:41'),
(14, '2018-05-02 01:38:35', 0, 1, '2eac05d3927bee279984fcfd02a2e8cd', 1, '2018-05-02 01:38:35'),
(15, '2018-05-02 02:06:45', 0, 5, 'f254a749cb896644bfe689c1adb463a7', 0, NULL),
(16, '2018-05-02 03:00:51', 0, 11, 'fba9f5713bb7b6e36905862c1a84b5fa', 0, NULL),
(17, '2018-05-02 14:13:17', 0, 12, '60643a2d971fe1074d0f271eac5af419', 0, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `validtokens`
--

CREATE TABLE `validtokens` (
  `vt_id` int(11) NOT NULL,
  `vt_createat` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `vt_usr_id` int(11) NOT NULL DEFAULT '0',
  `vt_st_id` int(11) NOT NULL DEFAULT '0',
  `vt_hash` varchar(50) NOT NULL DEFAULT '',
  `vt_status` int(11) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `validtokens`
--

INSERT INTO `validtokens` (`vt_id`, `vt_createat`, `vt_usr_id`, `vt_st_id`, `vt_hash`, `vt_status`) VALUES
(1, '2018-02-24 12:31:45', 1, 0, 'ab9e29079049bc6d2e767b9bd2fb1b38', 0),
(2, '2018-02-24 12:32:44', 1, 0, 'ab9e29079049bc6d2e767b9bd2fb1b38', 0),
(3, '2018-02-24 12:44:34', 1, 0, 'ab9e29079049bc6d2e767b9bd2fb1b38', 0),
(4, '2018-02-24 13:30:51', 1, 0, 'ab9e29079049bc6d2e767b9bd2fb1b38', 0),
(5, '2018-02-24 13:33:23', 0, 1, '2efde3a07c72a16a7f7deb0bec2d5db6', 0),
(6, '2018-02-24 13:45:36', 1, 0, 'ab9e29079049bc6d2e767b9bd2fb1b38', 0),
(7, '2018-02-24 13:49:24', 0, 1, '2efde3a07c72a16a7f7deb0bec2d5db6', 0),
(8, '2018-02-24 13:49:52', 1, 0, 'ab9e29079049bc6d2e767b9bd2fb1b38', 0),
(9, '2018-02-24 22:39:25', 1, 0, 'ab9e29079049bc6d2e767b9bd2fb1b38', 0),
(10, '2018-02-24 23:22:47', 1, 0, 'ab9e29079049bc6d2e767b9bd2fb1b38', 0),
(11, '2018-02-24 23:39:10', 1, 0, 'ab9e29079049bc6d2e767b9bd2fb1b38', 0),
(12, '2018-02-24 23:40:40', 1, 0, 'ab9e29079049bc6d2e767b9bd2fb1b38', 0),
(13, '2018-02-24 23:41:37', 1, 0, 'ab9e29079049bc6d2e767b9bd2fb1b38', 0),
(14, '2018-02-24 23:42:19', 1, 0, 'ab9e29079049bc6d2e767b9bd2fb1b38', 0),
(15, '2018-02-24 23:55:58', 1, 0, 'ab9e29079049bc6d2e767b9bd2fb1b38', 0),
(16, '2018-02-24 23:57:55', 1, 0, 'ab9e29079049bc6d2e767b9bd2fb1b38', 0),
(17, '2018-02-24 23:58:57', 1, 0, 'ab9e29079049bc6d2e767b9bd2fb1b38', 0),
(18, '2018-02-25 00:00:01', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(19, '2018-02-25 00:00:29', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(20, '2018-02-25 00:07:51', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(21, '2018-02-25 00:29:47', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(22, '2018-02-25 01:25:12', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(23, '2018-02-25 01:27:00', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(24, '2018-02-25 01:27:31', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(25, '2018-02-25 01:28:04', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(26, '2018-02-25 01:30:12', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(27, '2018-02-25 01:31:38', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(28, '2018-02-25 01:35:31', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(29, '2018-02-25 01:45:20', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(30, '2018-02-25 01:46:01', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(31, '2018-02-25 01:46:32', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(32, '2018-02-25 01:47:44', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(33, '2018-02-25 01:54:06', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(34, '2018-02-25 01:54:41', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(35, '2018-02-25 01:55:08', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(36, '2018-02-25 01:55:43', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(37, '2018-02-25 01:56:52', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(38, '2018-02-25 01:59:07', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(39, '2018-02-25 01:59:29', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(40, '2018-02-25 02:01:57', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(41, '2018-02-25 02:02:25', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(42, '2018-02-25 02:16:27', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(43, '2018-02-25 02:17:15', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(44, '2018-02-25 02:19:10', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(45, '2018-02-25 02:19:40', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(46, '2018-02-25 02:26:52', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(47, '2018-02-25 02:28:36', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(48, '2018-02-25 02:29:59', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(49, '2018-02-25 02:32:09', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(50, '2018-02-25 02:34:38', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(51, '2018-02-25 02:37:01', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(52, '2018-02-25 02:49:05', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(53, '2018-02-25 02:50:35', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(54, '2018-02-25 03:06:52', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(55, '2018-02-25 03:07:22', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(56, '2018-02-25 03:07:55', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(57, '2018-02-25 03:09:59', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(58, '2018-02-25 03:11:02', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(59, '2018-02-25 03:11:49', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(60, '2018-02-25 03:12:27', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(61, '2018-02-25 03:14:26', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(62, '2018-02-25 03:16:04', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(63, '2018-02-25 03:22:55', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(64, '2018-02-25 03:32:56', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(65, '2018-02-25 03:38:12', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(66, '2018-02-25 03:43:36', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(67, '2018-02-25 03:44:08', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(68, '2018-02-25 03:45:02', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(69, '2018-02-25 03:46:16', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(70, '2018-02-25 03:48:37', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(71, '2018-02-25 03:49:22', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(72, '2018-02-25 03:51:06', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(73, '2018-02-25 03:52:00', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(74, '2018-02-25 03:52:41', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(75, '2018-02-25 03:53:06', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(76, '2018-02-25 03:58:21', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(77, '2018-02-25 03:59:23', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(78, '2018-02-25 04:00:01', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(79, '2018-02-25 08:04:11', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(80, '2018-02-25 08:05:20', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(81, '2018-02-25 08:07:04', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(82, '2018-02-25 08:10:36', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(83, '2018-02-25 08:12:49', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(84, '2018-02-25 08:13:46', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(85, '2018-02-25 08:24:07', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(86, '2018-02-25 08:24:46', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(87, '2018-02-25 08:26:01', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(88, '2018-02-25 08:40:25', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(89, '2018-02-25 08:41:00', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(90, '2018-02-25 08:41:42', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(91, '2018-02-25 08:44:59', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(92, '2018-02-25 08:46:23', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(93, '2018-02-25 08:49:03', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(94, '2018-02-25 08:49:59', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(95, '2018-02-25 08:52:08', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(96, '2018-02-25 08:53:14', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(97, '2018-02-25 08:54:03', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(98, '2018-02-25 08:55:20', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(99, '2018-02-25 08:58:37', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(100, '2018-02-25 08:59:24', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(101, '2018-02-25 09:05:11', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(102, '2018-02-25 09:05:38', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(103, '2018-02-25 09:08:02', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(104, '2018-02-25 09:08:43', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(105, '2018-02-25 09:13:14', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(106, '2018-02-25 09:14:12', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(107, '2018-02-25 09:15:44', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(108, '2018-02-25 09:16:59', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(109, '2018-02-25 10:32:34', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(110, '2018-02-25 10:32:54', 0, 1, '61894dcf8978310ba558c1bb402f2fa6', 0),
(111, '2018-02-25 10:33:36', 0, 1, '61894dcf8978310ba558c1bb402f2fa6', 0),
(112, '2018-02-25 10:34:50', 0, 1, '61894dcf8978310ba558c1bb402f2fa6', 0),
(113, '2018-02-25 10:36:51', 1, 0, 'bb14cc905d33a597ba72f25915ce1421', 0),
(114, '2018-02-25 10:37:08', 0, 1, '61894dcf8978310ba558c1bb402f2fa6', 0),
(115, '2018-02-25 10:46:05', 0, 1, '61894dcf8978310ba558c1bb402f2fa6', 0),
(116, '2018-02-25 10:59:36', 0, 1, '61894dcf8978310ba558c1bb402f2fa6', 0),
(117, '2018-02-25 11:01:16', 0, 1, '61894dcf8978310ba558c1bb402f2fa6', 0),
(118, '2018-02-25 11:02:23', 0, 1, '61894dcf8978310ba558c1bb402f2fa6', 0),
(119, '2018-02-25 11:12:07', 0, 1, '61894dcf8978310ba558c1bb402f2fa6', 0),
(120, '2018-02-25 11:17:18', 0, 1, '61894dcf8978310ba558c1bb402f2fa6', 0),
(121, '2018-02-25 11:18:14', 0, 1, '61894dcf8978310ba558c1bb402f2fa6', 0),
(122, '2018-02-26 23:36:36', 0, 1, '1f10663725ac459af5d69d278df61fec', 0),
(123, '2018-02-26 23:42:59', 0, 1, '1f10663725ac459af5d69d278df61fec', 0),
(124, '2018-02-26 23:44:48', 0, 1, '1f10663725ac459af5d69d278df61fec', 0),
(125, '2018-02-26 23:50:23', 0, 1, '1f10663725ac459af5d69d278df61fec', 0),
(126, '2018-02-26 23:51:32', 0, 1, '1f10663725ac459af5d69d278df61fec', 0),
(127, '2018-02-26 23:52:02', 0, 1, '1f10663725ac459af5d69d278df61fec', 0),
(128, '2018-02-26 23:55:46', 0, 1, '1f10663725ac459af5d69d278df61fec', 0),
(129, '2018-02-26 23:56:48', 0, 1, '1f10663725ac459af5d69d278df61fec', 0),
(130, '2018-02-26 23:57:18', 0, 1, '1f10663725ac459af5d69d278df61fec', 0),
(131, '2018-02-26 23:57:41', 0, 1, '1f10663725ac459af5d69d278df61fec', 0),
(132, '2018-02-27 00:01:03', 0, 1, '691693023d49c9ec5639e3e3940614e9', 0),
(133, '2018-02-27 00:09:07', 0, 1, '691693023d49c9ec5639e3e3940614e9', 0),
(134, '2018-02-27 00:10:13', 0, 1, '691693023d49c9ec5639e3e3940614e9', 0),
(135, '2018-02-27 00:16:08', 0, 1, '691693023d49c9ec5639e3e3940614e9', 0),
(136, '2018-02-27 00:17:01', 0, 1, '691693023d49c9ec5639e3e3940614e9', 0),
(137, '2018-02-27 00:18:52', 0, 1, '691693023d49c9ec5639e3e3940614e9', 0),
(138, '2018-02-27 00:20:27', 0, 1, '691693023d49c9ec5639e3e3940614e9', 0),
(139, '2018-02-27 00:28:42', 0, 1, '691693023d49c9ec5639e3e3940614e9', 0),
(140, '2018-02-27 00:29:57', 0, 1, '691693023d49c9ec5639e3e3940614e9', 0),
(141, '2018-02-27 00:32:37', 0, 1, '691693023d49c9ec5639e3e3940614e9', 0),
(142, '2018-02-27 00:33:39', 0, 1, '691693023d49c9ec5639e3e3940614e9', 0),
(143, '2018-02-27 00:34:30', 0, 1, '691693023d49c9ec5639e3e3940614e9', 0),
(144, '2018-02-27 00:35:49', 0, 1, '691693023d49c9ec5639e3e3940614e9', 0),
(145, '2018-02-27 00:42:43', 0, 1, '691693023d49c9ec5639e3e3940614e9', 0),
(146, '2018-02-27 00:44:19', 0, 1, '691693023d49c9ec5639e3e3940614e9', 0),
(147, '2018-02-27 00:45:15', 0, 1, '691693023d49c9ec5639e3e3940614e9', 0),
(148, '2018-02-27 00:46:06', 0, 1, '691693023d49c9ec5639e3e3940614e9', 0),
(149, '2018-02-27 00:46:56', 0, 1, '691693023d49c9ec5639e3e3940614e9', 0),
(150, '2018-02-27 00:47:24', 0, 1, '691693023d49c9ec5639e3e3940614e9', 0),
(151, '2018-02-27 00:48:04', 0, 1, '691693023d49c9ec5639e3e3940614e9', 0),
(152, '2018-02-27 00:49:11', 0, 1, '691693023d49c9ec5639e3e3940614e9', 0),
(153, '2018-02-27 00:49:51', 0, 1, '691693023d49c9ec5639e3e3940614e9', 0),
(154, '2018-02-27 00:56:12', 0, 1, '691693023d49c9ec5639e3e3940614e9', 0),
(155, '2018-02-27 00:59:51', 0, 1, '691693023d49c9ec5639e3e3940614e9', 0),
(156, '2018-02-27 01:02:00', 0, 1, '691693023d49c9ec5639e3e3940614e9', 0),
(157, '2018-02-27 01:02:28', 0, 1, '691693023d49c9ec5639e3e3940614e9', 0),
(158, '2018-02-27 01:02:41', 0, 1, '691693023d49c9ec5639e3e3940614e9', 0),
(159, '2018-02-27 02:03:23', 0, 1, '691693023d49c9ec5639e3e3940614e9', 0),
(160, '2018-02-27 02:05:58', 0, 1, '691693023d49c9ec5639e3e3940614e9', 0),
(161, '2018-02-27 02:39:27', 0, 1, '691693023d49c9ec5639e3e3940614e9', 0),
(162, '2018-02-27 02:40:04', 0, 1, '691693023d49c9ec5639e3e3940614e9', 0),
(163, '2018-02-27 02:41:27', 0, 1, '691693023d49c9ec5639e3e3940614e9', 0),
(164, '2018-02-27 02:42:26', 0, 1, '691693023d49c9ec5639e3e3940614e9', 0),
(165, '2018-02-27 02:43:35', 0, 1, '691693023d49c9ec5639e3e3940614e9', 0),
(166, '2018-02-27 02:44:20', 0, 1, '691693023d49c9ec5639e3e3940614e9', 0),
(167, '2018-02-27 02:46:37', 0, 1, '691693023d49c9ec5639e3e3940614e9', 0),
(168, '2018-02-27 02:47:39', 0, 1, '691693023d49c9ec5639e3e3940614e9', 0),
(169, '2018-02-27 02:49:49', 0, 1, '691693023d49c9ec5639e3e3940614e9', 0),
(170, '2018-02-27 02:57:28', 0, 1, '691693023d49c9ec5639e3e3940614e9', 0),
(171, '2018-02-27 03:00:02', 0, 1, '691693023d49c9ec5639e3e3940614e9', 0),
(172, '2018-02-27 03:00:36', 0, 1, '691693023d49c9ec5639e3e3940614e9', 0),
(173, '2018-02-27 03:02:15', 0, 1, '691693023d49c9ec5639e3e3940614e9', 0),
(174, '2018-02-27 03:08:53', 0, 1, '691693023d49c9ec5639e3e3940614e9', 0),
(175, '2018-02-27 03:09:21', 1, 0, 'f6c36cde1156faf8e285cd7fa9d59f09', 0),
(176, '2018-02-27 03:10:06', 0, 1, '691693023d49c9ec5639e3e3940614e9', 0),
(177, '2018-02-27 03:23:43', 0, 1, '691693023d49c9ec5639e3e3940614e9', 0),
(178, '2018-02-27 07:25:41', 0, 1, '691693023d49c9ec5639e3e3940614e9', 0),
(179, '2018-02-27 07:26:45', 0, 1, '691693023d49c9ec5639e3e3940614e9', 0),
(180, '2018-02-27 07:32:07', 0, 1, '691693023d49c9ec5639e3e3940614e9', 0),
(181, '2018-02-27 07:36:48', 0, 1, '691693023d49c9ec5639e3e3940614e9', 0),
(182, '2018-02-27 19:52:43', 0, 1, '691693023d49c9ec5639e3e3940614e9', 0),
(183, '2018-03-02 00:04:40', 0, 1, 'bb33df82843550b03c1df7ba292b6917', 0),
(184, '2018-03-02 02:08:30', 0, 1, 'bb33df82843550b03c1df7ba292b6917', 0),
(185, '2018-03-02 02:09:26', 0, 1, 'bb33df82843550b03c1df7ba292b6917', 0),
(186, '2018-03-02 02:13:03', 0, 1, 'bb33df82843550b03c1df7ba292b6917', 0),
(187, '2018-03-02 02:15:57', 1, 0, 'efdd1fc7dccffc659cfc428cf209545d', 0),
(188, '2018-03-02 02:24:24', 1, 0, 'efdd1fc7dccffc659cfc428cf209545d', 0),
(189, '2018-03-02 02:25:50', 1, 0, 'efdd1fc7dccffc659cfc428cf209545d', 0),
(190, '2018-03-02 02:26:35', 1, 0, 'efdd1fc7dccffc659cfc428cf209545d', 0),
(191, '2018-03-02 03:26:16', 0, 1, 'bb33df82843550b03c1df7ba292b6917', 0),
(192, '2018-03-02 03:31:32', 0, 1, 'bb33df82843550b03c1df7ba292b6917', 0),
(193, '2018-03-02 03:50:45', 1, 0, 'efdd1fc7dccffc659cfc428cf209545d', 0),
(194, '2018-03-02 03:51:29', 1, 0, 'efdd1fc7dccffc659cfc428cf209545d', 0),
(195, '2018-03-02 04:09:36', 1, 0, 'efdd1fc7dccffc659cfc428cf209545d', 0),
(196, '2018-03-02 04:11:20', 0, 1, 'bb33df82843550b03c1df7ba292b6917', 0),
(197, '2018-03-02 04:11:40', 1, 0, 'efdd1fc7dccffc659cfc428cf209545d', 0),
(198, '2018-03-02 04:16:58', 1, 0, 'efdd1fc7dccffc659cfc428cf209545d', 0),
(199, '2018-03-02 04:18:07', 0, 1, 'bb33df82843550b03c1df7ba292b6917', 0),
(200, '2018-03-02 04:18:26', 1, 0, 'efdd1fc7dccffc659cfc428cf209545d', 0),
(201, '2018-03-02 04:19:41', 1, 0, 'efdd1fc7dccffc659cfc428cf209545d', 0),
(202, '2018-03-02 04:23:45', 1, 0, 'efdd1fc7dccffc659cfc428cf209545d', 0),
(203, '2018-03-02 04:28:13', 1, 0, 'efdd1fc7dccffc659cfc428cf209545d', 0),
(204, '2018-03-02 04:31:59', 1, 0, 'efdd1fc7dccffc659cfc428cf209545d', 0),
(205, '2018-03-02 04:32:46', 1, 0, 'efdd1fc7dccffc659cfc428cf209545d', 0),
(206, '2018-03-02 04:35:53', 1, 0, 'efdd1fc7dccffc659cfc428cf209545d', 0),
(207, '2018-03-02 04:38:24', 1, 0, 'efdd1fc7dccffc659cfc428cf209545d', 0),
(208, '2018-03-02 04:40:58', 1, 0, 'efdd1fc7dccffc659cfc428cf209545d', 0),
(209, '2018-03-03 09:04:07', 0, 1, 'f42a53fbd97c9ad6d40b3ff3f7128a3c', 0),
(210, '2018-03-03 09:08:13', 0, 1, 'f42a53fbd97c9ad6d40b3ff3f7128a3c', 0),
(211, '2018-03-03 09:09:41', 0, 1, 'f42a53fbd97c9ad6d40b3ff3f7128a3c', 0),
(212, '2018-03-03 09:11:07', 0, 1, 'f42a53fbd97c9ad6d40b3ff3f7128a3c', 0),
(213, '2018-03-03 09:22:24', 0, 1, 'f42a53fbd97c9ad6d40b3ff3f7128a3c', 0),
(214, '2018-03-03 09:23:34', 0, 1, 'f42a53fbd97c9ad6d40b3ff3f7128a3c', 0),
(215, '2018-03-03 09:25:17', 0, 1, 'f42a53fbd97c9ad6d40b3ff3f7128a3c', 0),
(216, '2018-03-03 09:26:27', 0, 1, 'f42a53fbd97c9ad6d40b3ff3f7128a3c', 0),
(217, '2018-03-03 09:27:25', 0, 1, 'f42a53fbd97c9ad6d40b3ff3f7128a3c', 0),
(218, '2018-03-03 09:28:34', 0, 1, 'f42a53fbd97c9ad6d40b3ff3f7128a3c', 0),
(219, '2018-03-03 09:37:31', 0, 1, 'f42a53fbd97c9ad6d40b3ff3f7128a3c', 0),
(220, '2018-03-03 09:39:09', 1, 0, 'd217a37135db3d4826d0b6a3ed204012', 0),
(221, '2018-03-03 10:43:16', 0, 1, 'f42a53fbd97c9ad6d40b3ff3f7128a3c', 0),
(222, '2018-03-03 10:44:16', 0, 1, 'f42a53fbd97c9ad6d40b3ff3f7128a3c', 0),
(223, '2018-03-03 10:51:01', 1, 0, 'd217a37135db3d4826d0b6a3ed204012', 0),
(224, '2018-03-03 10:52:20', 1, 0, 'd217a37135db3d4826d0b6a3ed204012', 0),
(225, '2018-03-03 10:55:13', 1, 0, 'd217a37135db3d4826d0b6a3ed204012', 0),
(226, '2018-03-03 10:56:54', 1, 0, 'd217a37135db3d4826d0b6a3ed204012', 0),
(227, '2018-03-03 12:12:50', 1, 0, 'd217a37135db3d4826d0b6a3ed204012', 0),
(228, '2018-03-05 21:27:53', 1, 0, '1c8624518d027fc56a4f1404d8636562', 0),
(229, '2018-03-05 23:29:49', 1, 0, '1c8624518d027fc56a4f1404d8636562', 0),
(230, '2018-03-05 23:43:20', 1, 0, '1c8624518d027fc56a4f1404d8636562', 0),
(231, '2018-03-05 23:44:33', 1, 0, '1c8624518d027fc56a4f1404d8636562', 0),
(232, '2018-03-05 23:49:52', 1, 0, '1c8624518d027fc56a4f1404d8636562', 0),
(233, '2018-03-05 23:53:42', 1, 0, '1c8624518d027fc56a4f1404d8636562', 0),
(234, '2018-03-05 23:54:32', 1, 0, '1c8624518d027fc56a4f1404d8636562', 0),
(235, '2018-03-05 23:57:03', 0, 1, '7d08179ace903c2cea4da039d0a5aa83', 0),
(236, '2018-03-05 23:58:32', 1, 0, '1c8624518d027fc56a4f1404d8636562', 0),
(237, '2018-03-06 21:01:42', 1, 0, '8a4e55099e09b2e9ea5741f2a31cc25d', 0),
(238, '2018-03-06 21:02:45', 0, 1, 'a9e713cce6f77aa8eb7cb6ed87ecad4c', 0),
(239, '2018-03-06 21:14:04', 1, 0, '8a4e55099e09b2e9ea5741f2a31cc25d', 0),
(240, '2018-03-06 21:14:54', 0, 1, 'a9e713cce6f77aa8eb7cb6ed87ecad4c', 0),
(241, '2018-03-06 21:16:04', 1, 0, '8a4e55099e09b2e9ea5741f2a31cc25d', 0),
(242, '2018-03-09 01:34:18', 1, 0, '1b20ebda68d13c31a5b5e3c5a48bd5eb', 0),
(243, '2018-03-09 01:52:43', 1, 0, '1b20ebda68d13c31a5b5e3c5a48bd5eb', 0),
(244, '2018-03-09 01:54:49', 1, 0, '1b20ebda68d13c31a5b5e3c5a48bd5eb', 0),
(245, '2018-03-09 01:56:46', 1, 0, '1b20ebda68d13c31a5b5e3c5a48bd5eb', 0),
(246, '2018-03-09 01:57:31', 1, 0, '1b20ebda68d13c31a5b5e3c5a48bd5eb', 0),
(247, '2018-03-09 01:58:12', 1, 0, '1b20ebda68d13c31a5b5e3c5a48bd5eb', 0),
(248, '2018-03-09 01:58:42', 1, 0, '1b20ebda68d13c31a5b5e3c5a48bd5eb', 0),
(249, '2018-03-09 02:00:27', 1, 0, '1b20ebda68d13c31a5b5e3c5a48bd5eb', 0),
(250, '2018-03-11 16:51:13', 1, 0, '3dd98f9a241638c6ea160aa4fa8dc256', 0),
(251, '2018-03-11 23:00:06', 1, 0, '09e385a880f0b9d00e158597891774e3', 0),
(252, '2018-03-12 00:58:17', 1, 0, '51c0b30b6aab1e959d77639642a04274', 0),
(253, '2018-03-12 01:25:32', 1, 0, '51c0b30b6aab1e959d77639642a04274', 0),
(254, '2018-03-12 01:25:46', 1, 0, '51c0b30b6aab1e959d77639642a04274', 0),
(255, '2018-03-12 01:26:10', 1, 0, '51c0b30b6aab1e959d77639642a04274', 0),
(256, '2018-03-12 01:27:01', 1, 0, '51c0b30b6aab1e959d77639642a04274', 0),
(257, '2018-03-12 01:28:33', 1, 0, '51c0b30b6aab1e959d77639642a04274', 0),
(258, '2018-03-12 01:28:57', 1, 0, '51c0b30b6aab1e959d77639642a04274', 0),
(259, '2018-03-12 01:30:33', 0, 1, '2ba0cb7822b219da1336db058d27d8b1', 0),
(260, '2018-03-12 17:23:10', 1, 0, '51c0b30b6aab1e959d77639642a04274', 0),
(261, '2018-03-12 17:27:25', 1, 0, '51c0b30b6aab1e959d77639642a04274', 0),
(262, '2018-03-12 17:28:59', 1, 0, '51c0b30b6aab1e959d77639642a04274', 0),
(263, '2018-03-17 11:14:49', 1, 0, '04fe5a1f910d25880644d2322a69aa02', 0),
(264, '2018-03-17 11:15:42', 1, 0, '04fe5a1f910d25880644d2322a69aa02', 0),
(265, '2018-03-17 11:16:29', 1, 0, '04fe5a1f910d25880644d2322a69aa02', 0),
(266, '2018-03-17 11:21:33', 1, 0, '04fe5a1f910d25880644d2322a69aa02', 0),
(267, '2018-03-17 11:22:30', 1, 0, '04fe5a1f910d25880644d2322a69aa02', 0),
(268, '2018-03-17 11:27:01', 1, 0, '04fe5a1f910d25880644d2322a69aa02', 0),
(269, '2018-03-17 11:50:47', 1, 0, '04fe5a1f910d25880644d2322a69aa02', 0),
(270, '2018-03-17 11:52:09', 1, 0, '04fe5a1f910d25880644d2322a69aa02', 0),
(271, '2018-03-17 11:52:52', 1, 0, '04fe5a1f910d25880644d2322a69aa02', 0),
(272, '2018-03-20 10:27:08', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(273, '2018-03-20 10:54:23', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(274, '2018-03-20 11:06:49', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(275, '2018-03-20 11:07:25', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(276, '2018-03-20 11:07:44', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(277, '2018-03-20 11:13:00', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(278, '2018-03-20 11:13:26', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(279, '2018-03-20 11:15:03', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(280, '2018-03-20 11:16:51', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(281, '2018-03-20 11:17:47', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(282, '2018-03-20 11:19:14', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(283, '2018-03-20 11:21:58', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(284, '2018-03-20 11:23:50', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(285, '2018-03-20 11:25:05', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(286, '2018-03-20 11:27:23', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(287, '2018-03-20 11:30:00', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(288, '2018-03-20 11:30:37', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(289, '2018-03-20 11:36:38', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(290, '2018-03-20 11:37:53', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(291, '2018-03-20 11:40:17', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(292, '2018-03-20 11:42:20', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(293, '2018-03-20 12:03:15', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(294, '2018-03-20 12:07:48', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(295, '2018-03-20 12:09:49', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(296, '2018-03-20 12:10:16', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(297, '2018-03-20 12:11:01', 0, 1, '35a1eb8f5d243bfde9744e755ee1d056', 0),
(298, '2018-03-20 12:11:21', 0, 1, '35a1eb8f5d243bfde9744e755ee1d056', 0),
(299, '2018-03-20 12:11:21', 0, 1, '35a1eb8f5d243bfde9744e755ee1d056', 0),
(300, '2018-03-20 12:11:57', 0, 1, '35a1eb8f5d243bfde9744e755ee1d056', 0),
(301, '2018-03-20 12:12:28', 0, 1, '35a1eb8f5d243bfde9744e755ee1d056', 0),
(302, '2018-03-20 12:14:47', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(303, '2018-03-20 12:15:10', 0, 1, '35a1eb8f5d243bfde9744e755ee1d056', 0),
(304, '2018-03-20 12:25:11', 0, 1, '35a1eb8f5d243bfde9744e755ee1d056', 0),
(305, '2018-03-20 12:26:32', 0, 1, '35a1eb8f5d243bfde9744e755ee1d056', 0),
(306, '2018-03-20 12:28:59', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(307, '2018-03-20 12:29:21', 0, 1, '35a1eb8f5d243bfde9744e755ee1d056', 0),
(308, '2018-03-20 12:30:49', 0, 1, '35a1eb8f5d243bfde9744e755ee1d056', 0),
(309, '2018-03-20 12:35:09', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(310, '2018-03-20 12:35:31', 0, 1, '35a1eb8f5d243bfde9744e755ee1d056', 0),
(311, '2018-03-20 12:36:23', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(312, '2018-03-20 12:36:33', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(313, '2018-03-20 12:36:51', 0, 1, '35a1eb8f5d243bfde9744e755ee1d056', 0),
(314, '2018-03-20 12:38:36', 0, 1, '35a1eb8f5d243bfde9744e755ee1d056', 0),
(315, '2018-03-20 12:40:07', 0, 1, '35a1eb8f5d243bfde9744e755ee1d056', 0),
(316, '2018-03-20 12:59:52', 0, 1, '35a1eb8f5d243bfde9744e755ee1d056', 0),
(317, '2018-03-20 13:00:44', 0, 1, '35a1eb8f5d243bfde9744e755ee1d056', 0),
(318, '2018-03-20 13:02:04', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(319, '2018-03-20 13:02:43', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(320, '2018-03-20 13:04:21', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(321, '2018-03-20 13:04:42', 0, 1, '35a1eb8f5d243bfde9744e755ee1d056', 0),
(322, '2018-03-20 13:04:51', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(323, '2018-03-20 13:05:45', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(324, '2018-03-20 13:06:11', 0, 1, '35a1eb8f5d243bfde9744e755ee1d056', 0),
(325, '2018-03-20 13:06:23', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(326, '2018-03-20 13:08:05', 0, 1, '35a1eb8f5d243bfde9744e755ee1d056', 0),
(327, '2018-03-20 13:08:05', 0, 1, '35a1eb8f5d243bfde9744e755ee1d056', 0),
(328, '2018-03-20 13:27:59', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(329, '2018-03-20 13:28:29', 0, 1, '35a1eb8f5d243bfde9744e755ee1d056', 0),
(330, '2018-03-20 13:34:23', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(331, '2018-03-20 13:35:00', 0, 1, '35a1eb8f5d243bfde9744e755ee1d056', 0),
(332, '2018-03-20 13:37:04', 0, 1, '35a1eb8f5d243bfde9744e755ee1d056', 0),
(333, '2018-03-20 13:37:40', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(334, '2018-03-20 13:38:18', 0, 1, '35a1eb8f5d243bfde9744e755ee1d056', 0),
(335, '2018-03-20 13:39:30', 0, 1, '35a1eb8f5d243bfde9744e755ee1d056', 0),
(336, '2018-03-20 13:40:57', 0, 1, '35a1eb8f5d243bfde9744e755ee1d056', 0),
(337, '2018-03-20 13:42:04', 0, 1, '35a1eb8f5d243bfde9744e755ee1d056', 0),
(338, '2018-03-20 13:42:25', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(339, '2018-03-20 13:42:50', 0, 1, '35a1eb8f5d243bfde9744e755ee1d056', 0),
(340, '2018-03-20 13:51:13', 0, 1, '35a1eb8f5d243bfde9744e755ee1d056', 0),
(341, '2018-03-20 14:05:34', 0, 1, '35a1eb8f5d243bfde9744e755ee1d056', 0),
(342, '2018-03-20 14:09:37', 0, 1, '35a1eb8f5d243bfde9744e755ee1d056', 0),
(343, '2018-03-20 14:09:59', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(344, '2018-03-20 14:11:08', 0, 1, '35a1eb8f5d243bfde9744e755ee1d056', 0),
(345, '2018-03-20 14:13:24', 0, 1, '35a1eb8f5d243bfde9744e755ee1d056', 0),
(346, '2018-03-20 14:15:07', 0, 1, '35a1eb8f5d243bfde9744e755ee1d056', 0),
(347, '2018-03-20 14:16:05', 0, 1, '35a1eb8f5d243bfde9744e755ee1d056', 0),
(348, '2018-03-20 14:17:17', 0, 1, '35a1eb8f5d243bfde9744e755ee1d056', 0),
(349, '2018-03-20 14:18:42', 0, 1, '35a1eb8f5d243bfde9744e755ee1d056', 0),
(350, '2018-03-20 14:19:46', 0, 1, '35a1eb8f5d243bfde9744e755ee1d056', 0),
(351, '2018-03-20 16:08:46', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(352, '2018-03-20 16:09:27', 0, 1, '35a1eb8f5d243bfde9744e755ee1d056', 0),
(353, '2018-03-20 16:11:57', 0, 1, '35a1eb8f5d243bfde9744e755ee1d056', 0),
(354, '2018-03-20 16:13:22', 0, 1, '35a1eb8f5d243bfde9744e755ee1d056', 0),
(355, '2018-03-20 16:15:36', 0, 1, '35a1eb8f5d243bfde9744e755ee1d056', 0),
(356, '2018-03-20 16:16:25', 0, 1, '35a1eb8f5d243bfde9744e755ee1d056', 0),
(357, '2018-03-20 16:17:28', 0, 1, '35a1eb8f5d243bfde9744e755ee1d056', 0),
(358, '2018-03-20 16:17:51', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(359, '2018-03-20 16:18:18', 0, 1, '35a1eb8f5d243bfde9744e755ee1d056', 0),
(360, '2018-03-20 16:21:09', 0, 1, '35a1eb8f5d243bfde9744e755ee1d056', 0),
(361, '2018-03-20 16:21:28', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(362, '2018-03-20 16:28:19', 0, 1, '35a1eb8f5d243bfde9744e755ee1d056', 0),
(363, '2018-03-20 16:29:32', 0, 1, '35a1eb8f5d243bfde9744e755ee1d056', 0),
(364, '2018-03-20 16:31:37', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(365, '2018-03-20 16:34:35', 0, 1, '35a1eb8f5d243bfde9744e755ee1d056', 0),
(366, '2018-03-20 16:36:41', 0, 1, '35a1eb8f5d243bfde9744e755ee1d056', 0),
(367, '2018-03-20 16:38:26', 0, 1, '35a1eb8f5d243bfde9744e755ee1d056', 0),
(368, '2018-03-20 16:52:39', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(369, '2018-03-20 17:02:05', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(370, '2018-03-20 17:02:25', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(371, '2018-03-20 17:02:59', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(372, '2018-03-20 17:05:05', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(373, '2018-03-20 17:06:36', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(374, '2018-03-20 17:07:00', 0, 1, '35a1eb8f5d243bfde9744e755ee1d056', 0),
(375, '2018-03-20 17:20:30', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(376, '2018-03-20 17:55:30', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(377, '2018-03-20 18:03:45', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(378, '2018-03-20 18:26:59', 0, 1, '35a1eb8f5d243bfde9744e755ee1d056', 0),
(379, '2018-03-20 18:29:12', 1, 0, '3ac7b2086edb276dc29a56e8d769b9c3', 0),
(380, '2018-03-21 10:33:16', 1, 0, '4aa036ed16a620be2b5099d0d5411e65', 0),
(381, '2018-03-21 10:44:15', 1, 0, '4aa036ed16a620be2b5099d0d5411e65', 0),
(382, '2018-03-21 10:44:56', 1, 0, '4aa036ed16a620be2b5099d0d5411e65', 0),
(383, '2018-03-21 11:16:38', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(384, '2018-03-21 11:18:37', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(385, '2018-03-21 11:19:00', 1, 0, '4aa036ed16a620be2b5099d0d5411e65', 0),
(386, '2018-03-21 11:19:18', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(387, '2018-03-21 11:24:40', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(388, '2018-03-21 11:25:18', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(389, '2018-03-21 11:26:47', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(390, '2018-03-21 11:27:07', 1, 0, '4aa036ed16a620be2b5099d0d5411e65', 0),
(391, '2018-03-21 11:29:37', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(392, '2018-03-21 11:32:02', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(393, '2018-03-21 11:33:22', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(394, '2018-03-21 11:33:58', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(395, '2018-03-21 11:38:30', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(396, '2018-03-21 11:42:21', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(397, '2018-03-21 11:54:57', 1, 0, '4aa036ed16a620be2b5099d0d5411e65', 0),
(398, '2018-03-21 11:57:59', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(399, '2018-03-21 11:58:59', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(400, '2018-03-21 11:59:32', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(401, '2018-03-21 11:59:53', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(402, '2018-03-21 12:00:22', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(403, '2018-03-21 12:01:35', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(404, '2018-03-21 12:02:09', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(405, '2018-03-21 12:02:48', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(406, '2018-03-21 12:03:21', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(407, '2018-03-21 12:06:59', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(408, '2018-03-21 12:07:10', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(409, '2018-03-21 12:08:01', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(410, '2018-03-21 12:08:35', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(411, '2018-03-21 12:13:37', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(412, '2018-03-21 12:16:00', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(413, '2018-03-21 12:16:18', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(414, '2018-03-21 12:16:42', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(415, '2018-03-21 12:19:26', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(416, '2018-03-21 12:19:49', 1, 0, '4aa036ed16a620be2b5099d0d5411e65', 0),
(417, '2018-03-21 12:23:34', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(418, '2018-03-21 12:24:46', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(419, '2018-03-21 12:39:45', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(420, '2018-03-21 12:41:10', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(421, '2018-03-21 12:54:57', 1, 0, '4aa036ed16a620be2b5099d0d5411e65', 0),
(422, '2018-03-21 12:58:25', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(423, '2018-03-21 13:00:06', 1, 0, '4aa036ed16a620be2b5099d0d5411e65', 0),
(424, '2018-03-21 13:01:37', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(425, '2018-03-21 13:14:39', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(426, '2018-03-21 13:22:21', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(427, '2018-03-21 13:24:12', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(428, '2018-03-21 13:25:18', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(429, '2018-03-21 13:27:57', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(430, '2018-03-21 13:32:18', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(431, '2018-03-21 13:32:36', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(432, '2018-03-21 13:52:26', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(433, '2018-03-21 14:36:54', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(434, '2018-03-21 14:39:08', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(435, '2018-03-21 14:39:49', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(436, '2018-03-21 14:41:05', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(437, '2018-03-21 14:42:31', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(438, '2018-03-21 14:42:59', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(439, '2018-03-21 14:43:19', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(440, '2018-03-21 14:44:36', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(441, '2018-03-21 14:45:34', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(442, '2018-03-21 14:46:20', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(443, '2018-03-21 14:49:53', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(444, '2018-03-21 14:51:04', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(445, '2018-03-21 14:51:25', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(446, '2018-03-21 14:53:01', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(447, '2018-03-21 15:02:53', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(448, '2018-03-21 15:03:49', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(449, '2018-03-21 15:05:18', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(450, '2018-03-21 15:24:39', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(451, '2018-03-21 15:25:49', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(452, '2018-03-21 15:27:50', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(453, '2018-03-21 15:28:42', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(454, '2018-03-21 15:32:30', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(455, '2018-03-21 15:37:34', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(456, '2018-03-21 15:40:06', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(457, '2018-03-21 15:43:06', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(458, '2018-03-21 15:44:42', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(459, '2018-03-21 15:46:09', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(460, '2018-03-21 15:47:46', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(461, '2018-03-21 15:48:33', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(462, '2018-03-21 15:49:00', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(463, '2018-03-21 15:49:52', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(464, '2018-03-21 15:50:37', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(465, '2018-03-21 15:58:42', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(466, '2018-03-21 17:09:17', 12, 0, 'f35a9a13d027908eafd067127c6a1ec2', 0),
(467, '2018-03-21 17:11:53', 1, 0, '4aa036ed16a620be2b5099d0d5411e65', 0),
(468, '2018-03-21 17:55:48', 12, 0, 'f35a9a13d027908eafd067127c6a1ec2', 0),
(469, '2018-03-21 17:56:03', 1, 0, '4aa036ed16a620be2b5099d0d5411e65', 0),
(470, '2018-03-21 17:57:02', 0, 1, '0c4fd2ad4992fdbe8261b2cec3e45ed0', 0),
(471, '2018-03-21 18:00:34', 1, 0, '4aa036ed16a620be2b5099d0d5411e65', 0),
(472, '2018-03-21 18:01:21', 12, 0, 'f35a9a13d027908eafd067127c6a1ec2', 0),
(473, '2018-03-22 10:03:12', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(474, '2018-03-22 10:06:57', 12, 0, '818f3d01d013285039f080deff175693', 0),
(475, '2018-03-22 10:07:51', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(476, '2018-03-22 10:13:24', 1, 0, '9b677b6a5f09ae0ef18609da3ee4edc2', 0),
(477, '2018-03-22 10:13:42', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(478, '2018-03-22 10:32:45', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(479, '2018-03-22 10:41:51', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(480, '2018-03-22 10:42:22', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(481, '2018-03-22 10:43:39', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(482, '2018-03-22 10:45:25', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(483, '2018-03-22 10:52:59', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(484, '2018-03-22 10:54:28', 1, 0, '9b677b6a5f09ae0ef18609da3ee4edc2', 0),
(485, '2018-03-22 10:55:38', 1, 0, '9b677b6a5f09ae0ef18609da3ee4edc2', 0),
(486, '2018-03-22 10:55:38', 1, 0, '9b677b6a5f09ae0ef18609da3ee4edc2', 0),
(487, '2018-03-22 10:55:46', 1, 0, '9b677b6a5f09ae0ef18609da3ee4edc2', 0),
(488, '2018-03-22 10:56:37', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(489, '2018-03-22 10:56:50', 1, 0, '9b677b6a5f09ae0ef18609da3ee4edc2', 0),
(490, '2018-03-22 10:56:50', 1, 0, '9b677b6a5f09ae0ef18609da3ee4edc2', 0),
(491, '2018-03-22 10:56:52', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(492, '2018-03-22 10:57:26', 1, 0, '9b677b6a5f09ae0ef18609da3ee4edc2', 0),
(493, '2018-03-22 10:59:37', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(494, '2018-03-22 11:00:02', 12, 0, '818f3d01d013285039f080deff175693', 0),
(495, '2018-03-22 11:03:18', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(496, '2018-03-22 11:10:16', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(497, '2018-03-22 11:16:31', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(498, '2018-03-22 11:30:36', 1, 0, '9b677b6a5f09ae0ef18609da3ee4edc2', 0),
(499, '2018-03-22 11:32:44', 12, 0, '818f3d01d013285039f080deff175693', 0),
(500, '2018-03-22 12:15:57', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(501, '2018-03-22 13:46:02', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(502, '2018-03-22 13:47:09', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(503, '2018-03-22 13:51:37', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(504, '2018-03-22 13:53:52', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(505, '2018-03-22 13:55:53', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(506, '2018-03-22 13:58:59', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(507, '2018-03-22 14:00:13', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(508, '2018-03-22 14:11:40', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(509, '2018-03-22 14:17:33', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(510, '2018-03-22 14:19:02', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(511, '2018-03-22 14:20:03', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(512, '2018-03-22 14:22:28', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(513, '2018-03-22 14:23:58', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(514, '2018-03-22 14:26:15', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(515, '2018-03-22 14:27:31', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(516, '2018-03-22 14:28:02', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(517, '2018-03-22 14:29:28', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(518, '2018-03-22 14:31:43', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(519, '2018-03-22 14:35:42', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(520, '2018-03-22 14:36:36', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(521, '2018-03-22 14:36:50', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(522, '2018-03-22 14:40:08', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(523, '2018-03-22 14:41:54', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(524, '2018-03-22 14:43:17', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(525, '2018-03-22 14:44:56', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(526, '2018-03-22 14:47:24', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(527, '2018-03-22 14:48:47', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(528, '2018-03-22 14:49:27', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(529, '2018-03-22 14:53:13', 1, 0, '9b677b6a5f09ae0ef18609da3ee4edc2', 0),
(530, '2018-03-22 14:53:46', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(531, '2018-03-22 14:57:56', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(532, '2018-03-22 16:27:55', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(533, '2018-03-22 16:28:50', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(534, '2018-03-22 16:29:17', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(535, '2018-03-22 16:35:29', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(536, '2018-03-22 17:33:06', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(537, '2018-03-22 17:33:27', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(538, '2018-03-22 17:40:41', 1, 0, '9b677b6a5f09ae0ef18609da3ee4edc2', 0),
(539, '2018-03-22 17:56:41', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(540, '2018-03-22 18:03:28', 1, 0, '9b677b6a5f09ae0ef18609da3ee4edc2', 0),
(541, '2018-03-22 18:03:53', 12, 0, '818f3d01d013285039f080deff175693', 0),
(542, '2018-03-22 18:04:18', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(543, '2018-03-22 18:11:23', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(544, '2018-03-22 18:17:19', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(545, '2018-03-22 18:18:40', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(546, '2018-03-22 18:20:03', 0, 1, 'ec40eddbbf0ea843115b04126848a5b3', 0),
(547, '2018-03-23 10:51:35', 0, 1, '9887bd5d905396d0e2ac14c98aa033f1', 0),
(548, '2018-03-23 11:05:55', 0, 1, '9887bd5d905396d0e2ac14c98aa033f1', 0),
(549, '2018-03-23 11:27:05', 0, 1, '9887bd5d905396d0e2ac14c98aa033f1', 0),
(550, '2018-03-23 11:30:16', 0, 1, '9887bd5d905396d0e2ac14c98aa033f1', 0),
(551, '2018-03-23 11:32:51', 0, 1, '9887bd5d905396d0e2ac14c98aa033f1', 0),
(552, '2018-03-23 11:34:45', 0, 1, '9887bd5d905396d0e2ac14c98aa033f1', 0),
(553, '2018-03-23 11:35:26', 0, 1, '9887bd5d905396d0e2ac14c98aa033f1', 0),
(554, '2018-03-23 11:45:33', 0, 1, '9887bd5d905396d0e2ac14c98aa033f1', 0),
(555, '2018-03-23 11:49:49', 0, 1, '9887bd5d905396d0e2ac14c98aa033f1', 0),
(556, '2018-03-23 12:09:48', 0, 1, '9887bd5d905396d0e2ac14c98aa033f1', 0),
(557, '2018-03-23 12:10:48', 0, 1, '9887bd5d905396d0e2ac14c98aa033f1', 0),
(558, '2018-03-23 12:32:17', 0, 1, '9887bd5d905396d0e2ac14c98aa033f1', 0),
(559, '2018-03-23 12:40:29', 0, 1, '9887bd5d905396d0e2ac14c98aa033f1', 0),
(560, '2018-03-23 12:47:52', 0, 1, '9887bd5d905396d0e2ac14c98aa033f1', 0),
(561, '2018-03-23 13:04:43', 0, 1, '9887bd5d905396d0e2ac14c98aa033f1', 0),
(562, '2018-03-23 13:08:39', 0, 1, '9887bd5d905396d0e2ac14c98aa033f1', 0),
(563, '2018-03-23 13:11:04', 1, 0, '194cbf044a4593dfa1e14d63ea3c05a8', 0),
(564, '2018-03-23 13:12:15', 0, 1, '9887bd5d905396d0e2ac14c98aa033f1', 0),
(565, '2018-03-23 13:13:45', 0, 1, '9887bd5d905396d0e2ac14c98aa033f1', 0),
(566, '2018-03-23 13:15:37', 0, 1, '9887bd5d905396d0e2ac14c98aa033f1', 0),
(567, '2018-03-23 13:55:34', 0, 1, '9887bd5d905396d0e2ac14c98aa033f1', 0),
(568, '2018-03-23 13:57:40', 0, 1, '9887bd5d905396d0e2ac14c98aa033f1', 0),
(569, '2018-03-23 14:23:02', 0, 1, '9887bd5d905396d0e2ac14c98aa033f1', 0),
(570, '2018-03-23 14:25:40', 0, 1, '9887bd5d905396d0e2ac14c98aa033f1', 0),
(571, '2018-03-23 14:45:15', 1, 0, '194cbf044a4593dfa1e14d63ea3c05a8', 0),
(572, '2018-03-23 14:45:31', 0, 1, '9887bd5d905396d0e2ac14c98aa033f1', 0),
(573, '2018-03-23 14:48:56', 0, 1, '9887bd5d905396d0e2ac14c98aa033f1', 0),
(574, '2018-03-23 14:50:11', 0, 1, '9887bd5d905396d0e2ac14c98aa033f1', 0),
(575, '2018-03-23 14:51:52', 0, 1, '9887bd5d905396d0e2ac14c98aa033f1', 0),
(576, '2018-03-23 16:43:17', 0, 1, '9887bd5d905396d0e2ac14c98aa033f1', 0),
(577, '2018-03-23 16:57:20', 1, 0, '194cbf044a4593dfa1e14d63ea3c05a8', 0),
(578, '2018-03-23 16:57:45', 12, 0, 'dccc84e1d478b2cb272e243fbd8d4f21', 0),
(579, '2018-03-23 16:57:58', 0, 1, '9887bd5d905396d0e2ac14c98aa033f1', 0),
(580, '2018-03-23 17:01:24', 0, 1, '9887bd5d905396d0e2ac14c98aa033f1', 0),
(581, '2018-03-23 17:01:44', 12, 0, 'dccc84e1d478b2cb272e243fbd8d4f21', 0),
(582, '2018-03-23 17:03:47', 0, 1, '9887bd5d905396d0e2ac14c98aa033f1', 0),
(583, '2018-03-23 17:05:27', 1, 0, '194cbf044a4593dfa1e14d63ea3c05a8', 0),
(584, '2018-03-23 17:29:27', 12, 0, 'dccc84e1d478b2cb272e243fbd8d4f21', 0),
(585, '2018-03-23 17:29:50', 1, 0, '194cbf044a4593dfa1e14d63ea3c05a8', 0),
(586, '2018-03-23 17:31:58', 0, 1, '9887bd5d905396d0e2ac14c98aa033f1', 0),
(587, '2018-03-23 17:36:33', 1, 0, '194cbf044a4593dfa1e14d63ea3c05a8', 0),
(588, '2018-03-23 17:36:58', 0, 1, '9887bd5d905396d0e2ac14c98aa033f1', 0),
(589, '2018-03-23 17:49:59', 0, 1, '9887bd5d905396d0e2ac14c98aa033f1', 0),
(590, '2018-03-23 17:51:33', 1, 0, '194cbf044a4593dfa1e14d63ea3c05a8', 0),
(591, '2018-03-23 18:35:56', 12, 0, 'dccc84e1d478b2cb272e243fbd8d4f21', 0),
(592, '2018-03-23 18:36:10', 1, 0, '194cbf044a4593dfa1e14d63ea3c05a8', 0),
(593, '2018-03-23 18:50:36', 0, 1, '9887bd5d905396d0e2ac14c98aa033f1', 0),
(594, '2018-03-23 18:57:25', 12, 0, 'dccc84e1d478b2cb272e243fbd8d4f21', 0),
(595, '2018-03-23 18:58:38', 0, 1, '9887bd5d905396d0e2ac14c98aa033f1', 0),
(596, '2018-04-03 11:13:16', 0, 1, '168f90fc9ad103afcaf4a245ed7b0cea', 0),
(597, '2018-04-03 11:39:35', 0, 1, '168f90fc9ad103afcaf4a245ed7b0cea', 0),
(598, '2018-04-03 11:47:37', 0, 1, '168f90fc9ad103afcaf4a245ed7b0cea', 0),
(599, '2018-04-03 11:51:48', 0, 1, '168f90fc9ad103afcaf4a245ed7b0cea', 0),
(600, '2018-04-03 11:52:55', 0, 1, '168f90fc9ad103afcaf4a245ed7b0cea', 0),
(601, '2018-04-03 11:56:17', 1, 0, 'cb40fe52e4136772288e7309927d1e2c', 0),
(602, '2018-04-03 11:58:00', 1, 0, 'cb40fe52e4136772288e7309927d1e2c', 0),
(603, '2018-04-03 12:19:37', 0, 1, '168f90fc9ad103afcaf4a245ed7b0cea', 0),
(604, '2018-04-03 12:57:16', 1, 0, 'cb40fe52e4136772288e7309927d1e2c', 0),
(605, '2018-04-03 12:58:21', 0, 1, '168f90fc9ad103afcaf4a245ed7b0cea', 0),
(606, '2018-04-03 13:00:30', 0, 1, '168f90fc9ad103afcaf4a245ed7b0cea', 0),
(607, '2018-04-03 13:00:42', 1, 0, 'cb40fe52e4136772288e7309927d1e2c', 0),
(608, '2018-04-03 13:01:00', 0, 1, '168f90fc9ad103afcaf4a245ed7b0cea', 0),
(609, '2018-04-03 13:09:29', 0, 1, '168f90fc9ad103afcaf4a245ed7b0cea', 0),
(610, '2018-04-03 13:11:07', 0, 1, '168f90fc9ad103afcaf4a245ed7b0cea', 0),
(611, '2018-04-03 13:12:05', 0, 1, '168f90fc9ad103afcaf4a245ed7b0cea', 0),
(612, '2018-04-03 13:12:51', 0, 1, '168f90fc9ad103afcaf4a245ed7b0cea', 0),
(613, '2018-04-03 13:16:07', 0, 1, '168f90fc9ad103afcaf4a245ed7b0cea', 0),
(614, '2018-04-03 13:16:49', 0, 1, '168f90fc9ad103afcaf4a245ed7b0cea', 0),
(615, '2018-04-03 13:19:14', 0, 1, '168f90fc9ad103afcaf4a245ed7b0cea', 0),
(616, '2018-04-03 13:20:58', 0, 1, '168f90fc9ad103afcaf4a245ed7b0cea', 0),
(617, '2018-04-03 13:22:19', 0, 1, '168f90fc9ad103afcaf4a245ed7b0cea', 0),
(618, '2018-04-03 13:25:14', 0, 1, '168f90fc9ad103afcaf4a245ed7b0cea', 0),
(619, '2018-04-03 13:26:38', 0, 1, '168f90fc9ad103afcaf4a245ed7b0cea', 0),
(620, '2018-04-03 13:31:14', 0, 1, '168f90fc9ad103afcaf4a245ed7b0cea', 0),
(621, '2018-04-03 13:32:26', 0, 1, '168f90fc9ad103afcaf4a245ed7b0cea', 0),
(622, '2018-04-03 13:33:26', 0, 1, '168f90fc9ad103afcaf4a245ed7b0cea', 0),
(623, '2018-04-03 13:41:41', 0, 1, '168f90fc9ad103afcaf4a245ed7b0cea', 0),
(624, '2018-04-03 13:43:29', 0, 1, '168f90fc9ad103afcaf4a245ed7b0cea', 0),
(625, '2018-04-03 13:45:43', 0, 1, '168f90fc9ad103afcaf4a245ed7b0cea', 0),
(626, '2018-04-03 13:46:55', 0, 1, '168f90fc9ad103afcaf4a245ed7b0cea', 0),
(627, '2018-04-03 13:50:12', 0, 1, '168f90fc9ad103afcaf4a245ed7b0cea', 0),
(628, '2018-04-03 13:52:12', 0, 1, '168f90fc9ad103afcaf4a245ed7b0cea', 0),
(629, '2018-04-03 13:53:36', 0, 1, '168f90fc9ad103afcaf4a245ed7b0cea', 0),
(630, '2018-04-03 13:54:26', 0, 1, '168f90fc9ad103afcaf4a245ed7b0cea', 0),
(631, '2018-04-03 14:02:33', 0, 1, '168f90fc9ad103afcaf4a245ed7b0cea', 0),
(632, '2018-04-03 14:06:31', 0, 1, '168f90fc9ad103afcaf4a245ed7b0cea', 0),
(633, '2018-04-03 14:09:48', 0, 1, '168f90fc9ad103afcaf4a245ed7b0cea', 0),
(634, '2018-04-03 14:10:14', 0, 1, '168f90fc9ad103afcaf4a245ed7b0cea', 0),
(635, '2018-04-03 14:11:59', 0, 1, '168f90fc9ad103afcaf4a245ed7b0cea', 0),
(636, '2018-04-03 14:16:45', 0, 1, '168f90fc9ad103afcaf4a245ed7b0cea', 0),
(637, '2018-04-03 14:21:48', 0, 1, '168f90fc9ad103afcaf4a245ed7b0cea', 0),
(638, '2018-04-03 14:29:48', 0, 1, '168f90fc9ad103afcaf4a245ed7b0cea', 0),
(639, '2018-04-03 16:50:07', 0, 1, '168f90fc9ad103afcaf4a245ed7b0cea', 0),
(640, '2018-04-03 16:52:56', 0, 1, '168f90fc9ad103afcaf4a245ed7b0cea', 0),
(641, '2018-04-03 17:17:59', 0, 1, '168f90fc9ad103afcaf4a245ed7b0cea', 0),
(642, '2018-04-03 17:20:06', 0, 1, '168f90fc9ad103afcaf4a245ed7b0cea', 0),
(643, '2018-04-03 17:22:45', 0, 1, '168f90fc9ad103afcaf4a245ed7b0cea', 0),
(644, '2018-04-03 17:26:03', 0, 1, '168f90fc9ad103afcaf4a245ed7b0cea', 0),
(645, '2018-04-03 17:34:17', 0, 1, '168f90fc9ad103afcaf4a245ed7b0cea', 0),
(646, '2018-04-03 17:35:51', 0, 1, '168f90fc9ad103afcaf4a245ed7b0cea', 0),
(647, '2018-04-03 17:40:41', 0, 1, '168f90fc9ad103afcaf4a245ed7b0cea', 0),
(648, '2018-04-03 17:41:48', 1, 0, 'cb40fe52e4136772288e7309927d1e2c', 0),
(649, '2018-04-03 17:57:25', 0, 1, '168f90fc9ad103afcaf4a245ed7b0cea', 0),
(650, '2018-04-03 17:58:16', 0, 1, '168f90fc9ad103afcaf4a245ed7b0cea', 0),
(651, '2018-04-03 17:59:07', 0, 1, '168f90fc9ad103afcaf4a245ed7b0cea', 0),
(652, '2018-04-04 13:49:27', 1, 0, '3d2bb61e8e1a943ae605b81b3c43fc52', 0),
(653, '2018-04-04 13:52:49', 0, 1, 'b471305c10ee60bd29b02d8d82a8af86', 0),
(654, '2018-04-04 13:53:28', 12, 0, '03e2ffdebcc110c4d093baa62f00cdaf', 1),
(655, '2018-04-04 13:59:20', 0, 1, 'b471305c10ee60bd29b02d8d82a8af86', 0),
(656, '2018-04-04 14:02:18', 1, 0, '3d2bb61e8e1a943ae605b81b3c43fc52', 0),
(657, '2018-04-04 14:04:26', 0, 1, 'b471305c10ee60bd29b02d8d82a8af86', 0),
(658, '2018-04-16 00:50:32', 0, 1, '1995b4925f4c2c5019dbcb787ae947f5', 0),
(659, '2018-04-16 01:42:56', 0, 1, '1995b4925f4c2c5019dbcb787ae947f5', 0),
(660, '2018-04-17 12:12:09', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(661, '2018-04-17 12:13:09', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(662, '2018-04-17 12:14:04', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(663, '2018-04-17 12:23:08', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(664, '2018-04-17 12:24:00', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(665, '2018-04-17 12:24:28', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(666, '2018-04-17 12:25:41', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(667, '2018-04-17 12:25:52', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(668, '2018-04-17 12:30:56', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(669, '2018-04-17 12:31:50', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(670, '2018-04-17 12:40:37', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(671, '2018-04-17 12:42:15', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(672, '2018-04-17 12:50:35', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(673, '2018-04-17 12:54:27', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(674, '2018-04-17 13:02:51', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(675, '2018-04-17 13:02:58', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(676, '2018-04-17 13:02:59', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(677, '2018-04-17 13:03:00', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(678, '2018-04-17 13:03:00', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(679, '2018-04-17 13:03:01', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(680, '2018-04-17 13:07:38', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(681, '2018-04-17 13:07:47', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(682, '2018-04-17 13:30:13', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(683, '2018-04-17 13:36:54', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(684, '2018-04-17 13:37:15', 0, 1, '0ebed31a369872704137d32b68d23c07', 0);
INSERT INTO `validtokens` (`vt_id`, `vt_createat`, `vt_usr_id`, `vt_st_id`, `vt_hash`, `vt_status`) VALUES
(685, '2018-04-17 13:37:26', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(686, '2018-04-17 13:37:28', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(687, '2018-04-17 13:37:29', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(688, '2018-04-17 13:37:29', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(689, '2018-04-17 13:37:30', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(690, '2018-04-17 13:37:30', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(691, '2018-04-17 13:37:59', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(692, '2018-04-17 13:38:55', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(693, '2018-04-17 13:40:08', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(694, '2018-04-17 13:40:09', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(695, '2018-04-17 13:40:14', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(696, '2018-04-17 13:40:27', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(697, '2018-04-17 13:42:35', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(698, '2018-04-17 13:43:16', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(699, '2018-04-17 13:43:49', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(700, '2018-04-17 13:45:03', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(701, '2018-04-17 13:45:06', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(702, '2018-04-17 13:45:07', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(703, '2018-04-17 13:45:07', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(704, '2018-04-17 13:47:00', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(705, '2018-04-17 13:47:33', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(706, '2018-04-17 13:48:13', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(707, '2018-04-17 13:48:15', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(708, '2018-04-17 13:48:17', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(709, '2018-04-17 13:48:27', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(710, '2018-04-17 13:56:15', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(711, '2018-04-17 13:57:05', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(712, '2018-04-17 13:57:07', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(713, '2018-04-17 13:57:08', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(714, '2018-04-17 13:57:08', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(715, '2018-04-17 13:57:08', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(716, '2018-04-17 13:57:09', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(717, '2018-04-17 13:57:09', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(718, '2018-04-17 13:57:09', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(719, '2018-04-17 13:57:09', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(720, '2018-04-17 13:57:10', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(721, '2018-04-17 13:57:10', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(722, '2018-04-17 13:57:14', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(723, '2018-04-17 13:57:14', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(724, '2018-04-17 13:58:47', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(725, '2018-04-17 14:00:12', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(726, '2018-04-17 14:00:21', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(727, '2018-04-17 14:00:25', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(728, '2018-04-17 14:00:34', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(729, '2018-04-17 14:00:36', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(730, '2018-04-17 14:00:37', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(731, '2018-04-17 14:00:38', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(732, '2018-04-17 14:00:54', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(733, '2018-04-17 14:05:02', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(734, '2018-04-17 14:06:05', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(735, '2018-04-17 14:07:02', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(736, '2018-04-17 14:07:21', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(737, '2018-04-17 14:07:23', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(738, '2018-04-17 14:07:27', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(739, '2018-04-17 14:07:49', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(740, '2018-04-17 14:10:18', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(741, '2018-04-17 14:11:10', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(742, '2018-04-17 14:11:15', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(743, '2018-04-17 14:11:39', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(744, '2018-04-17 14:12:48', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(745, '2018-04-17 14:12:50', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(746, '2018-04-17 14:12:51', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(747, '2018-04-17 14:12:52', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(748, '2018-04-17 14:12:52', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(749, '2018-04-17 14:12:52', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(750, '2018-04-17 14:12:53', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(751, '2018-04-17 14:12:53', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(752, '2018-04-17 14:13:21', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(753, '2018-04-17 14:14:00', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(754, '2018-04-17 14:14:13', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(755, '2018-04-17 14:14:46', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(756, '2018-04-17 14:14:51', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(757, '2018-04-17 14:15:45', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(758, '2018-04-17 14:17:07', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(759, '2018-04-17 14:17:16', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(760, '2018-04-17 14:44:13', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(761, '2018-04-17 14:54:49', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(762, '2018-04-17 17:13:57', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(763, '2018-04-17 17:14:47', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(764, '2018-04-17 17:15:05', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(765, '2018-04-17 17:28:35', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(766, '2018-04-17 17:28:55', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(767, '2018-04-17 17:29:17', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(768, '2018-04-17 17:29:18', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(769, '2018-04-17 17:29:19', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(770, '2018-04-17 17:30:05', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(771, '2018-04-17 17:31:02', 0, 1, '0ebed31a369872704137d32b68d23c07', 0),
(772, '2018-04-24 05:47:12', 0, 1, 'af1f0d395485f2d526b69b3609e119de', 0),
(773, '2018-04-24 05:49:20', 0, 1, 'af1f0d395485f2d526b69b3609e119de', 0),
(774, '2018-04-24 05:51:53', 0, 1, 'af1f0d395485f2d526b69b3609e119de', 0),
(775, '2018-04-24 05:52:02', 0, 1, 'af1f0d395485f2d526b69b3609e119de', 0),
(776, '2018-04-24 06:11:59', 0, 1, 'af1f0d395485f2d526b69b3609e119de', 0),
(777, '2018-04-24 06:12:41', 0, 1, 'af1f0d395485f2d526b69b3609e119de', 0),
(778, '2018-04-24 06:12:59', 0, 1, 'af1f0d395485f2d526b69b3609e119de', 0),
(779, '2018-04-24 06:23:51', 0, 1, 'af1f0d395485f2d526b69b3609e119de', 0),
(780, '2018-04-24 06:25:52', 0, 1, 'af1f0d395485f2d526b69b3609e119de', 0),
(781, '2018-04-24 06:30:49', 0, 1, 'af1f0d395485f2d526b69b3609e119de', 0),
(782, '2018-04-24 06:33:05', 0, 1, 'af1f0d395485f2d526b69b3609e119de', 0),
(783, '2018-04-24 06:38:40', 0, 1, 'af1f0d395485f2d526b69b3609e119de', 0),
(784, '2018-04-24 06:39:19', 0, 1, 'af1f0d395485f2d526b69b3609e119de', 0),
(785, '2018-04-24 06:44:52', 0, 1, 'af1f0d395485f2d526b69b3609e119de', 0),
(786, '2018-04-24 06:45:13', 0, 1, 'af1f0d395485f2d526b69b3609e119de', 0),
(787, '2018-04-24 06:47:27', 0, 1, 'af1f0d395485f2d526b69b3609e119de', 0),
(788, '2018-04-24 07:08:53', 0, 1, 'af1f0d395485f2d526b69b3609e119de', 0),
(789, '2018-04-24 07:09:45', 0, 1, 'af1f0d395485f2d526b69b3609e119de', 0),
(790, '2018-04-24 07:11:23', 0, 1, 'af1f0d395485f2d526b69b3609e119de', 0),
(791, '2018-04-24 12:24:09', 0, 1, 'af1f0d395485f2d526b69b3609e119de', 0),
(792, '2018-04-24 12:56:17', 0, 1, 'af1f0d395485f2d526b69b3609e119de', 0),
(793, '2018-04-24 12:58:36', 0, 1, 'af1f0d395485f2d526b69b3609e119de', 0),
(794, '2018-04-25 07:56:27', 0, 1, '286a30cc3671c4d0ea384de142e584ac', 0),
(795, '2018-04-25 07:57:51', 0, 1, '286a30cc3671c4d0ea384de142e584ac', 0),
(796, '2018-04-25 08:15:07', 0, 1, '286a30cc3671c4d0ea384de142e584ac', 0),
(797, '2018-04-25 08:39:28', 0, 1, '286a30cc3671c4d0ea384de142e584ac', 0),
(798, '2018-04-25 08:41:19', 0, 1, '286a30cc3671c4d0ea384de142e584ac', 0),
(799, '2018-04-25 08:48:53', 0, 1, '286a30cc3671c4d0ea384de142e584ac', 0),
(800, '2018-04-25 08:50:06', 0, 1, '286a30cc3671c4d0ea384de142e584ac', 0),
(801, '2018-04-26 08:49:14', 0, 1, '5414437c8a37ea1a5ae453ae7cd56644', 0),
(802, '2018-04-26 08:52:14', 0, 1, '5414437c8a37ea1a5ae453ae7cd56644', 0),
(803, '2018-04-26 08:54:07', 0, 1, '5414437c8a37ea1a5ae453ae7cd56644', 0),
(804, '2018-04-26 09:01:13', 0, 1, '5414437c8a37ea1a5ae453ae7cd56644', 0),
(805, '2018-04-26 09:02:24', 0, 1, '5414437c8a37ea1a5ae453ae7cd56644', 0),
(806, '2018-04-26 09:05:05', 0, 1, '5414437c8a37ea1a5ae453ae7cd56644', 0),
(807, '2018-04-26 09:08:05', 0, 1, '5414437c8a37ea1a5ae453ae7cd56644', 0),
(808, '2018-04-26 09:09:17', 0, 1, '5414437c8a37ea1a5ae453ae7cd56644', 0),
(809, '2018-04-26 09:10:55', 0, 1, '5414437c8a37ea1a5ae453ae7cd56644', 0),
(810, '2018-04-26 09:13:51', 0, 1, '5414437c8a37ea1a5ae453ae7cd56644', 0),
(811, '2018-04-26 10:15:00', 0, 1, '5414437c8a37ea1a5ae453ae7cd56644', 0),
(812, '2018-04-26 10:17:24', 0, 1, '5414437c8a37ea1a5ae453ae7cd56644', 0),
(813, '2018-04-26 10:18:23', 0, 1, '5414437c8a37ea1a5ae453ae7cd56644', 0),
(814, '2018-04-26 10:26:09', 0, 1, '5414437c8a37ea1a5ae453ae7cd56644', 0),
(815, '2018-04-26 10:27:32', 0, 1, '5414437c8a37ea1a5ae453ae7cd56644', 0),
(816, '2018-04-26 10:30:27', 0, 1, '5414437c8a37ea1a5ae453ae7cd56644', 0),
(817, '2018-04-26 10:31:40', 0, 1, '5414437c8a37ea1a5ae453ae7cd56644', 0),
(818, '2018-04-26 10:34:21', 0, 1, '5414437c8a37ea1a5ae453ae7cd56644', 0),
(819, '2018-04-26 10:36:25', 0, 1, '5414437c8a37ea1a5ae453ae7cd56644', 0),
(820, '2018-04-26 10:42:13', 0, 1, '5414437c8a37ea1a5ae453ae7cd56644', 0),
(821, '2018-04-26 10:52:37', 0, 1, '5414437c8a37ea1a5ae453ae7cd56644', 0),
(822, '2018-04-26 10:57:11', 0, 1, '5414437c8a37ea1a5ae453ae7cd56644', 0),
(823, '2018-04-26 10:58:20', 0, 1, '5414437c8a37ea1a5ae453ae7cd56644', 0),
(824, '2018-04-26 12:29:46', 0, 1, '5414437c8a37ea1a5ae453ae7cd56644', 0),
(825, '2018-04-26 13:17:38', 0, 1, '5414437c8a37ea1a5ae453ae7cd56644', 0),
(826, '2018-04-26 13:19:30', 0, 1, '5414437c8a37ea1a5ae453ae7cd56644', 0),
(827, '2018-04-26 13:20:05', 0, 1, '5414437c8a37ea1a5ae453ae7cd56644', 0),
(828, '2018-04-26 13:20:35', 0, 1, '5414437c8a37ea1a5ae453ae7cd56644', 0),
(829, '2018-04-26 13:21:08', 0, 1, '5414437c8a37ea1a5ae453ae7cd56644', 0),
(830, '2018-04-26 13:22:04', 0, 1, '5414437c8a37ea1a5ae453ae7cd56644', 0),
(831, '2018-04-26 13:22:55', 0, 1, '5414437c8a37ea1a5ae453ae7cd56644', 0),
(832, '2018-04-26 13:22:57', 0, 1, '5414437c8a37ea1a5ae453ae7cd56644', 0),
(833, '2018-04-26 13:22:59', 0, 1, '5414437c8a37ea1a5ae453ae7cd56644', 0),
(834, '2018-04-26 13:23:01', 0, 1, '5414437c8a37ea1a5ae453ae7cd56644', 0),
(835, '2018-04-26 13:49:20', 0, 1, '5414437c8a37ea1a5ae453ae7cd56644', 0),
(836, '2018-04-26 14:00:55', 0, 1, '5414437c8a37ea1a5ae453ae7cd56644', 0),
(837, '2018-04-26 14:01:36', 0, 1, '5414437c8a37ea1a5ae453ae7cd56644', 0),
(838, '2018-05-02 01:38:02', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(839, '2018-05-02 01:38:46', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(840, '2018-05-02 01:39:39', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(841, '2018-05-02 01:41:04', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(842, '2018-05-02 01:41:57', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(843, '2018-05-02 01:43:03', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(844, '2018-05-02 01:43:18', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(845, '2018-05-02 01:43:19', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(846, '2018-05-02 01:43:20', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(847, '2018-05-02 01:43:21', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(848, '2018-05-02 01:43:21', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(849, '2018-05-02 01:43:21', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(850, '2018-05-02 01:43:22', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(851, '2018-05-02 01:43:22', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(852, '2018-05-02 01:43:22', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(853, '2018-05-02 01:43:22', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(854, '2018-05-02 01:43:22', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(855, '2018-05-02 01:43:23', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(856, '2018-05-02 01:43:23', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(857, '2018-05-02 01:43:23', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(858, '2018-05-02 01:43:23', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(859, '2018-05-02 01:43:24', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(860, '2018-05-02 01:43:24', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(861, '2018-05-02 01:43:24', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(862, '2018-05-02 01:43:25', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(863, '2018-05-02 01:43:45', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(864, '2018-05-02 01:43:47', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(865, '2018-05-02 01:43:47', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(866, '2018-05-02 01:43:48', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(867, '2018-05-02 01:43:49', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(868, '2018-05-02 01:43:56', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(869, '2018-05-02 01:43:57', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(870, '2018-05-02 01:43:57', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(871, '2018-05-02 01:43:58', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(872, '2018-05-02 01:43:58', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(873, '2018-05-02 01:43:58', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(874, '2018-05-02 01:43:58', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(875, '2018-05-02 01:43:58', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(876, '2018-05-02 01:43:59', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(877, '2018-05-02 01:43:59', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(878, '2018-05-02 01:45:14', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(879, '2018-05-02 01:45:30', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(880, '2018-05-02 01:45:47', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(881, '2018-05-02 01:45:58', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(882, '2018-05-02 01:46:02', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(883, '2018-05-02 01:46:03', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(884, '2018-05-02 01:46:04', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(885, '2018-05-02 01:46:05', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(886, '2018-05-02 01:46:56', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(887, '2018-05-02 01:47:00', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(888, '2018-05-02 01:47:36', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(889, '2018-05-02 01:49:13', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(890, '2018-05-02 01:49:31', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(891, '2018-05-02 01:49:47', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(892, '2018-05-02 01:57:34', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(893, '2018-05-02 01:59:02', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(894, '2018-05-02 02:57:20', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(895, '2018-05-02 04:27:28', 1, 0, 'fbbac49af88af2f4c2d1335f2a0b07c7', 0),
(896, '2018-05-02 04:46:49', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(897, '2018-05-02 04:52:19', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(898, '2018-05-02 04:53:35', 1, 0, 'fbbac49af88af2f4c2d1335f2a0b07c7', 1),
(899, '2018-05-02 04:55:14', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(900, '2018-05-02 05:01:45', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(901, '2018-05-02 05:03:49', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(902, '2018-05-02 05:05:56', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(903, '2018-05-02 05:06:58', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(904, '2018-05-02 05:08:12', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(905, '2018-05-02 05:10:51', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(906, '2018-05-02 05:11:53', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(907, '2018-05-02 05:12:55', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(908, '2018-05-02 05:19:11', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(909, '2018-05-02 05:26:11', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(910, '2018-05-02 05:44:05', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(911, '2018-05-02 05:45:30', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(912, '2018-05-02 05:47:31', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(913, '2018-05-02 05:48:36', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(914, '2018-05-02 05:50:02', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(915, '2018-05-02 05:59:10', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(916, '2018-05-02 06:03:36', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(917, '2018-05-02 06:33:29', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(918, '2018-05-02 06:34:28', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(919, '2018-05-02 06:37:46', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(920, '2018-05-02 06:39:34', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(921, '2018-05-02 06:41:54', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(922, '2018-05-02 06:42:51', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(923, '2018-05-02 06:43:40', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(924, '2018-05-02 06:44:16', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(925, '2018-05-02 10:49:07', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(926, '2018-05-02 10:56:44', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(927, '2018-05-02 10:58:33', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(928, '2018-05-02 11:01:08', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(929, '2018-05-02 11:07:39', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(930, '2018-05-02 11:14:47', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(931, '2018-05-02 11:18:53', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(932, '2018-05-02 11:19:42', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(933, '2018-05-02 11:20:48', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(934, '2018-05-02 11:32:13', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(935, '2018-05-02 12:30:26', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(936, '2018-05-02 12:32:10', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(937, '2018-05-02 12:40:25', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(938, '2018-05-02 12:43:52', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(939, '2018-05-02 12:46:18', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(940, '2018-05-02 12:47:32', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(941, '2018-05-02 12:49:53', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(942, '2018-05-02 12:51:11', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(943, '2018-05-02 13:15:33', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(944, '2018-05-02 13:16:44', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(945, '2018-05-02 13:18:04', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(946, '2018-05-02 13:19:41', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(947, '2018-05-02 13:21:34', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(948, '2018-05-02 13:24:16', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(949, '2018-05-02 13:30:17', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(950, '2018-05-02 13:50:10', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(951, '2018-05-02 13:55:19', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(952, '2018-05-02 13:56:41', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(953, '2018-05-02 14:02:49', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(954, '2018-05-02 14:07:31', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(955, '2018-05-02 14:09:22', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(956, '2018-05-02 14:10:27', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(957, '2018-05-02 14:39:20', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(958, '2018-05-02 14:40:46', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(959, '2018-05-02 14:41:27', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(960, '2018-05-02 14:42:21', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(961, '2018-05-02 14:43:10', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(962, '2018-05-02 14:44:29', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(963, '2018-05-02 14:47:15', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(964, '2018-05-02 16:20:51', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(965, '2018-05-02 16:22:01', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(966, '2018-05-02 16:22:45', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(967, '2018-05-02 16:23:39', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(968, '2018-05-02 16:48:19', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(969, '2018-05-02 17:08:52', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(970, '2018-05-02 18:19:06', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(971, '2018-05-02 18:26:20', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(972, '2018-05-02 18:27:14', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(973, '2018-05-02 18:29:34', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(974, '2018-05-02 18:33:19', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(975, '2018-05-02 18:35:17', 0, 1, 'e575290518d08a0a3c07b8b28e653c29', 0),
(976, '2018-05-05 18:02:58', 0, 1, 'b37f24fbb4f8b623ce7cd4dd19261604', 0),
(977, '2018-05-05 18:56:41', 0, 1, 'b37f24fbb4f8b623ce7cd4dd19261604', 0),
(978, '2018-05-05 18:57:20', 0, 1, 'b37f24fbb4f8b623ce7cd4dd19261604', 0),
(979, '2018-05-05 19:01:51', 0, 1, 'b37f24fbb4f8b623ce7cd4dd19261604', 0),
(980, '2018-05-05 19:02:20', 0, 1, 'b37f24fbb4f8b623ce7cd4dd19261604', 0),
(981, '2018-05-05 19:02:40', 0, 1, 'b37f24fbb4f8b623ce7cd4dd19261604', 0),
(982, '2018-05-05 19:05:22', 0, 1, 'b37f24fbb4f8b623ce7cd4dd19261604', 0),
(983, '2018-05-07 03:33:42', 0, 1, 'bf3c975004a448d634edefe8037aee3f', 0),
(984, '2018-05-07 03:46:37', 0, 1, 'bf3c975004a448d634edefe8037aee3f', 0),
(985, '2018-05-07 03:58:40', 0, 1, 'bf3c975004a448d634edefe8037aee3f', 0),
(986, '2018-05-07 04:22:57', 0, 1, 'bf3c975004a448d634edefe8037aee3f', 0),
(987, '2018-05-07 04:24:38', 0, 1, 'bf3c975004a448d634edefe8037aee3f', 0),
(988, '2018-05-07 04:26:01', 0, 1, 'bf3c975004a448d634edefe8037aee3f', 0),
(989, '2018-05-07 04:42:34', 0, 1, 'bf3c975004a448d634edefe8037aee3f', 0),
(990, '2018-05-07 04:57:32', 0, 1, 'bf3c975004a448d634edefe8037aee3f', 0),
(991, '2018-05-07 05:00:36', 0, 1, 'bf3c975004a448d634edefe8037aee3f', 0),
(992, '2018-05-07 05:01:08', 0, 1, 'bf3c975004a448d634edefe8037aee3f', 0),
(993, '2018-05-07 05:05:35', 0, 1, 'bf3c975004a448d634edefe8037aee3f', 0),
(994, '2018-05-07 05:12:04', 0, 1, 'bf3c975004a448d634edefe8037aee3f', 0),
(995, '2018-05-10 06:01:09', 0, 1, '09eadc70d6c64e98e6b9b57205a379a1', 0),
(996, '2018-05-10 06:02:54', 0, 1, '09eadc70d6c64e98e6b9b57205a379a1', 0),
(997, '2018-05-10 06:04:15', 0, 1, '09eadc70d6c64e98e6b9b57205a379a1', 0),
(998, '2018-05-10 06:04:46', 0, 1, '09eadc70d6c64e98e6b9b57205a379a1', 0),
(999, '2018-05-10 06:13:36', 0, 1, '09eadc70d6c64e98e6b9b57205a379a1', 0),
(1000, '2018-05-10 06:14:01', 0, 1, '09eadc70d6c64e98e6b9b57205a379a1', 0),
(1001, '2018-05-10 06:14:37', 0, 1, '09eadc70d6c64e98e6b9b57205a379a1', 0),
(1002, '2018-05-10 06:16:32', 0, 1, '09eadc70d6c64e98e6b9b57205a379a1', 0),
(1003, '2018-05-10 06:22:16', 0, 1, '09eadc70d6c64e98e6b9b57205a379a1', 0),
(1004, '2018-05-10 06:22:31', 0, 1, '09eadc70d6c64e98e6b9b57205a379a1', 0),
(1005, '2018-05-10 06:23:29', 0, 1, '09eadc70d6c64e98e6b9b57205a379a1', 1);

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `accesos`
--
ALTER TABLE `accesos`
  ADD PRIMARY KEY (`acceso_id`);

--
-- Indices de la tabla `bitacorapaciente`
--
ALTER TABLE `bitacorapaciente`
  ADD PRIMARY KEY (`bp_id`),
  ADD UNIQUE KEY `bp_id_UNIQUE` (`bp_id`);

--
-- Indices de la tabla `citas`
--
ALTER TABLE `citas`
  ADD PRIMARY KEY (`cita_id`);

--
-- Indices de la tabla `citas_communication`
--
ALTER TABLE `citas_communication`
  ADD PRIMARY KEY (`cc_id`),
  ADD UNIQUE KEY `cc_id_UNIQUE` (`cc_id`);

--
-- Indices de la tabla `citas_status`
--
ALTER TABLE `citas_status`
  ADD PRIMARY KEY (`cs_id`),
  ADD UNIQUE KEY `cs_id_UNIQUE` (`cs_id`);

--
-- Indices de la tabla `citas_validation`
--
ALTER TABLE `citas_validation`
  ADD PRIMARY KEY (`cv_id`),
  ADD UNIQUE KEY `cv_id_UNIQUE` (`cv_id`);

--
-- Indices de la tabla `civil_estado`
--
ALTER TABLE `civil_estado`
  ADD PRIMARY KEY (`ce_id`),
  ADD UNIQUE KEY `ce_id_UNIQUE` (`ce_id`);

--
-- Indices de la tabla `configuraciones`
--
ALTER TABLE `configuraciones`
  ADD PRIMARY KEY (`cfg_id`);

--
-- Indices de la tabla `departamentos`
--
ALTER TABLE `departamentos`
  ADD PRIMARY KEY (`depto_id`),
  ADD UNIQUE KEY `depto_id_UNIQUE` (`depto_id`);

--
-- Indices de la tabla `emotions`
--
ALTER TABLE `emotions`
  ADD PRIMARY KEY (`e_id`),
  ADD UNIQUE KEY `e_id_UNIQUE` (`e_id`);

--
-- Indices de la tabla `expedientepaciente`
--
ALTER TABLE `expedientepaciente`
  ADD PRIMARY KEY (`expP_id`);

--
-- Indices de la tabla `faq_answers`
--
ALTER TABLE `faq_answers`
  ADD PRIMARY KEY (`fqa_id`),
  ADD UNIQUE KEY `fqa_id_UNIQUE` (`fqa_id`);

--
-- Indices de la tabla `faq_category`
--
ALTER TABLE `faq_category`
  ADD PRIMARY KEY (`fqc_id`),
  ADD UNIQUE KEY `fqc_id_UNIQUE` (`fqc_id`);

--
-- Indices de la tabla `faq_question`
--
ALTER TABLE `faq_question`
  ADD PRIMARY KEY (`fqq_id`),
  ADD UNIQUE KEY `fqq_id_UNIQUE` (`fqq_id`);

--
-- Indices de la tabla `faq_tags`
--
ALTER TABLE `faq_tags`
  ADD PRIMARY KEY (`fqt_id`),
  ADD UNIQUE KEY `fqt_id_UNIQUE` (`fqt_id`);

--
-- Indices de la tabla `frequency`
--
ALTER TABLE `frequency`
  ADD PRIMARY KEY (`f_id`),
  ADD UNIQUE KEY `f_id_UNIQUE` (`f_id`);

--
-- Indices de la tabla `gender`
--
ALTER TABLE `gender`
  ADD PRIMARY KEY (`g_id`),
  ADD UNIQUE KEY `g_id_UNIQUE` (`g_id`);

--
-- Indices de la tabla `menus`
--
ALTER TABLE `menus`
  ADD PRIMARY KEY (`menu_id`);

--
-- Indices de la tabla `nacionalidades`
--
ALTER TABLE `nacionalidades`
  ADD PRIMARY KEY (`nacionalidad_id`);

--
-- Indices de la tabla `newpwd`
--
ALTER TABLE `newpwd`
  ADD PRIMARY KEY (`np_id`);

--
-- Indices de la tabla `patientaddon`
--
ALTER TABLE `patientaddon`
  ADD PRIMARY KEY (`pa_id`),
  ADD UNIQUE KEY `pa_id_UNIQUE` (`pa_id`);

--
-- Indices de la tabla `perfilterapeuta`
--
ALTER TABLE `perfilterapeuta`
  ADD PRIMARY KEY (`pt_id`);

--
-- Indices de la tabla `prueba`
--
ALTER TABLE `prueba`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `puestos`
--
ALTER TABLE `puestos`
  ADD PRIMARY KEY (`puesto_id`);

--
-- Indices de la tabla `reference`
--
ALTER TABLE `reference`
  ADD PRIMARY KEY (`r_id`),
  ADD UNIQUE KEY `r_id_UNIQUE` (`r_id`);

--
-- Indices de la tabla `staff`
--
ALTER TABLE `staff`
  ADD PRIMARY KEY (`st_id`),
  ADD UNIQUE KEY `st_correo` (`st_correo`),
  ADD UNIQUE KEY `st_id_UNIQUE` (`st_id`);

--
-- Indices de la tabla `supportstaff`
--
ALTER TABLE `supportstaff`
  ADD PRIMARY KEY (`sps_id`),
  ADD UNIQUE KEY `sps_id_UNIQUE` (`sps_id`);

--
-- Indices de la tabla `supportstatus`
--
ALTER TABLE `supportstatus`
  ADD PRIMARY KEY (`spe_id`),
  ADD UNIQUE KEY `spe_id_UNIQUE` (`spe_id`);

--
-- Indices de la tabla `supportusr`
--
ALTER TABLE `supportusr`
  ADD PRIMARY KEY (`spu_id`),
  ADD UNIQUE KEY `spu_id_UNIQUE` (`spu_id`);

--
-- Indices de la tabla `testd_emotions`
--
ALTER TABLE `testd_emotions`
  ADD PRIMARY KEY (`tde_id`),
  ADD UNIQUE KEY `tde_id_UNIQUE` (`tde_id`);

--
-- Indices de la tabla `testd_medicine`
--
ALTER TABLE `testd_medicine`
  ADD PRIMARY KEY (`tdm_id`),
  ADD UNIQUE KEY `tdm_id_UNIQUE` (`tdm_id`);

--
-- Indices de la tabla `test_profile`
--
ALTER TABLE `test_profile`
  ADD PRIMARY KEY (`t_id`),
  ADD UNIQUE KEY `t_id_UNIQUE` (`t_id`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`usr_id`),
  ADD UNIQUE KEY `usr_correo` (`usr_correo`),
  ADD UNIQUE KEY `usr_id_UNIQUE` (`usr_id`);

--
-- Indices de la tabla `validatesess`
--
ALTER TABLE `validatesess`
  ADD PRIMARY KEY (`vs_id`);

--
-- Indices de la tabla `validtokens`
--
ALTER TABLE `validtokens`
  ADD PRIMARY KEY (`vt_id`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `accesos`
--
ALTER TABLE `accesos`
  MODIFY `acceso_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `bitacorapaciente`
--
ALTER TABLE `bitacorapaciente`
  MODIFY `bp_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `citas`
--
ALTER TABLE `citas`
  MODIFY `cita_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT de la tabla `citas_communication`
--
ALTER TABLE `citas_communication`
  MODIFY `cc_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `citas_status`
--
ALTER TABLE `citas_status`
  MODIFY `cs_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `citas_validation`
--
ALTER TABLE `citas_validation`
  MODIFY `cv_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT de la tabla `civil_estado`
--
ALTER TABLE `civil_estado`
  MODIFY `ce_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `configuraciones`
--
ALTER TABLE `configuraciones`
  MODIFY `cfg_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `departamentos`
--
ALTER TABLE `departamentos`
  MODIFY `depto_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `emotions`
--
ALTER TABLE `emotions`
  MODIFY `e_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `expedientepaciente`
--
ALTER TABLE `expedientepaciente`
  MODIFY `expP_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `faq_answers`
--
ALTER TABLE `faq_answers`
  MODIFY `fqa_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=45;

--
-- AUTO_INCREMENT de la tabla `faq_category`
--
ALTER TABLE `faq_category`
  MODIFY `fqc_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT de la tabla `faq_question`
--
ALTER TABLE `faq_question`
  MODIFY `fqq_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=44;

--
-- AUTO_INCREMENT de la tabla `faq_tags`
--
ALTER TABLE `faq_tags`
  MODIFY `fqt_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `frequency`
--
ALTER TABLE `frequency`
  MODIFY `f_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `gender`
--
ALTER TABLE `gender`
  MODIFY `g_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `menus`
--
ALTER TABLE `menus`
  MODIFY `menu_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `nacionalidades`
--
ALTER TABLE `nacionalidades`
  MODIFY `nacionalidad_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=246;

--
-- AUTO_INCREMENT de la tabla `newpwd`
--
ALTER TABLE `newpwd`
  MODIFY `np_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `patientaddon`
--
ALTER TABLE `patientaddon`
  MODIFY `pa_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `perfilterapeuta`
--
ALTER TABLE `perfilterapeuta`
  MODIFY `pt_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;

--
-- AUTO_INCREMENT de la tabla `prueba`
--
ALTER TABLE `prueba`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `puestos`
--
ALTER TABLE `puestos`
  MODIFY `puesto_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `reference`
--
ALTER TABLE `reference`
  MODIFY `r_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `staff`
--
ALTER TABLE `staff`
  MODIFY `st_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT de la tabla `supportstaff`
--
ALTER TABLE `supportstaff`
  MODIFY `sps_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT de la tabla `supportstatus`
--
ALTER TABLE `supportstatus`
  MODIFY `spe_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `supportusr`
--
ALTER TABLE `supportusr`
  MODIFY `spu_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT de la tabla `testd_emotions`
--
ALTER TABLE `testd_emotions`
  MODIFY `tde_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `testd_medicine`
--
ALTER TABLE `testd_medicine`
  MODIFY `tdm_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `test_profile`
--
ALTER TABLE `test_profile`
  MODIFY `t_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `usr_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT de la tabla `validatesess`
--
ALTER TABLE `validatesess`
  MODIFY `vs_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT de la tabla `validtokens`
--
ALTER TABLE `validtokens`
  MODIFY `vt_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1006;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
