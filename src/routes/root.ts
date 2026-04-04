import { Router, type Request, type Response } from "express";

const router = Router();

router.get("/", (req: Request, res: Response) => {
  if (!req.accepts("html")) {
    return res.status(406).send("Not Acceptable: This endpoint only provides text/html");
  }

  const html = `
    <h1>Application Endpoints</h1>
    <h3>Business Logic:</h3>
    <ul>
      <li><a href="/items">GET /items</a> - Get all items (HTML/JSON)</li>
      <li>GET /items/:id - Get specific item (HTML/JSON)</li>
      <li>POST /items - Create item</li>
    </ul>
    <h3>System:</h3>
    <ul>
      <li><a href="/alive">GET /alive</a> - state of server</li>
      <li><a href="/ready">GET /ready</a> - state of database</li>
    </ul>
  `;

  res.setHeader("Content-Type", "text/html");
  res.status(200).send(html);
});

export default router;