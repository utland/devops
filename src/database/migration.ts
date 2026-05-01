import db  from "./connection.js";

const migrate = async () => {
    await db.query(
        "CREATE TABLE IF NOT EXISTS items (\
            item_id SERIAL PRIMARY KEY, \
            quantity INT NOT NULL, \
            name VARCHAR(100) NOT NULL, \
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP \
        );"
    );
}

await migrate();