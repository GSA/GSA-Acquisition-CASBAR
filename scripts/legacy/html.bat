rmdir /s /q ..\..\..\..\GSA_Regs\GSA-Acquisition-CASBAR\html
rmdir /s /q ..\..\..\..\GSA_Regs\GSA-Acquisition-CASBAR\dita
call C:\GSA-Acquisition-Tools\TOOLS\DITA-OT\dita-ot-2.5.4\bin\dita  -i "..\ECFR2DITA\CASBAR\dita\Chapter_99_T48_7010.ditamap" -f gsa-copypaste.html -o "..\..\..\..\GSA_Regs\GSA-Acquisition-CASBAR\html\copypaste-FullParts" > "..\ECFR2DITA\CASBAR\Chapter_99_T48_7010-publishHTML-log.txt" 2>&1
call C:\GSA-Acquisition-Tools\TOOLS\DITA-OT\dita-ot-2.5.4\bin\dita  -i "..\ECFR2DITA\CASBAR\dita\Chapter_99_T48_7010.ditamap" -f gsa-copypaste.html.all -o "..\..\..\..\GSA_Regs\GSA-Acquisition-CASBAR\html\copypaste-AllTopic" > "..\ECFR2DITA\CASBAR\Chapter_99_T48_7010-publishHTML-log.txt" 2>&1
call C:\GSA-Acquisition-Tools\TOOLS\DITA-OT\dita-ot-2.5.4\bin\dita  -i "..\ECFR2DITA\CASBAR\dita\Chapter_99_T48_7010.ditamap" -f gsa-copypaste.html.subpart -o "..\..\..\..\GSA_Regs\GSA-Acquisition-CASBAR\html\copypaste-Subparts" > "..\ECFR2DITA\CASBAR\Chapter_99_T48_7010-publishHTML-log.txt" 2>&1
xcopy CASBAR\dita ..\..\..\..\GSA_Regs\GSA-Acquisition-CASBAR\dita /E/H/C/I/Y
xcopy Graphics ..\..\..\..\GSA_Regs\GSA-Acquisition-CASBAR\Graphics /E/H/C/I/Y
