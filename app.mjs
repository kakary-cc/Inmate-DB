import express from "express";
import session from "express-session";
import path from "path";
import url from "url";
import "./config.mjs";
import db from "./db.mjs";
import * as auth from "./auth.mjs";
import * as interactive from "./db-interactive.mjs";

import { criminalRoutes } from "./routes/criminal.mjs";
import { crimeRoutes } from "./routes/crime.mjs";
import { crimeChargeRoutes } from "./routes/crime_charge.mjs";
import { appealRoutes } from "./routes/appeal.mjs";
import { sentenceRoutes } from "./routes/sentence.mjs";
import { officerRoutes } from "./routes/officer.mjs";
import { probOfficerRoutes } from "./routes/prob_officer.mjs";
import { crimeCodeRoutes } from "./routes/crime_code.mjs";

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

const publicPaths = [
    "/",
    "/login",
    "/register",
    "/officer",
    "/prob_officer",
    "/crime_code",
];

app.use((req, res, next) => {
    if (!publicPaths.includes(req.path)) {
        if (!req.session.user) {
            res.send(`<script>alert("Access denied. Please login first!");
            window.location.href = "/login";</script>`);
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
    res.render("./");
});

app.get("/login", (req, res) => {
    res.render("./login");
});

app.post("/login", async (req, res) => {
    try {
        const user = await auth.login(req.body.email, req.body.password);
        await auth.startAuthenticatedSession(req, user);
        res.redirect("/");
    } catch (err) {
        console.log(err);
        res.render("./register", {
            message: err.message ?? "Login unsuccessful",
        });
    }
});

app.get("/logout", async (req, res) => {
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

app.get("/register", (req, res) => {
    res.render("./register");
});

app.post("/register", async (req, res) => {
    try {
        const newUser = await auth.register(req.body.email, req.body.password);
        await auth.startAuthenticatedSession(req, newUser);
        res.redirect("/");
    } catch (err) {
        console.log(err);
        res.render("./register", {
            message: err.message ?? "Registration error",
        });
    }
});

/*
 * All routes follow the standard below:
 * GET     /                    | list all entities
 * GET     /new                 | show the form to create a new entity
 * POST    /new                 | create a new entity
 * GET     /:id                 | show details of a specific entity
 * POST    /:id                 | change attributes of a specific entity
 * POST    /:id?method=DELETE   | delete a specific entity
 * DELETE  /:id                 | delete a specific entity
 */

app.use("/criminal", criminalRoutes);
app.use("/crime", crimeRoutes);
app.use("/crime_charge", crimeChargeRoutes);
app.use("/appeal", appealRoutes);
app.use("/sentence", sentenceRoutes);

app.use("/officer", officerRoutes);
app.use("/prob_officer", probOfficerRoutes);

app.use("/crime_code", crimeCodeRoutes);

// TODO: ???
app.post("/addOfficer/:Crime_ID", async (req, res) => {
    const { Crime_ID } = req.params;
    const { officerID } = req.body;

    try {
        const result = await interactive.insertCrimeOfficer(
            Crime_ID,
            officerID
        );
        if (result.success) {
            res.redirect(`/crime/view/${Crime_ID}`);
        } else {
            res.status(400).send(result.message);
        }
    } catch (error) {
        console.error("Error linking officer to crime:", error);
        res.status(500).send("Server error in processing your request.");
    }
});

// TODO: This route doesn't logically make sense.
app.get("/addSentence/:ProbOfficer_ID", async (req, res) => {
    try {
        const { ProbOfficer_ID } = req.params;
        console.log(ProbOfficer_ID);
        res.render("./sentence/new", { ProbOfficer_ID });
    } catch (err) {
        console.error(err);
        res.status(500).send("Error loading the add sentence page.");
    }
});

app.post("/addSentence/:ProbOfficer_ID", async (req, res) => {
    const { ProbOfficer_ID } = req.params;
    const { criminalID, type, startDate, endDate, violations } = req.body;

    try {
        const result = await interactive.insertSentence(
            criminalID,
            type,
            ProbOfficer_ID,
            startDate,
            endDate,
            violations
        );
        if (result.success) {
            res.redirect(`/prob_officer/view/${ProbOfficer_ID}`);
        } else {
            res.status(400).send(result.message);
        }
    } catch (error) {
        console.error("Error in submitting sentence:", error);
        res.status(500).send("Server error in processing your request.");
    }
});

app.get("/crime-officer-union", async (req, res) => {
    try {
        const { source, id } = req.query;
        const links = await interactive.getAllCrimeOfficerLinks();
        const context = { links: links };

        if (source === "crime") {
            context.crimeID = id;
        } else if (source === "officer") {
            context.officerID = id;
        }

        res.render("./crimeOfficerUnion", context);
    } catch (err) {
        console.error(err);
        res.status(500).send("Error retrieving crime-officer links.");
    }
});

app.post("/crime-officer-union/link", async (req, res) => {
    const { crimeID, officerID } = req.body;
    try {
        const result = await interactive.insertCrimeOfficer(crimeID, officerID);
        if (result.success) {
            res.redirect("/crime-officer-union");
        } else {
            res.status(400).send(result.message);
        }
    } catch (error) {
        console.error("Error linking crime to officer:", error);
        res.status(500).send("Server error in processing your request.");
    }
});

app.post(
    "/crime-officer-union/unlink/:Crime_ID/:Officer_ID",
    async (req, res) => {
        const { Crime_ID, Officer_ID } = req.params;
        try {
            const result = await interactive.removeCrimeOfficerLink(
                Crime_ID,
                Officer_ID
            );
            if (result.success) {
                res.redirect("/crime-officer-union");
            } else {
                res.status(400).send(result.message);
            }
        } catch (error) {
            console.error("Error unlinking crime and officer:", error);
            res.status(500).send("Error processing your request.");
        }
    }
);

const port = process.env.EXPRESS_PORT || 3000;
app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
