const fs = require('fs');
const path = require('path');

const url = process.env.SUPABASE_URL || 'COLE_AQUI_A_URL_REAL_QUE_VOCE_COPIOU_DO_SUPABASE';
const anonKey = process.env.SUPABASE_ANON_KEY || 'COLE_AQUI_A_CHAVE_ANON_REAL_QUE_VOCE_COPIOU_DO_SUPABASE';

const content = `window.RC_CONFIG = window.RC_CONFIG || {};
window.RC_CONFIG.SUPABASE_URL = ${JSON.stringify(url)};
window.RC_CONFIG.SUPABASE_ANON_KEY = ${JSON.stringify(anonKey)};
window.SUPABASE_URL = window.RC_CONFIG.SUPABASE_URL;
window.SUPABASE_ANON_KEY = window.RC_CONFIG.SUPABASE_ANON_KEY;
`;

const outPath = path.join(__dirname, '..', 'config.js');
fs.writeFileSync(outPath, content, 'utf8');
console.log('config.js generated with Supabase settings');
