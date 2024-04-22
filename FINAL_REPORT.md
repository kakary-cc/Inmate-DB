Source Code:

Deployed Project: [http://cs3083.kakari.cc/](http://cs3083.kakari.cc/)

---

Micheal Zhang (`mz3164`), William Zhou (`wwz2003`), Tony Zhang (`jz4263`)

---

#### 1. Database Design

##### a) E-R Diagram

![image](https://github.com/kakary-cc/Crime-Tracking-Database-System/assets/165611994/f31fcd9b-4f78-4775-81bf-d46d6e7a7e1e)

##### b) Schema Statements

Criminal(<ins>ID</ins>, Last, First, Street, City, State, Zip, Phone, V_status, P_status)

Alias(<ins>Alias_ID</ins>, @Criminal_ID, Alias)

Crimes(<ins>Crime_ID</ins>, @Criminal_ID, Classification, Date_charged, Status, Hearing_date, Appeal_cut_date)

Prob_Officer(<ins>Prob_ID</ins>, Last, First, Street, City, State, Zip, Phone, Email, Status)

Sentences(<ins>Sentence_ID</ins>, @Criminal_ID, @Prob_ID, Type, Start_date, End_date, Violations)

Officers(<ins>Officer_ID</ins>, Last, First, Precinct, Badge, Phone, Status)

Crime_Codes(<ins>Crime_code</ins>, Code_description)

Crime_Charges(<ins>Charge_ID</ins>, @Crime_ID, @Crime_code, Charge_status, Fine_amount, Court_fee, Amount_paid, Pay_due_date)

Crime_Officers(<ins>@Crime_ID</ins>, <ins>@Officer_ID</ins>)

Appeals(<ins>Appeal_ID</ins>, @Crime_ID, Filing_date, Hearing_date, Status)

Users(<u>User_ID</u>, Email, Passwd, Role, Status)

---

#### 2. Database Programming

##### a)

The MySQL database is hosted on a Raspberry Pi with public IP access.

##### b)

This application is hosted on a cloud VPS.

##### c)

Fill out `.env_template`, rename to `.env`

Run `npm install`

Run `node app.mjs`

##### d)

A multitude of stored procedures are used to make insertions, deletions, and retrievals safe from SQL injections and other primitive attacks.

The `CHECK` constraints add an additional layer of protection for data sanity

Triggers such as update_Crime_after_Appeal and update_Criminal_Probation_status are implemented to ensure data integrity. 

---

#### 3. Database Security (Database Level)

##### a)

The security is set for developers.

Database users must be authenticated to have data modification privileges.

`root` account will not be used except during the initial setup phase.

##### c)

```
CREATE ROLE read_only;
CREATE ROLE data_entry;
CREATE ROLE db_admin;
GRANT SELECT ON jail.* TO read_only;
GRANT INSERT, UPDATE ON jail.* TO data_entry;
GRANT ALL PRIVILEGES ON jail.* TO db_admin;
CREATE USER 'end_user'@'localhost' IDENTIFIED BY 'enduserpassword';
CREATE USER 'staff_user'@'localhost' IDENTIFIED BY 'staffuserpassword';
CREATE USER 'dev_user'@'localhost' IDENTIFIED BY 'devuserpassword';
GRANT read_only TO 'end_user'@'localhost';
GRANT data_entry TO 'staff_user'@'localhost';
GRANT db_admin TO 'dev_user'@'localhost';
FLUSH PRIVILEGES;
```

---

#### 4. Database Security (Application Level)

##### a)

The application will mandate users to register by email with an 8-digit minimum password.

The user's password is salted and hashed using the state-of-the-art cryptographic algorithm Argon2, before being stored in the database.

The application will block access to sensitive data for non-logged-in users.

The database URI and credentials are stored locally in environmental variables, hidden from front-end users and version controls.

On input forms, the front-end application enforces certain integrity checks.

##### b)

```
const register = async (email, password, userRole) => {
    if (password.length < 8) throw { message: "PASSWORD TOO SHORT" };
    const validRoles = ['read_only', 'data_entry', 'db_admin'];
    if (!validRoles.includes(userRole)) throw { message: "INVALID USER ROLE" };
    const newUser = new User(email, userRole);
    if ((await db.query(newUser.search()))[0].length !== 0)
        throw { message: "EMAIL ALREADY EXISTS" };
    newUser.password = await argon2.hash(password);
    await db.query(newUser.insert());
    return newUser;
};

const login = async (email, password) => {
    const newUser = new User(email);
    const result = await db.query(newUser.search());
    if (result[0].length === 0) throw { message: "USER NOT FOUND" };
    newUser.password = result[0][0].Passwd;
    if (!(await argon2.verify(newUser.password, password)))
        throw { message: "PASSWORDS DO NOT MATCH" };
    return newUser;
};
```
