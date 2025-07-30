import asyncio
import socket
from playwright.async_api import async_playwright

async def wait_for_port(host: str, port: int, timeout: int = 60):
    for _ in range(timeout):
        try:
            with socket.create_connection((host, port), timeout=2):
                return True
        except Exception:
            await asyncio.sleep(1)
    return False

async def main():
    print("🔁 Waiting for localhost:3000 to become reachable...")
    port_ready = await wait_for_port("localhost", 3000)
    if not port_ready:
        print("❌ Timeout waiting for localhost:3000 to be available.")
        return

    print("🚀 Launching browser for GENSYN login...")
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        page = await browser.new_page()

        try:
            print("🌐 Opening http://localhost:3000...")
            await page.goto("http://localhost:3000", timeout=60000)

            print("🖱 Clicking 'Login' button...")
            await page.get_by_role("button", name="Login").click()

            email_input = await page.wait_for_selector("input[type=email]", timeout=30000)
            email = input("📨 Enter your email for GENSYN: ").strip()
            await email_input.fill(email)

            continue_button = await page.wait_for_selector("button:has-text('Continue')", timeout=10000)
            await continue_button.click()

            print("⌛ Waiting for OTP screen...")
            await page.wait_for_selector("text=Enter verification code", timeout=60000)
            await asyncio.sleep(1)

            otp = input("🔐 Enter OTP from your email: ").strip()
            if len(otp) != 6:
                raise Exception("OTP must be exactly 6 digits.")

            # Focus the first OTP input via JS (to trigger proper keyboard event handlers)
            await page.evaluate("""
                const input = document.querySelector('input');
                if (input) input.focus();
            """)
            await asyncio.sleep(0.2)

            print("⌨️ Typing OTP...")
            await page.keyboard.type(otp, delay=100)

            await page.keyboard.press("Enter")  # Optional; many forms auto-submit

            # Wait for success confirmation
            try:
                print("🕵️ Waiting for login success confirmation...")
                await page.wait_for_selector("text=/successfully logged in/i", timeout=60000)
                print("✅ Login confirmed!")")
            except Exception:
                print("❌ Login message not found. Capturing fallback state...")
                html = await page.content()
        
        except Exception as e:
            print("❌ An error occurred:", str(e))
        finally:
            await browser.close()

if __name__ == "__main__":
    asyncio.run(main())
