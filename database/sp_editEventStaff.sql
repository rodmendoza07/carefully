USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_editEventStaff`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_editEventStaff` (
	IN shash VARCHAR(35),
    IN dStart DATETIME,
    IN dEnd DATETIME,
    IN optEdit INT,
    IN dateStartOld DATETIME
)
BEGIN
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

DELIMITER ;