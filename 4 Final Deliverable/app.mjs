import express from "express";
import session from "express-session";
import path from "path";
import url from "url";

import "./config.mjs";
import db from "./db.mjs";
import * as auth from "./auth.mjs";

const __dirname = path.dirname(url.fileURLToPath(import.meta.url));

const app = express();

app.use(express.static(path.join(__dirname, "public")));

app.set("view engine", "hbs");

app.use(express.urlencoded({ extended: false }));

app.use(
    session({
        secret: "secret",
        resave: false,
        saveUninitialized: true,
    })
);

// TODO
// const authRequiredPaths = ["/criminals/add", "crime_charges/add"];
const authRequiredPaths = [];

app.use((req, res, next) => {
    if (authRequiredPaths.includes(req.path)) {
        if (!req.session.user) {
            res.redirect("/login");
            return;
        }
    }
    next();
});

app.use((req, res, next) => {
    res.locals.user = req.session.user;
    next();
});

app.use((req, res, next) => {
    console.log(req.path.toUpperCase(), req.body);
    next();
});

// Test
db.query("show tables;", function (err, result) {
    if (err) throw err;
    result.forEach((row) => {
        console.log(row);
    });
});

// View and search within all criminals
app.get("/criminal", (req, res) => {
    res.render("criminal");
});

// View details of a criminal
app.get("/criminal/view/:id", (req, res) => {
    res.render("criminal_view");
});

// Add a criminal
app.get("/criminal/new", (req, res) => {
    res.render("criminal_new");
});


app.listen(process.env.EXPRESS_PORT);
