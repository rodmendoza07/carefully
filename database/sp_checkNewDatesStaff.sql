USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_checkNewDatesStaff`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_checkNewDatesStaff`(
	IN shash VARCHAR(35)
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
    
    SELECT
		c.cita_fecha_start
        , c.cita_fecha_end
		, c.* 
    FROM citas c 
    WHERE c.cita_doctor_id = userId
     AND c.cita_estatus = 1;
    
    SELECT userId;
END$$

DELIMITER ;