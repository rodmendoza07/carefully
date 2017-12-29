CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_newUser`(
	IN nombre varchar(40),
    IN ap varchar(100),
    IN correo varchar(50),
    IN pwd varchar(15),
    IN puesto int,
    IN department int
)
BEGIN
	DECLARE	usrlevel int;
    DECLARE userId int;
    DECLARE userHash varchar(50);
    DECLARE passHash varchar(50);
    
	SET usrlevel = 1;
    SET passHash =  md5(correo + pwd + (SELECT cfg_valor FROM configuraciones WHERE cfg_id = 1));
    
	INSERT INTO usuarios (
		usr_nombre,
        usr_paterno,
        usr_nivelUsr_id,
        usr_login,
        usr_password,
        usr_correo,
        usr_puesto_id,
        usr_departamento_id
    ) VALUES(
		nombre,
        ap,
        usrlevel,
        correo,
        passHash,
        correo,
        puesto,
        department
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