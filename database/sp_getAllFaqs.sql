USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_getAllFaqs`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_getAllFaqs` (
    IN shash VARCHAR(35),
    IN typePerson INT
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

    IF typePerson = 0 THEN
        SET userId = (SELECT vt_usr_id FROM validtokens WHERE vt_hash = shash AND vt_status = 1);
        SET userId = IFNULL(userId, -1);
        
        IF userId > 0 THEN
			SELECT
				q.fqq_id AS qId
				, q.fqq_question AS qQuestion
				, a.fqa_id AS aId
				, a.fqa_answer AS aAnswer
                , cat.fqc_desc AS cDesc
                , cat.fqc_id AS category
			FROM faq_question q
				INNER JOIN faq_answers a ON (q.fqq_id = a.fqa_q_id)
                INNER JOIN faq_category cat ON (q.fqq_cat = cat.fqc_id AND fqc_view = 1)
			ORDER BY q.fqq_id ASC;
        ELSE
			SIGNAL SQLSTATE '45000'
				SET message_text = 'Sin privilegios.';
        END IF;        
    ELSEIF typePerson = 1 THEN
		SET userId = (SELECT vt_st_id FROM validtokens WHERE vt_hash = shash AND vt_status = 1);
		SET userId = IFNULL(userId, -1);
        
        IF userId > 0 THEN
        SELECT
				q.fqq_id AS qId
				, q.fqq_question AS qQuestion
				, a.fqa_id AS aId
				, a.fqa_answer AS aAnswer
                , cat.fqc_desc AS cDesc
                , cat.fqc_id AS category
			FROM faq_question q
				INNER JOIN faq_answers a ON (q.fqq_id = a.fqa_q_id)
                INNER JOIN faq_category cat ON (q.fqq_cat = cat.fqc_id AND fqc_view = 2)
			ORDER BY q.fqq_id ASC;
        ELSE
			SIGNAL SQLSTATE '45000'
				SET message_text = 'Sin privilegios.';
        END IF;
    ELSE
        SIGNAL SQLSTATE '45000'
			SET message_text = 'Sin privilegios.';
    END IF;
END$$

DELIMITER ;