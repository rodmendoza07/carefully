USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_getAllNations`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_getAllNations` ()
BEGIN
	SELECT
		n.nacionalidad_id
        , n.nacionalidad_desc
	FROM nacionalidades n;
END$$

DELIMITER ;