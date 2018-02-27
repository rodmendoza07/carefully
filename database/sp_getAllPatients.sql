USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_getAllPatients`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_getAllPatients`(
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
    
    SET userId = (SELECT IFNULL(vt_st_id, 0) FROM validtokens WHERE vt_hash = shash AND vt_status = 1 AND vt_usr_id = 0);
	SET userId = IFNULL(userId, -1);
    
    SELECT
		u.usr_id
		, CONCAT(u.usr_nombre, ' ', u.usr_paterno, ' ', u.usr_materno) AS patienName
		, CONCAT('<button class="btn btn-primary btn-pill editar" data-pId="', u.usr_id, '">Editar</button>&nbsp;&nbsp;<button class="btn btn-warning btn-pill transferir" data-pId="', u.usr_id, '">Transferir</button>') AS btns
    FROM expedientepaciente e
		INNER JOIN usuarios u ON (e.expP_paciente_id = u.usr_id)
	WHERE e.expP_doctor_id = userId;
END$$

DELIMITER ;