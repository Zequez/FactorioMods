# Factorio Mods

A database for Factorio mods.

[http://factoriomods.com](http://factoriomods.com)

## Planned features

- Integration with Github
  - Automatically scrap the releases from mods hosted in Github instead
    of adding the releases manually and hosting them on AWS.
  - Automatically use the Github README file as mod description and
    use the first pharagraph as summary
- Read dependencies from the info.json file in the zipped
  - Actually add inter-mod dependencies, for now it just saves information about the Factorio version required
- Fork [Factorio Mod Manager](https://github.com/narrowtux/FactorioModManager/) or convince someone
  that actually knows Java to register a `factoriomod://` protocol to automatically download and
  install the mods by clicking "install" on the web app
- Add bookmarks functionality for users to save mods and access them easily
- Track mods downloads and visits, for stats, and for later history checking by users
- Add a more automated way to authorize developers, instead of receiving PMs in the forum
- Support for multiple authors
- Support for mod forking detection
- I noticed a few devs use AdFly to get a little support,
  maybe I could add a pop up on the first download and ask the user if he wants
  to activate an "dev-support-download toggle" to turn all downloads into AdFly links
  for the dev. And maybe a custom YouTube video link, also for support.
- Feature to create modpacks. Just select the mods you want and then it's
  gonna create a joined zip with all the mods. Or maybe just a page with the list of the mods
  and their downloads buttons, a big zipped file sounds like an expensive bandwidth bill. It could just
  download everything with one click, that would be better.

# Copyright / License

Copyright © Ezequiel Adrian Schwartzman. All Rights Reserved.

Licensed under the CPAL-1.0 (the same licence that Reddit uses, seems like a good licence for open sourcing web apps).