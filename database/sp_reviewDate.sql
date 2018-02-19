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