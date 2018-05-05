USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_getAllTickets`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_getAllTickets`(
	IN shash VARCHAR(45)
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
        (SELECT
            CONCAT(st.sps_id,'-st') AS folio
            , DATE_FORMAT(st.sps_createat, '%d/%m/%Y') AS dateS
            , DATE_FORMAT(st.sps_createat, '%h:%i %p') AS hours
            , st.sps_subject AS asunto
            , CONCAT('<span class="', ss.spe_badge,'" style="font-size:18px;">', ss.spe_desc, '</span>') AS estado
            , CONCAT(s.st_nombre, ' ', s.st_paterno, ' ', s.st_materno) AS nombre
            , s.st_correo AS userAccount
            , '<span class="badge badge-primary" style="font-size:18px;">Terapeuta</span>' AS typePerson
		FROM supportStaff st
			INNER JOIN supportStatus ss ON (ss.spe_id = st.sps_status)
            INNER JOIN staff s ON (s.st_id = st.sps_usr_id))
        UNION
        (SELECT
            CONCAT(spu.spu_id,'-usr') AS folio
            , DATE_FORMAT(spu.spu_createat, '%d/%m/%Y') AS dateS
            , DATE_FORMAT(spu.spu_createat, '%h:%i %p') AS hours
            , spu.spu_subject AS asunto
            , CONCAT('<span class="', ss.spe_badge,'" style="font-size:18px;">', ss.spe_desc, '</span>') AS estado
            , CONCAT(u.usr_nombre, ' ', u.usr_paterno, ' ', u.usr_materno) AS nombre
            , u.usr_correo AS userAccount
            , '<span class="badge badge-success" style="font-size:18px;">Paciente</span>' AS typePerson
        FROM supportUsr spu
            INNER JOIN supportStatus ss ON (ss.spe_id = spu.spu_status)
            INNER JOIN usuarios u ON (u.usr_id = spu.spu_usr_id));
    ELSE
        SIGNAL SQLSTATE '45000'
			SET message_text = 'Sin privilegios.';
    END IF;
END$$

DELIMITER ;