# PS2EXE
 https://gallery.technet.microsoft.com/PS2EXE-Convert-PowerShell-9e4e07f1

##Usage:

Call  the script with this parameters:

-inputFile	: PowerShell script file

-outputFile	: file name (with path) for the destination EXE file

-debug	(switch) : generate debug info in the destination EXE file. The dynamically generated .CS file will stored beside the output EXE file. Furthermore a .PDB file will be generated for the EXE file

-verbose	(switch) : shows also verbose informations – if any.

-x86	(switch) : compile EXE to run as 32 bit application

-x64	(switch) : compile EXE to run as 64 bit application

-runtime20	(switch) : force running the EXE in PowerShell 2.0 using .NET 2.0

-runtime30	(switch) : force running the EXE in PowerShell 3.0 using .NET 4.0

-lcid	: specify language ID for threads

-sta	: run PowerShell environment in Single Thread Apartment mode

-mta	: run PowerShell environment in Multithread Apartment mode

-noconsole	: compile PS script as Windows application

##Command

.\ps2exe.ps1 -inputFile input_filename.ps1 output_filename.exe
