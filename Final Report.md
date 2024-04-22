<h3>1) Database design</h2>

a) Final version of E-R diagram

![image](https://github.com/kakary-cc/Crime-Tracking-Database-System/assets/165611994/f31fcd9b-4f78-4775-81bf-d46d6e7a7e1e)

b) Final version of in schema statements

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

---

<h3>2) Database programming</h3>

a) We hosted a MySQL database on a Raspberry Pi with public IP access.

b) This app is hosted on cloud, VPS instance (Linode)

c) fill out .env_template, rename to .env

run npm install

run node app.mjs

Open the weblink [http://cs3083.kakari.cc/](http://cs3083.kakari.cc/)

d) Advanced SQL commands are incorporated in your app

<h3>3) Describe the database security at the database level</h3>

a) The security is set for developers.

b) Users must first register/login to modify data in the database.

c) Relavent SQL commands to limited / set privileges

```
CREATE ROLE read_only;
CREATE ROLE data_entry;
CREATE ROLE db_admin;
GRANT SELECT ON database_name.* TO read_only;
GRANT INSERT, UPDATE ON database_name.* TO data_entry;
GRANT ALL PRIVILEGES ON database_name.* TO db_admin;
CREATE USER 'end_user'@'localhost' IDENTIFIED BY 'enduserpassword';
CREATE USER 'staff_user'@'localhost' IDENTIFIED BY 'staffuserpassword';
CREATE USER 'dev_user'@'localhost' IDENTIFIED BY 'devuserpassword';
GRANT read_only TO 'end_user'@'localhost';
GRANT data_entry TO 'staff_user'@'localhost';
GRANT db_admin TO 'dev_user'@'localhost';
FLUSH PRIVILEGES;
```

<h3>4) Describe the database security at the application level</h3>

a) The appliccation will mandate users to register by email with a 8-digits minimum password.

b) Submit code snippet(s) to illustrate how the security aspect is implemented and to support your discussion.

```
import * as argon2 from "argon2";
import db from "./db.mjs";

function User(email, role) {
    this.email = email;
    this.password = "";
    this.role = role;
    this.search = () => `SELECT * FROM Users WHERE Email LIKE "${this.email}";`;
    this.insert = () =>
        `INSERT INTO Users (Email, Passwd, role) VALUES ("${this.email}", "${this.password}", "${this.role}");`;
}

const startAuthenticatedSession = (req, user) => {
    return new Promise((fulfill, reject) => {
        req.session.regenerate((err) => {
            if (!err) {
                req.session.user = user;
                fulfill(user);
            } else {
                reject(err);
            }
        });
    });
};

const endAuthenticatedSession = (req) => {
    return new Promise((fulfill, reject) => {
        req.session.destroy((err) => (err ? reject(err) : fulfill(null)));
    });
};

const register = async (email, password, userRole) => {
    if (password.length < 8) throw { message: "PASSWORD TOO SHORT" };
    // TODO: Check for invalid email, potential SQL injection
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
    // TODO: Check for invalid email, potential SQL injection
    const newUser = new User(email);
    const result = await db.query(newUser.search());
    if (result[0].length === 0) throw { message: "USER NOT FOUND" };
    newUser.password = result[0][0].Passwd;
    if (!(await argon2.verify(newUser.password, password)))
        throw { message: "PASSWORDS DO NOT MATCH" };
    return newUser;
};

export { startAuthenticatedSession, endAuthenticatedSession, register, login };
```
