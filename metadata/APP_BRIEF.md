<!-- gf-brief source=58ffeb3e1bd05b8541d977cb10a970a8d738d4f4b273eb743cdd39d70f7a21b4 written=2026-09-30T22:34:30+03:00 -->
# Winodroll

## What it is
Winodroll is a local will-call desk for impulse shoppers. You stamp a priced want onto a hold ticket, wait out computed hours on a live rail, then mark it bought or dropped—or cut early by sacrificing another cooling ticket. Hours come from price versus a monthly impulse limit, then priority, necessity, and discretion.

## Launch and onboarding
Cold launch opens in dark mode on a blank field, then either onboarding or the desk.

If onboarding is not finished, a three-page intro appears:
1. Title **"Hold the purchase."** Line **"Stamp a priced want and wait the hours."** Footer **"Page 1 of 3"**. Top-right **"Skip"**. Bottom **"Continue"**.
2. Title **"The rail ticks hours."** Line **"Price, priority, necessity, and discretion set the span."** Footer **"Page 2 of 3"**. **"Skip"** / **"Continue"**.
3. Title **"Same code keeps longer."** Line **"Cut early only by dropping another cooling ticket."** Footer **"Page 3 of 3"**. **"Skip"** / **"Next"**.

**"Skip"** or **"Next"** finishes the intro and opens the desk. On a device with no prior desk, the home empty state is **"File a want."** / **"The span starts."** with **"Stamp"**.

## Screens

### Desk (home)
No tab bar. Top chrome: **"Review"**, **"Rules"**, **"Settings"**.

**Empty desk:** **"File a want."**, **"The span starts."**, full-width **"Stamp"** (opens Stamp). Optional banners: **"Restored the last good desk."**, **"The desk file was unreadable."**, or **"The desk did not save."** with **"Retry"**.

**Populated desk:**
- Hour rail: **"Hold this purchase."**, remaining hours figure, **"hours left"**, captions **"stamped"**, **"covers"**, **"limit"** (monthly impulse limit as money).
- Claim-check face: want name, price, hold label (**"Blank"**, **"Cooling"**, **"Released"**, **"Released, bought"**, **"Released, dropped"**, or **"Released, cut"**), optional retail code.
- **"Cooling on the desk"** plus cooling count.
- Strip **"Same code keeps the longer span."** / **"Stamp another. Cut buys early."** (opens Longer span).
- **"Stamp"** (opens Stamp).
- While hours remain and more than one ticket is cooling: **"Cut"** (opens Cut). **"Cut"** is disabled when only one cooling ticket exists.
- When remaining hours reach zero: **"Bought"** and **"Dropped"** replace **"Cut"**. Success notes **"Bought."** or **"Dropped."**
- Alert **"Hold refused"** with message such as **"Wait or cut."** and **"OK"**.

### Stamp (sheet)
Title **"Stamp"**. Close control (VoiceOver **"Close"**). Section **"Want"** fields: **"Name"**, **"Price"**, **"Priority"** (default 1), **"Necessity, 0 to 100"** (default 50), **"Discretion, 0 to 100"** (default 50), **"Retail code, optional"**. Keyboard **"Done"**. When figures are valid, section **"Hold"** shows preview hours and **"Same retail code keeps the longer span."** Empty-desk hint **"File the first want."** Bottom **"Stamp"** (disabled until name, price > 0, priority > 0, and necessity/discretion in 0–100). Discard dialog **"Discard this want?"** / **"The name and figures are not stamped."** with **"Discard"** / **"Keep"**. Fault notes include **"Name the want."**, **"Price must be above zero."**, **"Stamp failed."**, and similar.

### Cut (sheet)
Title **"Cut"**. Close (VoiceOver **"Close"**). Section **"Cooling tickets"** lists other cooling wants with **"Cover"** or **"Short"** and hours left. Tapping a **Cover** row releases early (face bought, sacrifice cut). Tapping a **Short** row shows **"Cover is short. Ticket stays."** Empty: **"No other cooling ticket."** / **"Stamp another want to cut."** / **"Close"**. Refused: **"Cut is refused."** / **"Cut needs a cooling ticket."** / **"Close"**.

### Longer span (sheet)
Title **"Longer span"**. Close (VoiceOver **"Close"**). Explains **"Same retail code keeps the longer span."** and **"The rail does not restart. Hours come from price versus the monthly limit, then priority, necessity, and discretion."** Optional **"This ticket"** with name, **"Stamped hours"**, **"Retail code"**. Line **"Cut early only by dropping another cooling ticket whose remaining hours cover this rail."** Empty: **"Stamp a want first."** / **"Rehold needs a cooling ticket with a retail code."** / **"Close"**.

