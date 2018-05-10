USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_setTicketResolve`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_setTicketResolve`(
	IN shash VARCHAR(45)
    , IN ticketId INT
    , IN typeR VARCHAR(5)
)
BEGIN
	DECLARE userId INT;
    DECLARE userName VARCHAR(100);
    DECLARE `_rollback` BOOL DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SET `_rollback` = 1;
		ROLLBACK;
        RESIGNAL;
    END;
	
    SET userId = (SELECT vt_st_id FROM validtokens WHERE vt_hash = shash AND vt_status = 1);
    SET userId = IFNULL(userId, -1);
    
    IF userId > 0 THEN

        SET userName = (SELECT st_correo FROM staff WHERE st_id = userId)
        
        IF typeR = 'st' THEN
            START TRANSACTION

            UPDATE SET
            WHERE = ticketId
        ELSEIF typeR = 'usr' THEN
            START TRANSACTION

            UPDATE SET
            WHERE = ticketId
        END IF;

    ELSE
        SIGNAL SQLSTATE '45000'
			SET message_text = 'Sin privilegios.';
    END IF;
END$$

DELIMITER ;