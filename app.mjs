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
        const criminalSentences = await interactive.getCriminalSentences(criminalID);
        const criminalCrimes = await interactive.getCriminalCrimes(criminalID);

        if (!criminalDetails) {
            res.status(404).send('Criminal not found');
        } else {
            criminalDetails.selectedYesViolent = criminalDetails.V_status === 'Y';
            criminalDetails.selectedNoViolent = criminalDetails.V_status === 'N';
            criminalDetails.selectedYesProbation = criminalDetails.P_status === 'Y';
            criminalDetails.selectedNoProbation = criminalDetails.P_status === 'N';

            const formattedSentences = criminalSentences.map(sentence => {
                return {
                    ...sentence,
                    Start_date: formatDate(sentence.Start_date),
                    End_date: formatDate(sentence.End_date)
                };
            });

            const formattedCrimes = criminalCrimes.map(crime => {
                return {
                    ...crime,
                    Date_charged: formatDate(crime.Date_charged),
                    Hearing_date: formatDate(crime.Hearing_date),
                    Appeal_cut_date: formatDate(crime.Appeal_cut_date)
                };
            });

            res.render("criminal/single", {
                criminal: criminalDetails,
                sentences: formattedSentences,
                crimes: formattedCrimes
            });
        }
    } catch (err) {
        console.error(err);
        res.status(500).send("Error retrieving criminal details.");
    }
});

function formatDate(dateValue) {
    if (!dateValue) return '';
    return new Date(dateValue).toISOString().split('T')[0]; // Converts date to YYYY-MM-DD format
}


// update a single field for a single criminal
app.post('/criminal/update/:field', async (req, res) => {
    const { id, value } = req.body;
    const field = req.params.field;
    try {
        await interactive.updateCriminalField(id, field, value);
        res.json({ success: true });
    } catch (err) {
        console.error('Failed to update:', err);
        res.json({ success: false });
    }
});

// delete a single criminal
// TODO: convert post to delete
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

// add a sentence for a criminal: the page
app.get("/criminal/addSentence/:Criminal_ID", async (req, res) => {
    try {
        const { Criminal_ID } = req.params;
        res.render("criminal/addSentencePage", { criminal_ID: Criminal_ID });
    } catch (err) {
        console.error(err);
        res.status(500).send("Error loading the add sentence page.");
    }
});

// add a sentence for a criminal: the backend 
app.post('/criminal/addSentence/:Criminal_ID', async (req, res) => {
    const { Criminal_ID } = req.params;
    const { type, probID, startDate, endDate, violations } = req.body;

    try {
        const result = await interactive.insertSentence(Criminal_ID, type, probID, startDate, endDate, violations);
        if (result.success) {
            res.redirect(`/criminal/details/${Criminal_ID}`); 
        } else {
            res.status(500).send("Inner Error inserting new sentence for criminal") 
        }
    } catch (error) {
        console.error("Error inserting sentence:", error);
        res.status(500).render('errorPage', { error: "Outer Error inserting sentence." });
    }
});

// add a sentence for a criminal: the page
app.get("/criminal/addCrime/:Criminal_ID", async (req, res) => {
    try {
        const { Criminal_ID } = req.params;
        res.render("criminal/addCrimePage", { criminal_ID: Criminal_ID });
    } catch (err) {
        console.error(err);
        res.status(500).send("Error loading the add sentence page.");
    }
});

// add a crime for a criminal: the backend 
app.post('/criminal/addCrime/:Criminal_ID', async (req, res) => {
    const { Criminal_ID } = req.params;
    const { classification, dateCharged, status, hearingDate, appealCutDate } = req.body;

    try {
        const result = await interactive.insertCrime(Criminal_ID, classification, dateCharged, status, hearingDate, appealCutDate);
        if (result.success) {
            res.redirect('/criminal/details/' + Criminal_ID); 
        } else {
            res.status(400).send(result.message); 
        }
    } catch (error) {
        console.error('Error in submitting crime:', error);
        res.status(500).send("Server error in processing your request.");
    }
});

