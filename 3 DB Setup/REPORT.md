#### Updated E-R Diagram

![ERD](./images/ERD.png)

---

#### Database Server

We plan to host a MySQL database on DigitalOcean.

---

#### Table Schemas (a)
Table aliases

![Schema_2](./images/Schemas/Schema_2.png)

Table appeals

![Schema_3](./images/Schemas/Schema_3.png)

Table crimes

![Schema_4](./images/Schemas/Schema_4.png)

Table crime_charges

![Schema_8](./images/Schemas/Schema_8.png)

Table crime_codes

![Schema_9](./images/Schemas/Schema_9.png)

Table crime_officers

![Schema_1](./images/Schemas/Schema_1.png)

Table criminals

![Schema_5](./images/Schemas/Schema_5.png)

Table officers

![Schema_6](./images/Schemas/Schema_6.png)

Table prob_officers

![Schema_7](./images/Schemas/Schema_7.png)

Table Sentences 

![Schema_10](./images/Schemas/Schema_10.png)

---

#### Table Schemas (b)
Table aliases
![image](https://github.com/kakary-cc/Crime-Tracking-Database-System/assets/165611994/258aab57-9ee8-420c-bce6-8dd771c11775)

![image](https://github.com/kakary-cc/Crime-Tracking-Database-System/assets/165611994/7eb14f53-8d95-41a1-88f1-028530f08f95)

![image](https://github.com/kakary-cc/Crime-Tracking-Database-System/assets/165611994/14faeb91-2293-43f2-9d96-e6d6dca52cba)

![image](https://github.com/kakary-cc/Crime-Tracking-Database-System/assets/165611994/1f812c66-8489-431f-8d25-637973ebdd94)

![image](https://github.com/kakary-cc/Crime-Tracking-Database-System/assets/165611994/b99fc213-9385-4113-b91e-2dc4621a0160)

![image](https://github.com/kakary-cc/Crime-Tracking-Database-System/assets/165611994/10f3fc74-ca23-4253-b477-c79342eb0796)

![image](https://github.com/kakary-cc/Crime-Tracking-Database-System/assets/165611994/78e54c5f-e991-47da-9c84-9d960ac8dac5)

![image](https://github.com/kakary-cc/Crime-Tracking-Database-System/assets/165611994/67c111df-c2d5-4c88-9a1b-34041c61636e)

![image](https://github.com/kakary-cc/Crime-Tracking-Database-System/assets/165611994/b6d7ebc6-0691-4966-8cf3-d31c5d86d5f0)

![image](https://github.com/kakary-cc/Crime-Tracking-Database-System/assets/165611994/e26b3324-5735-4792-a309-1c7d9765d777)

#### Data Sample
Table aliases
![image](https://github.com/kakary-cc/Crime-Tracking-Database-System/assets/165611994/8f8a3181-05e2-4652-9f70-2af7d7a5e8ed)

![image](https://github.com/kakary-cc/Crime-Tracking-Database-System/assets/165611994/141c770f-d86b-42d1-8ca0-083c27d7956d)

![image](https://github.com/kakary-cc/Crime-Tracking-Database-System/assets/165611994/cb486d44-d047-48f9-90a0-4c9782081a9f)

![image](https://github.com/kakary-cc/Crime-Tracking-Database-System/assets/165611994/412f3e54-8d43-4c0e-adbb-0e8fab89229b)

![image](https://github.com/kakary-cc/Crime-Tracking-Database-System/assets/165611994/4175edd2-46d9-4662-9f9b-e6c3c17bc948)

![image](https://github.com/kakary-cc/Crime-Tracking-Database-System/assets/165611994/b2849318-9c93-4af1-926a-bd5c66ff7a6a)

![image](https://github.com/kakary-cc/Crime-Tracking-Database-System/assets/165611994/f65038bf-588e-4777-a2a9-8aa4689a2633)

![image](https://github.com/kakary-cc/Crime-Tracking-Database-System/assets/165611994/33076cbc-2bfb-4509-b8a2-55f6367cc72b)

![image](https://github.com/kakary-cc/Crime-Tracking-Database-System/assets/165611994/85485933-c4de-4b43-ac38-e7e0b97869b0)

![image](https://github.com/kakary-cc/Crime-Tracking-Database-System/assets/165611994/539feba9-d238-41f0-93bf-b9bcb62fe556)

#### Basic SQL Commands
CREATE PROCEDURE insert_criminal(
    IN p_Criminal_ID DECIMAL(6),
    IN p_Last VARCHAR(15),
    IN p_First VARCHAR(10),
    IN p_Street VARCHAR(30),
    IN p_City VARCHAR(20),
    IN p_State CHAR(2),
    IN p_Zip CHAR(5),
    IN p_Phone CHAR(10),
    IN p_V_status CHAR(1),
    IN p_P_status CHAR(1)
)

