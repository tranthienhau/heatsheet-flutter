# Heatsheet - Design System

Bright, modern school sports event manager (sports days, house competitions, tournaments). Light near-white pink-tinted surfaces, plum ink text, one bubble pink accent, a soft lavender support hue. Friendly and fast for busy teachers: one bold focal element per screen.

## Frame
- Mobile 393x852 (iPhone 16/17). Keep the top ~59px (status bar) and bottom ~34px (home indicator) clear of tappable content.
- Screen edge padding 20px. 8pt spacing scale: 4, 8, 12, 16, 24, 32.

## Color (use ONLY these colors; no default violet or indigo, no flat neutral grey)
- Background: #FCF4F9 (tinted near-white)
- Surface (cards, sheets): #FFFFFF
- Surface alt (grouped rows, tracks): #F7EAF2
- Accent bubble pink: #FC69C3 - large fills, icons, active indicators, big numerals. Labels on it are ink #1F0C18, never white.
- Accent fill (deep pink): #CA047E - primary buttons with WHITE label, links, chip text, progress fill.
- Accent tint: #FEE6F5 - chip backgrounds, selected states.
- Accent pressed: #C30379
- Ink: #1F0C18 - primary text.
- Text secondary: #5E4656. Text tertiary: #7A6271.
- Border hairline: #F0DDE8. Input and control border (borderStrong): #B682AE.
- Support lavender: #B09EFA (decoration, illustration, chips with ink text). Chart second series (supportStrong): #9880FA.
- Status (text on tint): success #0E7C3A on #E3F4E9, warning #A75906 on #FAEFE1, danger #CE2020 on #FBE5E5, info #C5047B on #F9E1F0.
- House colours (data only, always with the house name, dark ink text on or next to them): Falcons red #E5484D, Marlins blue #3E7BFA, Cedars green #2FA36B, Comets yellow #F5B300.

## Typography
- UI and body: Varela Round. Display (screen titles, hero headlines, big numbers): Sniglet 800. Numbers use tabular figures.
- Use only these 5 sizes: display 32 / Sniglet 800 / -0.01em; title 20 / 600; body 16 / 400; label 14 / 500; caption 13 / 500.
- Big hero stat numbers may be larger in Sniglet 800.
- Minimum text 12px (13px chips and tags, 14px safety or legal text).

## Shape and elevation
- Radius: card 20, control 14, input 12, pill 999.
- Card shadow: 0 1px 2px rgba(31,12,24,.04) + 0 8px 24px rgba(31,12,24,.06). No hard or black shadows.

## Icons
- One set only: Lucide-style rounded outline, 24px, 1.75 stroke. Do not mix filled and outline.

## Controls (one spec each, reused on every screen)
- Primary button: pill, 56px tall, #CA047E fill, white label 16/600. Pressed #C30379. Disabled 40% opacity.
- Secondary button: pill, white, 1.5px #B682AE border, ink label.
- Text input: 12px radius, 52px tall, white, 1px #B682AE border; focus 2px #CA047E ring; error #CE2020 border + 13px helper.
- Card: white, 20px radius, soft shadow.
- Chip: pill, 32px tall, #FEE6F5 fill with #CA047E text 13/500; selected chip = #CA047E fill with white text.
- Live badge: small pill with a dot, #CA047E text on #FEE6F5. Never red.
- Progress bar: 8px pill, track #F7EAF2, fill #CA047E.
- Segmented control: #F7EAF2 track, selected segment white with ink label and soft shadow.

## Shared components
- Bottom tab bar (on tab screens only): exactly 5 tabs in this order: Live (activity icon), Events (calendar icon), Schedule (clock icon), Standings (trophy icon), More (menu icon). Flat white bar, 1px #F0DDE8 top border, no gradient. Active tab: #CA047E icon + label 12/600 with a small #FEE6F5 pill behind the icon. Inactive: #5E4656 icon + label. Never rename, reorder, add or remove tabs.
- Tab screen header: screen title on the left in Sniglet 32, a small event chip 'Sports Day 2026' and a round avatar on the right.
- Full-screen, detail, modal and onboarding screens show NO bottom tab bar.

## Gradient and focal rules
- Any surface with white text uses the gradient #CA047E -> #C30379 (or the display-mode deep gradient #CA047E -> #6A2BB8), nothing lighter. The soft #FC69C3 -> #B09EFA blend is decoration only, never behind text.
- Photo overlays use an ink gradient (transparent to #1F0C18 at 85%) behind white text.
- Pills or chips on a gradient or photo use a dark translucent fill (ink at 50%), not white.
- One bold focal element per screen (hero progress card, podium, big score, bracket). Tab bar stays flat.

## Imagery
- Real photography only: school children and teachers at sports days, running tracks, playing fields, swimming pools, relay batons. Empty states and onboarding also use real photos or flat 2D vector art. NO 3D renders, claymorphism, isometric, CGI or glossy plastic objects.

## Meaning of color
- Red only for errors and destructive actions. Clashes and non-urgent warnings use the warning colour #A75906 with an icon. The Falcons house red is data, shown only as a dot or band next to the house name.

## Copy scope
- Do not mention: payment, subscription, premium, AI, parent chat, Google Classroom, SIS sync, livestream. No invented integrations or person names beyond those in the screen prompts. School is Westbrook Academy; the organiser is Mr Sam Carter.
