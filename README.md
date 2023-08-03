# NES PCM 40kHz Demo
## How to compile?

For ASM6:
1. Download [Loopy's ASM6 6502 assembler](http://3dscapture.com/NES/asm6.zip) ([Linux version](https://web.archive.org/web/20140920234021/http://www.yibbleware.com/nes/asm6-1.6-linux.zip))
2. Launch the assembler with the following command: ``asm6 -l source.asm dest.nes``
3. Run **dest.nes** with your emulator!

For CA65:
1. Download the [CC65 suite](https://cc65.github.io/)
2. Run the commands:
	```cmd
	mkdir ../output
	ca65 -g -o src_ca65.o src_ca65.asm -l ../output/list.txt
	ld65 -v -C uorom4mbit.cfg --dbgfile ../output/dest_ca65.dbg src_ca65.o -o ../output/dest_ca65.nes
	```
3. Run **output/dest_ca65.nes** with your emulator!
