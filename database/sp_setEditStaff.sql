USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_setEditStaff`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_setEditStaff`(
	IN shash VARCHAR(35),
    IN sIdstaff INT,
    IN sName VARCHAR(100), 
    IN sFirstname VARCHAR(100),
    IN sLastname VARCHAR(100),
    IN sService VARCHAR(20)
)
BEGIN
	DECLARE userId INT;
    DECLARE subss VARCHAR(5);
    DECLARE userHash VARCHAR(35);
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
		DROP TEMPORARY TABLE IF EXISTS tmp_jobsEdit;
		
		CREATE TEMPORARY TABLE tmp_jobsEdit (
			id INT NOT NULL AUTO_INCREMENT PRIMARY KEY
			, job INT
		);
        
        WHILE LENGTH(sService) > 0 DO
            INSERT INTO tmp_jobsEdit (
				job
            ) VALUES (
				SUBSTRING_INDEX(sService, ',', 1)
            );
            
            IF LENGTH(sService) = 1 THEN
				SET subss = SUBSTRING_INDEX(sService, ',', 1);
            ELSE
				SET subss = CONCAT(SUBSTRING_INDEX(sService, ',', 1), ',');
            END IF;
            
            SET sService = REPLACE(sService, subss, '');
        END WHILE;
    
		START TRANSACTION;
        
        UPDATE staff SET
            st_nombre = sName
            , st_paterno = sFirstname
            , st_materno = sLastname
            , st_fecha_actualizacion = NOW()
            , st_usr_id_actualizacion = userId
        WHERE st_id = sIdstaff;

        UPDATE perfilTerapeuta SET
            pt_status = 0
        WHERE pt_st_id = sIdstaff;

        INSERT INTO perfilTerapeuta (
			pt_st_id
            , pt_perfil
        ) SELECT
			sIdstaff
			, job
		FROM tmp_jobsEdit;

        IF `_rollback` THEN
            DROP TEMPORARY TABLE IF EXISTS tmp_jobsEdit;
			SIGNAL SQLSTATE '45000'
				SET message_text = 'Algo ha ido mal, intentalo más tarde.';
		ELSE
			DROP TEMPORARY TABLE IF EXISTS tmp_jobsEdit;
            COMMIT;
			SELECT 'OK' AS msg;
		END IF;
    ELSE 
        DROP TEMPORARY TABLE IF EXISTS tmp_jobsEdit;	
		SIGNAL SQLSTATE '45000'
			SET message_text = 'Sin privilegios.';
	END IF;
END$$

DELIMITER ;