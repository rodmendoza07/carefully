USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_getAllTherapist`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_getAllTherapist`(
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
	SET userId = IFNULL(userId, -1);
    
    IF userId > 0 THEN
		SELECT
			st_id AS tId
            , CONCAT(st_nombre, ' ', st_paterno, ' ', st_materno) AS nameComplete 
            , CASE
                WHEN st_estatus = 1 THEN '<span class="badge badge-info" style="font-size:18px;">Activo</span>'
                ELSE '<span class="badge badge-danger" style="font-size:18px;">Inactivo</span>'
            END AS tStatus
        FROM staff
        WHERE st_puesto_id = 3 
			AND st_departamento_id = 3;
    ELSE 	
		SIGNAL SQLSTATE '45000'
			SET message_text = 'Sin privilegios.';
	END IF;
END$$

DELIMITER ;

