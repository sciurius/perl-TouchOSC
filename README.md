# TouchOSC

This repository provices a set of Perl modules to programmatically
create layout files for TouchOSC.

**TouchOSC** is a fully modular control surface that runs on all iOS and
Android devices. Send and receive Open Sound Control or MIDI messages
over Wi-Fi to control all compatible software and hardware.

See [the TouchOSC website](https://hexler.net/products/touchosc) for
details.

## Features

* Create layouts with tab pages, each containing controls.
* Easy coordinates: always starting top-left.
* A broad range of controls is supported, more are planned.
* For design purposes a schematic image can be generated.
* Existing layouts can be imported to generate schematic images.

[Example image](example.png)

## Limitations

I developed this to aid in building TouchOSC layouts for Ardour to be
used on a tablet.

* Vertical layouts may have issues.
* Only OSC commands, no MIDI.
* Only the controls that I needed so far: label, push-button,
  toggle-button, led indicator, fader and rotary. More will be added
  when needed.

## INSTALLATION

To install this module, run the following commands:

	perl Makefile.PL
	make
	make test
	make install

## SUPPORT AND DOCUMENTATION

Development of this module takes place on GitHub:
https://github.com/sciurius/perl-TouchOSC.

You can find documentation for this module with the perldoc command.

    perldoc TouchOSC

Please report any bugs or feature requests using the issue tracker on
GitHub.

## COPYRIGHT AND LICENCE

Copyright (C) 2019 Johan Vromans

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

