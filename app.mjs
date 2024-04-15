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


// View and search within all crimes
app.get("/crime", (req, res) => {
    res.render("crime/", {});
});


const port =  process.env.EXPRESS_PORT || 3000;
app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});

// new criminal
app.post("/criminal/new_criminal", async (req, res) => {
    try {
        const { firstName, lastName, street, city, state, zipCode, phoneNumber, violent, probation } = req.body;

        const criminalDetails = {
            first: firstName,
            last: lastName,
            street: street,
            city: city,
            state: state,
            zip: zipCode,
            phone: phoneNumber,
            violent: violent === 'yes' ? 'Y' : 'N',
            probation: probation === 'yes' ? 'Y' : 'N'
        };

        await insertCriminal(criminalDetails);
        
        res.render("some_success_page", { message: "Criminal successfully added!" });
    } catch (err) {
        console.log(err);
        res.render("register", {
            message: err.message || "Create Criminal Unsuccessful",
        });
    }
});

async function insertCriminal(criminalDetails) {
    const { first, last, street, city, state, zip, phone, violent, probation } = criminalDetails;
    const query = `
        INSERT INTO Criminals (First, Last, Street, City, State, Zip, Phone, V_status, P_status)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);
    `;
    try {
        const result = await db.query(query, [first, last, street, city, state, zip, phone, violent, probation]);
        return result;
    } catch (err) {
        throw new Error('Failed to insert new criminal: ' + err.message);
    }
}
