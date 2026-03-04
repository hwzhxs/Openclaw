"""Test squad-landing: hover video, unmute, hover with audio."""
import asyncio
from playwright.async_api import async_playwright

async def main():
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        page = await browser.new_page()
        
        # Navigate
        await page.goto("https://hwzhxs.github.io/squad-landing/", wait_until="networkidle", timeout=30000)
        await page.wait_for_timeout(2000)
        
        # Take initial screenshot
        await page.screenshot(path="test_01_initial.png", full_page=True)
        print("Screenshot 1: initial page saved")
        
        # Find all video elements
        videos = await page.query_selector_all("video")
        print(f"Found {len(videos)} video elements")
        
        for i, v in enumerate(videos):
            src = await v.get_attribute("src")
            muted = await v.get_attribute("muted")
            autoplay = await v.get_attribute("autoplay")
            paused = await v.evaluate("el => el.paused")
            print(f"  Video {i}: src={src}, muted={muted}, autoplay={autoplay}, paused={paused}")
        
        # Find agent cards
        cards = await page.query_selector_all("[class*='agent'], [class*='card'], [class*='Card']")
        print(f"\nFound {len(cards)} card-like elements")
        
        # Look at page structure for agent sections
        sections = await page.evaluate("""() => {
            const els = document.querySelectorAll('section, [class*="agent"], [class*="card"], [class*="hero"]');
            return Array.from(els).map(el => ({
                tag: el.tagName,
                className: el.className,
                id: el.id,
                hasVideo: el.querySelector('video') !== null
            }));
        }""")
        print(f"\nSections/cards found: {len(sections)}")
        for s in sections:
            print(f"  {s['tag']} class={s['className']} id={s['id']} hasVideo={s['hasVideo']}")
        
        # Test 1: Hover over first agent card image - check if video plays
        print("\n--- TEST 1: Hover over agent card image ---")
        # Find elements with video inside
        video_containers = await page.evaluate("""() => {
            const videos = document.querySelectorAll('video');
            return Array.from(videos).map((v, i) => {
                const parent = v.closest('div[class*="card"], div[class*="agent"], section, div[class*="image"], div[class*="media"], div[class*="wrapper"]') || v.parentElement;
                const rect = parent.getBoundingClientRect();
                return {
                    index: i,
                    parentClass: parent.className,
                    parentTag: parent.tagName,
                    top: rect.top,
                    left: rect.left,
                    width: rect.width,
                    height: rect.height,
                    videoSrc: v.src,
                    videoPaused: v.paused,
                    videoMuted: v.muted
                };
            });
        }""")
        print(f"Video containers: {len(video_containers)}")
        for vc in video_containers:
            print(f"  #{vc['index']}: class={vc['parentClass']}, paused={vc['videoPaused']}, muted={vc['videoMuted']}, src={vc['videoSrc'][:80]}")
        
        # Hover over first non-hero video container (agent card)
        if len(videos) > 0:
            # First, check which video is the hero vs agent cards
            first_card_video_idx = 0
            for vc in video_containers:
                if 'hero' not in vc.get('parentClass', '').lower():
                    first_card_video_idx = vc['index']
                    break
            
            target_video = videos[first_card_video_idx]
            # Get bounding box and hover
            box = await target_video.bounding_box()
            if box:
                print(f"\nHovering over video {first_card_video_idx} at ({box['x']}, {box['y']})")
                await page.mouse.move(box['x'] + box['width']/2, box['y'] + box['height']/2)
                await page.wait_for_timeout(1500)
                
                paused_after = await target_video.evaluate("el => el.paused")
                current_time = await target_video.evaluate("el => el.currentTime")
                print(f"After hover: paused={paused_after}, currentTime={current_time}")
                await page.screenshot(path="test_02_hover.png", full_page=False)
                print("Screenshot 2: after hover saved")
        
        # Test 2: Find and click Unmute button
        print("\n--- TEST 2: Click Unmute button ---")
        unmute_btn = await page.query_selector("text=Unmute") or await page.query_selector("text=unmute") or await page.query_selector("[class*='mute'], [class*='Mute'], button:has-text('Unmute'), button:has-text('🔇'), button:has-text('🔊')")
        
        if not unmute_btn:
            # Try broader search
            buttons = await page.evaluate("""() => {
                const btns = document.querySelectorAll('button, [role="button"], [class*="mute"], [class*="sound"], [class*="audio"]');
                return Array.from(btns).map(b => ({
                    text: b.textContent.trim().substring(0, 50),
                    className: b.className,
                    tag: b.tagName
                }));
            }""")
            print(f"All buttons found: {len(buttons)}")
            for b in buttons:
                print(f"  {b['tag']} class={b['className']} text={b['text']}")
        
        if unmute_btn:
            await unmute_btn.scroll_into_view_if_needed()
            await unmute_btn.click()
            await page.wait_for_timeout(1000)
            print("Clicked unmute button")
            
            # Check hero video audio state
            hero_audio = await page.evaluate("""() => {
                const videos = document.querySelectorAll('video');
                const audios = document.querySelectorAll('audio');
                const results = [];
                videos.forEach((v, i) => results.push({type: 'video', index: i, muted: v.muted, paused: v.paused, volume: v.volume}));
                audios.forEach((a, i) => results.push({type: 'audio', index: i, muted: a.muted, paused: a.paused, volume: a.volume}));
                return results;
            }""")
            print(f"Audio state after unmute: {hero_audio}")
            await page.screenshot(path="test_03_unmuted.png", full_page=False)
        else:
            # Scroll to top to find hero section
            await page.evaluate("window.scrollTo(0, 0)")
            await page.wait_for_timeout(500)
            await page.screenshot(path="test_03_hero.png", full_page=False)
            print("No unmute button found. Saved hero screenshot.")
            
            # Check for any clickable audio elements
            audio_els = await page.evaluate("""() => {
                const all = document.querySelectorAll('*');
                const matches = [];
                for (const el of all) {
                    const text = el.textContent?.trim() || '';
                    const cls = el.className || '';
                    if ((typeof cls === 'string' && (cls.includes('mute') || cls.includes('sound') || cls.includes('audio'))) ||
                        text.includes('Unmute') || text.includes('🔇') || text.includes('🔊')) {
                        if (el.children.length < 3) {
                            matches.push({tag: el.tagName, class: typeof cls === 'string' ? cls.substring(0,80) : '', text: text.substring(0,50)});
                        }
                    }
                }
                return matches;
            }""")
            print(f"Audio-related elements: {audio_els}")
        
        # Test 3: Hover agent card after unmuting
        print("\n--- TEST 3: Hover agent card after unmute ---")
        if len(videos) > 0 and first_card_video_idx is not None:
            target_video = videos[first_card_video_idx]
            box = await target_video.bounding_box()
            if box:
                await target_video.scroll_into_view_if_needed()
                await page.wait_for_timeout(500)
                box = await target_video.bounding_box()
                await page.mouse.move(box['x'] + box['width']/2, box['y'] + box['height']/2)
                await page.wait_for_timeout(1500)
                
                muted_after = await target_video.evaluate("el => el.muted")
                paused_after = await target_video.evaluate("el => el.paused")
                volume = await target_video.evaluate("el => el.volume")
                print(f"After hover (post-unmute): muted={muted_after}, paused={paused_after}, volume={volume}")
                await page.screenshot(path="test_04_hover_unmuted.png", full_page=False)
                print("Screenshot 4: hover after unmute saved")
        
        await browser.close()
        print("\n✅ All tests completed")

asyncio.run(main())
