DELIMITER $$
CREATE PROCEDURE insert_appeal_by_crime_id(
    IN p_Crime_ID DECIMAL(9),
    IN p_Filling_date DATE,
    IN p_Hearing_date DATE,
    IN p_Status CHAR(1)
)
BEGIN
    INSERT INTO Appeals (
        Crime_ID,
        Filling_date,
        Hearing_date,
        Status
    ) VALUES (
        p_Crime_ID,
        p_Filling_date,
        p_Hearing_date,
        p_Status
    );
END$$
DELIMITER ;