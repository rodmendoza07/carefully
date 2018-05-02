USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_getThInfo`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_getThInfo`(
	IN shash VARCHAR(35)
    , IN stId INT
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
            st.st_id
            , st.st_nombre
            , st.st_paterno
            , st.st_materno
            , st.st_correo
            , pt.pt_perfil
        FROM staff st
            INNER JOIN perfilTerapeuta pt ON (st.st_id = pt.pt_st_id AND pt.pt_status = 1)
        WHERE st_id = stId;
    ELSE 	
		SIGNAL SQLSTATE '45000'
			SET message_text = 'Sin privilegios.';
	END IF;
END$$

DELIMITER ;