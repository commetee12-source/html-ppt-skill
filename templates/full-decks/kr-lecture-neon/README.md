# kr-lecture-neon · 한국어 연수용 대형 텍스트 덱

16-slide lecture deck for a **large Korean training room** (100+ seats) or a **Zoom class of several hundred**. Built and battle-tested on a 3-hour, 77-slide deck for ~500 new public servants.

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
| **Chapter colour system** | `.m1`–`.m4` set `--acc` / `--acc2` / `--glow`. The **top bar and the bottom-left tag carry that colour for the whole chapter**, not just the cover. Audiences lose track of where they are in a 70-slide deck; colour fixes that. |
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

## Typography

Sized for the back row, not for your laptop. `h1 86 · h2 60 · statement 66 · body 30 · list 34`px at 1280×720.

`word-break:keep-all` is set globally. **Korean must not break mid-word** — without it, 어절 split across lines and reading speed collapses.

## Density ceilings

Exceed these and the slide overflows 720px: **list 5~6 items · cards 4 (6 if title-only) · table 5 rows** (use `table.tight` at 5+) · **timeline 6 rows**.

## Gotchas that cost real time

- **Bar heights in `px`, never `%`.** With `%` the value and label sit *outside* the measured box, so `getBoundingClientRect()` overflow checks pass while the label collides with the source line.
- **Tall charts need `.slide.top` + `.srcline`.** Centred content wastes vertical space, and the absolutely-positioned `.src` collides with bottom labels.
- **Never `alert()`.** A modal freezes every event on the page. Use the built-in `toast()`.
- **Do not truncate a bar axis to exaggerate growth.** Keep zero and annotate the delta (`▲ +4.3`) instead. In a public-sector room somebody *will* call it out.

## Check before you ship

```js
// paste in the console — must print nothing
[...document.querySelectorAll('.slide')].forEach((el,i)=>{
  const p=el.classList.contains('on'); el.classList.add('on');
  const r=el.getBoundingClientRect();
  const z=parseFloat(getComputedStyle(document.documentElement).getPropertyValue('--z'))||1;
  let top=1e9,bot=-1e9;
  [...el.children].forEach(c=>{ if(/\b(bar|stag|snum|fx|src)\b/.test(c.className))return;
    const b=c.getBoundingClientRect(); top=Math.min(top,(b.top-r.top)/z); bot=Math.max(bot,(b.bottom-r.top)/z); });
  if(!p) el.classList.remove('on');
  if(top<50||bot>656) console.log('overflow', i+1, Math.round(top), Math.round(bot));
});
```

Serve over `python -m http.server` to run it — browser extensions block scripting on `file://`.

## Keys

`← →` move · `O` overview · `F` fullscreen · `S` presenter window · `R` reset timer · `Home/End` · click.
There is no `T` — the chapter colours *are* the theme, and cycling would destroy the wayfinding.

More detail: [`references/kr-lecture-decks.md`](../../../references/kr-lecture-decks.md)
