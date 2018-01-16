USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_getAllDates`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_getAllDates`(
	IN token_hash VARCHAR(35)
)
BEGIN
	DECLARE userId INT;
	DECLARE `_rollback` BOOL DEFAULT 0;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		SET `_rollback` = 1;
		RESIGNAL;
	END;

	SET userId = (SELECT IFNULL(vt_usr_id, 0) FROM validtokens WHERE vt_hash = token_hash AND vt_status= 1);

	IF userId > 0 THEN
		SELECT 
			cita_fecha_start
            , cita_fecha_end
            , cita_title
		FROM citas 
        WHERE cita_paciente_id = userId;
	ELSE
		SIGNAL SQLSTATE '45000'
			SET message_text = 'No existen citas.';
    END IF;
   
END$$

DELIMITER ;
