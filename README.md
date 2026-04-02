# 🚀 n8n v2.8.3 with Full Python Support (Fixed for Render.com)

This repository provides a custom Docker image for **n8n v2.8.3** that fixes the notorious "Virtual environment is missing" and "insufficient permissions" errors on Render.com.

## 🛠️ The Problem We Solved
The official n8n Docker image is missing the Python Task Runner source code, and Render's security policy (`noexec` on `/tmp`) blocks the default Python execution. 
**This image fixes it by:**
- Injecting the missing `@n8n/task-runner-python` source code.
- Pre-installing critical libraries: `requests`, `websockets`, `pandas`, `numpy`.
- Redirecting the runner to a safe internal directory.

## 🚀 One-Click Deployment

[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy?repo=https://github.com/TWOJA_NAZWA_UZYTKOWNIKA/n8n-internal-python)

## 📸 Proof it Works
![Python Node Working](https://raw.githubusercontent.com/TWOJA_NAZWA_UZYTKOWNIKA/n8n-internal-python/main/screenshot.png)
*(Wgraj swój zrzut ekranu do repozytorium i popraw ten link!)*

## 📦 Included Python Packages
- `pandas`, `numpy` (Data analysis)
- `requests` (API calls)
- `beautifulsoup4` (Web scraping)
- `websockets` (Required for n8n runner)

## 🔧 Manual Configuration
If you don't use the button above, ensure these Env Vars are set:
- `N8N_RUNNERS_MODE`: `internal`
- `N8N_RUNNERS_TEMP_DIRECTORY`: `/tmp/n8n_runner`
