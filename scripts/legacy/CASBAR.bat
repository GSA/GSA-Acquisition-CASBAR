mkdir CASBAR\dita
call downloadecfr.bat && call 1.RunECFRfixXSL_Volume7.bat && call 2.ECFRConversion.bat && call 3.AllInOne-Volume7.bat && call 4.CreateChapterDitamaps.bat && call 5.OrganizeFilesbyAgencyNumber.bat && call PublishScripts\CASBAR\html.bat
xcopy "CASBAR\dita" "C:\GSA_Regs\GSA-Acquisition-CASBAR\dita" /E /C /H /I /Y
rd /s /q "CASBAR\dita"
call removealldirs.bat
