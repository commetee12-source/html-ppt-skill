# kr-lecture-neon · 한국어 연수용 대형 텍스트 덱

17-slide lecture deck for a **large Korean training room** (100+ seats) or a **Zoom class of several hundred**. Built and battle-tested on a 3-hour, 77-slide deck for ~500 new public servants.

Deep-navy ground, 64px grid, per-chapter neon accent. One idea per slide, very large type, every number drawn as a chart.

**Use when:** 연수 · 강의 · 사내 교육 · 공공기관 교육 — long decks where the audience sits far from the screen and needs to feel chapter boundaries.
**Feel:** a serious briefing that still moves — quiet ground, one loud thing per slide.

---

## Why this one is self-contained

Every other full-deck template links `../../../assets/base.css` + `runtime.js` and pulls webfonts from a CDN. **This one inlines everything and uses a local Korean font stack.**

That is deliberate, not laziness. Training decks get **handed to trainees as a single file** and opened offline, from a USB stick or a downloads folder. A deck that needs four sibling files and a live CDN is broken the moment it leaves your machine.

If you are composing with the skill's shared assets instead, lift the `<style>` block — it is dependency-free and drops in as a `style.css`.

## What is different from the other templates

| | |
|---|---|
| **16:9 letterbox** | `transform:scale(min(vw/1280, vh/720))` — one slide fills the screen, centred, ratio kept at any window size. The other templates fill the window instead. |
| **Chapter colour system** | `.m1`–`.m5` set `--acc` / `--acc2` / `--glow`. The **top bar and the bottom-left tag carry that colour for the whole chapter**, not just the cover. Audiences lose track of where they are in a 70-slide deck; colour fixes that. |
| **Agenda slide (slide 2)** | `.agenda` + `.agn` — one chapter per row, each row in **that chapter's own colour**. This is the slide that *teaches* the colour code; without it the accents are decoration. |
| **Chapter cover animations** | `fx-gear` / `fx-shrink` / `fx-build` / `fx-ray` / `fx-star` — see `assets/animations/section-covers.css`. |
| **Dependency-free charts** | vertical bars, horizontal bars, before/after, step dots, KPI count-up, SVG line. No chart library. |
| **Presenter window** | `S` or the bottom-left button opens a **separate window** (elapsed timer · current + next slide). Separate window = it does not appear when you share only the slide window in Zoom. |
| **Print = PDF** | `@media print` drops the letterbox, restores `page-break-after`, and **freezes every animation at its final state** so bars and lines actually appear in the PDF. |

## The cover pattern — open with a time, land on a specific

The demo cover is not decoration; it is the deck's first working part.

```
2027년 1월,
AI와 여러분이 같이 출근합니다
— 그리고 여러분의 첫 업무 6개는, 전부 AI가 가장 잘하는 업무입니다
[자료 취합] [표 만들기] [공문 기안] [자료 찾기] [회의록] [민원 응대]
```

Three moves, in this order:

1. **A date the audience owns.** Not "AI 시대" — *their* start date. A cover that could headline any other lecture is a wasted cover.
2. **Immediately down to something concrete.** A date alone is atmosphere. The sub-line names what the lecture is actually about, so the course listing reads clearly.
3. **Chips make it literal.** Six nouns from their actual job. Now nobody is guessing what the next three hours contain.

**Then pay both off in the body.** This cover plants *two* hooks and slide 4 collects one of them (`맨 앞에서 보신 그 여섯 개입니다`). A hook you never collect is just a headline — brief the speaker to say *"맨 앞에 띄워놨던 그것"*, not to introduce it as if it were new.

**Do not put the closing question on the cover.** This deck opens with a claim and closes with `3년 뒤, 당신은 어떤 공무원입니까`. Ask it up front and the ending is a rerun.

**Tone check:** an exclamation mark on a cover (`2027년!`) reads as a flyer, not a briefing — it undercuts a deck whose whole first chapter is building unease. And mind the particle: `AI와 여러분은` is contrastive and pushes the two apart; `AI와 여러분이` keeps them arriving together, which is the point.

## The agenda slide — slide 2 teaches the colour code

The cover names the subject. It does not tell anyone what the next three hours contain,
and a row of chips is not an agenda — the eye reads it as decoration and moves on.

**Put a dedicated agenda slide immediately after the cover, and give every row its
chapter's own colour.** Same hex values as `.m1`–`.m5`:

