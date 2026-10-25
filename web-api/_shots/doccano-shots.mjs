// Edge 自动化：doccano 登录 → 项目列表页
import { createRequire } from 'node:module';
const require = createRequire('C:/Users/1/.workbuddy/binaries/node/workspace/node_modules/x.js');
const { chromium } = require('playwright-core');
import fs from 'node:fs';

const BASE = 'http://127.0.0.1:3000';
const OUT = 'D:/code/workbuddy/workbuddy-project/python/web-api/_shots';
fs.mkdirSync(OUT, { recursive: true });

const browser = await chromium.launch({ channel: 'msedge', headless: true, args: ['--no-proxy-server'] });
const ctx = await browser.newContext({ viewport: { width: 1440, height: 860 }, deviceScaleFactor: 2 });
const page = await ctx.newPage();
page.on('pageerror', e => console.log('PAGE_EXCEPTION:', String(e).slice(0, 300)));
page.on('response', r => { if (r.status() >= 400 && !r.url().includes('favicon')) console.log('HTTP_FAIL:', r.status(), r.url().slice(0, 150)); });

await page.goto(BASE + '/auth', { waitUntil: 'load', timeout: 60000 });
await page.waitForTimeout(6000);
console.log('login page URL:', page.url());
await page.screenshot({ path: `${OUT}/01-doccano-login.png` });
console.log('OK 01-doccano-login.png');

// 填表单
const userInput = page.locator('input[type="text"], input[type="email"], input[name="username"]').first();
await userInput.fill('admin');
await page.locator('input[type="password"]').first().fill('123456');
await page.screenshot({ path: `${OUT}/02-doccano-filled.png` });
console.log('filled admin/123456');

// 点登录按钮（卡片右下角的 Login 文本按钮），回车兜底
await page.keyboard.press('Enter');
await page.waitForTimeout(1500);
const loginBtn = page.locator('button:has-text("Login"), a:has-text("Login"), span:has-text("Login")').last();
if (await loginBtn.count()) await loginBtn.click().catch(() => {});
console.log('clicked sign-in');

let ok = false;
for (let i = 0; i < 20; i++) {
  await page.waitForTimeout(1500);
  const u = page.url();
  if (!/login/.test(u)) { ok = true; break; }
}
console.log('after login URL:', page.url());
await page.waitForTimeout(4000);
await page.screenshot({ path: `${OUT}/03-doccano-projects.png` });
console.log(ok ? 'OK 03-doccano-projects.png' : 'STILL LOGIN PAGE');
if (!ok) {
  const err = await page.evaluate(() => document.body.innerText.slice(0, 300));
  console.log('LOGIN PAGE TEXT:', err.replace(/\n+/g, ' | '));
}
await browser.close();
console.log('DONE');