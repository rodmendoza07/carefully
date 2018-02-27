USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_checkNewDatesStaff`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_checkNewDatesStaff`(
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

DELIMITER ;

USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_checkNewDatesUsr`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_checkNewDatesUsr`(
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

DELIMITER ;

USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_getAllce`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_getAllce`()
BEGIN
	SELECT
		ce.ce_id
        , ce.ce_desc
	FROM civil_estado ce;
END$$

DELIMITER ;

USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_getAllDates`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_getAllDates`(
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

DELIMITER ;

USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_getAllDatesStaff`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_getAllDatesStaff` (
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

DELIMITER ;

USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_getAllFaqs`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_getAllFaqs` ()
BEGIN
	SELECT
		q.fqq_id AS qId
        , q.fqq_question AS qQuestion
        , a.fqa_id AS aId
        , a.fqa_answer AS aAnswer
    FROM faq_question q
		INNER JOIN faq_answers a ON (q.fqq_id = a.fqa_q_id);
END$$

DELIMITER ;

USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_getAllgender`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_getAllgender` ()
BEGIN
	SELECT
		g.g_id
        , g.g_desc
    FROM gender g;
END$$

DELIMITER ;

USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_getAllNations`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_getAllNations` ()
BEGIN
	SELECT
		n.nacionalidad_id
        , n.nacionalidad_desc
	FROM nacionalidades n;
END$$

DELIMITER ;

USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_getAllPatients`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_getAllPatients`(
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

DELIMITER ;

USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_getBitacoraPaciente`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_getBitacoraPaciente`(
	IN shash VARCHAR(35),
    IN usrId INT
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

DELIMITER ;

USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_getInfoUser`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_getInfoUser`(
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

DELIMITER ;

USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_getMyTherapyStaff`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_getMyTherapyStaff`(
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

DELIMITER ;


USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_getMyTherapyUsr`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_getMyTherapyUsr`(
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

DELIMITER ;



USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_getNewPwd`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_getNewPwd`(
    IN opt INT,
	IN userMail VARCHAR(50),
    IN pwdNew VARCHAR(15),
    IN valHash_ VARCHAR(35)
)
BEGIN
	DECLARE eCounter INT;
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
        SET userEmail = (SELECT usr_correo FROM usuarios WHERE usr_id = userId);
        
        IF userId <> 0 THEN
            
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
            
        ELSE
			SIGNAL SQLSTATE '45000'
				SET message_text = 'Algo ha ido mal, intentalo más tarde.';
        END IF;
	END IF;
END$$

DELIMITER ;

USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_getProfileUsr`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_getProfileUsr`(
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

DELIMITER ;


USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_newUser`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_newUser`(
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

DELIMITER ;

USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_reviewDate`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_reviewDate`(
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

DELIMITER ;

USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_setBitacoraPaciente`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_setBitacoraPaciente`(
	IN shash VARCHAR(35),
    IN usrId INT,
    IN histFam TEXT,
    IN dinFam TEXT,
    IN mc TEXT,
    IN hpa TEXT, 
    IN am TEXT,
	IN psi TEXT,
    IN trauma TEXT,
    IN ps TEXT
)
BEGIN
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

DELIMITER ;
USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_setNewDate`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_setNewDate`(
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

DELIMITER ;

USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_setProfileUsr`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_setProfileUsr` (
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

DELIMITER ;

USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_validateAccount`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_validateAccount`(
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

DELIMITER ;

USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_validateToken`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_validateToken`(
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