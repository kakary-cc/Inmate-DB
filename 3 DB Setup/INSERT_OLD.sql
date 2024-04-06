USE Jail_DB;

INSERT INTO Criminals (Criminal_ID, Last, First, Street, City, State, Zip, Phone, V_status, P_status) VALUES
(100001, 'Smith', 'John', '123 Baker St', 'Gotham', 'NY', '12345', '5551234567', 'N', 'N'),
(100002, 'Doe', 'Jane', '456 Elm St', 'Metropolis', 'IL', '23456', '5552345678', 'Y', 'N');

INSERT INTO Aliases (Alias_ID, Criminal_ID, Alias) VALUES
(200001, 100001, 'Johnny'),
(200002, 100002, 'JD'),
(200003, 100001, 'J.Smith'),
(200004, 100002, 'JaneD');

INSERT INTO Crimes (Crime_ID, Criminal_ID, Classification, Date_charged, Status, Hearing_date, Appeal_cut_date) VALUES
(300000001, 100001, 'F', '2023-01-01', 'CL', '2023-01-15', '2023-02-01'),
(300000002, 100002, 'M', '2023-02-01', 'CA', '2023-02-15', '2023-03-15');

INSERT INTO Prob_officers (Prob_ID, Last, First, Street, City, State, Zip, Phone, Email, Status) VALUES
(40001, 'Johnson', 'Mike', '789 Pine St', 'Central City', 'CO', '34567', '5553456789', 'mike.j@justice.gov', 'A'),
(40002, 'Williams', 'Anna', '101 Oak St', 'Star City', 'WA', '45678', '5554567890', 'anna.w@justice.gov', 'A');

INSERT INTO Sentences (Sentence_ID, Criminal_ID, Type, Prob_ID, Start_date, End_date, Violations) VALUES
(500001, 100001, 'P', 40001, '2023-01-15', '2024-01-14', 0),
(500002, 100002, 'J', 40002, '2023-02-15', '2023-12-15', 1);

INSERT INTO Crime_codes (Crime_code, Code_description) VALUES
(1, 'Theft'),
(2, 'Robbery');

INSERT INTO Crime_charges (Charge_ID, Crime_ID, Crime_code, Charge_status, Fine_amount, Court_fee, Amount_paid, Pay_due_date) VALUES
(6000000001, 300000001, 1, 'PD', 500.0, 50.0, 0.0, '2023-03-01'),
(6000000002, 300000002, 2, 'GL', 1000.0, 100.0, 0.0, '2023-04-01');

INSERT INTO Officers (Officer_ID, Last, First, Precinct, Badge, Phone, Status) VALUES
(70000001, 'Brown', 'Chris', '1234', '123-ABC', '5555678901', 'A'),
(70000002, 'Davis', 'Emily', '5678', '456-DEF', '5556789012', 'A');

INSERT INTO Crime_officers (Crime_ID, Officer_ID) VALUES
(300000001, 70000001),
(300000002, 70000002);

INSERT INTO Appeals (Appeal_ID, Crime_ID, Filling_date, Hearing_date, Status) VALUES
(80001, 300000001, '2023-02-01', '2023-04-01', 'P'),
(80002, 300000002, '2023-03-01', '2023-05-01', 'P');