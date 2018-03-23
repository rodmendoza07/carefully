USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_blockDoctorDates`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_blockDoctorDates`(
	IN shash VARCHAR(35),
    IN dateStart DATETIME,
    IN dateEnd DATETIME,
    IN optBloq INT,
    IN dateStartOld DATETIME
)
BEGIN
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

DELIMITER ;