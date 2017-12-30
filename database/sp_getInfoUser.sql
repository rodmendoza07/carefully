USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_getInfoUser`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getInfoUser`(
	IN userName VARCHAR(50),
    IN passwd VARCHAR(15)
)
BEGIN
    DECLARE msgErr condition for sqlstate '10000';
    DECLARE passCompare VARCHAR(40);
	DECLARE userId INT;
    DECLARE validAccount INT;
    
    SET userId = (SELECT IFNULL(usr_id, 0) FROM usuarios WHERE usr_correo = userName);
	
    IF userId > 0 THEN
		SET validAccount = (SELECT COUNT(*) FROM validateSess WHERE vs_usr_id = userId AND vs_status = 1);
        IF validAccount > 0 THEN
			SET passCompare = CONCAT(userName, passwd, (SELECT cfg_valor FROM configuraciones WHERE cfg_id = 1));
		ELSE
			signal msgErr
				SET message_text = 'Tu cuenta aún no ha sido activada.';
		END IF;
        
        
	ELSE
		signal msgErr
			SET message_text = 'Usuario y/o contraseña incorrectos.';
	END IF;
END$$

DELIMITER ;

