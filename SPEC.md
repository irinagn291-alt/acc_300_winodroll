# Counterfoil — Build Specification

> Portfolio app 120, batch pending. This document is the complete brief for
> building this application. Read all of it before writing any code. Anything
> not specified here is your decision, but must stay consistent with section 3.

**One-line positioning:** File a priced want and wait its hours before marking it bought.

| Field | Value |
| --- | --- |
| Product name | Counterfoil |
| Bundle identifier | `com.counterfoil.desk` |
| Domain | https://counterfoil-desk.pro |
| Contact URL | https://counterfoil-desk.pro/contact-us |
| Deployment target | iOS 17.0 |
| Swift version | 6.2, strict concurrency `complete` |
| Devices | iPhone and iPad, portrait |
| Interface style | Dark |
| Asset prefix | `ctf_` |
| User-Agent | `Counterfoil/1.0 (iOS; +https://counterfoil-desk.pro)` |

---

## 1. Non-negotiable constraints

1. **No CocoaPods.** Dependencies come from Swift Package Manager, a local
   in-repo package, a vendored source folder, or nothing at all — per section 3.
2. **No shared code with other portfolio apps.** Business rules are re-implemented
   here under this app's own type names.
3. **All code, identifiers, comments, UI copy and the README are in English.**
4. **No launch gate, no WebView shell, no remote configuration, no analytics.**
   Guideline 4.2 (Minimum Functionality): this is a native SwiftUI product, not
   a web browsing experience. WKWebView / SFSafariViewController as UI is a
   reject. Push notifications, Core Location, and sharing do not make a
   browser or a thin catalog into an App Store app.
5. **Guideline 5.1.1 (Privacy):** never direct the user to grant camera access.
   A pre-permission screen may exist; the proceed button is **Continue** or
   **Next**, never "Allow camera", "Enable camera", "Grant camera", or a bare
   Allow/Enable that triggers `requestAccess`. The system alert is the only Allow.
6. **No CI files.** No `bitrise.yml`, no `Scripts/`, no `metadata/` folder.
7. **Assets are AI-generated.** No stock photography. SF Symbols may support
   small affordances but must never be the primary iconography.
8. **The app must build clean** with
   `xcodegen generate && xcodebuild -scheme Counterfoil -destination 'generic/platform=iOS' build`.
9. **Nothing may echo another app in this batch** in naming, layout or visuals.
10. **This is not a calorie meal-slot tracker** unless family is `food_tracker`.
   Do not invent food logging to fill the brief.

---

## 2. Product core

The product is offline-first. No account, no sign-in, no ads, no in-app purchase,
no analytics SDK, no remote config. All user data stays on the device.

A shopper stamps a hold ticket for a priced want and waits the computed hours before releasing it as bought.

### 2.1 User flow

1. Tap Cut on the seeded ticket to drop another cooling ticket whose remaining hours cover this rail
2. File a new want with price, priority, necessity and discretion, and scan its retail code if you have one
3. Watch the home rail count remaining hours from the family formula
4. When the rail reaches zero, release the want as bought or dropped
5. Open Review to read released, cut, and still-cooling tickets
6. Edit the monthly impulse limit on Rules

### 2.2 Essential behaviour

- Hold ticket on home with a live remaining-hours rail
- File a want with price, priority, necessity and discretion
- Hours from price versus monthly limit, priority, necessity and discretion, clamp 6 to 720
- Cut-cover: sacrifice another cooling ticket whose remaining hours cover this rail
- Stamping the same retail code while cooling keeps the longer computed span
- Review of released versus cut versus still cooling
- Local rules only, no checkout, no remote catalog

---

## 3. Uniqueness assignment for Counterfoil

| Axis | Assigned value |
| --- | --- |
| Architecture | **Hold-ticket ADT fold (Blank | Cooling | Released); the desk is a fold over Wants; Stamp writes a Ticket with computed hours and folds Blank to Cooling; Cut writes a CoverMark when the sacrificed Ticket remaining hours cover this rail and folds Cooling to Released; a short cover writes a ShortMark and keeps the Ticket; Cut on Blank is refused; Stamp of the same code while Cooling keeps the longer span; Stamp samples a Want that is not Released; empty desk writes Blank** |
| UI approach | **SwiftUI WKWebView representable · timeline** |
| Naming convention | **Will-call / claim-check lexicon** |
| File organization | **By hold role (Desk, Ticket, Rail, Stamp, Cut, CoverMark, ShortMark)** |
| Dependency strategy | **None** |
| Design direction | **premium · numeric-rail · duotone** |
| Typography | **SF Pro** |
| Navigation pattern | **Desk-locked chrome (the hold ticket never leaves; Review, Rules and Settings arrive as sheets)** |
| AI art style | **Cyberpunk digital art · photography-driven** |
| Functional twist | **Longer-span rehold** |
| Persistence | **UserDefaults+Codable** |
| Screen composition | see 3.6 |

### 3.0 Product concept

This is the product the contracts below are assigned to. Do not substitute another.

**Family** — cooling_span

**Core** — A shopper stamps a hold ticket for a priced want and waits the computed hours before releasing it as bought.

**Audience** — Impulse buyers who almost purchase on the spot and want a hold that gets longer if they come back to the same item.

**User flow**

1. Tap Cut on the seeded ticket to drop another cooling ticket whose remaining hours cover this rail
2. File a new want with price, priority, necessity and discretion, and scan its retail code if you have one
3. Watch the home rail count remaining hours from the family formula
4. When the rail reaches zero, release the want as bought or dropped
5. Open Review to read released, cut, and still-cooling tickets
6. Edit the monthly impulse limit on Rules

