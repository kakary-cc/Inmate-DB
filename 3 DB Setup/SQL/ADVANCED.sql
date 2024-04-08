USE jail;

-- Count total fine for a crime
DELIMITER //
CREATE OR REPLACE FUNCTION get_Total_fines(criminalID DECIMAL(6)) RETURNS DECIMAL(10,2)
BEGIN
    DECLARE totalFines DECIMAL(10,2);
    SELECT COALESCE(SUM(Fine_amount), 0) INTO totalFines
    FROM Crime_charges 
    INNER JOIN Crimes ON Crimes.Crime_ID = Crime_charges.Crime_ID
    WHERE Crimes.Criminal_ID = criminalID AND Crime_charges.Charge_status = 'GL';

    RETURN totalFines;
END//
DELIMITER ;

-- Update Crime charges
DELIMITER @@
CREATE OR REPLACE TRIGGER update_Crime_after_Appeal
AFTER UPDATE ON Appeals
FOR EACH ROW
BEGIN
    IF NEW.Status = 'A' THEN
        -- Update Crime_charges related to the crime of the successful appeal
        UPDATE Crime_charges
        JOIN Crimes ON Crime_charges.Crime_ID = Crimes.Crime_ID
        SET Crime_charges.Amount_paid = 0, Crime_charges.Charge_status = 'NG'
        WHERE Crimes.Crime_ID = NEW.Crime_ID;

        -- Update the status of the related crime to 'CL' (Closed)
        UPDATE Crimes
        SET Status = 'CL'
        WHERE Crime_ID = NEW.Crime_ID;
    END IF;
END @@

DELIMITER ;

-- Update Criminal srobation status
DELIMITER @@
CREATE OR REPLACE TRIGGER update_Criminal_Probation_status
AFTER UPDATE ON Sentences
FOR EACH ROW
BEGIN
    IF NEW.Type = 'P' THEN
        -- Update Crime_charges related to the crime of the successful appeal
        UPDATE Criminals
        SET Criminals.P_status = 'Y'
        WHERE Criminals.Criminal_ID = NEW.Criminal_ID;
        AND NEW.Start_date > GETDATE()
        AND NEW.End_date < GETDATE();

    END IF;
END @@

DELIMITER ;
