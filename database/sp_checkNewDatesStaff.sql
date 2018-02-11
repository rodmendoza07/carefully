USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_checkNewDatesStaff`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_checkNewDatesStaff`(
	IN shash VARCHAR(35),
    IN opt INT,
    IN cId INT
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
    
    IF opt = 1 THEN
		SELECT
			c.cita_fecha_start
			, c.cita_fecha_end
			, cc.cc_desc
			, CONCAT(usr.usr_nombre, ' ', usr.usr_paterno) AS usrNombre
		FROM citas c
			INNER JOIN citas_communication cc ON (c.cita_title = cc.cc_id)
			INNER JOIN usuarios usr ON (c.cita_paciente_id = usr_id)
			INNER JOIN citas_validation cv ON (c.cita_id = cv.cv_c_id)
		WHERE c.cita_doctor_id = userId
		 AND cv.cv_status = 0;
	
    ELSEIF opt = 2 THEN
		START TRANSACTION;
		
        UPDATE citas_validation SET
			cv_status = 1,
            cv_validat = CURRENT_TIMESTAMP,
            cv_st_id = userId
		WHERE cv_c_id = cId;
        
        IF `_rollback` THEN
			SIGNAL SQLSTATE '45000'
				SET message_text = 'Algo ha ido mal, intentalo más tarde.';
		ELSE
			COMMIT;
		END IF;
    ELSE
		SIGNAL SQLSTATE '45000'
			SET message_text = 'Opción inválida';
    END IF;
END$$

DELIMITER ;