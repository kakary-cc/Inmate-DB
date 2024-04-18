DELIMITER $$
CREATE PROCEDURE insert_crime(
    IN p_Criminal_ID DECIMAL(6),
    IN p_Classification CHAR(1),
    IN p_Date_charged DATE,
    IN p_Status CHAR(2),
    IN p_Hearing_date DATE,
    IN p_Appeal_cut_date DATE
)
BEGIN
    INSERT INTO Crimes (
        Criminal_ID,
        Classification,
        Date_charged,
        Status,
        Hearing_date,
        Appeal_cut_date
    ) VALUES (
        p_Criminal_ID,
        IFNULL(p_Classification, 'U'),
        p_Date_charged,
        p_Status,
        p_Hearing_date,
        p_Appeal_cut_date
    );
    IF p_Hearing_date <= p_Date_charged THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Hearing_date must be greater than Date_charged';
    END IF;
END$$
DELIMITER ;