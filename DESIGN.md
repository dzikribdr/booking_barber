---
name: Barber 96
colors:
  surface: '#121414'
  surface-dim: '#121414'
  surface-bright: '#38393a'
  surface-container-lowest: '#0c0f0f'
  surface-container-low: '#1a1c1c'
  surface-container: '#1e2020'
  surface-container-high: '#282a2b'
  surface-container-highest: '#333535'
  on-surface: '#e2e2e2'
  on-surface-variant: '#d0c5af'
  inverse-surface: '#e2e2e2'
  inverse-on-surface: '#2f3131'
  outline: '#99907c'
  outline-variant: '#4d4635'
  surface-tint: '#e9c349'
  primary: '#f2ca50'
  on-primary: '#3c2f00'
  primary-container: '#d4af37'
  on-primary-container: '#554300'
  inverse-primary: '#735c00'
  secondary: '#c8c6c5'
  on-secondary: '#303030'
  secondary-container: '#474746'
  on-secondary-container: '#b7b5b4'
  tertiary: '#d0cecd'
  on-tertiary: '#313030'
  tertiary-container: '#b5b2b2'
  on-tertiary-container: '#454545'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#ffe088'
  primary-fixed-dim: '#e9c349'
  on-primary-fixed: '#241a00'
  on-primary-fixed-variant: '#574500'
  secondary-fixed: '#e5e2e1'
  secondary-fixed-dim: '#c8c6c5'
  on-secondary-fixed: '#1b1b1c'
  on-secondary-fixed-variant: '#474746'
  tertiary-fixed: '#e5e2e1'
  tertiary-fixed-dim: '#c8c6c5'
  on-tertiary-fixed: '#1c1b1b'
  on-tertiary-fixed-variant: '#474646'
  background: '#121414'
  on-background: '#e2e2e2'
  surface-variant: '#333535'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.05em
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  container-padding: 24px
  stack-gap: 16px
  section-margin: 40px
  gutter: 16px
---

## Brand & Style

The design system is engineered to evoke the atmosphere of an exclusive, high-end gentlemen's lounge. The brand personality is masculine, refined, and cinematic, prioritizing a "dark mode" aesthetic that feels both private and premium. 

The visual style is a hybrid of **Minimalism** and **Glassmorphism**, utilizing deep matte surfaces contrasted with sharp gold accents and translucent layers. High-contrast imagery with dramatic lighting (chiaroscuro) is central to the visual narrative, creating an editorial feel that distinguishes the service from standard grooming apps. The emotional response should be one of confidence, prestige, and meticulous attention to detail.

## Colors

The palette is strictly limited to maintain a high-end cinematic tone. 

- **Primary (Gold):** Used exclusively for high-priority actions, branding elements, and active states. It should appear as a metallic accent rather than a fill color where possible.
- **Surface (Matte Black):** The foundation of the UI. This color is non-reflective and provides the deep "void" required for cinematic contrast.
- **Container (Charcoal):** Used for interactive cards and secondary surfaces to create subtle depth against the matte background.
- **Text (Soft White):** A high-legibility off-white to reduce eye strain in dark environments while maintaining sharp contrast.
- **Glass (Translucent):** A 60% opacity version of the charcoal gray used with heavy backdrop blurs (20px+) for navigation bars and overlays.

## Typography

This design system utilizes **Inter** exclusively to provide a modern, systematic, and clean aesthetic that balances the ornate nature of the gold accents. 

- **Headlines:** Set with tight tracking and heavy weights to mimic luxury editorial layouts.
- **Labels:** Utilize uppercase styling with increased letter spacing (0.05em) for a sophisticated, "branded" feel on small text elements like category headers or timestamps.
- **Readability:** Body text uses a slightly larger 16px base to ensure comfort against the high-contrast dark background.

## Layout & Spacing

The layout follows a **fluid grid** model optimized for mobile devices, using a standard 4-column structure for phone screens. 

- **Margins:** A generous 24px side margin is maintained to emphasize the premium, spacious feel. 
- **Rhythm:** An 8px base unit drives all spacing. Elements are grouped using 16px (tight) or 24px (standard) gaps. 
- **Safe Zones:** Top navigation and bottom action bars use glassmorphism effects; content should scroll behind these layers with a 32px padding offset to ensure no overlap with critical text.

## Elevation & Depth

Hierarchy is established through **Tonal Layers** and **Glassmorphism** rather than traditional shadows.

- **Level 0 (Base):** Matte Black (#121212).
- **Level 1 (Cards):** Charcoal Gray (#1E1E1E) with a subtle 1px border (#FFFFFF 10% opacity) to define edges.
- **Level 2 (Overlays):** Glassmorphic surfaces with a `backdrop-filter: blur(24px)` and a background color of `#1E1E1E` at 60% opacity.
- **Accent Elevation:** The Gold (#D4AF37) is used for "Active" states. Instead of a shadow, gold elements may use a soft outer glow (`box-shadow: 0 0 15px rgba(212, 175, 55, 0.3)`) to simulate cinematic lighting.

## Shapes

The shape language is defined by substantial, consistent rounding to soften the "masculine" hardness of the palette.

- **Standard UI Elements:** Buttons, input fields, and small chips use 16px (1rem) corner radius.
- **Containers:** Large cards and modal sheets use 24px (1.5rem) corner radius.
- **Media:** Photography should always adhere to the container's roundedness to maintain the "contained" cinematic look.

## Components

- **Gold Primary Button:** Solid Gold (#D4AF37) background with Black (#121212) text. 16px rounded corners. High-weight Inter bold text.
- **Glassmorphic Card:** Charcoal Gray background at 60% opacity with 20px background blur. 1px inner stroke in soft white (10% alpha).
- **Premium Input Field:** Charcoal Gray background, 16px rounded corners. The focus state replaces the subtle border with a 1px Gold stroke and a soft gold glow.
- **Minimalist Logo:** The logo should be rendered as a vector paths in solid Gold, utilizing a subtle outer glow filter to appear "neon" or "backlit."
- **Service List:** Items separated by thin charcoal dividers. Active selections are indicated by a gold vertical bar on the left edge.
- **Booking Calendar:** A dark grid where selected dates are highlighted in Gold with white text, and "today" is indicated by a gold outline.
