import { Router, type Request, type Response } from "express";
import db from "../database/connection.js";

const router = Router();

router.get("/alive", async (req: Request, res: Response) => {
    res.status(200).send("OK");
});

router.get("/ready", async (req: Request, res: Response) => {
  try {
    await db.query("SELECT 1");
    
    res.status(200).send("The databse is available");
  } catch (error) {
    res.status(503).send("The database is unavailable");
  }
});

export default router;
