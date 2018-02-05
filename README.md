# Seta Engine for Batch games
Seta Engine is a collection of several game engines for batch scripting.
The main engines are **Gpu** series, which are speciallized on graphics and physics processing.

Standard engines are listed below:

Engine | Description
-------|------------
Gpu | Graphics and physics processing.
Dsp | Audio playback and mixing processing (if applicable).

Features for Seta:Gpu
----
There are variants of same engine speciallized for a specific game style, for example, monochrome engines are usually faster than color ones because it uses native rendering (no external executables).

Standard versions are listed here:

Version | Features
--------|-------------
mini | Color-limited, char-based and basic engine. Keyboard support-only.
A | Monochrome, char-based and ultra fast engine. Keyboard support-only.
B | Coloured, char-based engine. Keyboard support-only.
C | (on development) Coloured, sprite-based engine. Keyboard support-only.

Programing on Seta:Gpu
----
Programing games on these engines is done by editing the engine itself because performance reasons.
Mainly char-based engines have a small block of code regarding to collision detection: what characters is used as enemy, wall, floor, etc.

See the wiki for more information about a specific version.


Features for Seta:Dsp
----
TODO: replace sox.exe to a more lightweight executable
Like **Gpu** series, there are variants for specific tasks.

Note that all engines support playback of short sounds.
The ideal variants might be:

Version | Features
--------|----------
A | Simple audio playback. Supported formats: uncompressed WAV, and OGG. MP3 is not supported due to copyright concerns.
B | Module player, based on libopenmpt library, inteded mainly for playback of impulse tracker files.

