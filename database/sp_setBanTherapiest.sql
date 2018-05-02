USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_setBanTherapiest`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_setBanTherapiest`(
	IN shash VARCHAR(35),
    IN sIdstaff INT
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
    
    SET userId = (SELECT vt_st_id FROM validtokens WHERE vt_hash = shash AND vt_status = 1);
	SET userId = IFNULL(userId, -1);

    IF userId > 0 THEN
		START TRANSACTION;
        
        UPDATE staff SET
            st_estatus = 0
            , st_fecha_cancelacion = NOW()
            , st_usr_id_cancelacion = userId
        WHERE st_id = sIdstaff;

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
END$$

DELIMITER ;