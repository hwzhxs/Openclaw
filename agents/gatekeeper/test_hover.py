from playwright.sync_api import sync_playwright
import time

with sync_playwright() as p:
    browser = p.chromium.launch()
    page = browser.new_page(viewport={'width': 1280, 'height': 900})
    page.goto('https://hwzhxs.github.io/squad-landing/', wait_until='networkidle')
    
    thinker = page.locator('text=Thinker').first
    thinker.scroll_into_view_if_needed()
    time.sleep(0.5)
    
    bbox = thinker.bounding_box()
    print(f'Thinker text bbox: {bbox}')
    
    # Screenshot before hover
    page.screenshot(path='before_hover.png')
    
    # Hover over the card area
    page.mouse.move(bbox['x'] + bbox['width']/2, bbox['y'])
    time.sleep(3)
    
    page.screenshot(path='after_hover.png')
    
    # Check for video elements
    videos = page.query_selector_all('video')
    print(f'Video elements found: {len(videos)}')
    for i, v in enumerate(videos):
        src = v.get_attribute('src') or ''
        source = v.query_selector('source')
        source_src = source.get_attribute('src') if source else ''
        visible = v.is_visible()
        paused = v.evaluate('el => el.paused')
        opacity = v.evaluate('el => getComputedStyle(el).opacity')
        display = v.evaluate('el => getComputedStyle(el).display')
        print(f'Video {i}: src={src}, source={source_src}, visible={visible}, paused={paused}, opacity={opacity}, display={display}')
    
    browser.close()
