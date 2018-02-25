USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_getAllgender`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_getAllgender` ()
BEGIN
	SELECT
		g.g_id
        , g.g_desc
    FROM gender g;
END$$

DELIMITER ;