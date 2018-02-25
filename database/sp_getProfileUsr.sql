USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_getProfileUsr`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_getProfileUsr`(
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
    
    SELECT
		CONCAT(usr.usr_nombre, ' ', usr.usr_paterno, ' ', usr.usr_materno) AS nombreUsuario
        , gen.g_desc AS gender
        , na.nacionalidad_desc AS nacionalidad
        , tp.t_age AS age
        , tp.t_birthDate AS birthDate
        , tp.t_civilState AS civilState
        , usr.usr_movil AS phoneContact
        , usr.usr_correo AS email
        , IFNULL(pa.pa_addon, '') AS aditional
        , IFNULL(bp.bp_famHist, '') AS famHist
        , IFNULL(bp.bp_dynFam, '') AS dinamicaFamiliar
        , IFNULL(bp.bp_reazons, '') AS movitosConsulta
        , IFNULL(bp.bp_actualProblem, '') AS problematicaActual
        , IFNULL(bp.bp_medicalAspects, '') AS aspectosMedicos
        , IFNULL(bp.bp_pshicological, '') AS psicologicos
        , IFNULL(bp.bp_trauma, '') AS traumas
        , IFNULL(bp.bp_socialProfile, '') AS perfilSocial
    FROM test_profile tp
		INNER JOIN usuarios usr ON (usr.usr_id = tp.t_usr_id)
		LEFT JOIN gender gen ON (gen.g_id = tp.t_gender)
		LEFT JOIN nacionalidades na ON (na.nacionalidad_id = usr.usr_nacionalidad_id)
        LEFT JOIN patientAddon pa ON (pa.pa_usr_id = usr.usr_id)
        LEFT JOIN bitacoraPaciente bp ON (bp.bp_usr_id = usr.usr_id)
	WHERE usr.usr_id = userId;
END$$

DELIMITER ;

