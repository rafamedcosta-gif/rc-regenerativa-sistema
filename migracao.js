const fs = require('fs');
const path = require('path');
const { Client } = require('pg');

const schemaPath = path.join(__dirname, 'schema.sql');
const connectionString = 'postgresql://postgres:Rafa280107*%23@db.rsnwdedbwukkucoyhfkt.supabase.co:5432/postgres';

async function main() {
  const sql = fs.readFileSync(schemaPath, 'utf8');
  const client = new Client({ connectionString });

  try {
    await client.connect();
    console.log('Conectado ao PostgreSQL do Supabase.');
    await client.query(sql);
    console.log('Schema aplicado com sucesso.');
  } catch (error) {
    console.error('Erro ao aplicar schema:', error.message);
    process.exitCode = 1;
  } finally {
    await client.end();
  }
}

main();
