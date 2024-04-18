DELIMITER $$
CREATE PROCEDURE insert_crime_charge(
    IN p_Crime_ID DECIMAL(9),
    IN p_Crime_code DECIMAL(3),
    IN p_Charge_status CHAR(2),
    IN p_Fine_amount DECIMAL(7,2),
    IN p_Court_fee DECIMAL(7,2),
    IN p_Amount_paid DECIMAL(7,2),
    IN p_Pay_due_date DATE
)
BEGIN
    INSERT INTO Crime_charges (
        Crime_ID,
        Crime_code,
        Charge_status,
        Fine_amount,
        Court_fee,
        Amount_paid,
        Pay_due_date
    ) VALUES (
        p_Crime_ID,
        p_Crime_code,
        p_Charge_status,
        p_Fine_amount,
        p_Court_fee,
        p_Amount_paid,
        p_Pay_due_date
    );
END$$
DELIMITER ;