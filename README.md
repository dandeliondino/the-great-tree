# The Great Tree
## by dandeliondino

A short retro adventure game created for [Kenney Jam 2022](https://itch.io/jam/kenney-jam-2022), a 48-hour game jam with a theme of "Growth".

Created with Godot 3.5 and Ink.

[Play in browser or download on itch.io](https://dandeliondino.itch.io/the-great-tree)

If you're looking for the Ink/GDScript integration, relevant files include:
- [storyline.ink](https://github.com/dandeliondino/the-great-tree/blob/master/project/interface/dialogue/storyline.ink) (comment out the "-> DONE" to run in ink, it *sort of* works)
- [ink_manager.gd](https://github.com/dandeliondino/the-great-tree/blob/master/project/scripts/ink_manager.gd)
- [dialogue_container.gd](https://github.com/dandeliondino/the-great-tree/blob/master/project/interface/dialogue/dialogue_container.gd)
- [journal_panel.gd](https://github.com/dandeliondino/the-great-tree/blob/master/project/interface/journal/journal_panel.gd)

## Additional downloads
### Required addons:
- [godot-ink](https://github.com/paulloz/godot-ink)
- [ink-engine-runtime.dll](https://github.com/inkle/ink/releases)

### Recommended addons:
- [integer_resolution_handler](https://github.com/Yukitty/godot-addon-integer_resolution_handler)
- [godot-color-palette](https://github.com/EricEzaM/godot-color-palette)

## Credits
- All art, fonts and most sound effects from [Kenney](https://www.kenney.nl/)
- Music and stingers from JRPG Collection by [Yubatake/OpenGameArt.Org](https://opengameart.org/content/jrpg-collection)
- "Fire Crackling" from [AntumDeluge/OpenGameArt.Org](https://opengameart.org/content/fire-crackling)
- "Stream Sounds" from [kurt/OpenGameArt.Org](https://opengameart.org/content/stream-sounds)
- "Forest Ambience" from [TinyWorlds/OpenGameArt.Org](https://opengameart.org/content/forest-ambience)
- Colors are an adaptation of CopheeMoth's [Lost Century Palette](https://lospec.com/palette-list/lost-century)
- Pixel art outline shader from [weekend](https://www.youtube.com/watch?v=nBds_kFL2yY) and [GDQuest and contributors]( https://www.gdquest.com/)
- Dialogue and quest-tracking using [Ink](https://www.inklestudios.com/ink/) and paulloz's [Godot Ink](https://github.com/paulloz/godot-ink)
- Project created with [Godot 3.5](https://godotengine.org/)

## Additional notes
- This project uses a second viewport to render the HUD at a higher resolution than the game world (allowing more flexibility for text) using the technique from ["How I Made The Smoothest Pixel Art Camera"](https://youtu.be/LoR4Xg1l29U) by Nesi

## License
Public domain. Please adapt any code used here with no source/credit needed. Assets included in this repository are public domain from [Kenney](https://www.kenney.nl/). Some music/audio assets included in the published game are CC-BY licensed and are not included here.