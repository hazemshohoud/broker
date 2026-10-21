// Enables the Identity Toolkit API (required for Firebase Auth) and
// checks whether Email/Password sign-in is configured.
//
// NOTE: Firebase Auth itself must be initialized once from the console —
// there is no public API to provision it on a new project. One-time step:
//   1. Open https://console.firebase.google.com/project/broker-app-2026/authentication
//   2. Click "Get started" → Sign-in method → Email/Password → Enable → Save.
//
// Usage: node tool/enable_email_auth.js
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

async function main() {
  const account = getGlobalDefaultAccount();
  if (!account) throw new Error('Run `firebase login` first.');
  await requireAuth({ project: projectId, user: account.user, tokens: account.tokens });

  const servicesClient = new Client({
    urlPrefix: 'https://serviceusage.googleapis.com',
    apiVersion: 'v1',
  });
  await servicesClient.post(
    `/projects/${projectId}/services/identitytoolkit.googleapis.com:enable`,
    {},
  );
  console.log('Identity Toolkit API enabled.');

  const authzClient = new Client({
    urlPrefix: 'https://identitytoolkit.googleapis.com',
    apiVersion: 'admin/v2',
  });
  try {
    const res = await authzClient.get(`/projects/${projectId}/config`);
    const emailEnabled = res.body?.signIn?.email?.enabled === true;
    console.log(
      emailEnabled
        ? 'Email/Password sign-in is ENABLED — auth is ready.'
        : 'Auth exists but Email/Password is disabled — enable it in the console.',
    );
  } catch {
    console.log(
      'Firebase Auth is not initialized yet.\n' +
      'Open https://console.firebase.google.com/project/' +
        `${projectId}/authentication → Get started → ` +
        'Sign-in method → Email/Password → Enable → Save.',
    );
  }
}

main().catch((error) => {
  console.error(error.message ?? error);
  process.exit(1);
});
