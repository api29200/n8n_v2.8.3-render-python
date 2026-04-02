# 🚀 n8n v2.8.3 with Fixed Python Support for Render.com

[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy?repo=https://github.com/api29200/n8n_v2.8.3-render-python)

This repository provides a custom, production-ready Docker image for **n8n v2.8.3** that fixes the "Virtual environment is missing" and "insufficient permissions" errors specifically on Render.com.

## 🛠️ The Fix (Internal Task Runner)
The official n8n Docker image for 2.8.3 is missing the Python Task Runner source code, and Render's security policy (`noexec` on `/tmp`) blocks default execution. 

**This repo fixes it by:**
- **Code Injection:** Cloning the missing `@n8n/task-runner-python` source directly into the image.
- **Dependency Fix:** Pre-installing `websockets` (missing in original runner) and common ETL libs (`pandas`, `numpy`, `requests`, `beautifulsoup4`).
- **Permission Bypass:** Redirecting the runner to `/tmp/n8n_runner` with full ownership for the `node` user.

## 📸 Proof it Works
![Python Node Working](https://raw.githubusercontent.com/api29200/n8n_v2.8.3-render-python/main/screenshot1.png)
*Success! Python Code Node executing with external libraries on Render.*

## 🚀 One-Click Installation
1. Click the **Deploy to Render** button above.
2. Select **Starter** plan (required for Disk persistence).
3. Set your `WEBHOOK_URL` (the URL Render gives you).
4. **Done!** Python nodes will work out of the box.

## 📦 Pre-installed Python Packages
- `pandas` & `numpy` (Data Processing)
- `requests` (API interaction)
- `beautifulsoup4` (Scraping)
- `openpyxl` (Excel support)
- `websockets` (Core requirement)

## 🔧 Why use this instead of official image?
The official image throws an `Attempt to read execution was blocked due to insufficient permissions` error on Render. This happens because the runner fails to start due to missing files in `/usr/local/lib/node_modules/@n8n/`. We've reverse-engineered the path traversal and restored the environment.

---
Created by [api29200](https://github.com/api29200) | Found a bug? Open an issue!