**Essential features**

- Hold ticket on home with a live remaining-hours rail
- File a want with price, priority, necessity and discretion
- Hours from price versus monthly limit, priority, necessity and discretion, clamp 6 to 720
- Cut-cover: sacrifice another cooling ticket whose remaining hours cover this rail
- Stamping the same retail code while cooling keeps the longer computed span
- Review of released versus cut versus still cooling
- Local rules only, no checkout, no remote catalog

**Twist** — Longer-span rehold. Hours come from price versus the monthly limit, then tick on the ticket rail. Stamping the same retail code again while the ticket is cooling keeps the longer of the two spans instead of restarting. Buying early is a cut: another cooling ticket whose remaining hours cover this rail is dropped, and this want releases.

**Why this is not a repeat** — Not Restante: that app snaps computed hours to a payday calendar and unlocks by covering the gap to payday. This home is a hold ticket whose rail ticks real hours, and the early path is a cut-cover against another ticket remaining hours, not a payday gate. Re-stamping the same retail code keeps the longer span, so coming back does not restart the wait. Not a fixed 24h or 7d timer, not a tab plus a list of wants, not a calorie tracker, and not a catalog crate. The search_api leftover is unused; filing never calls Open Food Facts. The ticket surface is a local print of a native hold, not a store or Safari shell. Distinct from Kentledge (subscription seats) and PlateOps (shareable report).

### 3.0a Craft from the shipped portfolio

Full craft is in KNOWLEDGE.md. Follow it. Do not copy type names or layouts.
- Home: Wait clock + swap-release.
- Invariant: Base hours from price vs monthly limit. hours = base × priority × (1.5 − nec/100) × (2 − disc/100). Clamp 6…720h. Buy early only by sacrificing another want.
- Never: No checkout.
- Desk `watch_rate`: OLS s/day vs day; R²; DU/DD/CU/CL/CD spread; COSC |dev|≤4.
- Taste DNA is section 7.6. Do not invent a second look.
- A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.

### 3.1 Architecture contract

The hold is a closed algebraic fold with cases Blank, Cooling, and Released, and a fourth case is a defect. The desk is a fold over Wants: Stamp samples a Want that is not Released, writes a Ticket with hours from the family formula, and folds Blank to Cooling, while an empty desk writes Blank. Cut writes a CoverMark when another cooling Ticket remaining hours cover this rail, drops that sacrificed ticket, and folds this Cooling to Released; a short cover writes a ShortMark and keeps this Ticket; Cut on Blank is refused. Stamp of the same retail code while Cooling keeps the longer of the two computed spans and does not restart the rail. One observable DeskStore pattern-matches the fold; views call stampWant and cutCover and never store a parallel cooling bool; unit tests prove not-Released sampling, Cut-on-Blank refuse, short-cover keep, CoverMark fold, longer-span rehold, and Blank empty.

Put a short comment block at the top of each principal type stating the role it
plays in this architecture. The README must justify the pattern for this product.

### 3.2 UI contract

100 percent SwiftUI, Dark. No WKWebView, no SFSafariViewController, no UIViewRepresentable, no camera preview, no TabView. The assigned SwiftUI WKWebView representable is leftover uniqueness salt; do not import WebKit and do not host a page. Home is the mechanic: Desk is one hold ticket filling remaining height and the iPad width, a TimelineView numeric rail of remaining hours, then the claim-check face under that rail, not a list of wants and not a store shell. Confine TimelineView, Canvas, and Shape to that one Desk hero. Filing, Cut, Review, Rules, and Settings are stock sheets (List, Form). Empty Desk and onboarding are full pages with frame(maxHeight: .infinity), generated cutout art, one headline, one line, and a bottom full-width Continue or Next. Primary Stamp is a full-width ButtonStyle with default, pressed, disabled, and loading. Cut uses the destructive variant. Chrome lives inside the label with contentShape, min 44pt. One spring on a successful Stamp or CoverMark (response about 0.4, damping about 0.8); everything else ease-out; Reduce Motion fades only. Numbers go through NumberFormatter. Colour is never the only Cooling versus Released signal. The ui axis string is never a section title.

### 3.3 Naming contract

Convention: Will-call / claim-check lexicon.

Examples to follow: `WillCall`, `ClaimCheck`, `CoverMark`, `stampTicket(_:)`

### 3.4 Dependency contract

Zero external dependencies. project.yml has no packages key. No SPM, no CocoaPods, no URLSession catalog client. The leftover search_api and AVCaptureMetadataOutput axes are unused; do not import AVFoundation or WebKit, do not request camera access, do not ship NSCameraUsageDescription, and do not call cgi/search.pl. Filing types an optional retail code. Foundation and SwiftUI only.

### 3.5 Navigation contract

Desk-locked chrome: the hold ticket never leaves. There is no TabView and no pushed detail. Stamp, Cut, zero-rail release, and the hour rail fuse on Desk. Review, Rules, and Settings arrive as sheets over the desk. Four destinations, never exactly three tabs. One haptic on a successful Stamp or CoverMark, none on presenting a sheet. Contact URL https://counterfoil-desk.pro/contact-us lives on Settings. After onboarding, read ProcessInfo.processInfo.arguments once: -ReviewScreen today stays on Desk, log presents Review, goals presents Rules. Extra key settings presents Settings. Skip onboarding on Simulator after the ctf.demo.v1 seed so the hook can fire.

### 3.6 Screen composition contract

