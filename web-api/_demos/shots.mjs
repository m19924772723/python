// Edge 截图：FastAPI /docs Swagger UI 与 /redoc
import { createRequire } from 'node:module';
const require = createRequire('C:/Users/1/.workbuddy/binaries/node/workspace/node_modules/x.js');
const { chromium } = require('playwright-core');

const OUT = 'D:/code/workbuddy/workbuddy-project/python/web-api/_shots';
const targets = [
  ['01-fastapi-swagger.png', 'http://127.0.0.1:8900/docs', 2500],
  ['02-fastapi-redoc.png', 'http://127.0.0.1:8900/redoc', 1800],
];
const browser = await chromium.launch({ channel: 'msedge', headless: true, args: ['--no-proxy-server'] });
const page = await (await browser.newContext({ viewport: { width: 1280, height: 860 }, deviceScaleFactor: 2 })).newPage();
for (const [name, url, wait] of targets) {
  try {
    await page.goto(url, { waitUntil: 'load', timeout: 25000 });
    await page.waitForTimeout(wait);
    await page.screenshot({ path: `${OUT}/${name}` });
    console.log('OK', name, await page.title());
  } catch (e) { console.log('ERR', name, e.message.split('\n')[0]); }
}
await browser.close();
