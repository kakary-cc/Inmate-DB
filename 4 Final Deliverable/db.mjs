import mysql from "mysql2"; // https://sidorares.github.io/node-mysql2/docs

let db = mysql.createConnection({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASS,
    database: process.env.DB_NAME,
});

db.connect((err) => {
    if (err) throw err;
    console.log("Connected!");
});

export default db;
