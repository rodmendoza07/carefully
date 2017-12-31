USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_validateToken`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_validateToken`(
	IN sessToken VARCHAR(40)
)
BEGIN
	DECLARE tcounter INT;
    DECLARE validDate INT;
    DECLARE msgErr condition for sqlstate '10000';
    
    SET tcounter = (SELECT COUNT(*) FROM validtokens WHERE vt_hash = sessToken AND vt_status = 1);
    
    IF tcounter > 0 THEN
		SET validDate = DATEDIFF((SELECT vt_createat FROM validtokens WHERE vt_hash = sessToken AND vt_status = 1), NOW());
        
        IF validDate = 0 THEN
			SELECT 'OK' as message;
        ELSE
			signal msgErr
			SET message_text = 'Sesión inválida.';
        END IF;
    ELSE
		signal msgErr
			SET message_text = 'Inicia sesión.';
    END IF;
END$$

DELIMITER ;