USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_setNewStaff`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_setNewStaff`(
	IN shash VARCHAR(35),
    IN sName VARCHAR(100), 
    IN sFirstname VARCHAR(100),
    IN sLastname VARCHAR(100),
    IN sEmail VARCHAR(100),
    IN sService VARCHAR(20),
    IN sDepartment INT,
    IN sJob INT
)
BEGIN
	DECLARE userId INT;
    DECLARE newStaff INT;
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
    
    IF (SELECT COUNT(*) FROM usuarios WHERE usr_correo = correo AND usr_status = 1) > 0 THEN
        SIGNAL SQLSTATE '45000'
			SET message_text = 'La cuenta ya está en uso.';
    END IF;

    IF userId > 0 THEN
		DROP TEMPORARY TABLE IF EXISTS tmp_jobs;
		
		CREATE TEMPORARY TABLE tmp_jobs (
			id INT NOT NULL AUTO_INCREMENT PRIMARY KEY
			, job INT
		);
        
        WHILE LENGTH(sService) > 0 DO
            INSERT INTO tmp_jobs (
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
        
        INSERT INTO staff (
			st_nombre
            , st_paterno
            , st_materno
            , st_departamento_id
            , st_puesto_id
            , st_login
            , st_correo
            , st_usr_id_alta
        ) VALUES (
			sName,
            sFirstname,
            sLastname,
            sDepartment,
            sJob,
            sEmail,
            sEmail,
            userId
        );
        
        SET newStaff = LAST_INSERT_ID();
        SET userHash = md5(CONCAT(convert(userId, char(50)), correo, nombre));
        
        INSERT INTO perfilTerapeuta (
			pt_st_id
            , pt_perfil
        ) SELECT
			newStaff
			, job
		FROM tmp_jobs;
        
        INSERT INTO validateSess (
            vs_st_id,
            vs_hash
        ) VALUES (
            newStaff,
            userHash
        );

        IF `_rollback` THEN
				SIGNAL SQLSTATE '45000'
					SET message_text = 'Algo ha ido mal, intentalo más tarde.';
		ELSE
			COMMIT;
			SELECT 'OK' AS msg;
		END IF;
    ELSE 	
		SIGNAL SQLSTATE '45000'
			SET message_text = 'Sin privilegios.';
	END IF;
END$$

DELIMITER ;