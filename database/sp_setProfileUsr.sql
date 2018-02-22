USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_setProfileUsr`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_setProfileUsr` (
	IN chash VARCHAR(35)
    , IN opt INT
    , IN cName VARCHAR(50)
    , IN gender INT
    , IN birthDate DATETIME
    , IN civilState INT
    , IN contactPhone INT
    , IN aditionalInfo TEXT
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
    
    IF opt = 1 THEN /*Información general*/
		select '';
    ELSEIF opt = 2 THEN  /*Información de contacto*/
		select '';
    ELSEIF opt = 3 THEN /* Información adicional*/
		select '';
	ELSEIF opt = 4 THEN /*Carga de imagen*/
		select '';
    ELSE
		select '';
    END IF;
END$$

DELIMITER ;