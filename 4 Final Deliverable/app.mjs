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
    console.log(req.path, req.body);
    next();
});

// Test
db.query("show tables;", function (err, result) {
    if (err) throw err;
    result.forEach((row) => {
        console.log(row);
    });
});

app.get("/login", (req, res) => {
  res.render("login");
});

app.post("/login", async (req, res) => {
  try {
    const user = await auth.login(
      sanitize(req.body.username),
      req.body.password
    );
    await auth.startAuthenticatedSession(req, user);
    res.redirect("/");
  } catch (err) {
    console.log(err);
    res.render("login", {
      message: loginMessages[err.message] ?? "Login unsuccessful",
    });
  }
});

app.get("/register", (req, res) => {
  res.render("register");
});

app.post("/register", async (req, res) => {
  try {
    const newUser = await auth.register(
      sanitize(req.body.username),
      sanitize(req.body.email),
      req.body.password
    );
    await auth.startAuthenticatedSession(req, newUser);
    res.redirect("/");
  } catch (err) {
    console.log(err);
    res.render("register", {
      message: registrationMessages[err.message] ?? "Registration error",
    });
  }
});

// View and search within all criminals
app.get("/criminal", (req, res) => {
    res.render("criminal/");
});

// View details of a criminal
app.get("/criminal/view/:id", (req, res) => {
    res.render("criminal/view");
});

// Add a criminal
app.get("/criminal/new", (req, res) => {
    res.render("criminal/new");
});


app.listen(process.env.EXPRESS_PORT);
