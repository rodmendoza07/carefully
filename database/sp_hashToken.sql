CREATE DEFINER=`vyreym`@`%` PROCEDURE `sp_hashToken`(
	IN userName VARCHAR(50),
    IN passwd VARCHAR(15)
)
BEGIN
	DECLARE passValid VARCHAR(50);
    DECLARE passRecived VARCHAR(50);
    DECLARE msgErr condition for sqlstate '10000';
    DECLARE sessOp INT;
    DECLARE diffDate double;
	
    SET passValid = (SELECT usr_password FROM usuarios WHERE usr_login = userName);
	SET passRecived = md5(userName + passwd + (SELECT cfg_valor FROM configuraciones WHERE cfg_id = 1));

	IF	passValid = passRecived THEN
		SET sessOp = (SELECT
						COUNT(*)
					FROM validTokens vt
						INNER JOIN usuarios usr ON (vt.vt_usr_id = (SELECT usr_id FROM usuarios WHERE usr_login = userName)));
            
		IF sessOp > 0 THEN
			SET diffDate = (SELECT DATEDIFF(CURRENT_TIMESTAMP,(SELECT 
																	vt_createat 
																FROM validTokens vt 
																	INNER JOIN usuarios usr ON (vt.vt_usr_id = (SELECT usr_id FROM usuarios WHERE usr_login = userName)))));
			
            SELECT diffDate;
            
		ELSE 
			INSERT INTO validTokens (
				vt_usr_id
                , vt_hash
            ) VALUES (
				(SELECT usr_id FROM usuarios WHERE usr_login = userName)
                , md5(CURRENT_TIMESTAMP + userName + passwd + (SELECT cfg_valor FROM configuraciones WHERE cfg_id = 1))
            );
            
            SELECT 
				vt_hash
            FROM validTokens vt
				INNER JOIN usuarios usr ON (vt.vt_usr_id = (SELECT usr_id FROM usuarios WHERE usr_login = userName))
			WHERE vt_status = 1;
            
        END IF;
	ELSE
		signal msgErr
			SET message_text = 'Usuario y/o contraseña inválidos';
    END IF;
END