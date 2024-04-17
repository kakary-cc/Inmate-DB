import express from "express";
import session from "express-session";
import path from "path";
import url from "url";
import "./config.mjs";
import db from "./db.mjs";
import * as auth from "./auth.mjs";
import * as interactive from "./db-interactive.mjs";

const __dirname = path.dirname(url.fileURLToPath(import.meta.url));

const app = express();

app.use(express.json());

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
        console.log("Error ending session:", err);
        res.status(500).send("Failed to log out");
    }
    res.redirect("/");
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


// View details of a criminal
app.get("/criminal/view/:id", (req, res) => {
    res.render("criminal/view");
});

// Add a criminal
app.get("/criminal/newin", (req, res) => {
    res.render("criminal/new");
});

// View and search within all crimes
app.get("/crime", (req, res) => {
    res.render("crime/", {});
});

// new criminal
app.post("/criminal/new", async (req, res) => {
    try {
        const {
            firstName,
            lastName,
            street,
            city,
            state,
            zipCode,
            phoneNumber,
            violent,
            probation,
        } = req.body;

        const criminalDetails = {
            first: firstName,
            last: lastName,
            street: street,
            city: city,
            state: state,
            zip: zipCode,
            phone: phoneNumber,
            violent: violent === "yes" ? "Y" : "N",
            probation: probation === "yes" ? "Y" : "N",
        };

        const result = await interactive.insertCriminal(criminalDetails);
        res.send(
            `<script>alert("Criminal successfully added!"); window.location.href = "/criminal/all"; </script>`
        );
    } catch (err) {
        console.log(err);
        res.send(
            `<script>alert("Create Criminal Unsuccessful"); window.location.href = "/criminal/new"; </script>`
        );
    }
});

// get all criminals
app.get("/criminal/all", async (req, res) => {
    try {
        let criminals = await interactive.getAllCriminals();
        criminals = criminals.map(criminal => ({
            ...criminal,
            Violent: criminal.V_status === 'Y' ? 'Yes' : 'No',
            Probation: criminal.P_status === 'Y' ? 'Yes' : 'No'
        }));
        res.render("criminal/all", { criminals: criminals });
    } catch (err) {
        console.error(err);
        res.status(500).send("Error retrieving criminals.");
    }
});

// display a single criminal in detail
app.get("/criminal/details/:Criminal_ID", async (req, res) => {
    try {
        const criminalID = req.params.Criminal_ID;
        const criminalDetails = await interactive.getCriminalDetails(criminalID);

        if (!criminalDetails) {
            res.status(404).send('Criminal not found');
        } else {
            criminalDetails.selectedYesViolent = criminalDetails.V_status === 'Y';
            criminalDetails.selectedNoViolent = criminalDetails.V_status === 'N';
            criminalDetails.selectedYesProbation = criminalDetails.P_status === 'Y';
            criminalDetails.selectedNoProbation = criminalDetails.P_status === 'N';

            res.render("criminal/single", { criminal: criminalDetails });
        }
    } catch (err) {
        console.error(err);
        res.status(500).send("Error retrieving criminal details.");
    }
});


app.post('/criminal/update/:field', async (req, res) => {
    console.log(req.body);
    const { id, value } = req.body;
    console.log(id, value);
    const field = req.params.field;
    try {
        await interactive.updateCriminalField(id, field, value);
        res.json({ success: true });
    } catch (err) {
        console.error('Failed to update:', err);
        res.json({ success: false });
    }
});

app.post('/criminal/delete/:criminalId', async (req, res) => {
    const criminalId = req.params.criminalId;

    try {
        const result = await interactive.deleteCriminalById(criminalId);
        if (result.success) {
            res.json({ success: true, message: "Criminal successfully deleted." });
        } else {
            res.status(500).json({ success: false, message: "Failed to delete criminal." });
        }
    } catch (error) {
        console.error("Error deleting criminal:", error);
        res.status(500).json({ success: false, message: "Error deleting criminal." });
    }
});


const port = process.env.EXPRESS_PORT || 3000;
app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
