// Lists registrations docs, or approves/deletes one, using the Firebase
// CLI's logged-in session.
// Usage:
//   node tool/list_registrations.js                → list all
//   node tool/list_registrations.js approve <uid>  → set status=approved
//   node tool/list_registrations.js delete <uid>   → delete doc
const path = require('path');
const { execSync } = require('child_process');

const firebaseToolsLib = path.join(
  execSync('npm root -g').toString().trim(),
  'firebase-tools',
  'lib',
);
const { Client } = require(path.join(firebaseToolsLib, 'apiv2'));
const { requireAuth } = require(path.join(firebaseToolsLib, 'requireAuth'));
const { getGlobalDefaultAccount } = require(path.join(firebaseToolsLib, 'auth'));

const projectId = 'broker-app-2026';
const databasePath = `projects/${projectId}/databases/(default)`;

async function main() {
  const account = getGlobalDefaultAccount();
  if (!account) throw new Error('Run `firebase login` first.');
  await requireAuth({ project: projectId, user: account.user, tokens: account.tokens });
  const client = new Client({ urlPrefix: 'https://firestore.googleapis.com', apiVersion: 'v1' });

  const [command, docId] = process.argv.slice(2);
  const collection = `${databasePath}/documents/registrations`;

  if (command === 'approve' || command === 'delete') {
    if (!docId) throw new Error(`Usage: node tool/list_registrations.js ${command} <docId>`);
    if (command === 'approve') {
      await client.patch(`${collection}/${docId}`, {
        fields: { status: { stringValue: 'approved' } },
      }, { queryParams: { 'updateMask.fieldPaths': 'status' } });
      console.log(`Approved ${docId}.`);
    } else {
      await client.delete(`${collection}/${docId}`);
      console.log(`Deleted ${docId}.`);
    }
    return;
  }

  const res = await client.get(collection);
  const docs = res.body.documents ?? [];
  console.log(`Found ${docs.length} document(s):`);
  for (const doc of docs) {
    console.log('\n---', doc.name.split('/').pop());
    for (const [key, value] of Object.entries(doc.fields ?? {})) {
      const raw = Object.values(value)[0];
      console.log(`  ${key}: ${JSON.stringify(raw)}`);
    }
  }
}

main().catch((error) => {
  console.error(error.message ?? error);
  process.exit(1);
});
