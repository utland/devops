import { Router, type Request, type Response } from "express";
import db from "../database/connection.js";

const router = Router();

router.get("/", async (req: Request, res: Response) => {
  try {
    const result = await db.query("SELECT name, quantity FROM items");
    const items = result.rows;

    res.status(200).format({
      "text/html": () => {
        let html = `
        <h1>Items</h1>
        <table border='1'>
          <thead>
            <tr><th>Name</th><th>Quantity</th></tr>
          </thead>
          <tbody>
            ${items.forEach((item: any) => {
             return `<tr><td>${item.name}</td><td>${item.quantity}</td></tr>`;
            })}
          </tbody>
        </table>
        `;

        res.send(html);
      },
      "application/json": () => {
        res.json(items)
      }
    })
  } catch (error) {
    res.status(500).format({
      "text/html": () => {
        res.send("<h1>Failed to get items</h1>")
      },
      "application/json": () => {
        res.json({ error: "Failed to get items"})
      }
    })
  }
});

router.get("/:id", async (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    const result = await db.query("SELECT * FROM items WHERE id = $1", [id]);
    const item = result.rows[0]

    if (!item) {
      return res.status(404).format({ 
        "text/html": () => {
          res.send("<h1>Item not found</h1>")
        },
        "application/json": () => {
          res.json({ error: "Item not found" })
        }
      });
    }

    res.status(200).format({
      "text/html": () => {
        let html = `
        <div>
          <h1>Id: ${item.inventory_id}</h1>
          <h2>Name: ${item.name}</h1>
          <h2>Quantity: ${item.quantity}</h1>
          <h2>CreatedAt: ${item.created_at}</h1>
        </div>
        `;

        res.send(html);
      },
      "application/json": () => {
        res.json(item)
      }
    })
  } catch (error) {
    res.status(500).format({
      "text/html": () => {
        res.send("<h1>Failed to get item</h1>")
      },
      "application/json": () => {
        res.json({ error: "Failed to get item"})
      }
    })
  }
});

router.post("/", async (req: Request, res: Response) => {
  try {
    const { name, quantity } = req.body;
    if (!name || !quantity) {
      return res.status(400).json({ error: "Name and price are required" });
    }

    await db.query(
      "INSERT INTO items (name, quantity) VALUES ($1, $2)",
      [name, quantity]
    );

    res.status(201);
  } catch (error) {
    res.status(500).format({
      "text/html": () => {
        res.send("<h1>Failed to create item</h1>")
      },
      "application/json": () => {
        res.json({ error: "Failed to create item"})
      }
    })
  }
});

export default router;