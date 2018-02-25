USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_getAllFaqs`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_getAllFaqs` ()
BEGIN
	SELECT
		q.fqq_id AS qId
        , q.fqq_question AS qQuestion
        , a.fqa_id AS aId
        , a.fqa_answer AS aAnswer
    FROM faq_question q
		INNER JOIN faq_answers a ON (q.fqq_id = a.fqa_q_id);
END$$

DELIMITER ;