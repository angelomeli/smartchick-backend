const mysql = require('mysql2/promise');
require('dotenv').config();

async function run() {
  try {
    const connection = await mysql.createConnection(process.env.DATABASE_URL || {
      host: process.env.DB_HOST,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME,
      port: process.env.DB_PORT
    });

    console.log("Connecté à Aiven !");

    await connection.execute("SET FOREIGN_KEY_CHECKS = 0;");

    // On s'assure que le compte meli@smartchick.cm existe ET possède is_active = 1
    const sqlInsert = `
      INSERT INTO users (id, nom, prenom, email, password_hash, role, is_active) 
      VALUES (
        'u0000000-0000-0000-0000-000000000001', 
        'meli', 
        'angelo', 
        'meli@smartchick.cm', 
        '$2b$10$7R6vW1A9876Uu389C9hKfeO9bVWhU2lgKQwgh9cXCOIZ3RztJ.N2a', 
        'admin',
        1
      )
      ON DUPLICATE KEY UPDATE 
        password_hash = '$2b$10$7R6vW1A9876Uu389C9hKfeO9bVWhU2lgKQwgh9cXCOIZ3RztJ.N2a',
        is_active = 1;
    `;
    
    await connection.execute(sqlInsert);
    console.log("Utilisateur mis à jour avec is_active = 1 ! 🐓");

    await connection.execute("SET FOREIGN_KEY_CHECKS = 1;");
    await connection.end();
  } catch (error) {
    try { await connection.execute("SET FOREIGN_KEY_CHECKS = 1;"); } catch(e){}
    console.error("Erreur :", error.message);
  }
}

run();