# TODO

## Content
- [x] Fact-check done (see `research_questions.txt`); clear fixes applied to the CSV.
- [ ] Decide the open items below (need your call).
- [ ] **Add more images** to any other question if wanted (fill the `Image` column in the CSV, rerun the converter).

## Gameplay

## Sound
- [ ] Low-time warning (tick) near the end of the timer.
- [ ] Menu / board music.
- [ ] Mute / volume control.
- [ ] Check `suspense.mp3` is long enough for a full 30 s question.

## Polish
- [ ] Timer bar changes colour when time is low.
- [ ] Transitions between start menu and grid.
- [ ] Layout is tuned for one window size (fixed margins, 1000 px popup). Test small windows and fullscreen (F11).
- [ ] Optionally start in fullscreen.
- [ ] Rename the `GOLD` constant in `blue_skin.gd` (now light blue) to something like `ACCENT`.
- [ ] Split `main.gd` into per-screen scripts/scenes (it builds every screen in code).

## Testing
- [ ] Play through a full game by hand: fades, steals, turn order, sounds. Only headless startup checks have been run so far.
- [ ] Check the Singaguessr images (portrait and landscape) look right in the popup.