### Review (sheet)
Title **"Review"**. Close (VoiceOver **"Close"**). Sections **"Released"**, **"Cut"**, **"Cooling"** with name, price, hold label, and cooling hours when cooling. Empty: **"No tickets yet."** / **"Released, cut, and cooling land here."** / **"Stamp a want"** (closes sheet). Error: **"Review did not load."** / **"The desk did not save. Retry, or close."** / **"Retry"**.

### Rules (sheet)
Title **"Rules"**. Close (VoiceOver **"Close"**). **"Monthly limit"** field **"Monthly impulse limit"** (starter value 400). Caption **"Hours come from price versus this limit. Local only. No checkout."** Live board **"Hours at this limit"** with **"hours this limit stamps"**, captions **"this limit"**, **"saved"**, **"on the rail"** or **"price"**, plus shift notes such as **"Raising the limit shortens hours on the live tickets."** **"Next stamp"** for blank wants. Empty board: **"No cooling hours."** / **"This limit sets the next stamp…"** Invalid draft: **"Set a monthly limit."** or **"Limit must be above zero."** **"Save"** (disabled until limit > 0); note **"Saved."** Discard dialog **"Discard the limit?"** / **"The new limit is not saved."** with **"Discard"** / **"Keep"**. Keyboard **"Done"**.

### Settings (sheet)
Title **"Settings"**. Close (VoiceOver **"Close"**). Optional **"Desk is clear."** Section **"Contact"**: link labeled with **"https://counterfoil-desk.pro/contact-us"** (VoiceOver **"Contact"**), or **"Contact is unavailable."** Section **"Desk"**: **"Show the intro"** (returns to onboarding), **"Reset the desk"**. Confirm **"Reset the desk?"** / **"All tickets, marks, and the monthly limit go."** with **"Reset the desk"** / **"Keep"**.

## Features
- Stamp a priced want (name, price, priority, necessity, discretion, optional typed retail code) onto a hold ticket
- Live hour rail of remaining hours versus stamped hours, cover count, and monthly limit
- Monthly impulse limit that sets hold hours from price (clamped roughly 6–720 hours)
- Hold states Blank, Cooling, Released (bought / dropped / cut)
- Same retail code keeps the longer span without restarting the rail
- Cut early by covering with another cooling ticket’s remaining hours
- Short cover leaves the face ticket in place
- Bought / Dropped when the rail hits zero
- Review of released, cut, and cooling tickets
- Rules board showing hours at the drafted limit
- Longer span explanation sheet
- Re-run intro; reset the desk
- Contact link to the support page
- Everything stays on this device; no checkout

## Behaviours that can look like bugs
- **"Stamp"** on the Stamp sheet stays disabled until name and valid figures are filled; fix by completing the fields.
- **"Cut"** on the desk stays disabled until a second cooling ticket exists; stamp another want first. With only one cooling ticket, Cut’s empty page says **"No other cooling ticket."**
- **"Bought"** / **"Dropped"** appear only when remaining hours are zero; before that the desk shows **"Cut"** (or disabled Cut). Trying early release can alert **"Hold refused"** / **"Wait or cut."**
- Picking a **Short** cover shows **"Cover is short. Ticket stays."**—intentional; pick a ticket marked **Cover**, or wait.
- Discard dialogs (**"Discard this want?"**, **"Discard the limit?"**) block leaving with unsaved edits; **"Discard"** or **"Keep"**.
- Empty Review (**"No tickets yet."**) and empty desk (**"File a want."**) until the first stamp.
- **"Save"** on Rules stays disabled until the monthly limit is above zero.
- After reset or first install, the desk is clear again; cooling tickets resume from saved state across launches until reset.

## Starter content and resume
On Simulator only, a one-time demo desk may appear after load (onboarding already complete): cooling **"Field bag"** and **"Desk lamp"**; released **"Notebook"** (bought) and **"Cable"** (cut); blank **"Chair"**, **"Kettle"**, **"Tray"**; monthly limit 400. On a real device there is no seed—empty desk after onboarding. Unfinished cooling holds resume with remaining hours ticking from the stamped start. Incomplete Stamp/Rules drafts are not kept if discarded.

## Permissions
None. The app never prompts for camera, photos, microphone, location, or tracking. Retail codes are typed by hand.

## Absent
Login or accounts; in-app purchase; ads; analytics; shared user-generated content; account deletion flow; App Tracking Transparency prompt.

## Data and support
Desk data stays on this device (**"Local only. No checkout."**). Support: Settings → Contact → **"https://counterfoil-desk.pro/contact-us"**.

## Scanning and health
None. No barcode or QR scanning. No health, medical, or product-health information or citations.

## Platform
UI strings are English; money and numbers follow the device locale. Portrait only (iPhone and iPad). Dark appearance. Requires iOS 17.0 or later.

## Category
Finance
