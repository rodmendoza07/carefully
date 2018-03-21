USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_blockDoctorDates`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_blockDoctorDates` (
	IN shash VARCHAR(35),
    IN dateStart DATETIME,
    IN dateEnd DATETIME,
    IN dateType INT
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
		START TRANSACTION;
        INSERT INTO citas (
			cita_fecha_start
			, cita_fecha_end
			, cita_paciente_id
			, cita_doctor_id
			, cita_title
        ) VALUES(
			dateStart
			, dateEnd
			, 0
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
			SET message_text = 'Sin privilegios.';
    END IF;
    
END$$

DELIMITER ;

