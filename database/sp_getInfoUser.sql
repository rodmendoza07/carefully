USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_getInfoUser`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getInfoUser`(
	IN userName VARCHAR(50),
    IN passwd VARCHAR(15)
)
DECLARE msgErr condition for sqlstate '10000';
    DECLARE passCompare VARCHAR(40);
	DECLARE userId INT;
    DECLARE validAccount INT;
    DECLARE sessToken VARCHAR(40);
    DECLARE previousToken INT;
    DECLARE `_rollback` BOOL DEFAULT 0;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET `_rollback` = 1;
    
    SET userId = (SELECT IFNULL(usr_id, 0) FROM usuarios WHERE usr_correo = userName);
	
    IF userId > 0 THEN
    
		SET validAccount = (SELECT COUNT(*) FROM validateSess WHERE vs_usr_id = userId AND vs_status = 1);
        
        IF validAccount > 0 THEN
			SET passCompare = md5(CONCAT(userName, passwd, (SELECT cfg_valor FROM configuraciones WHERE cfg_id = 1)));
            
            IF passCompare = (SELECT usr_password FROM usuarios WHERE usr_id = userId) THEN
                /*Sección token */
				SET previousToken = (SELECT COUNT(*) FROM validtokens WHERE vt_usr_id = userId);
                SET sessToken = md5(CONCAT(DATE_FORMAT(NOW(), '%Y%c%d'),userName,passwd,(SELECT cfg_valor FROM configuraciones WHERE cfg_id =  1)));
                
                IF previousToken > 0 THEN
					UPDATE validtokens SET
						vt_status = 0
					WHERE vt_usr_id = userId;
                    
                    START TRANSACTION;
                    INSERT INTO validtokens (
						vt_usr_id
                        , vt_hash
                    ) VALUES (
						userId
                        , sessToken
                    );
                    IF `_rollback` THEN
						signal msgErr
							SET message_text = 'Algo ha ido mal, intentalo más tarde.';
						ROLLBACK;
					ELSE
						COMMIT;
					END IF;
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
						signal msgErr
							SET message_text = 'Algo ha ido mal, intentalo más tarde.';
						ROLLBACK;
					ELSE
						COMMIT;
					END IF;
                END IF;
                
                /* Envia datos frontend */
                SELECT 
					sessToken as sessToken
                    , usr_nombre
                    , usr_paterno
				FROM usuarios
                WHERE usr_id = userId;
			ELSE
				signal msgErr
					SET message_text = 'Usuario y/o contraseña incorrectos.';
			END IF;
		
        ELSE
			signal msgErr
				SET message_text = 'Tu cuenta aún no ha sido activada.';
		END IF;
	
    ELSE
		signal msgErr
			SET message_text = 'Usuario y/o contraseña incorrectos.';
	END IF;
END