USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_getNewPwd`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_getNewPwd` (
	IN userMail VARCHAR(50)
)
BEGIN
	DECLARE eCounter INT;
    DECLARE `_rollback` BOOL DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SET `_rollback` = 1;
		ROLLBACK;
        RESIGNAL;
    END;
    
    SET eCounter = (SELECT COUNT(*) FROM usuarios WHERE usr_correo = userMail);
    
    IF eCounter > 0 THEN
		SELECT * FROM usuarios;
    ELSE
		SIGNAL SQLSTATE '45000'
			SET message_text =  'Cuenta inválida.';
    END IF;
END$$

DELIMITER ;