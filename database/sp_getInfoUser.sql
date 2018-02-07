USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_getInfoUser`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getInfoUser`(
	IN userName VARCHAR(50),
    IN passwd VARCHAR(15)
)
BEGIN
    
    DECLARE passCompare VARCHAR(40);
	DECLARE userId INT;
    DECLARE validAccount INT;
    DECLARE sessToken VARCHAR(40);
    DECLARE previousToken INT;
    DECLARE typeUser TINYINT;
    DECLARE `_rollback` BOOL DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SET `_rollback` = 1;
		ROLLBACK;
        RESIGNAL;
    END;
    
    SET userId = (SELECT IFNULL(usr_id, 0) FROM usuarios WHERE usr_correo = userName);
	SET typeUser = 0;
    SET userId = IFNULL(userId, 0);
    
    IF userId = 0 THEN
		SET userId = (SELECT IFNULL(st_id, 0) FROM staff WHERE st_correo = userName);
        SET typeUser = 1;
	END IF;
    
    IF userId > 0 THEN
		
        IF typeUser = 0 THEN
			SET validAccount = (SELECT COUNT(*) FROM validateSess WHERE vs_usr_id = userId AND vs_status = 1);
        ELSEIF typeUser = 1 THEN 
			SET validAccount = (SELECT COUNT(*) FROM validateSess WHERE vs_st_id = userId AND vs_status = 1);
        END IF;
        
        IF validAccount > 0 THEN
			SET passCompare = md5(CONCAT(userName, passwd, (SELECT cfg_valor FROM configuraciones WHERE cfg_id = 1)));
            
            IF (passCompare = (SELECT usr_password FROM usuarios WHERE usr_id = userId)) OR (passCompare = (SELECT st_password FROM staff WHERE st_id = userId)) THEN
                select 'entra a la comparación de pass';
                /*Sección token */
                
                SET sessToken = md5(CONCAT(DATE_FORMAT(NOW(), '%Y%c%d'),userName,passwd,(SELECT cfg_valor FROM configuraciones WHERE cfg_id =  1)));
                
                IF typeUser = 0 THEN
					SET previousToken = (SELECT COUNT(*) FROM validtokens WHERE vt_usr_id = userId);
                ELSEIF typeUser = 1 THEN
					SET previousToken = (SELECT COUNT(*) FROM validtokens WHERE vt_st_id = userId);
                END IF;
                
                IF previousToken > 0 AND typeUser = 0 THEN
					UPDATE validtokens SET
						vt_status = 0
					WHERE vt_usr_id = userId;
				ELSEIF previousToken > 0 AND typeUser = 1 THEN
					UPDATE validtokens SET
						vt_status = 0
					WHERE vt_usr_id = userId;
                /*
                    START TRANSACTION;
                    INSERT INTO validtokens (
						vt_usr_id
                        , vt_hash
                    ) VALUES (
						userId
                        , sessToken
                    );
                    IF `_rollback` THEN
						SIGNAL SQLSTATE '45000'
							SET message_text = 'Algo ha ido mal, intentalo más tarde.';
					ELSE
						COMMIT;
					END IF;*/
				ELSE
					START TRANSACTION;
                    INSERT INTO validtokens (
						vt_usr_id
                        , vt_hash
                    ) VALUES (
						userId
                        , sessToken
                    );
                    IF `_rollback` THEN
						SIGNAL SQLSTATE '45000'
							SET message_text = 'Algo ha ido mal, intentalo más tarde.';
					ELSE
						COMMIT;
					END IF;
                END IF;
                
                /* Envia datos frontend */
                /*SELECT 
					sessToken as sessToken
                    , usr_nombre
                    , usr_paterno
				FROM usuarios
                WHERE usr_id = userId;*/
			ELSE
				/*select 'entra else';*/
				SIGNAL SQLSTATE '45000'
					SET message_text = 'Usuario y/o contraseña inválidos.';
			END IF;
		
        ELSE
			SIGNAL SQLSTATE '45000'
				SET message_text = 'Activa tu cuenta para iniciar sesión.';
		END IF;
	
    ELSE
		SIGNAL SQLSTATE '45000'
			SET message_text = 'Usuario y/o contraseña incorrectos.';
	END IF;
END$$

DELIMITER ;