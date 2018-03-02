USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_supportStaff`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_supportStaff`(
	IN shash VARCHAR(45)
    , IN subjectm VARCHAR(200)
    , IN  descriptionm TEXT
    , IN opt INT
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
    
    IF opt = 1 THEN
		SELECT 
			st.sps_id AS folio
            , DATE_FORMAT(st.sps_createat, '%d/%m/%Y') AS dateS
            , DATE_FORMAT(st.sps_createat, '%h:%i %p') AS hours
            , st.sps_subject AS asunto
            , CONCAT('<span class="', ss.spe_badge,'" style="font-size:18px;">', ss.spe_desc, '</span>') AS estado
		FROM supportStaff st
			INNER JOIN supportStatus ss ON (ss.spe_id = st.sps_status)
        WHERE st.sps_usr_id = userId;
    ELSEIF opt = 2 THEN
		START TRANSACTION;
		
        INSERT INTO supportStaff (
			sps_usr_id
            , sps_status
            , sps_subject
            , sps_desc
        ) VALUES (
			userId
            , 3
            , subjectm
            , descriptionm
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
			SET message_text = 'Opción inválida.';
    END IF;
END$$

DELIMITER ;