Mans Hulden's Foma is needed to run the analyzer.
Perl interpreter is needed to convert the output of Foma to UD tags and features.

To load the analyzer into interactive Foma session:
foma -l rmc.foma

To generate and view the FST net in Windows:
foma -l view.foma & dot rmc.dot -Tpng -o rmc.png & start rmc.png

To load the analyzer into Foma, compile it and automatically save the binary stack as rmc.bin:
foma -l compile.foma

Use the saved stack to process the input file:
flookup rmc.bin < input.txt | foma2ud.pl > output.txt
