const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage({ viewport: { width: 1280, height: 900 } });
  await page.goto('https://hwzhxs.github.io/squad-landing/', { waitUntil: 'networkidle' });
  
  const thinker = page.locator('text=Thinker').first();
  await thinker.scrollIntoViewIfNeeded();
  await page.waitForTimeout(500);
  
  const bbox = await thinker.boundingBox();
  console.log('Thinker bbox:', JSON.stringify(bbox));
  
  await page.screenshot({ path: 'before_hover.png' });
  
  // Hover over the card
  await page.mouse.move(bbox.x + bbox.width / 2, bbox.y);
  await page.waitForTimeout(3000);
  
  await page.screenshot({ path: 'after_hover.png' });
  
  // Check videos
  const videos = await page.$$('video');
  console.log(`Video elements: ${videos.length}`);
  for (let i = 0; i < videos.length; i++) {
    const info = await videos[i].evaluate(el => ({
      src: el.src || '',
      sourceSrc: el.querySelector('source')?.src || '',
      visible: el.offsetParent !== null,
      paused: el.paused,
      opacity: getComputedStyle(el).opacity,
      display: getComputedStyle(el).display,
      currentTime: el.currentTime,
      readyState: el.readyState,
      width: el.videoWidth,
      height: el.videoHeight
    }));
    console.log(`Video ${i}:`, JSON.stringify(info));
  }
  
  await browser.close();
})();