Ticket desk with hour rail; Review lists released, cut and cooling; Rules edits the monthly limit; Settings holds contact. Physical screens: Desk, Review, Rules, Settings. Desk is the locked hold ticket (ReviewScreen today): live remaining-hours rail, Stamp, Cut-cover against another cooling ticket, and release as bought or dropped when the rail is at zero. Filing a want (price, priority, necessity, discretion, optional typed retail code) is a sheet from Desk, not a tab. Review is a sheet of released, cut, and still-cooling tickets (ReviewScreen log). Rules is a sheet that edits the monthly impulse limit (ReviewScreen goals). Settings is a Form for contact URL at https://counterfoil-desk.pro/contact-us, re-run onboarding, and resetAllData (deep link settings). Onboarding is a one-shot cover of three pages with Continue or Next at the bottom full width. Empty Desk is a full page: generated cutout art, headline File a want., one line The span starts., full-width bottom Stamp. Seeded Desk shows a live Cooling ticket so Stamp and Cut are enabled; a zero rail and a Blank desk are test fixtures, not the first frame. No Today, Scan, Search, or Goals screens. ReviewScreen today, log, and goals must open three different screens.

Section 5 lists the logical functions that must exist. This section decides how
they are grouped into actual screens. Where the two disagree, this section wins.

A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.

---

## 4. Target file organization

Scheme: **By hold role (Desk, Ticket, Rail, Stamp, Cut, CoverMark, ShortMark)**

```
Counterfoil/
  Desk/
  Ticket/
  Rail/
  Stamp/
  Cut/
  CoverMark/
  ShortMark/
  Assets.xcassets/
```

Adapt the leaf files to the architecture, but the top-level shape is fixed. Do
not create a `Utils/` or `Helpers/` dumping ground.

---

## 5. Screens

Build the screens named in section 3.6. The labels below are logical;
actual type names follow this app's naming convention.

### 5.1 Onboarding
Three to four pages. Explains the product, writes initial settings, sets a
completion flag. Skip still writes sensible defaults. Re-runnable from Settings.

### 5.2 Home
A first-class screen for **Home**. Must render empty, populated and error states.

### 5.3 Review
A first-class screen for **Review**. Must render empty, populated and error states.

### 5.4 Rules
A first-class screen for **Rules**. Must render empty, populated and error states.

### 5.5 Settings
A first-class screen for **Settings**. Must render empty, populated and error states.

### 5.6 Settings
Holds: re-run onboarding, reset all data (confirmed), and the contact link to
the domain contact-us URL.

### 5.7 Twist screen
See section 12. The twist needs at least one screen of its own plus a surface on the home screen.


---

## 6. Domain model

Minimum entities, named per this app's convention:

- **Want** — named per this app's convention.
- **Rule** — named per this app's convention.
- Plus whatever the twist in section 12 requires.


---

## 7. Design system

Direction: **premium · numeric-rail · duotone**

### 7.1 Palette

| Token | Hex | Use |
| --- | --- | --- |
| `background` | `#1B2C1E` | Screen background |
| `surface` | `#293D36` | Cards, rows, sheets |
| `ink` | `#F1F4F1` | Primary text and icons |
| `accent` | `#73D3B0` | Primary action, key figure, progress fill |
| `muted` | `#B0BFB3` | Secondary text, dividers, disabled |

Define these as named colours in `Assets.xcassets` and reach them through one
typed accessor. Never hard-code a hex string anywhere else.

### 7.2 Typography

Family: **SF Pro**

SF Pro via Font.system as the editorial type move: measure, generous leading, one hairline rule under the rail numerals, no third display size on Desk. Display is the remaining-hours figure, short and wide, one or two lines, never more than four, never above 34pt. Body is about 17pt for the claim-check face and want name. Caption is Cooling, Released, and Cut. At most six named steps behind one accessor: display, title, headline, body, caption, micro. Weights and step carry hierarchy. No Font.custom, no fixedSize, never below 12pt. Tabular figures for remaining hours, price, and the monthly limit through NumberFormatter. Dynamic Type; at AX5 the rail numeral may drop a step so it never clips; names truncate, numbers win. Day edges use Calendar.current.startOfDay then fold to Int YYYYMMDD.

Define a type scale of at most six steps behind one accessor and use only those
steps. Text stays legible at the largest Dynamic Type size.

### 7.3 Layout

- One base spacing unit (4 or 8 pt); only multiples of it.
- Corner radius and elevation are fixed by section 7.4, not chosen per screen.
- Every interactive element is at least 44x44 pt.

### 7.4 Component contract

Corner radius: **32pt** for cards, sheets and primary surfaces; **16pt** for chips, badges and small controls. Reach both through one accessor. Never a bare literal number, and never zero — a hard edge is not this app's design direction.

Elevation: **shadow** — a single soft drop-shadow token, reused everywhere a surface sits above another.

Primary control: **tinted glass** — primary chrome sits on a tinted translucent surface (`Material` plus the accent colour at low opacity), never plain flat colour.

This is arithmetic, not a suggestion: every card, sheet, chip and button in this app uses these two radii and this elevation style. Do not introduce a second radius or a second elevation style.

### 7.5 Custom rendering scope

This app's `ui` axis is **SwiftUI WKWebView representable · timeline**.

