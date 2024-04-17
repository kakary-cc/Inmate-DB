DELIMITER $$

USE jail;

CREATE PROCEDURE insert_prob_officer(
    IN p_Last VARCHAR(15),
    IN p_First VARCHAR(10),
    IN p_Street VARCHAR(30),
    IN p_City VARCHAR(20),
    IN p_State CHAR(2),
    IN p_Zip CHAR(5),
    IN p_Phone CHAR(10),
    IN p_Email VARCHAR(30),
    IN p_Status CHAR(1)
)
BEGIN
    INSERT INTO Prob_officers (
        Last,
        First,
        Street,
        City,
        State,
        Zip,
        Phone,
        Email,
        Status
    ) VALUES (
        p_Last,
        p_First,
        p_Street,
        p_City,
        p_State,
        p_Zip,
        p_Phone,
        p_Email,
        p_Status
    );
END$$

DELIMITER ;
