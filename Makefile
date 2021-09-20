default:
#asm:
	cl65 -v --config pceasm.cfg --cpu huc6280 -m main.map -tnone main.s -o main.bin
#	python3 padrom.py main.bin
	mv main.bin out.pce
run:
	mednafen ./out.pce

clean:
	rm -rf out.pce main.map 