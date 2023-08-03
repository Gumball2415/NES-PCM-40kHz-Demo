mkdir "../output"
ca65 -g -o src_ca65.o src_ca65.asm -l ../output/list.txt
ld65 -v -C uorom4mbit.cfg --dbgfile ../output/dest_ca65.dbg src_ca65.o -o ../output/dest_ca65.nes