If that approach uses anything beyond stock SwiftUI/UIKit controls — `Canvas`, `CALayer`, Metal, SceneKit, SpriteKit, RealityKit, a hand-drawn `UIViewRepresentable`, or any other pixel-level custom rendering — confine it to exactly one hero surface on one screen (the mechanic's home view, or the one screen this axis exists to showcase). Every other screen — every list, every settings screen, every sheet, every secondary surface — is built from stock components: `List`, `Form`, `NavigationStack`, `TabView`, `Button`, `.sheet`, native `Text`/`Image`. A second custom-rendered surface elsewhere in the app is a defect, not a stylistic choice.

If **SwiftUI WKWebView representable · timeline** is already fully native (no custom drawing layer), this section is satisfied automatically — there is nothing to confine.

The `ui` axis value is an implementation choice. It must never appear as a user-visible section title or label.

### 7.6 Taste DNA

Aesthetic: **editorial** (Editorial: measure, rules, type hierarchy, almost no boxes.)

Reference system: **premium** — steal rhythm and restraint, not their colours or logos.

Mood: **Apple-inspired premium aesthetic with precise spacing, modern typography, and a refined, polished visual language.**.

Home rhythm (`numeric-rail`, comfortable): A row of live figures, then the log. Numbers are the chrome.

Editorial: measure, rules, type hierarchy, almost no boxes. Layout `numeric-rail`, density comfortable. Kit 32/16, shadow, tinted glass. Palette recipe `duotone`. One spring on the commit (response ~0.4, damping ~0.8). Everything else is ease-out. Reduce Motion: fade, no spring. Reduce Motion: fade only. Do not invent a second radius or a second accent.

Type move: Editorial measure, generous leading, one rule. Reference type feel: editorial.

Motion (`spring`): One spring on the commit (response ~0.4, damping ~0.8). Everything else is ease-out. Reduce Motion: fade, no spring.

Voice (`dry`): Short verbs. No warmth padding. 'Saved.' not 'Your changes were saved successfully.'

Anti-slop from KNOWLEDGE.md applies. Taste never overrides contrast, 44pt hits, VoiceOver labels, or Reduce Motion.

---

## 8. UI and UX quality bar

Every item here is a defect if it is missing. Do not treat this as advice.

**Layout**

- Respect safe areas on every screen. Nothing sits under the notch, the Dynamic
  Island or the home indicator.
- The app is portrait-only on iPhone. Lock it in the Info settings and do not
  write rotation-dependent layout.
- No layout shift when asynchronous data arrives. Reserve the final size up
  front, or use a redacted placeholder of the same dimensions.
- Long product names must truncate gracefully, never push a number off screen.
  Numbers win; names truncate.
- Sibling cards, images and titles never overlap. Each cell owns its frame;
  `scaledToFill` is clipped to that cell. A chopped headline or two canvases
  in one slot is a defect, not a collage.
- Minimum tap target 44x44 pt for every interactive element, including small
  icon buttons and list accessories.
- Pick one base spacing unit and use only multiples of it. No arbitrary values.

**Keyboard**

- The grams field uses `.decimalPad`, and the decimal separator matches the
  user's locale.
- Content scrolls out from under the keyboard. The focused field is always
  visible.
- Tapping outside the field, or scrolling, dismisses the keyboard.
- Validate on the fly: reject negative and non-numeric input rather than
  crashing the parser later.

**Loading and state**

- Every asynchronous operation has a visible loading state.
- Guard against the spinner flash: if the work finishes in under 150 ms, do not
  show a spinner at all.
- Every list has a designed empty state containing a primary action, not just a
  sentence of text.
- Every error state offers a retry, and states plainly what failed.
- Disable the primary button while its action is in flight so it cannot be
  double-tapped into a double push or a duplicate entry.

**Typography and accessibility**

- All text scales with Dynamic Type. Verify at the largest accessibility size:
  nothing may clip or overlap.
- Every icon-only control has an `accessibilityLabel`. Decorative images are
  marked as decorative so VoiceOver skips them.
- Colour is never the only signal. Pair it with a label, a shape or an icon.
- Honour Reduce Motion: replace movement-heavy transitions with a fade.
- Meet contrast requirements against the palette in section 7. Check the muted
  colour against the background specifically; that is where these palettes fail.

**Formatting**

- Format every number with `NumberFormatter`, never string interpolation. Group
  separators and decimal separators must follow the locale.
- Energy is shown as a whole number of kcal. Macros are shown with at most one
  decimal place.
- Round only at the point of display. Stored values keep full precision.
- Day boundaries use `Calendar.current.startOfDay(for:)` in the user's current
  time zone. Handle the day changing while the app is open, and handle the
  short and long days that daylight saving produces.
- Unknown macro values render as a dash or the word "unknown", never as 0.

**Motion and feedback**

- One haptic on a successful commit (a food logged, a target saved). No haptic
  on navigation.
- Animations are short (0.2 to 0.35 s) and use a single shared easing curve.
- Nothing animates on first appearance of a screen except an intentional entry
  transition.

**Navigation**

- Back always works and never loses entered data without asking.
- A destructive action (delete a log row, reset all data) is confirmed.
- Modal sheets can always be dismissed; there is no dead end.
- Deep state is restorable: relaunching returns the user to a sane screen.


Every item here is a defect if it is missing. Section 7.4 fixed the numbers —
this is where they have to show up on screen.

**Hierarchy and density**

- Every screen has exactly one dominant element (a hero number, a canvas, a
  primary card) that the eye lands on first. A screen where every element has
  equal weight reads as a spreadsheet, not a product.
- Related content is grouped into a card or a section with the elevation
  style from 7.4, not left floating on the bare background.
- Unused flat background is not "minimal" — see the density rule in
  `KNOWLEDGE.md`. If a screen has room left after the mechanic and the
  content, add a secondary surface (a stat strip, a recent-activity card, a
  related-item row), not a `Spacer`.

**Components**

- Every card, sheet, chip, row and button in the app uses the corner radius
  and elevation from section 7.4. No screen introduces its own radius or its
  own shadow value "just for this one card".
- Buttons have a pressed state (`ButtonStyle` with a scale or opacity change
  on `isPressed`) and a disabled state that is visibly different, not just
  non-interactive.
- Chips and badges are pill or rounded-rect shaped per 7.4, never a bare
  `Text` with no background sitting where a control is expected.
- A functional control (add, filter, sort, close, more, share, delete) is an
  SF Symbol inside a properly hit-targeted `Button`. SF Symbols are fine and
  expected here — section 16 only bans them as the app's primary brand
  iconography (app icon, empty-state hero, onboarding art), which is what the
  generated assets in section 13 are for.

**Depth and material**

- At least one surface in the app (a sheet, a modal, a floating toolbar) uses
  the elevation style from 7.4 to visibly sit above the content behind it.
  A flat app with no depth anywhere reads as a wireframe.
- Icons and generated art sit on the surface colour from 7.1, never directly
  on a colour that makes their edges disappear.

**Motion as feedback, not decoration**

- The one dominant element in a screen (7.4's primary control, the mechanic's
  hero) responds visibly to touch: a scale, a colour shift, a haptic — pick
  at least one. A control that looks identical pressed and unpressed reads as
  broken, not calm.

**Taste DNA (section 7.6)**

- Home uses the assigned layout family and density. Three identical equal-weight
  cards, a leftover bento hole, or a second column structure copied down the
  page is a defect.
- Copy follows the assigned voice. No em-dash, no elevate/unlock/seamless, no
  emoji, no SECTION 01 labels.
- Motion follows the assigned personality and honours Reduce Motion with a fade.
  One signature motion per view. No glow stacked on glass stacked on spring.
- Tokens by intent: the live verb wears accent; delete does not wear primary.


---

## 9. Concurrency

The target builds with Swift 6.2 and `SWIFT_STRICT_CONCURRENCY = complete`. It
must compile with **zero concurrency warnings**. Warnings here become crashes
later, so they are not negotiable.

- All UI types are `@MainActor`. Annotate the type, not individual methods.
- Any value crossing an actor boundary is `Sendable`. Prefer immutable structs
  of primitives.
- Do not use `@unchecked Sendable`. If it is genuinely unavoidable, it needs a
  comment explaining what guarantees the safety.
- No mutable global state. No `static var` that is written after launch.
- Networking and storage APIs are `async` and honour cancellation. When the
  search query changes, cancel the in-flight task; do not let a stale response
  overwrite fresh results.
- Use structured concurrency. Avoid `Task.detached` unless there is a stated
  reason. Never fire a `Task` that outlives the view without owning it.
- Never use `DispatchQueue.main.asyncAfter` to paper over an ordering problem.
  Fix the ordering.
- `Timer` and notification observers are invalidated in `deinit` or on
  disappear.


---

## 10. Persistence engineering

Chosen technology: **UserDefaults+Codable**

One Codable DeskDocument (schemaVersion from 1, Wants with hold Blank Cooling or Released, Tickets with computed hours and stampedAt, CoverMarks, ShortMarks, Rules monthly limit, daykeys as Int YYYYMMDD) encoded to JSON Data in UserDefaults under ctf.desk.v1. Hold case is stored; cooling-ness is not a parallel bool. Remaining hours are computed hours minus elapsed since stampedAt, floored at zero. In-memory DeskStore is the source of truth; UserDefaults is the projection. Views never touch UserDefaults. Debounce writes. Flush when scenePhase becomes inactive or background, and after Stamp, CoverMark, ShortMark, Rules save, or reset. Decoding failure falls back to ctf.desk.v1.backup, then an empty desk, never a crash. resetAllData() is reachable from Settings. Tests use a private UserDefaults suite. Simulator seed only once behind ctf.demo.v1 writes several priced Wants, at least two Cooling tickets with rails above zero so Cut is live, one Released and one Cut so Review is a used product, a monthly limit on Rules, marks onboarding complete, and never seeds Blank as the first frame. Never seed on a device.

This app persists to **files on disk**. The following are mandatory.

- Write atomically. Either `Data.write(to:options: .atomic)` or write to a
  temporary file and `FileManager.replaceItemAt`. A non-atomic write that is
  interrupted leaves a truncated file and the app will not launch.
- Create the containing directory with
  `withIntermediateDirectories: true` before the first write.
- Every document carries a `schemaVersion` field from version 1, and the decoder
  switches on it.
- Decoding failure must be recoverable: keep the previous good file as a
  `.backup`, fall back to it, and if that also fails start from empty state and
  tell the user. Never crash on a corrupt file.
- All file IO happens off the main thread. The main thread never blocks on disk.
- Debounce writes during rapid edits, but force a flush when `scenePhase`
  becomes `.inactive` or `.background`, and after any destructive action.
- Exclude caches from backup with `URLResourceValues.isExcludedFromBackup` where
  appropriate; user data belongs in Application Support and should be backed up.
- Keep an explicit in-memory source of truth and treat the file as a projection
  of it, so a failed write never leaves the UI showing data that does not exist.


Regardless of technology:

- One seam between domain logic and storage; the UI never touches storage types.
- Writes survive a force-quit. Do not rely on `applicationWillTerminate`.
- Provide `resetAllData()`, used by tests and reachable from Settings.

---

## 11. Networking

- One client type owns both Open Food Facts endpoints.
- Set `User-Agent` on every request. Open Food Facts throttles clients that do
  not identify themselves.
- 15 second timeout. One retry on a transient transport failure, then a typed
  error. Do not retry a 404.
- Cancel the in-flight search when the query changes. Debounce input by roughly
  300 ms.
- Decode into DTO types that mirror the JSON exactly, then map to domain types.
  Never decode straight into your domain model.
- Dedicated `JSONDecoder` with `.useDefaultKeys`. Never `convertFromSnakeCase` —
  Open Food Facts keys like `energy-kcal_100g` break snake_case conversion.
- Resolve a scanned code with `GET /api/v2/product/<barcode>.json`, not a search.
- Open Food Facts data is user-contributed and frequently incomplete. Every
  numeric field is optional. A product with no energy value is a normal case
  that the UI must present, not an error.
- Some numeric fields arrive as strings. The decoder must accept both a number
  and a numeric string for every nutriment.
- `status` of `0` in the product response means not found. Map it to a distinct
  error case so the UI can offer manual entry.
- Never crash on malformed JSON. A decoding failure is a handled error.
- Cache every resolved product locally on success, so the app degrades to a
  working offline catalogue.


Set `User-Agent: Counterfoil/1.0 (iOS; +https://counterfoil-desk.pro)` on every request. Never reuse another app's string.
No required remote catalog. Network only if this product actually needs it.

---

## 11b. App Store readiness

The app must be submittable without further work.

- `PrivacyInfo.xcprivacy` in the target, declaring the UserDefaults access API
  reason `CA92.1` and the file timestamp reason `C617.1`, with
  `NSPrivacyTracking` false and no collected data types.
- `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO` in the pbxproj so TestFlight
  does not sit on Missing Compliance.
- `NSCameraUsageDescription` written specifically for this app. Generic strings
  get rejected.
- `LSApplicationCategoryType` of `public.app-category.healthcare-fitness`.
- Portrait only, iPhone and iPad (`TARGETED_DEVICE_FAMILY = "1,2"`).
- No account, no sign-in, no delete-account flow, no in-app purchase, no ads, no
  user-generated content, and therefore no report or block UI.
- App Tracking Transparency is never invoked.
- The camera is the only sensitive permission requested.
- Guideline 5.1.1 (Privacy): do not encourage or direct the user to grant camera
  access. A pre-permission screen may exist, but the proceed button must be
  **Continue** or **Next** — never "Allow camera", "Enable camera",
  "Grant camera", or a bare Allow/Enable that calls `requestAccess`. The
  system dialog is the only Allow. Denied/restricted offers Open Settings.
- The app must not present itself as a clinician or as medical advice.
- Guideline 4.2 (Design — Minimum Functionality): the binary must be a native
  product, not a web browsing experience. No WKWebView / SFSafariViewController
  / UIWebView as home, a tab, or the primary UX. A content catalog, article
  reader, or site wrapper that could be a website is a reject. Push
  notifications, Core Location, and sharing do not make that acceptable.
- Guideline 1.4.1 (Safety — Physical Harm): if the binary shows health or
  medical recommendations, body-based targets, dosages, "you should" guidance,
  or product health claims (food, drink, supplement, remedy), put citations
  in the app. Tappable links to the sources, easy to find: same screen as the
  claim, or a Sources row one tap from Settings. Name the source (Open Food
  Facts, USDA FoodData Central, WHO, NIH MedlinePlus, …) and link it. A
  "not medical advice" footer without sources is a reject. A personal log
  that never advises does not invent claims to cite.
- Nutrition catalog data is credited to the database this app actually uses
  (Open Food Facts unless the spec names another). Credit is a tappable link,
  not a dead "OpenFoodFacts" label.


Ignore the food-log and Open Food Facts lines above when they conflict with this
family. Category for this app is `public.app-category.finance`. Camera permission only if the
product actually captures.

Project settings that follow from the above:

```yaml
INFOPLIST_KEY_UIUserInterfaceStyle: Dark
INFOPLIST_KEY_UISupportedInterfaceOrientations: UIInterfaceOrientationPortrait
INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad: UIInterfaceOrientationPortrait
INFOPLIST_KEY_UIRequiresFullScreen: YES
INFOPLIST_KEY_ITSAppUsesNonExemptEncryption: NO
INFOPLIST_KEY_LSApplicationCategoryType: public.app-category.finance
TARGETED_DEVICE_FAMILY: "1,2"
SWIFT_STRICT_CONCURRENCY: complete
```

---

## 12. Functional twist: Longer-span rehold

Longer-span rehold: base hours come from price versus the monthly impulse limit, then hours = base × priority × (1.5 − necessity/100) × (2 − discretion/100), clamped 6 to 720, and the home rail ticks that remaining TimeInterval, not a 24h or 7d timer. Stamping the same retail code again while the ticket is Cooling keeps the longer of the two spans instead of restarting the wait. Buying early is a cut: another cooling ticket whose remaining hours cover this rail is dropped, this want releases as bought, and a CoverMark is written. A cover that is short writes a ShortMark and the ticket stays Cooling. When remaining hours reach zero the ticket can release as bought or dropped without a cover. No checkout, no remote catalog, no payday calendar, and no Safari shell.

This is the app's marketed differentiator. It must be:

- visible on the home screen, not buried in settings;
- backed by real persisted data, not a cosmetic flourish;
- covered by at least one unit test;
- described in the README as the reason a user would pick this app.

---

## 13. AI-generated assets

Art style: **Cyberpunk digital art · photography-driven**


Base prompt, reused and extended for every asset:

```
Photography-driven cyberpunk digital art. Night-city will-call window, wet claim-check stock, phosphor hour rail, rain on glass, long-exposure street light, photographic grain, isolated subject, quiet ground, no readable letters or numbers, no logo, no betting chrome, no storefront catalog, no specified colours
```

All 12 images below are required. Generate each one, export
as PNG, and add it to `Assets.xcassets` as its own image set named exactly as
given. Every name carries the `ctf_` prefix.

### 13.1 App icon rules (strict)

The icon is rejected by App Store Connect if any of these are wrong:

- Exactly **1024 x 1024 px**.
- **No alpha channel.**
- sRGB colour profile, 8 bits per channel, PNG.
- **No text and no words** in the artwork.
- **No rounded corners and no built-in mask.**
- The subject stays inside the middle 80%.

### 13.2 Full asset list

| # | Image set | Size (px) | Alpha | Purpose |
| --- | --- | --- | --- | --- |
| 1 | `ctf_AppIcon` | 1024x1024 | **NO** | App Store icon. NO alpha channel, NO transparency, NO text, NO rounded corners, NO drop shadow outside the canvas. |
| 2 | `ctf_Splash` | 1290x2796 | fill | Launch background. The middle third must stay quiet so the wordmark reads on top. |
| 3 | `ctf_Onboarding1` | 1024x1536 | **required cutout** | Onboarding page 1 illustration: what the app is for. |
| 4 | `ctf_Onboarding2` | 1024x1536 | **required cutout** | Onboarding page 2 illustration: the main verb. |
| 5 | `ctf_Onboarding3` | 1024x1536 | **required cutout** | Onboarding page 3 illustration: why they stay. |
| 6 | `ctf_EmptyHome` | 1024x1024 | **required cutout** | Empty state: the home screen has nothing yet. Calm and inviting, never sad. |
| 7 | `ctf_EmptyList` | 1024x1024 | **required cutout** | Empty state: a secondary list has no rows. |
| 8 | `ctf_CardBackdrop` | 1200x800 | fill | Backdrop art for a primary card. Low contrast so text stays readable. |
| 9 | `ctf_ControlFace` | 512x512 | **required cutout** | Custom control artwork used for the primary interactive element. |
| 10 | `ctf_TwistHero` | 1024x1024 | **required cutout** | Hero art for the 'Longer-span rehold' feature screen. |
| 11 | `ctf_SuccessMark` | 512x512 | **required cutout** | Shown briefly when the primary action succeeds. |
| 12 | `ctf_HeaderDecor` | 1200x600 | **required cutout** | Decorative header accent on the main screen. |

### Prompt per asset

**`ctf_AppIcon`** — 1024x1024

```
Photography-driven cyberpunk still of a single claim-check ticket with a phosphor hour rail, wet stock, night glass, subject centred filling the canvas edge to edge, no text, no letters, no words, no alpha, no transparency, no rounded corners, no drop shadow outside the canvas
```

**`ctf_Splash`** — 1290x2796

```
Vertical night-city will-call window, rain on glass, phosphor rail at the edges, quiet uncluttered centre band, photographic grain, no readable text
```

**`ctf_Onboarding1`** — 1024x1536

```
A priced want becoming a stamped hold ticket in one glance, wet claim-check stock, night glass, photographic, no text

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`ctf_Onboarding2`** — 1024x1536

```
A hand mid-stamp on a hold ticket whose hour rail is already ticking, phosphor line, wet stock, photographic, no text

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`ctf_Onboarding3`** — 1024x1536

```
The same ticket later, rail nearly spent, a second ticket waiting as cover, accumulated hold, photographic, no text

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`ctf_EmptyHome`** — 1024x1024

```
An unused claim-check window with a blank ticket slot, wet stock waiting, calm and inviting, never sad, no text

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`ctf_EmptyList`** — 1024x1024

```
An empty review rack for released and cut tickets, bare will-call slots, calm, no text

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`ctf_CardBackdrop`** — 1200x800

```
Low-contrast wet night glass and faint phosphor rail, quiet enough for text, no letters
```

**`ctf_ControlFace`** — 512x512

```
Face of a single stamp die for a claim-check, square-on, wet metal and ticket stock, no text

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`ctf_TwistHero`** — 1024x1024

```
Two overlapping hold tickets, the longer hour rail kept, phosphor lines, wet stock, no text

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`ctf_SuccessMark`** — 512x512

```
A freshly struck claim-check stamp on ticket stock, no letters, no digits

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`ctf_HeaderDecor`** — 1200x600

```
Wide band of night glass and a faint phosphor rail, low contrast, no text

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```


### 13.3 Asset rules

- Cut-outs (everything except AppIcon, Splash, CardBackdrop): isolated subject,
  real PNG alpha, all four corners transparent. No square plate.
- Assets must be semantically different from each other.
- Record the exact prompt used for every asset in the README.
- SF Symbols are permitted only for close, chevron, share and similar system
  affordances.

Scanner frames, reticles, and seamless tiles are drawn in SwiftUI via `Path` or `Shape`. GenerateImage is not used for those. Every other in-app graphic (except AppIcon, Splash, CardBackdrop) is a **cutout**: isolated SOLID opaque subject in the center, real PNG alpha, all four corners transparent. An opaque square plate inside a circle or pentagon is a fail. A hollow glass box or wire frame with a transparent center is a fail.

---

## 14. Demo data

Seed a small local demo dataset for this family's entities so Simulator
screenshots are not empty. The same seed must mark onboarding complete and
fill the primary surface — otherwise `-ReviewScreen` never fires. Never seed
on a physical device. Guard with `#if targetEnvironment(simulator)` and
`ctf.demo.v1`.

Seed the happy path: the home primary verb is enabled. The blocked / gated /
error state is a unit-test fixture, not Simulator home. Home chrome names the
job and the next tap in words a stranger knows. Axis values (`ui`, `naming`,
`architecture`) never become user-visible titles. A card that looks tappable
is a `Button`. A readout does not use button chrome.

---

## 16. Anti-patterns

The following will fail review:

- `try!`, `as!`, or force-unwrapping anything derived from the network, the
  database or a file.
- `fatalError` anywhere reachable at runtime. It is acceptable only for a
  programmer error in an initialiser that cannot fail in practice, and needs a
  comment.
- Swallowing an error with an empty `catch`.
- `print` used as production logging.
- A hard-coded hex colour outside the single colour accessor.
- A hard-coded font name outside the single typography accessor.
- An SF Symbol used as the app's brand iconography — the app icon, the
  empty-state hero, or onboarding art. Those come from section 13. SF Symbols
  are the right choice for every functional control (add, filter, sort,
  close, share, delete) — leaving those as bare text instead of a symbol is
  also a defect.
- Storing a value that can be computed (day totals, remaining budget, macro
  percentages).
- Blocking the main thread on disk or network work.
- `UIScreen.main` for sizing. Use the geometry the layout system gives you.
- Index positions used as list identity. Identity is a stable identifier.
- A view that reaches into the persistence layer directly, bypassing the
  architecture's designated seam.
- Business logic inside a `View` body or a `UIViewController` method, when the
  assigned architecture places it elsewhere.
- Copying a source file from another app in this batch.
- A `TabView` with exactly three tabs. That is the factory stamp — two or
  four-to-five destinations, or a different chrome. ReviewScreen keys are
  not tabs.


---

## 17. Tests

Add a unit test target `CounterfoilTests` covering at minimum:

1. The core domain invariant of this family (the thing that would be wrong if
   the calculator, decay, crate, or log lied).
2. Empty, populated and invalid input paths for the primary verb.
3. The section 12 twist logic.
4. One architecture-specific test proving the pattern holds.
5. A persistence round-trip: write, relaunch-equivalent reload, verify.
6. Parse `ProcessInfo.processInfo.arguments` once after onboarding. 
   `-ReviewScreen today|log|goals` switches the running app's live navigation. Extra cover slugs open those screens.
   Cover that parser with a unit test. Do not host a `View` in the test.

---

## 18. README.md

Write `README.md` at the app folder root covering:

1. What the app does and who it is for.
2. The architecture used and **why** it suits this product.
3. The unique feature added and how it works.
4. The AI art style and the exact prompt used for every asset.
5. How this app differs from others in the batch.
6. Build instructions.

---

## 19. Definition of done

**Build**
- [ ] `xcodegen generate` succeeds.
- [ ] `xcodebuild -scheme Counterfoil -destination 'generic/platform=iOS' build` succeeds.
- [ ] Zero new compiler warnings.
- [ ] Strict concurrency `complete` compiles clean.
- [ ] Test target passes.

**Function**
- [ ] Onboarding to first successful primary action works on a clean install.
- [ ] Every screen in section 3.6 exists and handles empty / filled / error.
- [ ] Reset and contact link live in Settings.
- [ ] Force-quitting immediately after a write loses nothing.
- [ ] Seeded home names the job and next tap; primary verb enabled.
- [ ] App reads `-ReviewScreen today|log|goals` after onboarding.

**Uniqueness**
- [ ] Architecture matches **Hold-ticket ADT fold (Blank | Cooling | Released); the desk is a fold over Wants; Stamp writes a Ticket with computed hours and folds Blank to Cooling; Cut writes a CoverMark when the sacrificed Ticket remaining hours cover this rail and folds Cooling to Released; a short cover writes a ShortMark and keeps the Ticket; Cut on Blank is refused; Stamp of the same code while Cooling keeps the longer span; Stamp samples a Want that is not Released; empty desk writes Blank** with no leakage across layers.
- [ ] UI approach matches **SwiftUI WKWebView representable · timeline**.
- [ ] Custom rendering, if any, is confined to one hero surface (section 7.5).
- [ ] Navigation matches **Desk-locked chrome (the hold ticket never leaves; Review, Rules and Settings arrive as sheets)**.
- [ ] Screen composition follows section 3.6.
- [ ] Typography uses **SF Pro** and nothing else.
- [ ] Palette matches section 7.1 exactly.
- [ ] Home rhythm and motion match section 7.6. No second look.

**Quality**
- [ ] Section 8 UI/UX bar satisfied end to end.
- [ ] Contact link present.
- [ ] `PrivacyInfo.xcprivacy` present and correct.
- [ ] README complete.

---

## 20. Build commands

```bash
cd Counterfoil
xcodegen generate
xcodebuild -scheme Counterfoil -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build
xcrun simctl list devices available
xcodebuild -scheme Counterfoil -destination 'platform=iOS Simulator,id=<UDID>' test
```

Signing is off only on that command line. Do not put CODE_SIGNING_ALLOWED, CODE_SIGNING_REQUIRED, CODE_SIGN_IDENTITY or DEVELOPMENT_TEAM in project.yml — CI signs the archive. Leave CODE_SIGN_STYLE: Automatic as the scaffold set it. The exact simulator does not matter — use any available UDID from the list.
