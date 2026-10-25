// Edge 自动化：healthchecks 登录页 + 登录后仪表盘 + Django admin 截图
import { createRequire } from 'node:module';
const require = createRequire('C:/Users/1/.workbuddy/binaries/node/workspace/node_modules/x.js');
const { chromium } = require('playwright-core');

const BASE = 'http://127.0.0.1:8910';
const OUT = 'D:/code/workbuddy/workbuddy-project/python/web-api/_shots';

const browser = await chromium.launch({ channel: 'msedge', headless: true, args: ['--no-proxy-server'] });
const ctx = await browser.newContext({ viewport: { width: 1280, height: 860 }, deviceScaleFactor: 2 });
const page = await ctx.newPage();

// 1. 登录页
await page.goto(`${BASE}/accounts/login/`, { waitUntil: 'load', timeout: 25000 });
await page.waitForTimeout(1200);
await page.screenshot({ path: `${OUT}/03-hc-login.png` });
console.log('OK 03-hc-login.png');

// 2. 登录 → 仪表盘（表单字段 name=email / name=password，容器 #login-form）
await page.fill('#login-form input[name="email"]', 'admin@example.org');
await page.fill('#login-form input[name="password"]', 'hc123456');
await page.click('#login-form button[type="submit"]');
await page.waitForURL('**/checks/**', { timeout: 20000 }).catch(() => {});
await page.waitForTimeout(1800);
console.log('登录后 URL:', page.url());
await page.screenshot({ path: `${OUT}/04-hc-dashboard.png` });
console.log('OK 04-hc-dashboard.png');

// 3. Django admin
await page.goto(`${BASE}/admin/`, { waitUntil: 'load', timeout: 20000 });
await page.waitForTimeout(1000);
await page.screenshot({ path: `${OUT}/05-hc-admin.png` });
console.log('OK 05-hc-admin.png', await page.title());

await browser.close();
