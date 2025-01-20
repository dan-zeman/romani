Mans Hulden's Foma is needed to run the analyzer.

To load the analyzer into Foma, compile it and automatically save the binary stack as rmc.bin:
foma -l rmc.foma

Use the saved stack to process the input file:
flookup rmc.bin < input.txt > output.txt
