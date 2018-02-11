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