// add a probation officer: the page
app.get("/prob_officer/newin", (req, res) => {
    res.render("prob_officer/new");
});

// add a probation officer: the backend
app.post('/prob_officer/new', async (req, res) => {
    const { firstName, lastName, street, city, state, zipCode, phoneNumber, email, status } = req.body;

    try {
        const result = await interactive.insertProbationOfficer(firstName, lastName, street, city, state, zipCode, phoneNumber, email, status);
        if (result.success) {
            res.redirect('/prob_officer/all'); 
        } else {
            res.status(500).send('Failed to create probation officer.');
        }
    } catch (error) {
        console.error("Error creating new probation officer:", error);
        res.status(500).send("Error creating probation officer.");
    }
});

// get all probation officers
app.get("/prob_officer/all", async (req, res) => {
    try {
        let probOfficers = await interactive.getAllProbOfficers();
        res.render("prob_officer/all", { probOfficers: probOfficers });
    } catch (err) {
        console.error(err);
        res.status(500).send("Error retrieving probation officers.");
    }
});

// get a single probation officer
app.get("/prob_officer/details/:Prob_ID", async (req, res) => {
    try {
        const probID = req.params.Prob_ID;
        const probOfficerDetails = await interactive.getProbationOfficerById(probID);
        const probOfficerSentences = await interactive.getProbationOfficerSentences(probID);   

        if (!probOfficerDetails) {
            res.status(404).send('Probation officer not found');
        } else {
            const formattedSentences = probOfficerSentences.map(sentence => {
                return {
                    ...sentence,
                    Start_date: formatDate(sentence.Start_date),
                    End_date: formatDate(sentence.End_date)
                };
            });
            probOfficerDetails.StatusActive = probOfficerDetails.Status === 'A';
            probOfficerDetails.StatusInactive = probOfficerDetails.Status === 'I';
            res.render("prob_officer/single", {
                probOfficer: probOfficerDetails, 
                sentences: formattedSentences
            });
        }
    } catch (err) {
        console.error('Error retrieving probation officer details:', err);
        res.status(500).send("Error retrieving probation officer details.");
    }
});

// delete a probation officer
app.post('/prob_officer/delete/:probOfficerId', async (req, res) => {
    const probOfficerId = req.params.probOfficerId;

    try {
        const result = await interactive.deleteProbOfficerByID(probOfficerId);
        if (result.success) {
            res.json({ success: true, message: "Probation officer successfully deleted." });
        } else {
            res.status(500).json({ success: false, message: "Failed to delete probation officer." });
        }
    } catch (error) {
        console.error("Error deleting probation officer:", error);
        res.status(500).json({ success: false, message: "Error deleting probation officer." });
    }
});

app.post('/prob_officer/update/:field', async (req, res) => {
    const { id, value } = req.body;
    const field = req.params.field;

    try {
        const validFields = ['First', 'Last', 'Street', 'City', 'State', 'Zip', 'Phone', 'Email', 'Status'];

        // bare of handling potential SQL injections (future reference)
        if (!validFields.includes(field)) {
            return res.status(400).json({ success: false, message: "Invalid field name for update." });
        }

        await interactive.updateProbOfficerField(id, field, value);
        res.json({ success: true, message: "Probation officer updated successfully." });
    } catch (error) {
        console.error(`Error updating probation officer field ${field}:`, error);
        res.status(500).json({ success: false, message: "Failed to update probation officer." });
    }
});

app.get('/crime/all', async (req, res) => {
    try {
        const Crimes = await interactive.getAllCrimes();

        const formattedCrimes = Crimes.map(crime => {
            return {
                ...crime,
                Date_charged: formatDate(crime.Date_charged),
                Hearing_date: formatDate(crime.Hearing_date),
                Appeal_cut_date: formatDate(crime.appealCutDate)

            };
        });

        res.render("crime/all", {Crimes: formattedCrimes})
    } catch (err) {
        console.error(err);
        res.status(500).send("Error retrieving crimes.");
    }
});

const port = process.env.EXPRESS_PORT || 3000;
app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});

