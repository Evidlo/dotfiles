---
name: derivation
description: Build up a physics/math derivation one factor at a time, or write it into a document. Use when the user wants to understand or record a derivation from first principles — walking through an equation step by step, introducing frequency/angle/temperature dependence into an existing result, or writing a .md derivation file. Triggers on "derive", "from first principles", "step by step", "ok next step", "walk me through", or edits to rt_equations*.md-style derivation documents.
---

# Derivation

Two modes. **Walkthrough** = the user is building understanding interactively.
**Document** = writing the derivation into a file. The same conventions govern both;
the difference is only pacing and math syntax.

## Core rule: names are earned, never assigned

Never open with "define G(a,b) ≡ …" and then use it. Write the physics out in full,
notice that the same expression appears twice, and *only then* name it — stating what
grouping earned the name. If a symbol appears once, it does not get a name.

Corollary: when a named quantity is inherited from a paper (Bishop's $G_B$, Holstein's
$T$), re-derive what it actually equals rather than assuming the paper's label maps onto
your grouping. Mismatches here are where real errors hide.

## Core rule: define at the moment of need

Introduce each quantity where it is first used, not in an upfront block.
If attenuation needs τ, define τ right after writing the attenuation factor.
If τ needs σ, define σ next. If σ needs φ, define φ next. Follow the dependency
chain backward as it surfaces, never front-load it.

**Do not write an "Ingredients", "Definitions", "Setup", or "Notation" section**
before the derivation. Do not add "Step-by-step" as a header. A derivation section
is one flowing narrative with **bold lead-ins**, not nested subsections.

## Core rule: one thing at a time

Each step adds exactly one factor, one integral, or one assumption. Never two.
State what the new factor physically *is* — one clause of intuition, not a paragraph.
Carry units through, in brackets after the expression.

Watch for the step where a label disappears (a frequency integral collapsing a
spectrum to a scalar rate, an angular integral collapsing a direction). Call it out:
those pivots are what license everything downstream to factor, and they are the steps
most often glossed over.

## Walkthrough mode

The user sets the pace with "ok next step". Until they say otherwise:

- **One sentence per turn**, optionally with one short display equation.
- Then **stop**. Do not continue to the next step, do not preview where this is going,
  do not summarize what was covered.
- No preamble ("Great question", "Now we need to…"). Start with the content.
- If the user asks a clarifying question mid-walk, answer it in one sentence and
  stay on the current step — do not advance.
- If the user catches an error or circularity, concede in one sentence and correct.
  No re-derivation of the whole chain, no apology paragraph.

Long multi-part explanations are a failure mode here even when correct — the user
said "this was too much to take in in one step." When in doubt, split the step.

## Document mode

- Match the file's existing math syntax (these documents use LaTeX `$…$` / `$$…$$`).
- **The document must stand alone.** No references a reader of this file cannot resolve:
  no sibling documents, no source filenames, no function or variable names from an
  implementation, and no symbols that were defined elsewhere. If a point is worth making,
  make it in the document's own terms — say "the cross-section at line center is
  position-dependent" rather than "this is why $\sigma_{\text{tot}}$ and not $\sigma_0$",
  where $\sigma_0$ is a symbol this document never introduced. Internal cross-references
  ("the sections below assume this") are fine.
- Motivate a naming or decomposition choice by what it buys inside the derivation, never
  by what some other document or program happens to call it.
- Keep assumptions separated and individually testable. If two independent assumptions
  were both needed for a result, say so, and give the counterexample showing neither
  alone suffices (e.g. "with a monochromatic Sun, CFR still holds but the integral
  collapses instead of factoring").
- Keep the general case in the main line; put specializations (isothermal, isotropic,
  optically thin) as a closing **Remark** that derives the simplification as a
  *consequence*, explicitly flagged as convenience rather than physics.
- Preserve position/state labels as long as possible — write $\varphi(x,v)$, not
  $\varphi(v)$, even when a later section assumes uniformity. Dropping the label early
  is what hides where an assumption is load-bearing.
- Check for symbol collisions before introducing one ($T$ is temperature; $\mathcal{X}$
  or the implementation's own symbol is safer).
- Prefer the constant with no hidden state dependence as the base quantity
  (frequency-integrated $\sigma_{\text{tot}}$ over line-center $\sigma_0 \propto T^{-1/2}$).
- When told to rewrite a section, replace exactly that section; leave the surrounding
  document alone and say what you left untouched.
- After writing, state briefly what was added beyond what was discussed, so the user
  can reject it — they read and revise these by hand.

## Chat formatting

Unicode math when talking to the user: σ, φ, τ, ν₀, ∫, ⁻¹, √. Never inline `$…$` in
chat — this GUI does not render it. LaTeX belongs only inside document files.

## Verification

Do not go grep the implementation to corroborate a derivation unless asked. When the
user does ask, cite `file.py:line` for each structural claim.
