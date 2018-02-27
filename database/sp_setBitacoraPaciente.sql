USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_setBitacoraPaciente`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_setBitacoraPaciente`(
	IN shash VARCHAR(35),
    IN usrId INT,
    IN histFam TEXT,
    IN dinFam TEXT,
    IN mc TEXT,
    IN hpa TEXT, 
    IN am TEXT,
	IN psi TEXT,
    IN trauma TEXT,
    IN ps TEXT
)
BEGIN
	DECLARE userId INT;
    DECLARE expCount INT;
    DECLARE `_rollback` BOOL DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SET `_rollback` = 1;
		ROLLBACK;
        RESIGNAL;
    END;
    
    SET userId = (SELECT IFNULL(vt_st_id, 0) FROM validtokens WHERE vt_hash = shash AND vt_status = 1 AND vt_usr_id = 0);
	SET userId = IFNULL(userId, -1);
    
    SET expCount = (SELECT COUNT(*) FROM bitacoraPaciente);
    
    IF expCount = 0 THEN
		START TRANSACTION;
            INSERT INTO bitacoraPaciente (
				bp_usr_id
                , bp_famHist
                , bp_dynFam
                , bp_reazons
                , bp_actualProblem
                , bp_medicalAspects
                , bp_pshicological
                , bp_trauma
                , bp_socialProfile
            ) VALUES(
				usrId
                , histFam
                , dinFam
                , mc
                , hpa
                , am
                , psi
                , trauma
                , ps
            );
            
        IF `_rollback` THEN
			SIGNAL SQLSTATE '45000'
				SET message_text = 'Algo ha ido mal, intentalo más tarde.';
		ELSE
			COMMIT;
			SELECT 'OK' AS msg;
		END IF;
    ELSEIF expCount > 0 THEN
		
        START TRANSACTION;
        
        IF histFam != '' THEN
			UPDATE bitacoraPaciente SET 
				bp_famHist = histFam
			WHERE bp_usr_id = userId;
		END IF;
        
        IF dinFam != '' THEN
			UPDATE bitacoraPaciente SET 
				bp_dynFam = dinFam
			WHERE bp_usr_id = userId;
		END IF;
        
        IF mc != '' THEN
			UPDATE bitacoraPaciente SET 
				bp_reazons = mc
			WHERE bp_usr_id = userId;
		END IF;
        
        IF hpa != '' THEN
			UPDATE bitacoraPaciente SET 
				bp_actualProblem = hpa
			WHERE bp_usr_id = userId;
		END IF;
        
        IF am != '' THEN
			UPDATE bitacoraPaciente SET 
				bp_medicalAspects = am
			WHERE bp_usr_id = userId;
		END IF;
        
        IF psi != '' THEN
			UPDATE bitacoraPaciente SET 
				bp_pshicological = psi
			WHERE bp_usr_id = userId;
		END IF;
        
        IF trauma != '' THEN
			UPDATE bitacoraPaciente SET 
				bp_trauma = trauma
			WHERE bp_usr_id = userId;
		END IF;
        
        IF ps != '' THEN
			UPDATE bitacoraPaciente SET 
				bp_socialProfile = ps
			WHERE bp_usr_id = userId;
		END IF;

        IF `_rollback` THEN
			SIGNAL SQLSTATE '45000'
				SET message_text = 'Algo ha ido mal, intentalo más tarde.';
		ELSE
			COMMIT;
			SELECT 'OK' AS msg;
		END IF;
    ELSE
		SIGNAL SQLSTATE '45000'
			SET message_text = 'Opción inválida.';
    END IF;
END$$

DELIMITER ;