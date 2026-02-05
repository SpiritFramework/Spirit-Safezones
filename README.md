# 🛡️ Spirit-SafeZone

[![Version](https://img.shields.io/badge/version-2.0.0-blue)]()
[![License](https://img.shields.io/badge/license-MIT-yellow)]()
[![Status](https://img.shields.io/badge/status-stable-brightgreen)]()

**A lightweight, customizable FiveM safe zone script with visual boundaries and zone protection.**

---

## ⚠️ Dependencies & Requirements

&gt; **IMPORTANT:** This script requires **[Spirit-Notifications]** to function properly.

| Dependency | Required | Description | Download |
|------------|----------|-------------|----------|
| **[Spirit-Notifications]** | ✅ **Required** | Custom notification system for enter/exit alerts | [GitHub](https://github.com/SpiritFramework/Spirit-Notifications-FiveM) |

---

## 📋 Features

- 🎯 **Circular Zones** - Shows Safezones on mini map / big map.
- 👁️ **Visual Boundaries** - Configurable markers showing zone limits
- 🚫 **Weapon Control** - Disable/enable weapons inside safe zones
- 🚗 **Vehicle Protection** - Optional god mode for vehicles in zones
- 🎨 **Fully Customizable** - Easy configuration via config file
- ⚡ **Optimized** - Low resource usage (0.01-0.03ms)
- 🔔 **Notifications** - Visual alerts when entering/leaving zones *(via Spirit-Notfications)*

---

## 🚀 Installation

### Step 1: Install Dependencies

**You MUST install [Spirit-Notfications] first:**

```bash
# 1. Download Spirit-Notfications
Download https://github.com/SpiritFramework/Spirit-Notifications-FiveM

# 2. Add to your server resources
[resources]/Spirit-Notfications/

# 3. Ensure it in server.cfg (BEFORE SafeZone)
ensure Spirit-Notfications

### Step 2: Install Spirit-Safezones

# 1. **Download** the latest release from the [releases page](https://github.com/SpiritFramework/Spirit-Safezones-FiveM)

# 2. **Extract** the folder into your FiveM resources directory:
   ```bash
   [resources]/SafeZones/
