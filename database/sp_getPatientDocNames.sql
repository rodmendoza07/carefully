USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_getPatientDocNames`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_getPatientDocNames`(
	IN shash INT,
    IN typePerson INT,
    IN startDate DATETIME
)
BEGIN
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

DELIMITER ;