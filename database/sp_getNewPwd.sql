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