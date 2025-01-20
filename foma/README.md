Mans Hulden's Foma is needed to run the analyzer.

To load the analyzer into Foma:
foma -l rmc.foma

Inside Foma, save the stack in a binary file so it can be used in batch mode:
save stack rmc.bin
exit

Outside Foma, use the saved stack to process the input file:
flookup rmc.bin < input.txt > output.txt