```html
<section class="slide agenda"><div class="bar"></div><div class="stag">오늘</div><div class="snum"></div>
  <h2 class="s an" style="--i:0">오늘은 <span class="grad">네 장</span>을 지나갑니다</h2>
  <ol class="agn">
    <li class="ag1 an" style="--i:1"><span class="mno">M1</span><h3>왜 지금 바뀌는가</h3><span class="tag">배경</span></li>
    <li class="ag3 hi an" style="--i:3"><span class="mno">M3</span><h3>그리고 직접 만듭니다</h3><span class="tag">본체</span></li>
    …
  </ol>
  <p class="sub s an" style="--i:6">장이 바뀌면 <b>색이 바뀝니다.</b> 지금 어디쯤인지는 <b>화면 왼쪽 아래</b>를 보시면 됩니다.</p>
</section>
```

Four things make it work:

1. **One row per chapter, never more.** Sub-topics belong on that chapter's cover
   (`.mod-toc`), not here. Five rows is the ceiling — six overflows.
2. **The row's left border and number carry the chapter colour** (`.ag1`–`.ag5`).
   Per-chapter accents are wayfinding only if the audience is shown the key once;
   this is where they see all of it at a glance.
3. **Say the rule out loud on this slide** — *"장이 바뀌면 색이 바뀝니다."* A colour
   system nobody is told about is just a palette.
4. **Mark the longest chapter with `.hi`.** The audience's real question is not
   "what are the topics" but "where does this actually go" — `본체` answers it.

The top bar on `.agenda` is a five-stop rainbow of the same hexes, so the slide reads
as structurally different from both the cover and the body at a glance.

**Do not put times on it.** `M3 · 55분` makes the room hold the presenter to a clock
and makes the deck unusable for the next cohort. Number and title only; the timing
lives in the presenter notes.

## Typography

Sized for the back row, not for your laptop. `h1 86 · h2 60 · statement 66 · body 30 · list 34`px at 1280×720.

`word-break:keep-all` is set globally. **Korean must not break mid-word** — without it, 어절 split across lines and reading speed collapses.

## Density ceilings

Exceed these and the slide overflows 720px: **list 5~6 items · cards 4 (6 if title-only) · table 5 rows** (use `table.tight` at 5+) · **timeline 6 rows** · **agenda 5 rows**.

## Gotchas that cost real time

- **Bar heights in `px`, never `%`.** With `%` the value and label sit *outside* the measured box, so `getBoundingClientRect()` overflow checks pass while the label collides with the source line.
- **Tall charts need `.slide.top` + `.srcline`.** Centred content wastes vertical space, and the absolutely-positioned `.src` collides with bottom labels.
- **Never `alert()`.** A modal freezes every event on the page. Use the built-in `toast()`.
- **Do not truncate a bar axis to exaggerate growth.** Keep zero and annotate the delta (`▲ +4.3`) instead. In a public-sector room somebody *will* call it out.

## Check before you ship

```js
// paste in the console — must print nothing
// Use offsetTop/offsetHeight, NOT getBoundingClientRect. Rects include the deck's
// own transforms: the letterbox scale AND, on a slide that has not finished its
// entry animation, the .an translateY(36px). A rect-based check therefore reports
// every un-entered slide as ~36px too tall and floods you with false failures.
[...document.querySelectorAll('.slide')].forEach((el,i)=>{
  const p=el.classList.contains('on'); el.classList.add('on');
  let top=1e9,bot=-1e9;
  [...el.children].forEach(c=>{ const cs=getComputedStyle(c);
    if(cs.position==='absolute'||cs.display==='none') return;   // bar/stag/snum/fx/src/notes
    top=Math.min(top,c.offsetTop); bot=Math.max(bot,c.offsetTop+c.offsetHeight); });
  const scrolls = el.scrollHeight>el.clientHeight;
  if(!p) el.classList.remove('on');
  if(top<52||bot>656||scrolls) console.log('overflow', i+1, top, bot);
});
```

Want the tightest slides rather than a pass/fail? Same loop, but collect `656-bot`
and sort — anything under ~15px will overflow the moment you add a word.

Serve over `python -m http.server` to run it — browser extensions block scripting on `file://`.

## Keys

`← →` move · `O` overview · `F` fullscreen · `S` presenter window · `R` reset timer · `Home/End` · click.
There is no `T` — the chapter colours *are* the theme, and cycling would destroy the wayfinding.

More detail: [`references/kr-lecture-decks.md`](../../../references/kr-lecture-decks.md)
