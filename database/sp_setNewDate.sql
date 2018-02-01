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