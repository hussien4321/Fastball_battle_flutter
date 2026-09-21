<div align="center">

# Fastball Battle

**A reaction-timing baseball game with a hand-built sprite animation engine.** Every frame is drawn through a single `CustomPainter`, and character animation is a pure function of game state rather than a timer.

[![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white)](https://dart.dev)

Built without a game engine or sprite library — rendering is hand-written over Flutter's Canvas

</div>

---

## Tech stack

| Concern | Choice |
|---|---|
| Rendering | Flutter `CustomPainter` over `dart:ui.Image`, `canvas.drawImageRect` |
| Animation | Normalised-position frame mapping (no engine, no sprite library) |
| Content | JSON-defined characters, enemies and stages |
| Audio | `audioplayers` — music beds and effects |
| Re-engagement | `flutter_local_notifications` |
| Monetisation | `firebase_admob`, `flutter_inapp_purchase` |

---

## Technical highlights

| Area | Approach | |
|---|---|---|
| **Animation that can't desync** | Frame selection is derived from normalised game position, not driven by a clock. The sprite *is* the state, so a dropped frame or a paused app can never leave a character mid-swing. | [↓](#1-animation-as-a-pure-function-of-state) |
| **One collision, two reactions** | The batter and pitcher react to the same event at different points on one shared timeline, so a hit reads correctly from both sides of the screen. | [↓](#2-collision-choreography-on-a-shared-timeline) |
| **Characters without code** | A character is a JSON description of image sequences. Adding one is an asset drop and a data entry — no new painter, no new branch. | [↓](#3-data-driven-character-definitions) |
| **Repainting only when it matters** | `shouldRepaint` compares every field that can change a pixel, so an idle frame costs nothing. | [↓](#4-explicit-repaint-gating) |

---

## Architecture

```
lib/
├── animations/game_painter.dart   The entire renderer — one CustomPainter
├── models/                        Character, Enemy, Stage, Action, Bgm — all data
├── services/objects_loader.dart   Loads JSON definitions, decodes images to dart:ui.Image
├── services/stats_loader.dart     Unlock thresholds and high scores
├── pages/                         Game loop, character/enemy/stage select, payments
└── helpers/views/                 Character preview, stage preview, dialogs
```

Everything the game can display is a decoded `dart:ui.Image` held in memory before play starts, so the render path never touches the asset bundle.

---

## Implementation

### 1. Animation as a pure function of state

The usual way to animate a sprite is a frame counter advanced on a timer. It works until something stutters — then the animation and the simulation disagree, and a character finishes swinging at a ball that already went past.

Here there is no frame counter. Every animated element maps a **normalised position** (0.0 → 1.0 through its phase) onto an index in its image list:

```dart
UI.Image getCharImage() {
  if (obstacleStatus == OBSTACLE_STATUS.DEATH && !obstacleIsHit
      && strikes < 3 && obstacleDeathPos >= 0.3) {
    int hurtIndex = ((obstacleDeathPos - 0.3) * 10 / 7 * charHurtImages.length * 0.99).floor();
    return charHurtImages[hurtIndex];
  } else if (strikes >= 3) {
    …                                    // death sequence, remapped to its own window
  } else if (!canInput && …) {
    int inputIndex = (inputPos * charInputImages.length * 0.99).floor();
    return charInputImages[inputIndex];
  } else {
    idleIndex = (charIdleImages.length * (DateTime.now().millisecond / 1000)).floor();
    return charIdleImages[idleIndex];   // idle is the one free-running loop
  }
}
```

The animation cannot drift, because there is nothing to drift *from* — the frame is recomputed from the simulation every paint. Interrupt the game, background the app, drop frames on a slow device: the sprite is still exactly the frame that matches the ball's position.

The `* 0.99` is the small detail that makes it safe. A position of exactly `1.0` would index one past the end; scaling the range just under the array length clamps it without a branch on every lookup.

Idle is the deliberate exception, driven off the wall clock — it isn't tied to anything in the simulation, so a free-running loop is the right model for it.

### 2. Collision choreography on a shared timeline

A pitch resolving is a single value, `obstacleDeathPos`, sweeping 0 → 1. Both characters react to it, but not at the same time:

- The **pitcher** is hit while `obstacleDeathPos <= 0.7` — the ball has been struck and is travelling back toward them.
- The **batter** is hit while `obstacleDeathPos >= 0.3` — the ball got past and is arriving at them.

Each window is then remapped onto its own 0 → 1 range (`(pos - 0.3) * 10 / 7`) so the reaction sprite plays its full sequence inside its slice of the timeline. The collision sprite is placed by the same value, at whichever end of the screen took the hit.

The result is that a hit reads correctly from both sides — the ball leaves the bat and the pitcher reacts *later*, at the point it reaches them — from one number, with no separate event scheduling and nothing to keep in sync.

### 3. Data-driven character definitions

A character never appears in code. It's a JSON description of which image sequences it owns:

```dart
class Action {
  String _srcPrefix;   // "assets/char_animations/slugger_swing_"
  int _startIndex;     // first numbered frame
  int _imageCount;     // how many to load
}

class Character {
  int _unlockThreshold;
  Action _idleAction, _swingAction, _hurtAction, _deathAction;
}
```

The loader expands each `Action` into a decoded image list at startup; the painter only ever sees `List<UI.Image>`. Adding a playable character means dropping numbered frames into assets and adding an entry to the JSON — no new painter branch, no new widget. Enemies and stages follow the same shape, which is what makes the unlockable roster a content problem rather than an engineering one.

`unlockThreshold` sits on the same object, so progression is declared beside the character it gates.

### 4. Explicit repaint gating

`CustomPainter.shouldRepaint` defaults are easy to get wrong in either direction — repaint always and you burn battery on a static screen, repaint never and the game freezes. This compares every field that can change a pixel:

```dart
bool shouldRepaint(GamePainter old) =>
  old.machinePos != machinePos || old.obstaclePos != obstaclePos ||
  old.obstacleDeathPos != obstacleDeathPos || old.obstacleIsHit != obstacleIsHit ||
  old.obstacleStatus != obstacleStatus || old.canInput != canInput ||
  old.inputPos != inputPos || old.idleIndex != idleIndex ||
  old.enemyIndex != enemyIndex || old.strikes != strikes || …;
```

Including the resolved images themselves (`currentImage`, `enemyImage`, `collisionImage`) covers the case where a position moved too little to matter but crossed a frame boundary — the thing a position-only comparison would miss.

---

## Main features

- **Timing-based batting mini-game** with escalating pitch speed and strike-out rules.
- **Unlockable characters, enemies and stages**, gated on score thresholds.
- **Layered sprite animation** composed from JSON-declared frame sequences.
- **Music and sound effects**, with per-stage backing tracks.
- **In-app purchases** alongside ad-supported free play.

---

## Getting started

```bash
flutter pub get
flutter run
```

> **Note:** targets a pre-null-safety Dart SDK and pins `firebase_admob`, which has since been replaced by `google_mobile_ads`. It needs a dependency upgrade pass to build on current stable.

---
