USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_reviewDate`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_reviewDate` (
	IN shash VARCHAR(35),
    IN userType INT,
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
    
    SET userId = (SELECT vt_usr_id FROM validtokens WHERE vt_hash = shash AND vt_status = 1);
    SET userId = IFNULL(userId, -1);
    
    IF userType = 1 THEN
		select 'hola';
    ELSEIF userType = 2 THEN
		select 'bien y tu';
    ELSE
		SIGNAL SQLSTATE '45000'
			SET message_text = 'Estatus no válido.';
    END IF;
END$$

DELIMITER ;