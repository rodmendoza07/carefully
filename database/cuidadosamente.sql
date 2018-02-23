-- phpMyAdmin SQL Dump
-- version 4.0.10.18
-- https://www.phpmyadmin.net
--
-- Servidor: localhost:3306
-- Tiempo de generación: 22-02-2018 a las 22:52:12
-- Versión del servidor: 5.6.36-cll-lve
-- Versión de PHP: 5.6.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Base de datos: `cuidadosamente`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`xh2c0lsbptra`@`localhost` PROCEDURE `sp_checkNewDatesStaff`(
	IN shash VARCHAR(35),
    IN opt INT,
    IN cId INT,
    IN cStatus INT,
    IN dStart VARCHAR(20),
    IN dEnd VARCHAR(20)
)
BEGIN
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
		WHERE c.cita_paciente_id = userId
			AND (cv.cv_status = 0 OR cv.cv_status_view = 0);
	
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

CREATE DEFINER=`xh2c0lsbptra`@`localhost` PROCEDURE `sp_checkNewDatesUsr`(
	IN shash VARCHAR(35),
    IN opt INT,
    IN cId INT,
    IN cStatus INT,
    IN dStart VARCHAR(20),
    IN dEnd VARCHAR(20)
)
BEGIN
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

CREATE DEFINER=`xh2c0lsbptra`@`localhost` PROCEDURE `sp_getAllDates`(
	IN token_hash VARCHAR(35)
)
BEGIN
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

CREATE DEFINER=`xh2c0lsbptra`@`localhost` PROCEDURE `sp_getAllDatesStaff`(
	IN token_hash VARCHAR(35)
)
BEGIN
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
			/*COUNT(c.cita_title) AS dateNumber*/
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
        WHERE cita_doctor_id = userId;
	ELSE
		SIGNAL SQLSTATE '45000'
			SET message_text = 'No existen citas.';
    END IF;
END$$

CREATE DEFINER=`xh2c0lsbptra`@`localhost` PROCEDURE `sp_getInfoUser`(
	IN userName VARCHAR(50),
    IN passwd VARCHAR(15)
)
BEGIN
    
    DECLARE passCompare VARCHAR(40);
	DECLARE userId INT;
    DECLARE validAccount INT;
    DECLARE sessToken VARCHAR(40);
    DECLARE previousToken INT;
    DECLARE typeUser TINYINT;
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

CREATE DEFINER=`xh2c0lsbptra`@`localhost` PROCEDURE `sp_getMyTherapyStaff`(
	IN shash VARCHAR(35)
)
BEGIN
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
        WHERE cita_doctor_id = userId;
	ELSE
		SIGNAL SQLSTATE '45000'
			SET message_text = 'Algo ha ido mal, intentelo más tarde.';
    END IF;
    
END$$

CREATE DEFINER=`xh2c0lsbptra`@`localhost` PROCEDURE `sp_getMyTherapyUsr`(
	IN shash VARCHAR(35)
)
BEGIN
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
        WHERE cita_paciente_id = userId;
	ELSE
		SIGNAL SQLSTATE '45000'
			SET message_text = 'Algo ha ido mal, intentelo más tarde.';
    END IF; 
END$$

CREATE DEFINER=`xh2c0lsbptra`@`localhost` PROCEDURE `sp_getNewPwd`(
    IN opt INT,
	IN userMail VARCHAR(50),
    IN pwdNew VARCHAR(15),
    IN valHash_ VARCHAR(35)
)
BEGIN
	DECLARE eCounter INT;
    DECLARE userId INT;
    DECLARE pwdHash VARCHAR(35);
    DECLARE `_rollback` BOOL DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SET `_rollback` = 1;
		ROLLBACK;
        RESIGNAL;
    END;
    
    SET eCounter = (SELECT COUNT(*) FROM usuarios WHERE usr_correo = userMail);
    
    IF opt = -1 THEN
    
		IF eCounter > 0 THEN
			
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
			
		ELSE
			SIGNAL SQLSTATE '45000'
				SET message_text =  'Cuenta inválida.';
		END IF;
        
	ELSEIF opt = -2 THEN
		
        SET userId = (SELECT np_usr_id FROM newPwd WHERE np_hash = valHash_);
		
        START TRANSACTION;
		
        UPDATE usuarios SET
			usr_password = md5(CONCAT((SELECT usr_correo FROM usuarios WHERE usr_id = userId), pwdNew, (SELECT cfg_valor FROM configuraciones WHERE cfg_id = 1)))
		WHERE usr_id = userId;
        
        UPDATE newPwd SET
			np_status = 1
		WHERE np_hash = valHash_;
        
        IF `_rollback` THEN
			SIGNAL SQLSTATE '45000'
				SET message_text = 'Algo ha ido mal, intentalo más tarde.';
		ELSE
			COMMIT;
		END IF;
	END IF;
END$$

CREATE DEFINER=`xh2c0lsbptra`@`localhost` PROCEDURE `sp_getProfileUsr`(
	IN shash VARCHAR(35)
)
BEGIN
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
		CONCAT(usr.usr_nombre, ' ', usr.usr_paterno, ' ', usr.usr_materno) AS nombreUsuario
        , gen.g_desc AS gender
        , na.nacionalidad_desc AS nacionalidad
        , tp.t_age AS age
        , tp.t_birthDate AS birthDate
        , tp.t_civilState AS civilState
        , usr.usr_movil AS phoneContact
        , usr.usr_correo AS email
        , pa.pa_addon AS aditional
    FROM test_profile tp
		INNER JOIN usuarios usr ON (usr.usr_id = tp.t_usr_id)
		LEFT JOIN gender gen ON (gen.g_id = tp.t_gender)
		LEFT JOIN nacionalidades na ON (na.nacionalidad_id = usr.usr_nacionalidad_id)
        LEFT JOIN patientAddon pa ON (pa.pa_usr_id = usr.usr_id)
	WHERE usr.usr_id = userId;
END$$

CREATE DEFINER=`xh2c0lsbptra`@`localhost` PROCEDURE `sp_newUser`(
	IN nombre varchar(40),
    IN ap varchar(100),
    IN correo varchar(50),
    IN pwd varchar(15),
    IN opt int
)
BEGIN
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

