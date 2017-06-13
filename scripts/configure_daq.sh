#!/bin/sh

#reset DAQ
mpoke 0x65c00000 0x8
#unreset and set TTS override and input mask
mpoke 0x65c00000 0xc81
#read DAQ status
mpeek 0x65c00004
