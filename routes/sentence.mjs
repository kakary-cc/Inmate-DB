import express from "express";
import * as interactive from "../db-interactive.mjs";

const app = express();

app.get("/new", async (req, res) => {
    // TODO: Get Criminal_ID from param.
    try {
        // const { Criminal_ID } = req.params;
        const Criminal_ID = req.query["criminal_id"];
        res.render("./sentence/new", { criminal_ID: Criminal_ID });
    } catch (err) {
        console.error(err);
        res.status(500).send("Error loading the add sentence page.");
    }
});

app.post("/new", async (req, res) => {
    const Criminal_ID = req.query["criminal_id"];
    // const { Criminal_ID } = req.params;
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
            res.redirect(`/criminal/${Criminal_ID}`);
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

export { app as sentenceRoutes };
