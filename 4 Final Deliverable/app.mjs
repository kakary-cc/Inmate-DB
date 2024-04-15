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

const authRequiredPaths = [
    "/criminal/new",
    "/crime/new",
    "/appeal/new",
    "/crime-code/new",
];

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

app.get("/", (req, res) => {
    res.render("index");
});

app.get("/login", (req, res) => {
    res.render("login");
});


app.post("/logout", async (req, res) => {
    try {
        if (req.session.user) {
            await auth.endAuthenticatedSession(req);
        }
    } catch (err) {
        console.log('Error ending session:', err);
        res.status(500).send("Failed to log out");
    }
    res.redirect("/")
});

app.post("/login", async (req, res) => {
    try {
        const user = await auth.login(req.body.email, req.body.passwd);
        await auth.startAuthenticatedSession(req, user);
        res.redirect("/");
    } catch (err) {
        console.log(err);
        res.render("register", {
            message: err.message ?? "Login unsuccessful",
        });
    }
});

app.get("/register", (req, res) => {
    res.render("register");
});

app.post("/register", async (req, res) => {
    try {
        const newUser = await auth.register(req.body.email, req.body.passwd);
        await auth.startAuthenticatedSession(req, newUser);
        res.redirect("/");
    } catch (err) {
        console.log(err);
        res.render("register", {
            message: err.message ?? "Registration error",
        });
    }
});

// View and search within all criminals
app.get("/criminal", (req, res) => {
    res.render("criminal/", {});
});

// View details of a criminal
app.get("/criminal/view/:id", (req, res) => {
    res.render("criminal/view");
});

// Add a criminal
app.get("/criminal/new", (req, res) => {
    res.render("criminal/new");
});

const port =  process.env.EXPRESS_PORT || 3000;
app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
