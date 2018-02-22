USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_getMyTherapyUsr`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getMyTherapyUsr`(
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
    
    SET userId = (SELECT vt_usr_id FROM validtokens WHERE vt_hash = shash AND vt_status = 1);
    SET userId = IFNULL(userId, -1);
    
    IF userId > 0 THEN
		SELECT
			/*COUNT(c.cita_title) AS dateNumber*/
			c.cita_fecha_start
            , c.cita_fecha_end
            , c.cita_title
            , c.cita_estatus
            , cs.cs_desc
            , cc.cc_desc
            , cs.cs_color
            , CONCAT(st.st_nombre, ' ', st.st_paterno, ' ', st.st_materno) AS therapist
		FROM citas c
			INNER JOIN citas_status cs ON (c.cita_estatus = cs.cs_id)
            INNER JOIN citas_communication cc ON (c.cita_title = cc.cc_id)
            INNER JOIN staff st ON (st.st_id = c.cita_doctor_id)
        WHERE cita_paciente_id = userId;
	ELSE
		SIGNAL SQLSTATE '45000'
			SET message_text = 'Algo ha ido mal, intentelo más tarde.';
    END IF; 
END$$

DELIMITER ;

