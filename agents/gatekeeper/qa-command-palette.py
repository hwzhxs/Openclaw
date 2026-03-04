"""QA test for Command Palette v1.1 UX polish"""
from playwright.sync_api import sync_playwright
import time, os

URL = "https://thursday-videos-ser-interstate.trycloudflare.com"
SHOTS = r"C:\Users\azureuser\.openclaw-agent3\workspace\qa-shots"
os.makedirs(SHOTS, exist_ok=True)

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page(viewport={"width": 1280, "height": 800})
    
    # 1. Load page
    print("=== LOADING PAGE ===")
    try:
        page.goto(URL, timeout=30000)
        page.wait_for_load_state('networkidle', timeout=15000)
    except Exception as e:
        print(f"Load error: {e}")
        page.screenshot(path=f"{SHOTS}/01-load-error.png", full_page=True)
        browser.close()
        exit(1)
    
    page.screenshot(path=f"{SHOTS}/01-initial.png", full_page=True)
    print(f"Title: {page.title()}")
    print(f"URL: {page.url}")
    
    # 2. Try to open command palette (common shortcuts: Cmd+K, Ctrl+K, Ctrl+P, /)
    print("\n=== OPEN COMMAND PALETTE ===")
    # Try Ctrl+K first
    page.keyboard.press("Control+k")
    page.wait_for_timeout(500)
    page.screenshot(path=f"{SHOTS}/02-after-ctrl-k.png")
    
    # Check if a modal/dialog appeared
    visible_dialogs = page.locator('[role="dialog"], [role="combobox"], [class*="command"], [class*="palette"], [class*="modal"], [class*="Command"]').all()
    print(f"Dialogs found after Ctrl+K: {len(visible_dialogs)}")
    
    if not visible_dialogs:
        # Try Ctrl+P
        page.keyboard.press("Control+p")
        page.wait_for_timeout(500)
        page.screenshot(path=f"{SHOTS}/02b-after-ctrl-p.png")
        visible_dialogs = page.locator('[role="dialog"], [role="combobox"], [class*="command"], [class*="palette"], [class*="modal"], [class*="Command"]').all()
        print(f"Dialogs found after Ctrl+P: {len(visible_dialogs)}")
    
    if not visible_dialogs:
        # Try clicking a trigger button
        triggers = page.locator('button:has-text("command"), button:has-text("search"), button:has-text("⌘"), [class*="trigger"]').all()
        print(f"Trigger buttons found: {len(triggers)}")
        if triggers:
            triggers[0].click()
            page.wait_for_timeout(500)
            page.screenshot(path=f"{SHOTS}/02c-after-trigger-click.png")

    # Dump page content for analysis
    content = page.content()
    print(f"\nPage content length: {len(content)}")
    # Print first 3000 chars to understand structure
    print(f"\n--- PAGE CONTENT (first 3000 chars) ---")
    print(content[:3000])
    
    # 3. Check for any interactive elements
    print("\n=== INTERACTIVE ELEMENTS ===")
    buttons = page.locator('button').all()
    print(f"Buttons: {len(buttons)}")
    for b in buttons[:10]:
        try:
            txt = b.text_content(timeout=1000)
            vis = b.is_visible()
            print(f"  Button: '{txt[:50]}' visible={vis}")
        except:
            pass
    
    inputs = page.locator('input').all()
    print(f"Inputs: {len(inputs)}")
    
    # 4. Check a11y basics
    print("\n=== A11Y CHECK ===")
    # Check for aria attributes on command palette elements
    aria_elements = page.locator('[role="listbox"], [role="option"], [role="combobox"], [aria-label], [aria-modal]').all()
    print(f"ARIA elements: {len(aria_elements)}")
    for el in aria_elements[:10]:
        try:
            role = el.get_attribute('role')
            label = el.get_attribute('aria-label')
            print(f"  role={role} aria-label={label}")
        except:
            pass
    
    # 5. Keyboard nav test - if palette is open
    print("\n=== KEYBOARD NAV ===")
    page.keyboard.press("Control+k")
    page.wait_for_timeout(500)
    
    # Try arrow keys
    page.keyboard.press("ArrowDown")
    page.wait_for_timeout(200)
    page.keyboard.press("ArrowDown")
    page.wait_for_timeout(200)
    page.keyboard.press("ArrowUp")
    page.wait_for_timeout(200)
    page.screenshot(path=f"{SHOTS}/03-keyboard-nav.png")
    
    # 6. Click outside to dismiss
    print("\n=== CLICK OUTSIDE DISMISS ===")
    page.mouse.click(10, 10)
    page.wait_for_timeout(500)
    page.screenshot(path=f"{SHOTS}/04-after-click-outside.png")
    
    # 7. Reopen and test Escape
    print("\n=== ESCAPE DISMISS ===")
    page.keyboard.press("Control+k")
    page.wait_for_timeout(500)
    page.keyboard.press("Escape")
    page.wait_for_timeout(500)
    page.screenshot(path=f"{SHOTS}/05-after-escape.png")
    
    # 8. Console errors
    print("\n=== CONSOLE ERRORS ===")
    errors = []
    page.on("console", lambda msg: errors.append(msg.text) if msg.type == "error" else None)
    page.reload()
    page.wait_for_load_state('networkidle', timeout=15000)
    page.wait_for_timeout(2000)
    if errors:
        for e in errors:
            print(f"  ERROR: {e}")
    else:
        print("  No console errors captured after reload")
    
    page.screenshot(path=f"{SHOTS}/06-final.png", full_page=True)
    browser.close()
    print("\n=== DONE ===")
