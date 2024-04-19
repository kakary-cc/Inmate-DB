DELIMITER $$
CREATE PROCEDURE insert_officer(
    IN p_Last VARCHAR(15),
    IN p_First VARCHAR(10),
    IN p_Precinct CHAR(4),
    IN p_Badge VARCHAR(14),
    IN p_Phone CHAR(10),
    IN p_Status CHAR(1)
)
BEGIN
    INSERT INTO Officers (
        Last,
        First,
        Precinct,
        Badge,
        Phone,
        Status
    ) VALUES (
        p_Last,
        p_First,
        p_Precinct,
        p_Badge,
        p_Phone,
        p_Status
    );
END$$
DELIMITER ;