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
const brokerId = 'Bhcw0EQI34VL5k6aDe4tWiEzH153';
const brokerIds = [
  'Bhcw0EQI34VL5k6aDe4tWiEzH153',
  'u6I6JZfvh8WuhfkwxVakOHhDRI72',
  '8DN4ELpg5ob3y41RCE4KU1OPY3j1',
  '8Qoo0edNnztkv82XAiEW',
];

const now = new Date().toISOString();

const clients = [
  {
    id: 'client-1',
    data: {
      brokerId,
      name: 'أحمد محمود العطار',
      phone: '01099887766',
      interest: 'وان هايد بارك',
      note: 'محدد ميعاد معاينة يوم السبت القادم الساعة 4 عصراً',
      createdAt: { timestampValue: now },
    },
  },
  {
    id: 'client-2',
    data: {
      brokerId,
      name: 'د. سارة إبراهيم',
      phone: '01122334455',
      interest: 'سوديك إيست',
      note: 'تبحث عن شقة 3 غرف في شرق النيل دور متكرر',
      createdAt: { timestampValue: now },
    },
  },
  {
    id: 'client-3',
    data: {
      brokerId,
      name: 'م. حسام الشريف',
      phone: '01233445566',
      interest: 'ماونتن فيو آي سيتي',
      note: 'جاهز للسداد كاش أو تقسيط على سنتين',
      createdAt: { timestampValue: now },
    },
  },
];

const commissions = [
  {
    id: 'comm-1',
    data: {
      brokerId,
      title: 'وان هايد بارك',
      details: 'وحدة دوبلكس فيلا B4',
      amount: { doubleValue: 171750.0 },
      status: { stringValue: 'approved' },
      createdAt: { timestampValue: now },
    },
  },
  {
    id: 'comm-2',
    data: {
      brokerId,
      title: 'سوديك إيست',
      details: 'شقة 180م نصف تشطيب',
      amount: { doubleValue: 90000.0 },
      status: { stringValue: 'pending' },
      createdAt: { timestampValue: now },
    },
  },
];

const withdrawals = [
  {
    id: 'with-1',
    data: {
      brokerId,
      amount: { doubleValue: 50000.0 },
      method: { stringValue: 'instapay' },
      methodNumber: { stringValue: '01011112222' },
      status: { stringValue: 'completed' },
      createdAt: { timestampValue: now },
    },
  },
];

function toWrites(collection, docs) {
  return docs.map(({ id, data }) => {
    const fields = {};
    for (const [k, v] of Object.entries(data)) {
      if (v && typeof v === 'object' && ('stringValue' in v || 'doubleValue' in v || 'timestampValue' in v)) {
        fields[k] = v;
      } else {
        fields[k] = { stringValue: String(v) };
      }
    }
    return {
      update: {
        name: `${databasePath}/documents/${collection}/${id}`,
        fields,
      },
    };
  });
}

async function main() {
  const account = getGlobalDefaultAccount();
  if (!account) throw new Error('Run `firebase login` first.');
  await requireAuth({ project: projectId, user: account.user, tokens: account.tokens });
  const client = new Client({ urlPrefix: 'https://firestore.googleapis.com', apiVersion: 'v1' });

  const allWrites = [];
  for (const bId of brokerIds) {
    const brokerClients = clients.map((c, i) => ({
      id: `${bId}-client-${i + 1}`,
      data: { ...c.data, brokerId: bId },
    }));
    const brokerCommissions = commissions.map((c, i) => ({
      id: `${bId}-comm-${i + 1}`,
      data: { ...c.data, brokerId: bId },
    }));
    const brokerWithdrawals = withdrawals.map((w, i) => ({
      id: `${bId}-with-${i + 1}`,
      data: { ...w.data, brokerId: bId },
    }));

    allWrites.push(
      ...toWrites('clients', brokerClients),
      ...toWrites('commissions', brokerCommissions),
      ...toWrites('withdrawal_requests', brokerWithdrawals),
    );
  }

  await client.post(`${databasePath}/documents:commit`, { writes: allWrites });
  console.log(`Seeded ${allWrites.length} broker documents across ${brokerIds.length} brokers.`);
}

main().catch((err) => {
  console.error(err.message ?? err);
  process.exit(1);
});
