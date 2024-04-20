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
    res.render("./");
});

app.get("/login", (req, res) => {
    res.render("./login");
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

// Add a criminal
app.get("/criminal/new", (req, res) => {
    res.render("./criminal/new");
});

// View and search within all crimes
app.get("/crime", (req, res) => {
    res.render("./crime", {});
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
app.get("/criminal", async (req, res) => {
    try {
        let criminals = await interactive.getAllCriminals();
        criminals = criminals.map((criminal) => ({
            ...criminal,
            Violent: criminal.V_status === "Y" ? "Yes" : "No",
            Probation: criminal.P_status === "Y" ? "Yes" : "No",
        }));
        res.render("./criminal", { criminals: criminals });
    } catch (err) {
        console.error(err);
        res.status(500).send("Error retrieving criminals.");
    }
});

// display a single criminal in detail
app.get("/criminal/view/:Criminal_ID", async (req, res) => {
    try {
        const criminalID = req.params.Criminal_ID;
        const criminalDetails = await interactive.getCriminalDetails(
            criminalID
        );
        const criminalSentences = await interactive.getCriminalSentences(
            criminalID
        );
        const criminalCrimes = await interactive.getCriminalCrimes(criminalID);

        if (!criminalDetails) {
            res.status(404).send("Criminal not found");
        } else {
            criminalDetails.selectedYesViolent =
                criminalDetails.V_status === "Y";
            criminalDetails.selectedNoViolent =
                criminalDetails.V_status === "N";
            criminalDetails.selectedYesProbation =
                criminalDetails.P_status === "Y";
            criminalDetails.selectedNoProbation =
                criminalDetails.P_status === "N";

            const formattedSentences = criminalSentences.map((sentence) => {
                return {
                    ...sentence,
                    Start_date: formatDate(sentence.Start_date),
                    End_date: formatDate(sentence.End_date),
                };
            });

            const formattedCrimes = criminalCrimes.map((crime) => {
                return {
                    ...crime,
                    Date_charged: formatDate(crime.Date_charged),
                    Hearing_date: formatDate(crime.Hearing_date),
                    Appeal_cut_date: formatDate(crime.Appeal_cut_date),
                };
            });

            res.render("./criminal/view", {
                criminal: criminalDetails,
                sentences: formattedSentences,
                crimes: formattedCrimes,
            });
        }
    } catch (err) {
        console.error(err);
        res.status(500).send("Error retrieving criminal details.");
    }
});

function formatDate(dateValue) {
    if (!dateValue) return "";
    return new Date(dateValue).toISOString().split("T")[0]; // Converts date to YYYY-MM-DD format
}

// update a single field for a single criminal
app.post("/criminal/update/:field", async (req, res) => {
    const { id, value } = req.body;
    const field = req.params.field;
    try {
        await interactive.updateCriminalField(id, field, value);
        res.json({ success: true });
    } catch (err) {
        console.error("Failed to update:", err);
        res.json({ success: false });
    }
});

// delete a single criminal
app.delete("/criminal/delete/:criminalId", async (req, res) => {
    const criminalId = req.params.criminalId;

    try {
        const result = await interactive.deleteCriminalById(criminalId);
        if (result.success) {
            res.json({
                success: true,
                message: "Criminal successfully deleted.",
            });
        } else {
            res.status(500).json({
                success: false,
                message: "Failed to delete criminal.",
            });
        }
    } catch (error) {
        console.error("Error deleting criminal:", error);
        res.status(500).json({
            success: false,
            message: "Error deleting criminal.",
        });
    }
});

// add a sentence for a criminal: the page
app.get("/sentence/new", async (req, res) => {
    // TODO: Get Criminal_ID from param.
    try {
        const { Criminal_ID } = req.params;
        res.render("./sentence/new", { criminal_ID: Criminal_ID });
    } catch (err) {
        console.error(err);
        res.status(500).send("Error loading the add sentence page.");
    }
});

// add a sentence for a criminal: the backend
app.post("/criminal/addSentence/:Criminal_ID", async (req, res) => {
    const { Criminal_ID } = req.params;
    const { type, probID, startDate, endDate, violations } = req.body;

    try {
        const result = await interactive.insertSentence(
            Criminal_ID,
            type,
            probID,
            startDate,
            endDate,
            violations
        );
        if (result.success) {
            res.redirect(`/criminal/view/${Criminal_ID}`);
        } else {
            res.status(500).send(
                "Inner Error inserting new sentence for criminal"
            );
        }
    } catch (error) {
        console.error("Error inserting sentence:", error);
        res.status(500).render("./error", {
            error: "Outer Error inserting sentence.",
        });
    }
});

// add a sentence for a criminal: the page
app.get("/crime/add", async (req, res) => {
    // Ger Criminal_ID from param
    try {
        const { Criminal_ID } = req.params;
        res.render("./crime/new", { criminal_ID: Criminal_ID });
    } catch (err) {
        console.error(err);
        res.status(500).send("Error loading the add sentence page.");
    }
});

// add a crime for a criminal: the backend
app.post("/criminal/addCrime/:Criminal_ID", async (req, res) => {
    const { Criminal_ID } = req.params;
    const { classification, dateCharged, status, hearingDate, appealCutDate } =
        req.body;

    try {
        const result = await interactive.insertCrime(
            Criminal_ID,
            classification,
            dateCharged,
            status,
            hearingDate,
            appealCutDate
        );
        if (result.success) {
            res.redirect(`/criminal/view/${Criminal_ID}`);
        } else {
            res.status(400).send(result.message);
        }
    } catch (error) {
        console.error("Error in submitting crime:", error);
        res.status(500).send("Server error in processing your request.");
    }
});

// add a probation officer: the page
app.get("/prob_officer/new", (req, res) => {
    res.render("./prob_officer/new");
});

// add a probation officer: the backend
app.post("/prob_officer/new", async (req, res) => {
    const {
        firstName,
        lastName,
        street,
        city,
        state,
        zipCode,
        phoneNumber,
        email,
        status,
    } = req.body;

    try {
        const result = await interactive.insertProbationOfficer(
            firstName,
            lastName,
            street,
            city,
            state,
            zipCode,
            phoneNumber,
            email,
            status
        );
        if (result.success) {
            res.redirect("/prob_officer");
        } else {
            res.status(500).send("Failed to create probation officer.");
        }
    } catch (error) {
        console.error("Error creating new probation officer:", error);
        res.status(500).send("Error creating probation officer.");
    }
});

// get all probation officers
app.get("/prob_officer", async (req, res) => {
    try {
        let probOfficers = await interactive.getAllProbOfficers();
        res.render("./prob_officer", { probOfficers: probOfficers });
    } catch (err) {
        console.error(err);
        res.status(500).send("Error retrieving probation officers.");
    }
});

// get a single probation officer
app.get("/prob_officer/view/:Prob_ID", async (req, res) => {
    try {
        const probID = req.params.Prob_ID;
        const probOfficerDetails = await interactive.getProbationOfficerById(
            probID
        );
        const [probOfficerSentences] =
            await interactive.getProbationOfficerSentences(probID);

        if (!probOfficerDetails) {
            res.status(404).send("Probation officer not found");
        } else {
            const formattedSentences = probOfficerSentences.map((sentence) => {
                return {
                    ...sentence,
                    Start_date: formatDate(sentence.Start_date),
                    End_date: formatDate(sentence.End_date),
                };
            });
            probOfficerDetails.StatusActive = probOfficerDetails.Status === "A";
            probOfficerDetails.StatusInactive =
                probOfficerDetails.Status === "I";
            res.render("./prob_officer/view", {
                probOfficer: probOfficerDetails,
                sentences: formattedSentences,
            });
        }
    } catch (err) {
        console.error("Error retrieving probation officer details:", err);
        res.status(500).send("Error retrieving probation officer details.");
    }
});

// delete a probation officer
app.post("/prob_officer/delete/:probOfficerId", async (req, res) => {
    const probOfficerId = req.params.probOfficerId;

    try {
        const result = await interactive.deleteProbOfficerByID(probOfficerId);
        if (result.success) {
            res.json({
                success: true,
                message: "Probation officer successfully deleted.",
            });
        } else {
            res.status(500).json({
                success: false,
                message: "Failed to delete probation officer.",
            });
        }
    } catch (error) {
        console.error("Error deleting probation officer:", error);
        res.status(500).json({
            success: false,
            message: "Error deleting probation officer.",
        });
    }
});

app.post("/prob_officer/update/:field", async (req, res) => {
    const { id, value } = req.body;
    const field = req.params.field;

    try {
        const validFields = [
            "First",
            "Last",
            "Street",
            "City",
            "State",
            "Zip",
            "Phone",
            "Email",
            "Status",
        ];

        // bare of handling potential SQL injections (future reference)
        if (!validFields.includes(field)) {
            return res.status(400).json({
                success: false,
                message: "Invalid field name for update.",
            });
        }

        await interactive.updateProbOfficerField(id, field, value);
        res.json({
            success: true,
            message: "Probation officer updated successfully.",
        });
    } catch (error) {
        console.error(
            `Error updating probation officer field ${field}:`,
            error
        );
        res.status(500).json({
            success: false,
            message: "Failed to update probation officer.",
        });
    }
});

// get all crimes
app.get("/crime", async (req, res) => {
    try {
        const Crimes = await interactive.getAllCrimes();

        const formattedCrimes = Crimes.map((crime) => {
            return {
                ...crime,
                Date_charged: formatDate(crime.Date_charged),
                Hearing_date: formatDate(crime.Hearing_date),
                Appeal_cut_date: formatDate(crime.Appeal_cut_date),
            };
        });

        res.render("./crime", { Crimes: formattedCrimes });
    } catch (err) {
        console.error(err);
        res.status(500).send("Error retrieving crimes.");
    }
});

// get crime by id
app.get("/crime/view/:Crime_ID", async (req, res) => {
    try {
        const { Criminal_ID, Crime_ID } = req.params;
        const Crime = await interactive.getCrimeById(Crime_ID);
        const [appeals] = await interactive.getAppealsByCrimeID(Crime_ID);
        const [charges] = await interactive.getCrimeChargesByCrimeID(Crime_ID);
        const [aliases] = await interactive.getAliasesByCriminalID(Criminal_ID);
        const [officers] = await interactive.getOfficersByCrimeID(Crime_ID);

        Crime.Date_charged = formatDate(Crime.Date_charged);
        Crime.Hearing_date = formatDate(Crime.Hearing_date);
        Crime.Appeal_cut_date = formatDate(Crime.Appeal_cut_date);

        const formattedAppeals = appeals.map((appeal) => {
            return {
                ...appeal,
                Filling_date: formatDate(appeal.Filling_date),
                Hearing_date: formatDate(appeal.Hearing_date),
                Appeal_cut_date: formatDate(appeal.Appeal_cut_date),
            };
        });

        const formattedCharges = charges.map((charge) => ({
            ...charge,
            Pay_due_date: formatDate(charge.Pay_due_date),
        }));

        if (!Crime) {
            res.status(404).send("Crime not found");
        } else {
            res.render("./crime/view", {
                crime: Crime,
                formattedAppeals,
                formattedCharges,
                aliases,
                officers,
            });
        }
    } catch (err) {
        console.error(err);
        res.status(500).send("Error retrieving crime details.");
    }
});

// add appeal by crime_ID: the frontend
app.get("/appeal/new", async (req, res) => {
    // TODO: Get Crime_ID from pram
    try {
        const { Crime_ID } = req.params;
        res.render("./appeal/new", { crime_ID: Crime_ID });
    } catch (err) {
        console.error(err);
        res.status(500).send("Error loading the add appeal page.");
    }
});

// add appeal by crime_ID: the backend
app.post("/crime/addAppeal/:Crime_ID", async (req, res) => {
    const { Crime_ID } = req.params;
    const { fillingDate, hearingDate, status } = req.body;

    try {
        const result = await interactive.addAppealByCrimeID(
            Crime_ID,
            fillingDate,
            hearingDate,
            status
        );
        if (result.success) {
            res.redirect(`/crime/view/${Crime_ID}`);
        } else {
            res.status(400).send(result.message);
        }
    } catch (error) {
        console.error("Error in submitting appeal:", error);
        res.status(500).send("Server error in processing your request.");
    }
});

// add charge by crime_ID: the frontend
app.get("/crime_charge/new", async (req, res) => {
    // Get Crime_ID from param
    try {
        const { Crime_ID } = req.params;
        res.render("./charge/new", { crime_ID: Crime_ID });
    } catch (err) {
        console.error(err);
        res.status(500).send("Error loading the add charge page.");
    }
});

// add charge by crime_ID: the backend
app.post("/crime/addCharge/:Crime_ID", async (req, res) => {
    const { Crime_ID } = req.params;
    const {
        crimeCode,
        chargeStatus,
        fineAmount,
        courtFee,
        amountPaid,
        payDueDate,
    } = req.body;

    try {
        const result = await interactive.insertCrimeChargeByCrimeID(
            Crime_ID,
            crimeCode,
            chargeStatus,
            fineAmount,
            courtFee,
            amountPaid,
            payDueDate
        );
        if (result.success) {
            res.redirect(`/crime/view/${Crime_ID}`);
        } else {
            res.status(400).send(result.message);
        }
    } catch (error) {
        console.error("Error in submitting crime charge:", error);
        res.status(500).send("Server error in processing your request.");
    }
});

// TODO: This route doesn't logically make sense.
app.get("/prob_officer/addSentence/:ProbOfficer_ID", async (req, res) => {
    try {
        const { ProbOfficer_ID } = req.params;
        console.log(ProbOfficer_ID);
        res.render("./sentence/new", { ProbOfficer_ID });
    } catch (err) {
        console.error(err);
        res.status(500).send("Error loading the add sentence page.");
    }
});

app.post("/prob_officer/addSentence/:ProbOfficer_ID", async (req, res) => {
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

// TODO: add Alias
app.get("/criminal/alias/new", async (req, res) => {
    // TODO: Get Criminal_ID from param
    try {
        const { Criminal_ID } = req.params;
        res.render("./criminal/alias/new", { Criminal_ID });
    } catch (err) {
        console.error(err);
        res.status(500).send("Error loading the add sentence page.");
    }
});

app.post("/criminal/addAlias/:Criminal_ID", async (req, res) => {
    const { Criminal_ID } = req.params;
    const { alias } = req.body;

    try {
        const result = await interactive.insertAlias(Criminal_ID, alias);
        if (result.success) {
            res.redirect(`/criminal/view/${Criminal_ID}`);
        } else {
            res.status(400).send(result.message);
        }
    } catch (error) {
        console.error("Error in submitting alias:", error);
        res.status(500).send("Server error in processing your request.");
    }
});

// create an officer: the frontend
app.get("/officer/new", (req, res) => {
    res.render("./officer/new");
});

// create an officer: the backend
app.post("/officer/new", async (req, res) => {
    const { firstName, lastName, precinct, badge, phone, status } = req.body;

    try {
        const result = await interactive.insertOfficer(
            lastName,
            firstName,
            precinct,
            badge,
            phone,
            status
        );
        if (result.success) {
            res.redirect("/officer");
        } else {
            res.status(500).send("Failed to create officer.");
        }
    } catch (error) {
        console.error("Error creating new officer:", error);
        res.status(500).send("Error creating officer.");
    }
});

app.get("/officer", async (req, res) => {
    try {
        let officers = await interactive.getAllOfficers();

        res.render("./officer", { officers: officers });
    } catch (err) {
        console.error(err);
        res.status(500).send("Error retrieving officers.");
    }
});

app.get("/officer/view/:Officer_ID", async (req, res) => {
    try {
        const officerID = req.params.Officer_ID;
        const [officerDetails] = await interactive.getOfficerById(officerID);
        const [crimes] = await interactive.getCrimesByOfficerID(officerID);

        if (!officerDetails) {
            res.status(404).send("Officer not found");
        } else {
            res.render("./officer/view", { officer: officerDetails, crimes });
        }
    } catch (err) {
        console.error(err);
        res.status(500).send("Error retrieving officer details.");
    }
});

app.post("/officer/delete/:Officer_ID", async (req, res) => {
    const officerID = req.params.Officer_ID;

    try {
        const result = await interactive.deleteOfficerByID(officerID);
        if (result.success) {
            res.json({
                success: true,
                message: "Officer successfully deleted.",
            });
        } else {
            res.status(500).json({
                success: false,
                message: "Failed to delete officer.",
            });
        }
    } catch (error) {
        console.error("Error deleting officer:", error);
        res.status(500).json({
            success: false,
            message: "Error deleting officer.",
        });
    }
});

app.post("/crime/addOfficer/:Crime_ID", async (req, res) => {
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

// TODO: Why do we need this?
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

// TODO: Why do we need this?
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
