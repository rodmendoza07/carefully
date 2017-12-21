CREATE DEFINER=`vyreym`@`%` PROCEDURE `sp_newUser`(
	IN nombre varchar(40),
    IN ap varchar(100),
    IN correo varchar(100),
    IN pwd varchar(100)
)
BEGIN
	DECLARE	usrlevel int;
    DECLARE userId int;
    DECLARE userHash varchar(50);
	SET usrlevel = 1;
    
	INSERT INTO usuarios (
		usr_nombre,
        usr_paterno,
        usr_nivelUsr_id,
        usr_login,
        usr_password,
        usr_correo
    ) VALUES(
		nombre,
        ap,
        usrlevel,
        correo,
        md5(pwd),
        correo
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
    
    SELECT vs_hash FROM validateSess WHERE vs_usr_id = userId;
END