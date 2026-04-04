import { Router, type Request, type Response } from "express";
import db from "../database/connection.js";

const router = Router();

router.get("/", async (req: Request, res: Response) => {
  try {
    const result = await db.query("SELECT name, quantity FROM items");
    res.json(result.rows);
  } catch (error) {
    res.status(500).json({ error: "Failed to get items" });
  }
});

router.get("/:id", async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const result = await db.query("SELECT * FROM items WHERE id = $1", [id]);

    if (result.rows.length === 0) {
      res.status(404).json({ error: "Item not found" });
      return;
    }

    res.json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: "Failed to get item" });
  }
});

router.post("/", async (req: Request, res: Response) => {
  try {
    const { name, quantity } = req.body;
    if (!name || !quantity) {
      res.status(400).json({ error: "Name and price are required" });
      return;
    }

    const result = await db.query(
      "INSERT INTO items (name, quantity) VALUES ($1, $2)",
      [name, quantity]
    );

    res.status(201).json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: "Failed to create item" });
  }
});

export default router;