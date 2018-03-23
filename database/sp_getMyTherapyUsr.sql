USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_getMyTherapyUsr`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_getMyTherapyUsr`(
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
            DATE_FORMAT(c.cita_fecha_start, '%d/%m/%Y') AS dia
            , CONCAT(DATE_FORMAT(c.cita_fecha_start, '%h:%i %p'), '-', DATE_FORMAT(c.cita_fecha_end, '%h:%i %p')) AS horario
            , CONCAT('<span class="',cs.cs_badge,'" style="font-size:18px;">', cs.cs_desc, '</span>') AS cs_desc
            , CONCAT(st.st_nombre, ' ', st.st_paterno, ' ', st.st_materno) AS therapist
		FROM citas c
			INNER JOIN citas_status cs ON (c.cita_estatus = cs.cs_id)
            INNER JOIN citas_communication cc ON (c.cita_title = cc.cc_id)
            INNER JOIN staff st ON (st.st_id = c.cita_doctor_id)
        WHERE c.cita_paciente_id = userId
			AND c.cita_estatus <> 5;
	ELSE
		SIGNAL SQLSTATE '45000'
			SET message_text = 'Algo ha ido mal, intentelo más tarde.';
    END IF; 
END$$

DELIMITER ;