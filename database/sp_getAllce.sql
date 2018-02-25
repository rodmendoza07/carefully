USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_getAllce`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_getAllce`()
BEGIN
	SELECT
		ce.ce_id
        , ce.ce_desc
	FROM civil_estado ce;
END$$

DELIMITER ;