# wotlk-nx

> **Our ports:** [wow-nx](https://github.com/nx-mod/wow-nx) (WoW 1.12.1) · [wotlk-nx](https://github.com/nx-mod/wotlk-nx) (WoW 3.3.5a) · [haloce-nx](https://github.com/nx-mod/haloce-nx) (Halo: Combat Evolved)

<p align="center">
  <img src="docs/assets/benilla-wotlk-banner.png" alt="Benilla WotLK" width="100%">
</p>

[benilla-wotlk](https://github.com/Onixaz/benilla-wotlk), a World of Warcraft 3.3.5a client written in Rust and Bevy,
ported to the Nintendo Switch. Like [wow-nx](https://github.com/nx-mod/wow-nx), it draws through wgpu on a deko3d
backend, the Switch's native GPU API. Touch and USB keyboard/mouse work; Joy-Con HID reaches the app as gamepad input,
but controller play is not enabled yet.

> [!NOTE]
> You need your own 3.3.5a client (build 12340) for the game data, and a 3.3.5a server to play on. This repository
> contains no Blizzard content.

## Status

The Switch port is being brought up from wow-nx: the deko3d renderer, the Rust std target and the libnx layer work, and
the controller support is still being adapted to 3.3.5a. There is no release yet, so the install paths and build
commands below describe where the port is headed.

On the console, the login screen, authentication, realm list, character select and character creation work. World entry
on external servers is still being checked; use a server with Warden disabled until that is confirmed. On the desktop,
benilla-wotlk can authenticate, enter the world and run the stock 3.3.5a interface, though parts of the data and
gameplay layers still use 1.12.1 layouts or behavior.

## Install

1. Copy your 3.3.5a client's `Data` folder to `sdmc:/wotlk-nx/Data`. Copy the clean build-12340 `Wow.exe` from the same
   client to `sdmc:/wotlk-nx/Wow.exe` (`WoW.exe` and `wow.exe` are also read) so Warden memory checks have the reference
   image. Add `Interface/AddOns` there too if you want your addons.
2. Put `wotlk-nx.nro` in `sdmc:/wotlk-nx/` (or `sdmc:/switch/`) and start it from the homebrew menu. A release build
   looks for newer releases on GitHub while it loads and offers them; `WOTLKNX_UPDATE=0` turns that off.
3. Optional: `sdmc:/wotlk-nx/benilla.env` sets the server, login and character (below). Without it, type them on the
   login screen with the system keyboard (tap the text box).

Settings and saved state live in `sdmc:/wotlk-nx/benilla-config/`, as on the PC.

### benilla.env

`KEY=VALUE` lines, read at start:

| Key | Does |
|---|---|
| `WOW_HOST` | the logon server (`localhost:3724` by default) |
| `WOW_USER`, `WOW_PASS` | log in without typing (kept in plain text on the card) |
| `WOW_CHAR` | select a character without typing |
| `WOTLKNX_FPS=1` | the fps overlay, top left |
| `WOTLKNX_UPDATE=0` | no update check |
| `WOTLKNX_PROFILE=1` | a sampling profiler: `samples.txt` every 30 s, named by `switch/profile.py` |
| `WOTLKNX_GPU_PIPELINES=1` | GPU time per pipeline in the log |

Vertical sync is the game's own Video option.

## Controls

Touch moves the cursor and clicks; a tap on a text box opens the system keyboard. A USB keyboard and mouse work as on
the PC. Joy-Con buttons and sticks are emitted as Bevy gamepad events but are not bound to the game or UI yet.

Planned Joy-Con layout, not active until the 3.3.5a controller layer is ported:

| Button | In the world | In menus and windows |
|---|---|---|
| Left stick | move | |
| Right stick | camera (L or R held: zoom) | cursor |
| B | jump | back |
| A, Y, X | action slots 1, 2, 3 | A: confirm / click |
| D-pad | action slots 4–7 | move between buttons |
| ZL, ZR (held) | the other action layers | |
| L, R | target nearest friend, enemy | |
| Left stick press | autorun | |
| Right stick press | interact: talk, loot, skin, attack | |
| + | window wheel | |
| − | controller menu | |

## Build

Needs devkitPro (devkitA64, libnx, switch-tools) and the Rust nightly in `switch/env.sh` with `rust-src`. Then:

```sh
sh switch/build-benilla.sh -j2        # target/wotlk-nx.nro
```

Releases come from GitHub Actions (`.github/workflows/switch.yml`): pushing a tag `nx-v<version>` builds the release
profile (`WOTLKNX_SHIP=1`: every dependency in one codegen unit) numbered with the run number and publishes it as
`build-<n>` with the stored `wotlk-nx-switch.zip` the updater reads. `switch/release.sh` publishes a local build the
same way. `WOTLKNX_DEKO3D_DEBUG=1` links deko3d's debug library and names the work in a GPU fault.

The PC client is upstream's: [benilla-wotlk](https://github.com/Onixaz/benilla-wotlk#readme).

## What nx-mod changed

- A Rust std target for the Switch (`aarch64-nintendo-switch-newlib`, `switch/`), linked with libnx;
  `third_party/libc` with Horizon's socket and type layouts fixed for 64-bit (they were the 3DS's).
- `third_party/wgpu-hal`: a deko3d backend in wgpu's GL slot, with naga → uam shader translation cached on the SD
  card, per-pass GPU timing, and upstream's Vulkan stall patch alongside. `third_party/wgpu` and `wgpu-core` turn that
  slot on for the Switch.
- `crates/benilla-uam`: uam, deko3d's shader compiler, built into the NRO.
- `crates/benilla-horizon`: what libnx gives Rust (random numbers, `sysconf`, sockets), a thread-caching allocator,
  threads spread over the cores, the launch picture, the system keyboard, the self-updater and a sampling profiler.
- `crates/benilla-app/src/switch.rs`: the window, the applet loop, HID input (the Joy-Con as a gamepad, not bound yet),
  the SD card paths and `benilla.env`.
- Controller play is open work: there is no `crates/benilla-pad` in this tree yet. Its Rust layer needs a 3.3.5a UI
  seam and a `30300` addon before the gamepad bar can be used.
- `main` mirrors upstream; this work is on `switch`.

## Credits

- **[Onixaz](https://github.com/Onixaz/benilla-wotlk)** and contributors: benilla-wotlk.
- **[samwhosung](https://github.com/samwhosung/benilla)** and contributors: benilla, which benilla-wotlk began as.
- **[lucasvallejodev](https://github.com/lucasvallejodev/benilla-gamepad)**: benilla-pad, the controller crate.
- **[thelinkin3000](https://github.com/thelinkin3000/halo-ce-universal)** and nx-mod: the self-updater design, from
  haloce-nx.
- **[gfx-rs](https://github.com/gfx-rs/wgpu)**: wgpu and naga.
- **[devkitPro](https://github.com/devkitPro/uam)**: uam, deko3d, devkitA64; **[switchbrew](https://github.com/switchbrew/libnx)**: libnx.
- **[centollOS](https://github.com/centollOS/SwitchWakerHD)**: the uam patches.
- **[rust-lang](https://github.com/rust-lang/libc)**: the libc crate.

## Legal

Unofficial fan project, not affiliated with Blizzard Entertainment or Nintendo. World of Warcraft is a trademark of
Blizzard Entertainment. Code is under MIT or Apache 2.0, as upstream; uam is under zlib and MIT; the updater's design
is CC0. Running homebrew needs custom firmware, which breaks Nintendo's terms and can get a console banned.
