1) Database design

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

2) Database programming

a) We hosted a MySQL database on a Raspberry Pi with public IP access.

b) This app is hosted on cloud, VPS instance (Linode)

c) fill out .env_template, rename to .env

run npm install

run node app.mjs

Open the weblink [http://cs3083.kakari.cc/](http://cs3083.kakari.cc/)

d) Advanced SQL commands are incorporated in your app

3) Describe the database security at the database level

a) Specify whether the security is set for developers or end users

b) Discuss how you set up security at the database level (access control)

c) Relavent SQL commands to limited / set privileges

4) Describe the database security at the application level

a) Discuss how database security at the application level is incorporated in your
project.

b) Submit code snippet(s) to illustrate how the security aspect is implemented and to support your discussion.

