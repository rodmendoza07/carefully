USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_blockDoctorDates`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_blockDoctorDates`(
	IN shash VARCHAR(35),
    IN dateStart DATETIME,
    IN dateEnd DATETIME
)
BEGIN
	DECLARE userId INT;
    DECLARE lastId INT;
    DECLARE firstId INT;
    DECLARE tmp_paciente INT;
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
			SET message_text = 'Sin privilegios.';
    END IF;
    
END$$

DELIMITER ;