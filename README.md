# Counterfoil

Hold a priced want on a will-call ticket and wait the computed hours before marking it bought.

Impulse shoppers stamp a ticket instead of checking out. Hours come from price versus a monthly impulse limit, then priority, necessity, and discretion, clamped from 6 to 720. The home rail ticks remaining hours. Stamping the same retail code while the ticket is cooling keeps the longer span. Buying early is a cut: another cooling ticket whose remaining hours cover this rail is dropped.

## Architecture

The hold is a closed algebraic fold: `Blank | Cooling | Released`. A fourth case is a defect.

The desk is a fold over wants. Stamp samples a want that is not Released, writes a ticket with hours from the family formula, and folds Blank to Cooling. An empty desk writes Blank. Cut writes a CoverMark when another cooling ticket’s remaining hours cover this rail, drops that ticket, and folds this Cooling to Released. A short cover writes a ShortMark and keeps this ticket. Cut on Blank is refused. Stamp of the same retail code while Cooling keeps the longer computed span and does not restart the rail.

This pattern fits the product because the ticket is one hold, not a list of flags. Cooling-ness is the fold case, never a parallel bool. `DeskStore` pattern-matches that fold. Views call `stampWant` and `cutCover`.

## Longer-span rehold

Visible on the desk as “Same code keeps the longer span.” That is why someone picks this app: coming back to the same retail code lengthens the wait instead of restarting it. The Longer span sheet shows the formula. Unit tests cover the family hours, CoverMark fold, short cover, Cut on Blank, and longer-span rehold.

## How this is not a repeat

Not Restante: hours tick in real time on the ticket rail, and the early path is a cut-cover against another ticket, not a payday gate. Not a fixed 24h or 7d timer, not a tab plus a list of wants, and not a store or Safari shell. Filing types an optional retail code. There is no catalog fetch.

## Art

Style: photography-driven cyberpunk digital art. Night-city will-call window, wet claim-check stock, phosphor hour rail, rain on glass, long-exposure street light, photographic grain, isolated subject, quiet ground, no readable letters or numbers, no logo, no betting chrome, no storefront catalog, no specified colours.

Image sets (empty placeholders until assets.generate): `ctf_AppIcon`, `ctf_Splash`, `ctf_Onboarding1`, `ctf_Onboarding2`, `ctf_Onboarding3`, `ctf_EmptyHome`, `ctf_EmptyList`, `ctf_CardBackdrop`, `ctf_ControlFace`, `ctf_TwistHero`, `ctf_SuccessMark`, `ctf_HeaderDecor`.

## Build

```bash
cd apps/Counterfoil
xcodegen generate
xcodebuild build-for-testing -scheme Counterfoil -destination 'generic/platform=iOS Simulator'
```

iOS 17+, Swift 6.2, no packages. Simulator demo seed is `ctf.demo.v1`. Launch arguments `-ReviewScreen today|log|goals|settings|rehold` open Desk, Review, Rules, Settings, and Longer span after onboarding.
