@echo off

odin build src -out:BobbyCarrot.exe -microarch:generic -resource:res/main.rc -subsystem:windows -o:speed