CREATE DEFINER=`xh2c0lsbptra`@`localhost` PROCEDURE `sp_reviewDate`(
	IN shash VARCHAR(35),
    IN userType INT,
    IN cId INT
)
BEGIN
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

CREATE DEFINER=`xh2c0lsbptra`@`localhost` PROCEDURE `sp_setNewDate`(
	IN token_hash VARCHAR(35),
    IN dateStart DATETIME,
    IN dateEnd DATETIME,
    IN dateType INT
)
BEGIN
	DECLARE userId INT;
    DECLARE doctorId INT;
    DECLARE compareStart INT;
    DECLARE compareEnd INT;
    DECLARE dates INT;
    DECLARE lastIns INT;
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
			
			IF (SELECT COUNT(*) FROM available_hours WHERE (TIME(dateStart) BETWEEN hh_start AND hh_end) AND hh_status = 1) > 0 && (SELECT COUNT(*) FROM available_hours WHERE (TIME(dateEnd) BETWEEN hh_start AND hh_end) AND hh_status = 1) > 0 THEN
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

CREATE DEFINER=`xh2c0lsbptra`@`localhost` PROCEDURE `sp_setProfileUsr`(
	IN chash VARCHAR(35)
    , IN opt INT
    , IN cName VARCHAR(50)
    , IN gender INT
    , IN birthDate DATETIME
    , IN civilState INT
    , IN contactPhone INT
    , IN aditionalInfo TEXT
)
BEGIN
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

CREATE DEFINER=`xh2c0lsbptra`@`localhost` PROCEDURE `sp_validateAccount`(
	IN codeAccount varchar(50)
)
BEGIN
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

CREATE DEFINER=`xh2c0lsbptra`@`localhost` PROCEDURE `sp_validateToken`(
	IN sessToken VARCHAR(40)
)
BEGIN
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

