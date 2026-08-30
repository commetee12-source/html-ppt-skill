# Korean lecture decks — 연수·강의용 대형 텍스트 덱

Rules extracted from shipping a 3-hour, 77-slide deck to ~500 trainees. Read before building anything for a **large room** or a **hundreds-of-people Zoom class** in Korean.

Reference implementation: [`templates/full-decks/kr-lecture-neon/`](../templates/full-decks/kr-lecture-neon/).

---

## 1. Korean line breaking

```css
html,body{ word-break:keep-all; overflow-wrap:break-word; line-break:strict }
```

**Non-negotiable.** Korean breaks at 어절 boundaries. The browser default splits mid-word, which is legible up close and unreadable from row 12. This single declaration is the highest-value line in the stylesheet.

## 2. Sizing for the back row

At a 1280×720 authoring canvas:

| | px |
|---|---|
| h1 | 86 |
| h2 | 60 (`.s` 50) |
| statement | 66 (`.s` 54 · `.xs` 44) |
| body / table | 30 |
| big list | 34 |
| card title | 32 · card body 25 |
| source note | 17–19 |

Line-height **1.7 for body, 1.8 for lists**. Tighter reads as a wall of text from distance.

## 3. One idea per slide

A 3-hour lecture wants **60–80 slides, not 25**. ~2.5 min per slide. When a slide holds two ideas, the audience is still parsing the first while you talk about the second.

**Density ceilings** (exceed → overflow at 720px): list 5~6 · cards 4 (6 if title-only) · table 5 rows · timeline 6 rows.

## 4. Chapter colour is wayfinding, not decoration

Give each chapter one accent and **hold it for the whole chapter** — the top bar and the corner tag, not just the cover. In a 70-slide deck the audience constantly loses track of where they are.

Validated 5-colour set on deep navy:

| | | note |
|---|---|---|
| M1 | `#38f2ff` cyan | |
| M2 | `#ff4ecd` magenta | |
| M3 | `#8b7bff` violet | |
| M4 | `#b6ff5a` lime | glow must be desaturated `rgba(140,220,60,.40)` — full-saturation lime does not read as distinct on navy |
| M5 | `#ffb03a` amber | same, `rgba(255,150,40,.40)` |

Pair the colour switch with a **chapter-cover animation** so the boundary is felt, not just seen → `assets/animations/section-covers.css`.

## 5. Every number becomes a chart

If a number is worth saying aloud, it is worth drawing. Dependency-free primitives in the template: vertical bars, horizontal bars, before/after boxes, step dots, KPI count-up, SVG polyline.

### Bar heights in `px`, never `%`

The trap that cost the most time. With `.vbars{height:300px}` + `.col{height:var(--h)}` as a percentage, the **value above and the label below sit outside the measured box**. `getBoundingClientRect()` overflow checks pass — while the label overlaps the source line on screen.

Give `--h` in px and let the column sit in normal flow. Then the box measures what you see.

### Do not truncate the axis

Starting a bar axis at 20 instead of 0 makes a 21.8 → 28.6 rise look dramatic. **In a public-sector room somebody will call it out**, and the whole deck loses credibility. Keep zero; annotate the delta instead:

```html
<div class="lab">2026년 <span class="hla">▲ +4.3</span></div>
```

### Tall charts need `.slide.top` + `.srcline`

Vertically centred content wastes space at both ends, and the absolutely-positioned `.src` block collides with bottom labels. For a chart that wants the full height: top-align the slide and move the citation into the flow.

## 5b. The cover has a job

Open with **a date the audience owns**, then land on **something concrete** in the very next line, then make it literal with chips.

A cover that could headline any other AI lecture (`나의 업무파트너 AI`, `AI 시대의 ○○`) is wasted. A cover carrying *their* start date cannot be recycled — which is exactly why it lands.

**Plant hooks on the cover and collect them in the body.** A hook nobody collects is just a headline. Write the collection into the speaker notes explicitly — *"맨 앞에 띄워놨던 그것"* — because a presenter who introduces it as new kills a payoff you set up 90 minutes earlier.

**Keep the closing question off the cover.** Open with a claim, close with the question. Ask it twice and the ending is a rerun.

Two details that decide the tone:

- **No exclamation mark.** `2027년!` reads as a flyer. If chapter 1 is building unease, the cover must not undercut it in the first second.
- **Watch the particle.** `AI와 여러분은` is contrastive — it pushes the two apart. `AI와 여러분이` has them arriving together. One character changes the whole proposition.

## 6. Timing — slow, and slow *everything*

Entry animations tuned for a laptop feel frantic in a big room. Working values:

| | |
|---|---|
| element rise | **1s**, travel **34px** |
| stagger (`--i`) | **230ms** |
| bars grow | **1.8s** after **.55s** |
| line draws | **2.7s** after **.6s** |
| count-up | **1.9s** |
| slide fade | **.5s** |

Two notes:

- **Increase travel distance along with duration.** Longer duration alone reads as sluggish, not deliberate — the eye needs to see movement.
- **Slow every layer at once.** Slowing body text but leaving charts fast breaks the rhythm and looks broken.

## 7. Print is a deliverable, not a fallback

Trainees ask for the PDF. `@media print` must:

1. drop the letterbox transform, restore `page-break-after`
2. **freeze every animation at its final state** — `.col{height:var(--h)!important}`, `stroke-dashoffset:0!important`, `.an{opacity:1!important;transform:none!important}`

Skip step 2 and the PDF prints **empty charts**.

## 8. Presenter view must be a separate window

An in-page overlay is visible to everyone when you share your screen. Open a real window.

Use `window.open('', 'name')` and **write into `pw.document` directly**. `localStorage` and `BroadcastChannel` are unreliable on `file://`, which is exactly how trainees open the file.

Two things that bite:

- **Popup blockers.** Keyboard `S` needs page focus *and* survives blocking only sometimes. Ship a **button** too — a click is an unambiguous user gesture. Reflect the open state on the button so the presenter can see it worked.
- **`pw.closed` can read true before the window settles.** Put a grace period (~3s) on any auto-cleanup, or the presenter view closes itself the moment it opens.

## 9. Never `alert()`

A modal freezes every event on the page — including whatever automation or hook you are using to check the deck. Use a self-removing toast for warnings.

## 10. Verify in a browser, not by reading

Serve it (`python -m http.server`) — extensions block scripting on `file://`. Then run the overflow check in the README. Static reading will not catch a slide that overflows by 20px, and 20px is exactly enough to put a label under the footer.
