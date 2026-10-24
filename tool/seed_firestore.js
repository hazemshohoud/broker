// Seeds sample home data into Firestore using the Firebase CLI's logged-in session.
// Usage: node tool/seed_firestore.js
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

const developers = [
  { name: 'SODIC', logoUrl: 'https://images.unsplash.com/photo-1599305445671-ac291c95aaa9?auto=format&fit=crop&w=200&q=80' },
  { name: 'HYDE PARK', logoUrl: 'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?auto=format&fit=crop&w=200&q=80' },
  { name: 'MOUNTAIN VIEW', logoUrl: 'https://images.unsplash.com/photo-1572021335469-31706a17aaef?auto=format&fit=crop&w=200&q=80' },
  { name: 'ORA', logoUrl: 'https://images.unsplash.com/photo-1516876437184-593fda40c7ce?auto=format&fit=crop&w=200&q=80' },
  { name: 'MODON', logoUrl: 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?auto=format&fit=crop&w=200&q=80' },
  { name: 'PALM HILLS', logoUrl: 'https://images.unsplash.com/photo-1557804506-669a67965ba0?auto=format&fit=crop&w=200&q=80' },
  { name: 'EMAAR', logoUrl: 'https://images.unsplash.com/photo-1542744173-8e7e53415bb0?auto=format&fit=crop&w=200&q=80' },
].map((item, order) => ({
  id: item.name.toLowerCase().replace(/\s+/g, '-'),
  data: { name: item.name, logoUrl: item.logoUrl, order },
}));

const offers = [
  {
    title: 'عروض بروكر حصرية بمناسبة الافتتاح',
    imageUrl: 'https://images.unsplash.com/photo-1560518883-ce09059eeffa?auto=format&fit=crop&w=1000&q=80',
  },
  {
    title: 'Waterway - Launching Soon بنظام سداد 8 سنوات',
    imageUrl: 'https://images.unsplash.com/photo-1570129477492-45c003edd2be?auto=format&fit=crop&w=1000&q=80',
  },
  {
    title: 'Palm Hills - مرحلة جديدة بأفضل عائد استثماري',
    imageUrl: 'https://images.unsplash.com/photo-1582407947304-fd86f028f716?auto=format&fit=crop&w=1000&q=80',
  },
].map((item, order) => ({
  id: `offer-${order + 1}`,
  data: { title: item.title, imageUrl: item.imageUrl, order },
}));

const onboardingSlides = [
  {
    title: 'أكبر شبكة مشروعات عقارية',
    description: 'تصفح مئات المشروعات الحصرية والكمبوندات بأعلى نسب عمولات في السوق المصري.',
    imageUrl: 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?auto=format&fit=crop&w=1200&q=80',
    order: 1,
  },
  {
    title: 'إدارة ذكية وشاملة لعملائك',
    description: 'سجّل عملاءك واحتياجاتهم وتابع صفقاتك مع إمكانية التواصل الفوري عبر الهاتف والواتساب.',
    imageUrl: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=1200&q=80',
    order: 2,
  },
  {
    title: 'سحب فوري لأرباحك وعمولاتك',
    description: 'تابع رصيدك المتاح واسحب أرباحك وعمولاتك مباشرة عبر إنستاباي أو المحفظة الإلكترونية.',
    imageUrl: 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=1200&q=80',
    order: 3,
  },
  {
    title: 'بوابتك الرقمية للوساطة العقارية',
    description: 'انضم لشبكة وسطاء بروكر المحترفين وابدأ في إتمام الصفقات وتنمية أرباحك من اليوم.',
    imageUrl: 'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?auto=format&fit=crop&w=1200&q=80',
    order: 4,
  },
].map((item, idx) => ({
  id: `slide_${idx + 1}`,
  data: item,
}));

// Filter options shown in the app's filter sheet — the admin panel edits this doc.
const filterOptions = {
  propertyTypes: ['شقة', 'فيلا', 'أرض', 'مكتب', 'محل', 'منزل', 'روف'],
  regions: [
    {
      name: 'شرق النيل',
      districts: ['الحي الأول', 'الحي الثالث', 'الحي الرابع', 'الحي الخامس', 'الحي الثالث عشر', 'حي الأزهر المتميز', 'مركز المدينة'],
    },
    {
      name: 'بني سويف',
      districts: ['الكورنيش', 'زهرة الدائري', 'حي الزهور', 'الرمد الجديد', 'الحي الغربي', 'طريق السادات', 'الروضة', 'الأباصيري', 'مقبل', 'عبد السلام عارف', 'صلاح سالم'],
    },
    {
      name: 'مراكز',
      districts: ['ببا', 'الفشن', 'سمسطا', 'الواسطى'],
    },
  ],
  readinessStatuses: ['جاهز', 'تحت الإنشاء'],
  finishings: ['تشطيب كامل', 'نصف تشطيب', 'عضم'],
  amenities: [
    'مستشفى',
    'جامعة',
    'مدرسة',
    'نادي',
    'سوبر ماركت',
    'عيادة',
    'صيدلية',
    'جيم',
    'كافيه او مطعم',
    'مساحات خضراء',
  ],
};

const compounds = [
  {
    id: 'one-hyde-park',
    name: 'وان هايد بارك',
    developerName: 'Hyde Park',
    developerLogoUrl: 'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?auto=format&fit=crop&w=200&q=80',
    developerStartPrice: 6870000,
    resaleStartPrice: null,
    commission: 171750,
    propertyTypes: ['شقة', 'فيلا', 'روف'],
    region: 'شرق النيل',
    district: 'الحي الأول',
    readiness: 'جاهز',
    finishing: 'تشطيب كامل',
    imageUrl: 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?auto=format&fit=crop&w=1200&q=80',
    imageUrls: [
      'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1600566753376-12c8ab7fb75b?auto=format&fit=crop&w=1200&q=80',
    ],
  },
  {
    id: 'sodic-east',
    name: 'سوديك إيست',
    developerName: 'SODIC',
    developerLogoUrl: 'https://images.unsplash.com/photo-1599305445671-ac291c95aaa9?auto=format&fit=crop&w=200&q=80',
    developerStartPrice: 7200000,
    resaleStartPrice: 7900000,
    commission: 180000,
    propertyTypes: ['شقة', 'فيلا'],
    region: 'شرق النيل',
    district: 'حي الأزهر المتميز',
    readiness: 'تحت الإنشاء',
    finishing: 'نصف تشطيب',
    imageUrl: 'https://images.unsplash.com/photo-1600566753376-12c8ab7fb75b?auto=format&fit=crop&w=1200&q=80',
    imageUrls: [
      'https://images.unsplash.com/photo-1600566753376-12c8ab7fb75b?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1600573472550-8090b5e0745e?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?auto=format&fit=crop&w=1200&q=80',
    ],
  },
  {
    id: 'mv-icity',
    name: 'ماونتن فيو آي سيتي',
    developerName: 'Mountain View',
    developerLogoUrl: 'https://images.unsplash.com/photo-1572021335469-31706a17aaef?auto=format&fit=crop&w=200&q=80',
    developerStartPrice: 6900000,
    resaleStartPrice: 7350000,
    commission: 172500,
    propertyTypes: ['شقة', 'مكتب', 'محل'],
    region: 'بني سويف',
    district: 'الكورنيش',
    readiness: 'جاهز',
    finishing: 'تشطيب كامل',
    imageUrl: 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=1200&q=80',
    imageUrls: [
      'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1613977257363-707ba9348227?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1613490493576-7fde63acd811?auto=format&fit=crop&w=1200&q=80',
    ],
  },
  {
    id: 'zed-east',
    name: 'زد إيست',
    developerName: 'ORA',
    developerLogoUrl: 'https://images.unsplash.com/photo-1516876437184-593fda40c7ce?auto=format&fit=crop&w=200&q=80',
    developerStartPrice: 9800000,
    resaleStartPrice: null,
    commission: 245000,
    propertyTypes: ['شقة', 'روف'],
    region: 'بني سويف',
    district: 'حي الزهور',
    readiness: 'تحت الإنشاء',
    finishing: 'عضم',
    imageUrl: 'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?auto=format&fit=crop&w=1200&q=80',
    imageUrls: [
      'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1513694203232-719a280e022f?auto=format&fit=crop&w=1200&q=80',
    ],
  },
  {
    id: 'palm-hills-new-cairo',
    name: 'بالم هيلز',
    developerName: 'Palm Hills',
    developerLogoUrl: 'https://images.unsplash.com/photo-1557804506-669a67965ba0?auto=format&fit=crop&w=200&q=80',
    developerStartPrice: 7750000,
    resaleStartPrice: 8200000,
    commission: 193750,
    propertyTypes: ['منزل', 'أرض'],
    region: 'مراكز',
    district: 'الواسطى',
    readiness: 'جاهز',
    finishing: 'نصف تشطيب',
    imageUrl: 'https://images.unsplash.com/photo-1576941089067-2de3c901e126?auto=format&fit=crop&w=1200&q=80',
    imageUrls: [
      'https://images.unsplash.com/photo-1576941089067-2de3c901e126?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1583608205776-bfd35f0d9f83?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1502005229762-ee1b2b3ba304?auto=format&fit=crop&w=1200&q=80',
    ],
  },
  {
    id: 'modon-ras-elhekma',
    name: 'مدن راس الحكمة',
    developerName: 'MODON',
    developerLogoUrl: 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?auto=format&fit=crop&w=200&q=80',
    developerStartPrice: 12500000,
    resaleStartPrice: null,
    commission: 312500,
    propertyTypes: ['فيلا', 'أرض'],
    region: 'مراكز',
    district: 'ببا',
    readiness: 'تحت الإنشاء',
    finishing: 'عضم',
    imageUrl: 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?auto=format&fit=crop&w=1200&q=80',
    imageUrls: [
      'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1512915922686-57c11dde9b6b?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1600607687920-4e2a09cf159d?auto=format&fit=crop&w=1200&q=80',
    ],
  },
].map(c => ({
  id: c.id,
  data: {
    name: c.name,
    location: `${c.district}، ${c.region}`,
    region: c.region,
    district: c.district,
    readiness: c.readiness,
    finishing: c.finishing,
    developerName: c.developerName,
    developerLogoUrl: c.developerLogoUrl,
    developerStartPrice: c.developerStartPrice,
    resaleStartPrice: c.resaleStartPrice,
    commission: c.commission,
    propertyTypes: c.propertyTypes,
    phone: '+201000000000',
    whatsapp: '+201000000000',
    imageUrl: c.imageUrl,
    imageUrls: c.imageUrls,
    area: c.area || 'تبدأ من 130 م² إلى 320 م²',
    deliveryDate: c.deliveryDate || (c.readiness === 'جاهز' ? 'استلام فوري' : '2026/2027'),
    mapUrl: c.mapUrl || 'https://maps.google.com/?q=29.0667,31.0994',
    amenities: c.amenities || {
      'مستشفى': '1 كم',
      'جامعة': '1 كم',
      'مدرسة': '1 كم',
      'نادي': '1 كم',
      'سوبر ماركت': '1 كم',
      'عيادة': '1 كم',
      'صيدلية': '1 كم',
      'جيم': '1 كم',
      'كافيه او مطعم': '1 كم',
      'مساحات خضراء': '1 كم',
    },
    faqs: c.faqs || {
      'لماذا هذا العقار؟': `يتميز مشروع ${c.name} بموقع استراتيجي في ${c.district}، ${c.region} بتصميم حديث ومساحات متنوعة وخدمات متكاملة.`,
      'معلومات عن المطور': `شركة ${c.developerName} هي من كبرى شركات التطوير العقاري الموثوقة ولها سجل حافل بالمشاريع الناجحة.`,
      'هل تصلح للاستثمار العقاري': 'نعم، يوفر المشروع عائداً إيجارياً مرتفعاً وقيمة استثمارية متزايدة مع إمكانية إعادة بيع سريعة.',
      'خدمة إعادة البيع': 'تطبيق بروكر يوفر لعملائه خدمة حصرية لتسويق وإعادة بيع الوحدة عبر شبكة الوسطاء المعتمدة.',
    },
    attachments: [
      { 'title': 'بروشور المشروع الكامل (PDF)', 'type': 'pdf', 'size': '4.2 MB' },
      { 'title': 'المخطط العام والماستر بلان (Master Plan)', 'type': 'image', 'size': '2.8 MB' },
      { 'title': 'جدول خطط السداد ونظم التقسيط', 'type': 'doc', 'size': '1.5 MB' },
    ],
  },
}));

function toValue(value) {
  if (value === null || value === undefined) return { nullValue: null };
  if (Array.isArray(value)) return { arrayValue: { values: value.map(toValue) } };
  if (typeof value === 'object') {
    return {
      mapValue: {
        fields: Object.fromEntries(Object.entries(value).map(([k, v]) => [k, toValue(v)])),
      },
    };
  }
  if (typeof value === 'boolean') return { booleanValue: value };
  if (typeof value === 'number') {
    return Number.isInteger(value)
      ? { integerValue: value.toString() }
      : { doubleValue: value };
  }
  return { stringValue: String(value) };
}

async function writeDoc(client, docPath, data) {
  await client.patch(docPath, { fields: toValue(data).mapValue.fields });
}

async function main() {
  const account = getGlobalDefaultAccount();
  if (!account) {
    throw new Error('No Firebase CLI account found. Run `firebase login` first.');
  }
  await requireAuth({ project: projectId, user: account.user, tokens: account.tokens });

  const client = new Client({
    urlPrefix: 'https://firestore.googleapis.com',
    apiVersion: 'v1',
    auth: true,
  });

  console.log(`Seeding Firestore for project ${projectId}...`);

  for (const dev of developers) {
    await writeDoc(client, `${databasePath}/documents/developers/${dev.id}`, dev.data);
    console.log(`  + developer: ${dev.data.name}`);
  }

  for (const offer of offers) {
    await writeDoc(client, `${databasePath}/documents/offers/${offer.id}`, offer.data);
    console.log(`  + offer: ${offer.data.title}`);
  }

  await writeDoc(client, `${databasePath}/documents/config/filter_options`, filterOptions);
  console.log('  + config/filter_options');

  for (const comp of compounds) {
    await writeDoc(client, `${databasePath}/documents/compounds/${comp.id}`, comp.data);
    console.log(`  + compound: ${comp.data.name} (${comp.data.imageUrls.length} images)`);
  }

  for (const slide of onboardingSlides) {
    await writeDoc(client, `${databasePath}/documents/onboarding/${slide.id}`, slide.data);
    console.log(`  + onboarding: ${slide.data.title}`);
  }

  console.log('Done.');
}

main().catch((err) => {
  console.error('Seed failed:', err.message || err);
  process.exit(1);
});
