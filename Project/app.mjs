import mysql from 'mysql2';

let con = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: "FAMURASAME"
});

con.connect(function(err) {
  if (err) throw err;
  console.log("Connected!");
});

let sql = "show databases;";

con.query(sql, function (err, result) {
  if (err) throw err;
  console.log("Result: " + result);
  console.log(result[0]);
});