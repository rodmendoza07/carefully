USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_getAllDatesStaff`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_getAllDatesStaff` (
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

	SET userId = (SELECT IFNULL(vt_st_id, 0) FROM validtokens WHERE vt_hash = token_hash AND vt_status= 1);

	IF userId > 0 THEN
		SELECT
			/*COUNT(c.cita_title) AS dateNumber*/
			DISTINCT(c.cita_fecha_start)
            , c.cita_fecha_end
            , c.cita_title
            , c.cita_estatus
            , cs.cs_desc
            , cc.cc_desc
            , cs.cs_color
		FROM citas c
			INNER JOIN citas_status cs ON (c.cita_estatus = cs.cs_id)
            INNER JOIN citas_communication cc ON (c.cita_title = cc.cc_id)
        WHERE cita_doctor_id = userId;
	ELSE
		SIGNAL SQLSTATE '45000'
			SET message_text = 'Opción inválida.';
    END IF;
END$$

DELIMITER ;