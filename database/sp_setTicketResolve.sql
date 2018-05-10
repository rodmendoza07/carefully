USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_setTicketResolve`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_setTicketResolve`(
	IN shash VARCHAR(45)
    , IN ticketId INT
    , IN typeR VARCHAR(5)
    , IN typeStatus INT
    , IN commentSupport VARCHAR(1000)
)
BEGIN
	DECLARE userId INT;
    DECLARE userName VARCHAR(100);
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

        SET userName = (SELECT st_correo FROM staff WHERE st_id = userId);
        
        IF typeR = 'usr' THEN
            IF typeStatus = 1 THEN 
                START TRANSACTION;

                UPDATE supportUsr SET
                    spu_status = 1
                    , spu_updateat =  NOW()
                    , spu_supportId = userId            
                WHERE spu_id = ticketId;

                IF `_rollback` THEN
                    SIGNAL SQLSTATE '45000'
                        SET message_text = 'Algo ha ido mal, intentalo más tarde.';
                ELSE
                    COMMIT;
                    SELECT 'OK' AS msg;
                END IF;

            ELSEIF typeStatus = 2 THEN
                START TRANSACTION;
                
                UPDATE supportUsr SET
                    spu_status = 2
                    , spu_updateat =  NOW()
                    , spu_supportId = userId            
                WHERE spu_id = ticketId;

                INSERT INTO supportDetailusr (
                    sdu_ticket_id
                    , sdu_staffId
                    , sdu_comment
                ) VALUES (
                    ticketId
                    , userId
                    , commentSupport
                );  

                IF `_rollback` THEN
                    SIGNAL SQLSTATE '45000'
                        SET message_text = 'Algo ha ido mal, intentalo más tarde.';
                ELSE
                    COMMIT;
                    SELECT 'OK' AS msg;
                END IF;

            END IF;
            
        ELSEIF typeR = 'st' THEN
            IF typeStatus = 1 THEN 
                START TRANSACTION;

                UPDATE supportStaff SET
                    sps_status = 1
                    , sps_updateat =  NOW()
                    , sps_supportId = userId            
                WHERE sps_id = ticketId;

                IF `_rollback` THEN
                    SIGNAL SQLSTATE '45000'
                        SET message_text = 'Algo ha ido mal, intentalo más tarde.';
                ELSE
                    COMMIT;
                    SELECT 'OK' AS msg;
                END IF;

            ELSEIF typeStatus = 2 THEN
                START TRANSACTION;
                
                UPDATE supportStaff SET
                    sps_status = 2
                    , sps_updateat =  NOW()
                    , sps_supportId = userId            
                WHERE sps_id = ticketId;

                INSERT INTO supportDetailst (
                    sds_ticket_id
                    , sds_staffId
                    , sds_comment
                ) VALUES (
                    ticketId
                    , userId
                    , commentSupport
                );  

                IF `_rollback` THEN
                    SIGNAL SQLSTATE '45000'
                        SET message_text = 'Algo ha ido mal, intentalo más tarde.';
                ELSE
                    COMMIT;
                    SELECT 'OK' AS msg;
                END IF;

            END IF;
        END IF;

    ELSE
        SIGNAL SQLSTATE '45000'
			SET message_text = 'Sin privilegios.';
    END IF;
END$$

DELIMITER ;