CREATE TABLE IF NOT EXISTS `accesos` (
  `acceso_id` int(11) NOT NULL AUTO_INCREMENT,
  `nivel_usr` int(11) NOT NULL DEFAULT '0',
  `menu_id` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`acceso_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `available_hours`
--

CREATE TABLE IF NOT EXISTS `available_hours` (
  `hh_id` int(11) NOT NULL AUTO_INCREMENT,
  `hh_start` time DEFAULT NULL,
  `hh_end` time DEFAULT NULL,
  `hh_status` int(11) NOT NULL DEFAULT '1',
  PRIMARY KEY (`hh_id`),
  UNIQUE KEY `hh_id_UNIQUE` (`hh_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=2 ;

--
-- Volcado de datos para la tabla `available_hours`
--

INSERT INTO `available_hours` (`hh_id`, `hh_start`, `hh_end`, `hh_status`) VALUES
(1, '08:00:00', '20:00:00', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `citas`
--

CREATE TABLE IF NOT EXISTS `citas` (
  `cita_id` int(11) NOT NULL AUTO_INCREMENT,
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
  `cita_title` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`cita_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=2 ;

--
-- Volcado de datos para la tabla `citas`
--

INSERT INTO `citas` (`cita_id`, `cita_fecha_start`, `cita_fecha_end`, `cita_paciente_id`, `cita_doctor_id`, `cita_estatus`, `cita_fecha_alta`, `cita_usr_id_alta`, `cita_doctor_id_alta`, `cita_usr_id_update`, `cita_st_update`, `cita_fecha_update`, `cita_fecha_cancelacion`, `cita_usr_id_cancelacion`, `cita_st_id_cancelacion`, `cita_title`) VALUES
(1, '2018-02-12 08:30:00', '2018-02-12 09:20:00', 1, 1, 1, '2018-02-12 12:18:33', 1, 0, 0, 0, NULL, NULL, 0, 0, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `citasEstatus`
--

CREATE TABLE IF NOT EXISTS `citasEstatus` (
  `citaEstatus_id` int(11) NOT NULL AUTO_INCREMENT,
  `citaEstatus_nombre` varchar(45) NOT NULL DEFAULT '',
  `citaEstatus_abreviatura` varchar(5) NOT NULL DEFAULT '',
  `citaEstatus_estatus` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`citaEstatus_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `citas_communication`
--

CREATE TABLE IF NOT EXISTS `citas_communication` (
  `cc_id` int(11) NOT NULL AUTO_INCREMENT,
  `cc_desc` varchar(40) NOT NULL DEFAULT '',
  `cc_createat` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `cc_status` int(11) NOT NULL DEFAULT '1',
  PRIMARY KEY (`cc_id`),
  UNIQUE KEY `cc_id_UNIQUE` (`cc_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=3 ;

--
-- Volcado de datos para la tabla `citas_communication`
--

INSERT INTO `citas_communication` (`cc_id`, `cc_desc`, `cc_createat`, `cc_status`) VALUES
(1, 'Chat', '2018-02-12 12:14:20', 1),
(2, 'Videoconferencia', '2018-02-12 12:14:20', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `citas_status`
--

CREATE TABLE IF NOT EXISTS `citas_status` (
  `cs_id` int(11) NOT NULL AUTO_INCREMENT,
  `cs_desc` varchar(40) NOT NULL DEFAULT '',
  `cs_createat` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `cs_status` int(11) NOT NULL DEFAULT '1',
  `cs_color` varchar(10) NOT NULL DEFAULT '',
  `cs_badge` varchar(45) NOT NULL DEFAULT '',
  PRIMARY KEY (`cs_id`),
  UNIQUE KEY `cs_id_UNIQUE` (`cs_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--
-- Volcado de datos para la tabla `citas_status`
--

INSERT INTO `citas_status` (`cs_id`, `cs_desc`, `cs_createat`, `cs_status`, `cs_color`, `cs_badge`) VALUES
(1, 'Enviada', '2018-02-21 23:52:42', 1, '#29ABE2', 'badge badge-enviado'),
(2, 'Agendada', '2018-02-21 23:52:42', 1, '#8CC63F', 'badge badge-info'),
(3, 'Reprogramada', '2018-02-21 23:52:42', 1, '#FBB03B', 'badge badge-reprogramado'),
(4, 'Cancelada', '2018-02-21 23:52:42', 1, '#F15A24', 'badge badge-cancelado');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `citas_validation`
--

CREATE TABLE IF NOT EXISTS `citas_validation` (
  `cv_id` int(11) NOT NULL AUTO_INCREMENT,
  `cv_c_id` int(11) NOT NULL DEFAULT '0',
  `cv_createat` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `cv_validat` datetime DEFAULT NULL,
  `cv_status` tinyint(4) NOT NULL DEFAULT '0',
  `cv_status_view` tinyint(4) NOT NULL DEFAULT '0',
  `cv_usr_id` int(11) NOT NULL DEFAULT '0',
  `cv_st_id` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`cv_id`),
  UNIQUE KEY `cv_id_UNIQUE` (`cv_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `civil_estado`
--

CREATE TABLE IF NOT EXISTS `civil_estado` (
  `ce_id` int(11) NOT NULL AUTO_INCREMENT,
  `ce_desc` varchar(45) NOT NULL DEFAULT '',
  `ce_createat` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ce_status` int(11) NOT NULL DEFAULT '1',
  PRIMARY KEY (`ce_id`),
  UNIQUE KEY `ce_id_UNIQUE` (`ce_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=6 ;

--
-- Volcado de datos para la tabla `civil_estado`
--

INSERT INTO `civil_estado` (`ce_id`, `ce_desc`, `ce_createat`, `ce_status`) VALUES
(1, 'Soltero', '2018-02-22 00:09:51', 1),
(2, 'Casado', '2018-02-22 00:09:51', 1),
(3, 'Divorciado', '2018-02-22 00:09:51', 1),
(4, 'Unión libre', '2018-02-22 00:09:51', 1),
(5, 'Otro', '2018-02-22 00:09:51', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `conceptosEC`
--

CREATE TABLE IF NOT EXISTS `conceptosEC` (
  `concepto_id` int(11) NOT NULL AUTO_INCREMENT,
  `concepto_descripcion` varchar(45) NOT NULL DEFAULT '',
  `concepto_abreviatura` varchar(5) NOT NULL DEFAULT '',
  `concepto_naturaleza` int(11) NOT NULL DEFAULT '0',
  `concepto_estatus` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`concepto_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `configuraciones`
--

CREATE TABLE IF NOT EXISTS `configuraciones` (
  `cfg_id` int(11) NOT NULL AUTO_INCREMENT,
  `cfg_nombre` varchar(45) NOT NULL DEFAULT '',
  `cfg_valor` varchar(100) NOT NULL DEFAULT '',
  `cfg_estatus` tinyint(4) NOT NULL DEFAULT '1' COMMENT 'Configuraciones generales de la aplicación:\n\nInicio de Consultas\nTermino de Consultar\n\nCorreo de Envió de mails etc',
  `cfg_fecha_alta` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `cfg_usr_id_alta` int(11) NOT NULL DEFAULT '0',
  `cfg_fecha_cancelacion` datetime DEFAULT NULL,
  `cfg_usr_id_cancelacion` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`cfg_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=2 ;

--
-- Volcado de datos para la tabla `configuraciones`
--

INSERT INTO `configuraciones` (`cfg_id`, `cfg_nombre`, `cfg_valor`, `cfg_estatus`, `cfg_fecha_alta`, `cfg_usr_id_alta`, `cfg_fecha_cancelacion`, `cfg_usr_id_cancelacion`) VALUES
(1, 'secret', 'Uncarefully', 1, '2018-01-03 10:11:07', 0, NULL, 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `curricula`
--

CREATE TABLE IF NOT EXISTS `curricula` (
  `curricula_id` int(11) NOT NULL AUTO_INCREMENT,
  `usr_id` int(11) NOT NULL DEFAULT '0',
  `estudios_id` int(11) NOT NULL DEFAULT '0',
  `curricula_institucion` varchar(100) NOT NULL DEFAULT '',
  `curricula_inicial` varchar(6) NOT NULL DEFAULT '',
  `curricula_final` varchar(6) NOT NULL DEFAULT '',
  `curricula_fecha_alta` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `curricula_usr_id_alta` int(11) NOT NULL DEFAULT '0',
  `curricula_fecha_actualizacion` int(11) DEFAULT NULL,
  `curricula_usr_id_actualizacion` int(11) NOT NULL DEFAULT '0',
  `curricula_estatus` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`curricula_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `departamentos`
--

CREATE TABLE IF NOT EXISTS `departamentos` (
  `depto_id` int(11) NOT NULL AUTO_INCREMENT,
  `depto_nombre` varchar(45) NOT NULL DEFAULT '',
  `depto_abreviatura` varchar(5) NOT NULL DEFAULT '',
  `depto_responsable` int(11) NOT NULL DEFAULT '0',
  `depto_fecha_alta` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `depto_usr_id_alta` int(11) NOT NULL DEFAULT '0',
  `depto_fecha_actualizacion` datetime DEFAULT CURRENT_TIMESTAMP,
  `depto_usr_id_actualizacion` int(11) NOT NULL DEFAULT '0',
  `depto_estatus` tinyint(4) DEFAULT '1',
  PRIMARY KEY (`depto_id`),
  UNIQUE KEY `depto_id_UNIQUE` (`depto_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=4 ;

--
-- Volcado de datos para la tabla `departamentos`
--

INSERT INTO `departamentos` (`depto_id`, `depto_nombre`, `depto_abreviatura`, `depto_responsable`, `depto_fecha_alta`, `depto_usr_id_alta`, `depto_fecha_actualizacion`, `depto_usr_id_actualizacion`, `depto_estatus`) VALUES
(1, 'admin', 'admin', 0, '2018-01-03 10:11:07', 0, '2018-01-03 10:11:07', 0, 1),
(2, 'paciente', 'pacie', 0, '2018-01-03 10:11:07', 0, '2018-01-03 10:11:07', 0, 1),
(3, 'terapia', 'terap', 0, '2018-01-03 10:11:07', 0, '2018-01-03 10:11:07', 0, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `emotions`
--

CREATE TABLE IF NOT EXISTS `emotions` (
  `e_id` int(11) NOT NULL AUTO_INCREMENT,
  `e_desc` varchar(45) NOT NULL DEFAULT '',
  `e_createat` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `e_status` int(11) NOT NULL DEFAULT '1',
  PRIMARY KEY (`e_id`),
  UNIQUE KEY `e_id_UNIQUE` (`e_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=11 ;

--
-- Volcado de datos para la tabla `emotions`
--

INSERT INTO `emotions` (`e_id`, `e_desc`, `e_createat`, `e_status`) VALUES
(1, 'Miedo', '2018-02-22 00:09:51', 1),
(2, 'Culpa', '2018-02-22 00:09:51', 1),
(3, 'Vergüenza', '2018-02-22 00:09:51', 1),
(4, 'Frustración', '2018-02-22 00:09:51', 1),
(5, 'Arrepentimiento', '2018-02-22 00:09:51', 1),
(6, 'Celos', '2018-02-22 00:09:51', 1),
(7, 'Inseguridad', '2018-02-22 00:09:51', 1),
(8, 'Desinterés', '2018-02-22 00:09:51', 1),
(9, 'Envídia', '2018-02-22 00:09:51', 1),
(10, 'Dolor', '2018-02-22 00:09:51', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `estadoCuenta`
--

CREATE TABLE IF NOT EXISTS `estadoCuenta` (
  `ec_id` int(11) NOT NULL AUTO_INCREMENT,
  `ec_paciente_id` int(11) NOT NULL DEFAULT '0',
  `ec_concepto_id` int(11) NOT NULL DEFAULT '0',
  `ec_referencia` varchar(45) NOT NULL DEFAULT '',
  `ec_importe` decimal(18,2) NOT NULL DEFAULT '0.00',
  `ec_fecha` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ec_usr_id_alta` int(11) NOT NULL DEFAULT '0',
  `ec_estatus` tinyint(4) NOT NULL DEFAULT '1',
  `ec_fecha_cancelacion` datetime DEFAULT NULL,
  `ec_usr_id_cancelacion` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`ec_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `estudios`
--

CREATE TABLE IF NOT EXISTS `estudios` (
  `estudios_id` int(11) NOT NULL AUTO_INCREMENT,
  `estudios_nombre` varchar(45) NOT NULL DEFAULT '',
  `estudios_fecha_alta` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `estudios_usr_id_alta` int(11) NOT NULL DEFAULT '0',
  `estudios_fecha_actualizacion` datetime DEFAULT NULL,
  `estudios_usr_id_actualizacion` int(11) NOT NULL DEFAULT '0',
  `estudios_estatus` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`estudios_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `expedientepaciente`
--

CREATE TABLE IF NOT EXISTS `expedientepaciente` (
  `expP_id` int(11) NOT NULL AUTO_INCREMENT,
  `expP_fecha_alta` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expP_doctor_id` int(11) NOT NULL DEFAULT '0',
  `expP_paciente_id` int(11) NOT NULL DEFAULT '0',
  `expP_estatus` tinyint(4) NOT NULL DEFAULT '1',
  `expP_usr_id_alta` int(11) NOT NULL DEFAULT '0',
  `expP_fecha_cancelacion` datetime DEFAULT CURRENT_TIMESTAMP,
  `expP_usr_id_cancelacion` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`expP_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=2 ;

--
-- Volcado de datos para la tabla `expedientepaciente`
--

INSERT INTO `expedientepaciente` (`expP_id`, `expP_fecha_alta`, `expP_doctor_id`, `expP_paciente_id`, `expP_estatus`, `expP_usr_id_alta`, `expP_fecha_cancelacion`, `expP_usr_id_cancelacion`) VALUES
(1, '2018-02-09 08:16:39', 1, 1, 1, 0, '2018-02-09 08:16:39', 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `expedientePacienteConceptos`
--

CREATE TABLE IF NOT EXISTS `expedientePacienteConceptos` (
  `expPC_id` int(11) NOT NULL AUTO_INCREMENT,
  `expPC_nombre` varchar(45) NOT NULL DEFAULT '',
  `expPC_estatus` tinyint(4) NOT NULL DEFAULT '1',
  `expPC_fecha_alta` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expPC_usr_id_alta` int(11) NOT NULL DEFAULT '0',
  `expPC_fecha_cancelacion` datetime DEFAULT NULL,
  `expPC_usr_id_cancelacion` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`expPC_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `expedientePacienteDetalle`
--

CREATE TABLE IF NOT EXISTS `expedientePacienteDetalle` (
  `expPD_id` int(11) NOT NULL AUTO_INCREMENT,
  `expP_id` int(11) NOT NULL DEFAULT '0',
  `expPC_id` int(11) NOT NULL DEFAULT '0',
  `expPD_estatus` tinyint(4) NOT NULL DEFAULT '1',
  `expPD_fecha_alta` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expPD_usr_id_alta` int(11) NOT NULL DEFAULT '0',
  `expPD_fecha_cancelacion` datetime DEFAULT NULL,
  `expPD_usr_id_cancelacion` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`expPD_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `experienciaProfesional`
--

CREATE TABLE IF NOT EXISTS `experienciaProfesional` (
  `expProf_id` int(11) NOT NULL AUTO_INCREMENT,
  `expProf_usr_id` int(11) DEFAULT '0',
  `expProf_institucion` varchar(100) NOT NULL DEFAULT '',
  `expProf_inicio` varchar(6) NOT NULL DEFAULT '',
  `expProf_fin` varchar(6) NOT NULL DEFAULT '',
  `expProf_descripcion` varchar(1000) NOT NULL DEFAULT '',
  `expProf_jefe` varchar(45) NOT NULL DEFAULT '',
  `expProf_telefono` varchar(20) NOT NULL DEFAULT '',
  `expProf_fecha_alta` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expProf_usr_id_alta` int(11) NOT NULL DEFAULT '0',
  `expProf_fecha_actualizacion` datetime DEFAULT NULL,
  `expProf_usr_id_actualizacion` int(11) NOT NULL DEFAULT '0',
  `expProf_estatus` int(11) NOT NULL DEFAULT '1',
  PRIMARY KEY (`expProf_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `frequency`
--

CREATE TABLE IF NOT EXISTS `frequency` (
  `f_id` int(11) NOT NULL AUTO_INCREMENT,
  `f_desc` varchar(45) NOT NULL DEFAULT '',
  `f_createat` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `f_status` int(11) NOT NULL DEFAULT '1',
  PRIMARY KEY (`f_id`),
  UNIQUE KEY `f_id_UNIQUE` (`f_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=5 ;

--
-- Volcado de datos para la tabla `frequency`
--

INSERT INTO `frequency` (`f_id`, `f_desc`, `f_createat`, `f_status`) VALUES
(1, 'Nunca', '2018-02-22 00:09:51', 1),
(2, 'Varios días', '2018-02-22 00:09:51', 1),
(3, 'La mitad de los días', '2018-02-22 00:09:51', 1),
(4, 'Casí todos los días', '2018-02-22 00:09:51', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `gender`
--

CREATE TABLE IF NOT EXISTS `gender` (
  `g_id` int(11) NOT NULL AUTO_INCREMENT,
  `g_desc` varchar(45) NOT NULL DEFAULT '',
  `g_createat` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `g_status` int(11) NOT NULL DEFAULT '1',
  PRIMARY KEY (`g_id`),
  UNIQUE KEY `g_id_UNIQUE` (`g_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=4 ;

--
-- Volcado de datos para la tabla `gender`
--

INSERT INTO `gender` (`g_id`, `g_desc`, `g_createat`, `g_status`) VALUES
(1, 'Femenino', '2018-02-22 00:09:51', 1),
(2, 'Masculino', '2018-02-22 00:09:51', 1),
(3, 'Otro', '2018-02-22 00:09:51', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `horariosDoctores`
--

CREATE TABLE IF NOT EXISTS `horariosDoctores` (
  `horario_id` int(11) NOT NULL AUTO_INCREMENT,
  `horario_dia` int(11) NOT NULL DEFAULT '0',
  `horario_inicia` varchar(5) NOT NULL DEFAULT '',
  `horario_termina` varchar(5) NOT NULL DEFAULT '',
  `horario_estatus` tinyint(4) NOT NULL DEFAULT '1',
  `horario_fecha_alta` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `horario_usr_id_alta` int(11) NOT NULL DEFAULT '0',
  `horario_fecha_cancelacion` datetime DEFAULT NULL,
  `horario_usr_id_cancelacion` int(11) DEFAULT '0',
  PRIMARY KEY (`horario_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `menus`
--

CREATE TABLE IF NOT EXISTS `menus` (
  `menu_id` int(11) NOT NULL AUTO_INCREMENT,
  `menu_descripcion` varchar(45) NOT NULL DEFAULT '',
  `menu_parent` int(11) NOT NULL DEFAULT '0',
  `menu_url` varchar(100) NOT NULL DEFAULT '',
  `menu_estatus` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`menu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `nacionalidades`
--

CREATE TABLE IF NOT EXISTS `nacionalidades` (
  `nacionalidad_id` int(11) NOT NULL AUTO_INCREMENT,
  `nacionalidad_desc` varchar(45) NOT NULL DEFAULT '',
  `nacionalidad_abreviatura` varchar(45) NOT NULL DEFAULT '',
  `nacionalidad_estatus` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`nacionalidad_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `newPwd`
--

CREATE TABLE IF NOT EXISTS `newPwd` (
  `np_id` int(11) NOT NULL AUTO_INCREMENT,
  `np_createat` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `np_usr_id` int(11) NOT NULL DEFAULT '0',
  `np_hash` varchar(50) NOT NULL DEFAULT '',
  `vt_status` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`np_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=26 ;

--
-- Volcado de datos para la tabla `newPwd`
--

INSERT INTO `newPwd` (`np_id`, `np_createat`, `np_usr_id`, `np_hash`, `vt_status`) VALUES
(1, '2018-01-05 16:29:11', 1, '724b886f0f4c75d1a38fa4f8d112c741', 0),
(2, '2018-01-05 16:30:04', 1, 'f6f43ddf2db7040eb49da543a16b783c', 0),
(3, '2018-01-05 16:31:01', 1, '06fb7b4bf90b5f2d08d953555b41d8d8', 0),
(4, '2018-01-05 16:31:10', 1, 'be941d6a2da294b61fe6b1da215e9b3b', 0),
(5, '2018-01-05 16:32:59', 1, '282a971bf54b74a174b818fab415fe11', 0),
(6, '2018-01-05 16:33:26', 1, 'd1cb0ff420ffaf2b13677466167e7689', 0),
(7, '2018-01-05 16:40:16', 1, 'af9066373b90b12fc103f54ce860f217', 0),
(8, '2018-01-05 16:48:09', 1, 'c18d77019c59035ea7010941ee42431b', 0),
(9, '2018-01-05 16:49:35', 1, 'd9a9573c06a87dcabdabc3debde67fbf', 0),
(10, '2018-01-05 16:49:47', 1, '9e246e3cd561df638ae36f982139e654', 0),
(11, '2018-01-05 16:52:48', 1, 'af9fb0001dd96d718f62b5b79070fcfc', 0),
(12, '2018-01-07 11:44:22', 1, 'adba4b28b890fb00491e5c6b53713028', 0),
(13, '2018-01-07 11:47:26', 1, '3c29fb7028eb587cd65220be4855bdd9', 0),
(14, '2018-01-07 12:00:24', 1, '0c5acd8978fe601c0225f3de461fe384', 0),
(15, '2018-01-07 12:02:30', 1, '12c6178e0db91c55540ab23ed055cc5d', 0),
(16, '2018-01-07 12:06:02', 1, '36f69e6055903248807083f23c479e14', 0),
(17, '2018-01-07 12:06:39', 1, '9277f00736c939a7d399ded562799633', 0),
(18, '2018-01-07 12:08:10', 1, '351778d7efae1f5b53613e1495cfa560', 0),
(19, '2018-01-07 12:10:52', 1, 'fab2d4e871de962377aafc2aa287b388', 0),
(20, '2018-01-07 12:22:18', 1, '85d73950f0f597031b8975b3b09e19b9', 0),
(21, '2018-01-07 12:22:18', 1, '85d73950f0f597031b8975b3b09e19b9', 0),
(22, '2018-01-07 12:22:46', 1, 'cf4241d74b157382995c7122fdb84547', 0),
(23, '2018-01-07 12:23:59', 1, '47354204ede7bcb66a5b841f0a80e1d5', 0),
(24, '2018-01-22 19:48:59', 7, 'f595b42348424e565a918b923795d93f', 0),
(25, '2018-02-12 13:06:27', 7, '7682c8ec907d295016685e30fcd2a4be', 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `nivelesUsuario`
--

CREATE TABLE IF NOT EXISTS `nivelesUsuario` (
  `nivelUsr_id` int(11) NOT NULL AUTO_INCREMENT,
  `nivelUsr_descripcion` varchar(45) NOT NULL DEFAULT '',
  `nivelUsr_estatus` tinyint(4) NOT NULL DEFAULT '1',
  `nivelUsr_fecha_alta` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `nivelUsr_usr_id_alta` int(11) NOT NULL DEFAULT '0',
  `nivelUsr_fecha_cancelacion` datetime DEFAULT NULL,
  `nivelUsr_usr_id_cancelacion` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`nivelUsr_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pagosDetalle`
--

CREATE TABLE IF NOT EXISTS `pagosDetalle` (
  `pagoD_id` int(11) NOT NULL AUTO_INCREMENT,
  `pagoD_fecha` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `pagoD_ec_id` int(11) NOT NULL DEFAULT '0',
  `pagoD_tipoPago_id` int(11) NOT NULL DEFAULT '0',
  `pagoD_autorizacion` varchar(45) NOT NULL DEFAULT '',
  `pagoD_fecha_alta` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `pagoD_usr_id_alta` int(11) NOT NULL DEFAULT '0',
  `pagoD_fecha_cancelacion` datetime DEFAULT NULL,
  `pagoD_usr_id_cancelacion` int(11) NOT NULL DEFAULT '0',
  `pagoD_estatus` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`pagoD_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `patientAddon`
--

CREATE TABLE IF NOT EXISTS `patientAddon` (
  `pa_id` int(11) NOT NULL AUTO_INCREMENT,
  `pa_usr_id` int(11) NOT NULL DEFAULT '0',
  `pa_addon` text NOT NULL,
  `pa_createat` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `pa_updateat` datetime DEFAULT NULL,
  PRIMARY KEY (`pa_id`),
  UNIQUE KEY `pa_id_UNIQUE` (`pa_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `puestos`
--

CREATE TABLE IF NOT EXISTS `puestos` (
  `puesto_id` int(11) NOT NULL AUTO_INCREMENT,
  `puesto_descripcion` varchar(45) NOT NULL DEFAULT '',
  `puesto_estatus` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`puesto_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=4 ;

--
-- Volcado de datos para la tabla `puestos`
--

INSERT INTO `puestos` (`puesto_id`, `puesto_descripcion`, `puesto_estatus`) VALUES
(1, 'admin', 1),
(2, 'paciente', 1),
(3, 'terapeuta', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `reference`
--

CREATE TABLE IF NOT EXISTS `reference` (
  `r_id` int(11) NOT NULL AUTO_INCREMENT,
  `r_desc` varchar(45) NOT NULL DEFAULT '',
  `r_createat` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `r_status` int(11) NOT NULL DEFAULT '1',
  PRIMARY KEY (`r_id`),
  UNIQUE KEY `r_id_UNIQUE` (`r_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=9 ;

--
-- Volcado de datos para la tabla `reference`
--

INSERT INTO `reference` (`r_id`, `r_desc`, `r_createat`, `r_status`) VALUES
(1, 'Un amigo o falimiar', '2018-02-22 00:09:51', 1),
(2, 'Mi doctor', '2018-02-22 00:09:51', 1),
(3, 'Busqué en internet', '2018-02-22 00:09:51', 1),
(4, 'Vi un anuncio', '2018-02-22 00:09:51', 1),
(5, 'Redes sociales', '2018-02-22 00:09:51', 1),
(6, 'En un artículo', '2018-02-22 00:09:51', 1),
(7, 'Medios de comunicación (radio/tv)', '2018-02-22 00:09:51', 1),
(8, 'Otro', '2018-02-22 00:09:51', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `staff`
--

CREATE TABLE IF NOT EXISTS `staff` (
  `st_id` int(11) NOT NULL AUTO_INCREMENT,
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
  `st_usr_id_cancelacion` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`st_id`),
  UNIQUE KEY `st_correo` (`st_correo`),
  UNIQUE KEY `st_id_UNIQUE` (`st_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=2 ;

--
-- Volcado de datos para la tabla `staff`
--

INSERT INTO `staff` (`st_id`, `st_nombre`, `st_paterno`, `st_materno`, `st_departamento_id`, `st_puesto_id`, `st_nivelUsr_id`, `st_login`, `st_password`, `st_nacionalidad_id`, `st_correo`, `st_casa`, `st_movil`, `st_estatus`, `st_fecha_alta`, `st_usr_id_alta`, `st_fecha_actualizacion`, `st_usr_id_actualizacion`, `st_fecha_cancelacion`, `st_usr_id_cancelacion`) VALUES
(1, 'Sara', 'Beneyto', '', 3, 3, 0, 'sara@cuidadosamente.com', '2eac05d3927bee279984fcfd02a2e8cd', NULL, 'sara@cuidadosamente.com', '55-0000-0000', '55-0000-0000', 1, '2018-02-09 07:46:48', 0, '2018-02-09 07:46:48', 0, NULL, 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `testD_emotions`
--

CREATE TABLE IF NOT EXISTS `testD_emotions` (
  `tde_id` int(11) NOT NULL AUTO_INCREMENT,
  `tde_emotion_id` int(11) NOT NULL DEFAULT '0',
  `tde_createat` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`tde_id`),
  UNIQUE KEY `tde_id_UNIQUE` (`tde_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `testD_medicine`
--

CREATE TABLE IF NOT EXISTS `testD_medicine` (
  `tdm_id` int(11) NOT NULL AUTO_INCREMENT,
  `tdm_emotion_id` int(11) NOT NULL DEFAULT '0',
  `tdm_createat` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`tdm_id`),
  UNIQUE KEY `tdm_id_UNIQUE` (`tdm_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `test_profile`
--

CREATE TABLE IF NOT EXISTS `test_profile` (
  `t_id` int(11) NOT NULL AUTO_INCREMENT,
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
  `t_civilState` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`t_id`),
  UNIQUE KEY `t_id_UNIQUE` (`t_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=2 ;

--
-- Volcado de datos para la tabla `test_profile`
--

INSERT INTO `test_profile` (`t_id`, `t_usr_id`, `t_gender`, `t_birthdate`, `t_age`, `t_service`, `t_therapyBefore`, `t_health`, `t_sleep`, `t_emotion_freq`, `t_anxiety`, `t_relationship`, `t_relationship_freq`, `t_reference`, `t_civilState`) VALUES
(1, 1, 2, '1987-04-11 00:00:00', 30, 5, 0, 2, 3, 1, 1, 4, 1, 5, 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tiposPago`
--

CREATE TABLE IF NOT EXISTS `tiposPago` (
  `tipoPago_id` int(11) NOT NULL AUTO_INCREMENT,
  `tipoPago_descripcion` varchar(45) NOT NULL DEFAULT '',
  `tipoPago_abreviatura` varchar(10) NOT NULL DEFAULT '',
  `tipoPago_estatus` tinyint(4) NOT NULL DEFAULT '1',
  `tipoPago_fecha_alta` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tipoPago_usr_id_alta` int(11) NOT NULL DEFAULT '0',
  `tipoPago_fecha_cancelacion` datetime DEFAULT CURRENT_TIMESTAMP,
  `tipoPago_usr_id_cancelacion` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`tipoPago_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE IF NOT EXISTS `usuarios` (
  `usr_id` int(11) NOT NULL AUTO_INCREMENT,
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
  `usr_usr_id_cancelacion` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`usr_id`),
  UNIQUE KEY `usr_correo` (`usr_correo`),
  UNIQUE KEY `usr_id_UNIQUE` (`usr_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=14 ;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`usr_id`, `usr_nombre`, `usr_paterno`, `usr_materno`, `usr_departamento_id`, `usr_puesto_id`, `usr_nivelUsr_id`, `usr_login`, `usr_password`, `usr_nacionalidad_id`, `usr_correo`, `usr_casa`, `usr_movil`, `usr_estatus`, `usr_fecha_alta`, `usr_usr_id_alta`, `usr_fecha_actualizacion`, `usr_usr_id_actualizacion`, `usr_fecha_cancelacion`, `usr_usr_id_cancelacion`) VALUES
(1, 'Rodrigo', 'Mendoza', '', 2, 2, 1, 'lr.mendozar@gmail.com', 'e62180490b281461ebdf3e48e9f2c483', NULL, 'lr.mendozar@gmail.com', '55-0000-0000', '55-0000-0000', 1, '2018-01-03 10:19:15', 0, '2018-01-03 10:19:15', 0, NULL, 0),
(2, 'Sara', 'Hernandez', '', 2, 2, 1, 'minks_stm@hotmail.com', '9dec735ba08a651fec7f382de088855f', NULL, 'minks_stm@hotmail.com', '55-0000-0000', '55-0000-0000', 1, '2018-01-03 14:41:26', 0, '2018-01-03 14:41:26', 0, NULL, 0),
(3, 'Rod', 'Mendoza', '', 2, 2, 1, 'lr.mendozar@me.com', '6fd3feab04a9254a73e05dae64d854e5', NULL, 'lr.mendozar@me.com', '55-0000-0000', '55-0000-0000', 1, '2018-01-07 12:30:05', 0, '2018-01-07 12:30:05', 0, NULL, 0),
(6, 'Rod', 'Mendoza', '', 2, 2, 1, 'lr.mendozar@icloud.com', '68b418734fc0b52c527fb99900112f20', NULL, 'lr.mendozar@icloud.com', '55-0000-0000', '55-0000-0000', 1, '2018-01-08 10:59:13', 0, '2018-01-08 10:59:13', 0, NULL, 0),
(7, 'Sara', 'Perez', '', 2, 2, 1, 'Sbeneytoperez@hotmail.com', '944d645d5c4a425e703a56706825d3bf', NULL, 'Sbeneytoperez@hotmail.com', '55-0000-0000', '55-0000-0000', 1, '2018-01-10 09:53:27', 0, '2018-01-10 09:53:27', 0, NULL, 0),
(8, 'Sara', 'Beneyti', '', 2, 2, 1, 'Sbeneytoperez@hoymail.com', 'd7d883a61c703c7c80255686b0f9d196', NULL, 'Sbeneytoperez@hoymail.com', '55-0000-0000', '55-0000-0000', 1, '2018-01-14 09:45:03', 0, '2018-01-14 09:45:03', 0, NULL, 0),
(9, 'Mera', 'Perez', '', 2, 2, 1, 'Redpsicologosenlinea@hotmail.com', '4d98c4c7ccb2edde39b167a0da3af271', NULL, 'Redpsicologosenlinea@hotmail.com', '55-0000-0000', '55-0000-0000', 1, '2018-01-14 09:46:32', 0, '2018-01-14 09:46:32', 0, NULL, 0),
(11, 'SARA', 'beneyto', '', 2, 2, 1, 'terapiacuidadosamente@gmail.com', 'd2ed2f285b1526c248cbe5738ade5bfa', NULL, 'terapiacuidadosamente@gmail.com', '55-0000-0000', '55-0000-0000', 1, '2018-02-12 13:20:25', 0, '2018-02-12 13:20:25', 0, NULL, 0),
(12, 'juan', 'carlos', '', 2, 2, 1, 'jccarrerap@hotmail.com', '10f76a2b1f05ad8205c200b278bb1354', NULL, 'jccarrerap@hotmail.com', '55-0000-0000', '55-0000-0000', 1, '2018-02-16 19:20:26', 0, '2018-02-16 19:20:26', 0, NULL, 0),
(13, 'Marco', 'Garcia', '', 2, 2, 1, 'morozc0@hotmail.com', '4ec2377ab8ba4d53f28fd59d6bd2ee4c', NULL, 'morozc0@hotmail.com', '55-0000-0000', '55-0000-0000', 1, '2018-02-19 10:35:55', 0, '2018-02-19 10:35:55', 0, NULL, 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `validateSess`
--

CREATE TABLE IF NOT EXISTS `validateSess` (
  `vs_id` int(11) NOT NULL AUTO_INCREMENT,
  `vs_createat` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `vs_usr_id` int(11) NOT NULL DEFAULT '0',
  `vs_st_id` int(11) NOT NULL DEFAULT '0',
  `vs_hash` varchar(50) NOT NULL DEFAULT '',
  `vs_status` int(11) NOT NULL DEFAULT '0',
  `vs_activateat` datetime DEFAULT NULL,
  PRIMARY KEY (`vs_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=12 ;

--
-- Volcado de datos para la tabla `validateSess`
--

INSERT INTO `validateSess` (`vs_id`, `vs_createat`, `vs_usr_id`, `vs_st_id`, `vs_hash`, `vs_status`, `vs_activateat`) VALUES
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
(11, '2018-02-19 10:35:55', 13, 0, 'f4620228dfe155ff8cc4c3b81f49a127', 1, '2018-02-19 10:38:19');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `validtokens`
--

CREATE TABLE IF NOT EXISTS `validtokens` (
  `vt_id` int(11) NOT NULL AUTO_INCREMENT,
  `vt_createat` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `vt_usr_id` int(11) NOT NULL DEFAULT '0',
  `vt_st_id` int(11) NOT NULL DEFAULT '0',
  `vt_hash` varchar(50) NOT NULL DEFAULT '',
  `vt_status` int(11) NOT NULL DEFAULT '1',
  PRIMARY KEY (`vt_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=32 ;

--
-- Volcado de datos para la tabla `validtokens`
--

INSERT INTO `validtokens` (`vt_id`, `vt_createat`, `vt_usr_id`, `vt_st_id`, `vt_hash`, `vt_status`) VALUES
(1, '2018-02-09 07:50:45', 1, 0, 'cc82d044fe993d83e04adfa3b627d620', 0),
(2, '2018-02-09 07:55:36', 1, 0, 'cc82d044fe993d83e04adfa3b627d620', 0),
(3, '2018-02-09 08:23:24', 0, 1, '53f6c1c6186477ee19437e7d24f3ec28', 0),
(4, '2018-02-09 10:05:58', 1, 0, 'cc82d044fe993d83e04adfa3b627d620', 0),
(5, '2018-02-09 10:06:55', 1, 0, 'cc82d044fe993d83e04adfa3b627d620', 0),
(6, '2018-02-09 10:07:12', 1, 0, 'cc82d044fe993d83e04adfa3b627d620', 0),
(7, '2018-02-09 10:08:24', 1, 0, 'cc82d044fe993d83e04adfa3b627d620', 0),
(8, '2018-02-09 10:11:07', 1, 0, 'cc82d044fe993d83e04adfa3b627d620', 0),
(9, '2018-02-09 10:11:29', 1, 0, 'cc82d044fe993d83e04adfa3b627d620', 0),
(10, '2018-02-12 12:17:07', 1, 0, '3075d2a28fd76aca5bf8e1ce664abe45', 0),
(11, '2018-02-12 12:21:45', 1, 0, '3075d2a28fd76aca5bf8e1ce664abe45', 0),
(12, '2018-02-12 13:21:56', 11, 0, '41d25fe4f3c66842b7a59e0f43a2843d', 0),
(13, '2018-02-12 13:29:40', 11, 0, '41d25fe4f3c66842b7a59e0f43a2843d', 1),
(14, '2018-02-12 13:32:46', 0, 1, '7b26d8074badffb661fea48594579c8b', 0),
(15, '2018-02-13 21:53:36', 0, 1, 'b57037676b35f32b5ee517fccf2101f4', 0),
(16, '2018-02-16 19:21:59', 12, 0, '53e98683f16a8efd590ddd7f02ed65cf', 0),
(17, '2018-02-16 19:26:31', 12, 0, '53e98683f16a8efd590ddd7f02ed65cf', 0),
(18, '2018-02-19 10:42:35', 13, 0, 'fd034735a2d8a382b11da7d379fba191', 0),
(19, '2018-02-19 17:17:47', 13, 0, 'fd034735a2d8a382b11da7d379fba191', 0),
(20, '2018-02-19 17:17:57', 13, 0, 'fd034735a2d8a382b11da7d379fba191', 1),
(21, '2018-02-20 18:39:37', 12, 0, 'bac09316f0d196dd3900ed3796a437cc', 0),
(22, '2018-02-22 00:12:11', 0, 1, '391619f2f1492d11d7bcca9ebadf5d75', 0),
(23, '2018-02-22 00:21:32', 1, 0, 'edf5aa9f3692a0e6a36290423ce6a2ce', 0),
(24, '2018-02-22 00:22:07', 0, 1, '391619f2f1492d11d7bcca9ebadf5d75', 0),
(25, '2018-02-22 17:14:36', 12, 0, '2197afb84a8e5b0e69956cf26422fa29', 0),
(26, '2018-02-22 17:15:55', 12, 0, '2197afb84a8e5b0e69956cf26422fa29', 0),
(27, '2018-02-22 17:40:22', 1, 0, 'edf5aa9f3692a0e6a36290423ce6a2ce', 1),
(28, '2018-02-22 17:40:45', 0, 1, '391619f2f1492d11d7bcca9ebadf5d75', 1),
(29, '2018-02-22 18:35:48', 12, 0, '2197afb84a8e5b0e69956cf26422fa29', 0),
(30, '2018-02-22 19:58:11', 12, 0, '2197afb84a8e5b0e69956cf26422fa29', 0),
(31, '2018-02-22 22:51:27', 12, 0, '0c1ba159a64fa5d7bdfb5f3db2da03c5', 1);

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
