# Factorio Mods [![Build Status](https://travis-ci.org/Zequez/FactorioMods.svg)](https://travis-ci.org/Zequez/FactorioMods)

[FactorioMods.com](http://factoriomods.com) it's an open
source web app to host Factorio Mods, and make it easier for user and devs alike
to share, find, download, and manage mods.

[Trello board with tasks being worked, ideas, planning and stuff](https://trello.com/b/Ii5IHVxG/factoriomods). For bug report use the Github issues.

## Is FactorioMods a mod manager?

No, FactorioMods it's not a mod manager, after you download the mods, you have to install them
yourself. However there is another open source app, [FactorioModManager](https://github.com/narrowtux/FactorioModManager) that
allows you to do just that, and [here is the forum post with instructions of how to use it](http://www.factorioforums.com/forum/viewtopic.php?f=69&t=13327).

Since these are both open source apps, it's just a matter of time until
we can coordinate to use a common protocol to install mods in the same way
that NexusModManager does it.

## How do I submit mods?

For now just create an account on the site, and then [PM me on the forum](http://www.factorioforums.com/forum/ucp.php?i=pm&mode=compose&u=1553) and I'll set your permissions up. I still need to strengthen the system until I make it
fully public.

## How to get it up and running locally

If you want to contribute you'll probably need to run it locally

```bash
git clone https://github.com/Zequez/FactorioMods
bundle
```

At this point you'll need to configure a Postgres server.

```bash
rake db:setup
rake fake_data
```

That might take a while, specially because `rake fake_data` actually scraps posts from the Factorio forum.

After that you just have to

```bash
rails s
```

And you're on! ...probably... didn't actually test it from scratch on a different
computer, you might need to install some things, I'm sure you'll figure it out!

## Running tests

```bash
guard
```

## Planned features

- Integration with Github
  - Automatically scrap the releases from mods hosted in Github instead
    of adding the releases manually and hosting them on AWS.
  - Automatically use the Github README file as mod description and
    use the first pharagraph as summary
  - Maybe just host the mods list on the repo?
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

Licensed under the CPAL-1.0 (the same license that Reddit uses, seemed like a good license for open sourcing web apps).