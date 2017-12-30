USE `cuidadosamente`;
DROP procedure IF EXISTS `sp_validateAccount`;

DELIMITER $$
USE `cuidadosamente`$$
CREATE PROCEDURE `sp_validateAccount`(
	IN codeAccount varchar(50)
)
BEGIN
	DECLARE msgErr condition for sqlstate '10001';
    DECLARE noRegister int;
    DECLARE registerallready int;
    DECLARE registerActivate int;
    
    SET noRegister = (SELECT COUNT(*) FROM validateSess WHERE vs_hash = codeAccount);
    SET registerallready = (SELECT COUNT(*) FROM validateSess WHERE vs_hash = codeAccount AND vs_status = 1);
    SET registerActivate = (SELECT COUNT(*) FROM validateSess WHERE vs_hash = codeAccount AND vs_status = 0);
    
	IF noRegister = 0 THEN
		signal msgErr
			SET message_text = 'Registrate para activar tu cuenta';
    ELSEIF registerallready > 0 THEN
		signal msgErr
			SET message_text = 'Tu cuenta ya ha sido activada';
	ELSEIF registerActivate > 0 THEN
		UPDATE validateSess SET
			vs_status = 1
            , vs_activateat = CURRENT_TIMESTAMP
		WHERE vs_hash = codeAccount;
        
        SELECT
			'activate' as estatus
            , vs_activateat
        FROM validateSess
        WHERE vs_hash = codeAccount;
	ELSE
		signal msgErr
			SET message_text = 'Error en la activación';
    END IF;
END$$

DELIMITER ;

