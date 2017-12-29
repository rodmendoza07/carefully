CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_newUser`(
	IN nombre varchar(40),
    IN ap varchar(100),
    IN correo varchar(50),
    IN pwd varchar(15),
    IN opt int
)
BEGIN
	DECLARE	usrlevel int;
    DECLARE userId int;
    DECLARE userHash varchar(50);
    DECLARE passHash varchar(50);
    DECLARE usr_dept int;
    DECLARE usr_job int;
    DECLARE msgErr condition for sqlstate '10000';
    DECLARE `_rollback` BOOL DEFAULT 0;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET `_rollback` = 1;
    
    /*SELECT usr_id, usr_correo FROM usuarios;*/
    DECLARE CONTINUE HANDLER FOR 1062
    BEGIN
		signal msgErr
			SET message_text = 'La cuenta ya está en uso';
    END;
    
	SET usrlevel = 1;
    SET passHash =  md5(correo + pwd + (SELECT cfg_valor FROM configuraciones WHERE cfg_id = 1));
    
    IF opt = 1 THEN
		SET usr_dept = 2;
        SET usr_job = 2;
	END IF;
	IF opt = 2 THEN
		SET usr_dept = 3;
        SET usr_job = 3;
    END IF;
    
    START TRANSACTION;
	INSERT INTO usuarios (
		usr_nombre,
        usr_paterno,
        usr_nivelUsr_id,
        usr_login,
        usr_password,
        usr_correo,
        usr_departamento_id,
        usr_puesto_id
    ) VALUES(
		nombre,
        ap,
        usrlevel,
        correo,
        passHash,
        correo,
        usr_dept,
        usr_job
	);
    
    SET userId = (SELECT usr_id FROM usuarios WHERE usr_correo = correo);
    SET userHash = md5(convert(userId, char(50)) + correo + nombre);
    
    INSERT INTO validateSess (
		vs_usr_id,
        vs_hash
    ) VALUES (
		userId,
        userHash
    );
    IF `_rollback` THEN
		signal msgErr
			SET message_text = 'camara';
        ROLLBACK;
	ELSE
		COMMIT;
        SELECT vs_hash FROM validateSess WHERE vs_usr_id = userId;
    END IF;
END