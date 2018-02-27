USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_getBitacoraPaciente`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_getBitacoraPaciente`(
	IN shash VARCHAR(35),
    IN usrId INT
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
		CONCAT(usr.usr_nombre, ' ', usr.usr_paterno, ' ', usr.usr_materno) AS patientName
        , bp.bp_famHist
        , bp.bp_dynFam
        , bp.bp_reazons
        , bp.bp_actualProblem
        , bp.bp_medicalAspects
        , bp.bp_pshicological
        , bp.bp_trauma
        , bp.bp_socialProfile
	FROM bitacoraPaciente bp
		INNER JOIN usuarios usr ON (usr.usr_id = bp.bp_usr_id)
	WHERE bp_usr_id = usrId;
END$$

DELIMITER ;