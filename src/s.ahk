#NoEnv
;#Warn
;#NoTrayIcon
#Persistent
#SingleInstance Force

;{;;;;;;, TOGGLE, ;;;;;;;;;
SetWorkingDir %A_ScriptDir%
Process, Exist,
CURPID= %ERRORLEVEL%
cacheloc= %A_Temp%
ARCH= 64
ProgramFilesX86 := A_ProgramFiles . (A_PtrSize=8 ? " (x86)" : "")
if (A_Is64bitOS	= 0)
	{
		ARCH= 32
		ProgramFilesX86 := A_ProgramFiles
	}
home= %A_ScriptDir%
splitpath,home,srcfn,srcpth
if ((srcfn = "src")or(srcfn = "bin")or(srcfn = "binaries"))
	{
		home= %srcpth%
	}	
binhome= %home%\bin
source= %home%\src	
SetWorkingDir, %home%
ARIA= %binhome%\aria2c.exe
LKDIRS= %ProgramFilesX86%|%A_ProgramFiles%|%binhome%|%home%
GITWEB= https://github.com
GITSWEB= https://github.com
Loop, %save%
	{
		if (A_LoopFileSizeMB < 30)
			{
				filedelete, %save%
			}
	}

skeltmp= %home% 

FormatTime, date, YYYY_MM_DD, yyyy-MM-dd
FormatTime, TimeString,,Time
rntp= hide
skhtnum=
oldvrnum= 
buildtnum= 
oldsznum= 
olsize= 
olsha= 
olrlsdt= 
vernum= 
INIT= 

if ("%1%" = "show")
	{
		rntp= max
	}

SKOPT= %home%\skopt.cfg
if !FileExist(SKOPT)
	{
		INIT= 1
		gosub, SKOPTRESET
	}

gosub, READSKOPT


;{;;;;;;;;;;;;;;;;;;;;;;;;   TOOL TIPS    ;;;;;;;;;;;;;;;;;;;;;;;;;;;
DwnGit_TT :="Download Git executables"
SelGit_TT :="Select the Git.exe"
ILogin_TT :="github username"
REPODATS_TT :="GitHub ROM repository project"
ROMDATS_TT :="GitHub ROM DB project"
IMGDATS_TT :="GitHub Image DAT repository project"
IPass_TT :="github password"
IToken_TT :="Personal Access Token"
DwnRls_TT :="Download gh.exe"
SelRls_TT :="Select the gh.exe"
DwnNSIS_TT :="Download the NSIS executable"
SelNSIS_TT :="Select makensis.exe"
DwnAHK_TT :="Download AutoHotkey"
IALTH_TT :="Alternate user repositories`ndelimited by a ''>''"
SelAHK_TT :="Assigns the Ahk2Exe compiler executable"
SelBLD_TT :="Assigns the build directory.`nusually the same as your source directory"
SelGPD_TT :="Assigns the GitHub Projects directory`nusually ..\..\Documents\GitHub"
SelGSD_TT :="Assigns the github project Directory"
SelGWD_TT :="Assigns the projects' website directory`nusually ..\Documents\GitHub\$gituser$.github.io\"
SelDPL_TT :="Assigns the deployment directory`nwhere project-executables and assets are compiled to"
SelSRC_TT :="The source Directory`nusually this current directory"
UVER_TT :="the 'version.txt' file containing update information."
UFLU_TT :="the update file (also the portable executable)"
IURL_TT :="The Website url which reports the internet ip address"
HOSTINGURL_TT :="The URL for all emulators and assets"
SelDXB_TT :="Detect your environment and download needed programs"
IContinue_TT :="Sets the current environment."
SelDIR_TT :="Selects the location of the currently selected item"
PushNotes_TT :="The commit message uploaded to github as well as the changelog"
VerNum_TT :="The new version of the project"
AddIncVer_TT :="Increases the version number"
COMPILE_TT :="Deploys the project to github"
LogView_TT :="View the deployment log"
GitPush_TT :="Pushes the changes to github.com"
ServerPush_TT :="Uploads releases"
MMT_RC_TT :="Downloads, assigns or disables multi-monitor software"
KBM_RC_TT :="Downloads, assigns or disables keyboard-mapping software"
BGM_RC_TT :="Downloads, assigns or disables borderless windowing software"
PRE_RC_TT :="Downloads or assigns audio-output devices pre=launch"
POST_RC_TT :="Downloads or assigns audio-output devices post=launch"
SiteUpdate_TT :="Updates the website"
CANCEL_TT :="Interrupts the deployment"
INITINCL_TT :="Re-indexes the source directory and adds any new files to be included"
RePODATS_TT :="Recompiles any changes to your repository lists"
PortVer_TT :="compiles the portable executable"
OvrStable_TT :="compiles the installer"
IMGBLD_TT :="Recompiles the metadata database xmls"


;};;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;{;;;;;;;;;;;;;;;;;;;  INITIALIZATION MENU GUI  ;;;;;;;;;;;;;;;;;;;;;;;;;;
setupguiitems= ILogin|IEmail|IPass|IToken|DwnGit|SelGit|DwnRls|SelRls|DwnNSIS|SelNSIS|DwnAHK|SelAHK|SelBLD|SelGPD|DwnPULL|SelGSD|DwnIO|SelGWD|SelDPL|SelSRC|UVER|UFLU|IURL|RJPRJCTSET|RJPRJCT|HOSTINGURL|ROMDATS|REPODATS|IMGDATS|IReset|SelDXB|ICONTINUE
Gui,Font,Bold
Gui Add, GroupBox, x11 y1 w370 h429, Deployment Tool Setup
Gui,Font,normal
Gui Add, Text, x20 y20 w29 h14 ,login:
Gui Add, Text, x287 y25 w88 h14 , (github username)
Gui Add, Edit, x51 y18 w234 h21 vILogin gILogin,%GITUSER%
Gui Add, Text, x18 y45 w29 h14 , pass:
Gui Add, Edit, x51 y41 w138 h21 vIPass gIPass password,***************
Gui Add, Text, x190 y45 w29 h14 , email:
Gui Add, Edit, x221 y41 w155 h21 vIEmail gIEmail,%GITMAIL%
Gui Add, Text, x50 y68 h15,Project Name:
Gui Add, Edit, x140 y66 w150 h21 center vRJPRJCT gRJPRJCT,%RJPRJCT%
Gui Add, Button,x292 y66 h21 w34 vRJPRJCTSET gRJPRJCTSET,SET
;Gui Add, Text, x18 y68 w29 h14 , token:
;Gui Add, Edit, x51 y64 w295 h21 vIToken gIToken, %_GITPAT%
;Gui Add, Link, x351 y66 w10 h19, <a href="https://help.github.com/en/articles/creating-a-personal-access-token-for-the-command-line#creating-a-token">?</a>

Gui Add, Button, x16 y88 w13 h17 vDwnGit gDwnGit, V
Gui Add, Text, x123 y90 w228 h14 vTxtGit +Right, %GITAPP%
Gui Add, Button, x355 y87 w20 h19 vSelGit gSelGit, F

Gui Add, Button, x16 y109 w13 h17 vDwnRls gDwnRls, V
Gui Add, Text, x123 y112 w228 h14 vTxtRls +Right, %GITRLS%
Gui Add, Button, x355 y108 w20 h19 vSelRls gSelRls, F

Gui Add, Button, x16 y130 w13 h17 vDwnNSIS gDwnNSIS, V
Gui Add, Text, x123 y134 w228 h14 vTxtNSIS +Right, %NSIS%
Gui Add, Button, x355 y130 w20 h19 vSelNSIS gSelNSIS, F

Gui Add, Button, x16 y152 w13 h17 vDwnAHK gDwnAHK, V
Gui Add, Text, x123 y155 w228 h14 vTxtAHK +Right, %AHKDIR%
Gui Add, Button, x355 y152 w20 h19 vSelAHK gSelAHK, F


Gui Add, Text, x123 y175 w228 h14 vTxtGPD +Right, %GITROOT%
Gui Add, Button, x353 y170 w23 h23 vSelGPD gSelGPD, ...

Gui Add, Text, x123 y197 w228 h14 vTxtGSD +Right, %GITD%
Gui Add, Button, x353 y193 w23 h23 vSelGSD gSelGSD, ...

Gui Add, Text, x123 y221 w228 h14 vTxtDPL +Right, %DEPL%
Gui Add, Button, x353 y216 w23 h23 vSelDPL gSelDPL, ...
;Gui Add, Button, x16 y218 w13 h17 vDwnPULL gPULLSKEL, C

;Gui Add, Button, x16 y241 w13 h17 vDwnIO gPULLIO, C
Gui Add, Text, x123 y243 w228 h14 vTxtGWD +Right, %SITEDIR%
Gui Add, Button, x353 y239 w23 h23 vSelGWD gSelGWD, ...

Gui Add, Text, x123 y267 w228 h14  vTxtBLD +Right, %BUILDIR%
Gui Add, Button, x353 y262 w23 h23 vSelBLD gSelBLD, ...

Gui Add, Text, x123 y290 w228 h14 vTxtSRC +Right, %SKELD%
Gui Add, Button, x353 y285 w23 h23 vSelSRC gSelSRC, ...

Gui Add, Edit, x123 y310 w235 h21 vUVER gUVER, %UPDTURL%
Gui Add, Edit, x123 y333 w235 h21 vUFLU gUFLU, %UPDTFILE%
Gui Font,Bold
Gui Font,Normal
;Gui Add, Edit, x30 y357 w326 h21 vIURL gIURL, %IPLK%
Gui Add, Button, x10 y432 w51 h19 vIReset gIReset, reset_all
Gui Add, Button, x331 y432 w51 h19 vSelDXB gSelDXB, quick

Gui Add, Edit, x30 y360 w100 h21 vREPODATS gREPODATS, %REPODATS%
Gui Add, Edit, x145 y360 w100 h21 vROMDATS gROMDATS, %ROMDATS%
Gui Add, Edit, x265 y360 w100 h21 vIMGDATS gIMGDATS, %IMGDATS%
Gui Add, Edit, x20 y403 w120 h21 vHOSTINGURL gHOSTINGURL, %HOSTINGURL%
Gui Add, Edit, x195 y403 w120 h21 vIALTH gIALTH, %IALTH%

Gui Font, Bold
Gui Add, Button, x159 y433 w80 h23 vICONTINUE gICONTINUE, CONTINUE
Gui Add, Text, x141 y412 w56 h14, Git-Repo
Gui Add, Text, x320 y412 w56 h14, Alt-Repo
Gui Add, Text, x35 y385 w56 h14, ROM-DB
Gui Add, Text, x177 y385 w56 h14, HASH-DB
Gui Add, Text, x285 y385 w56 h14, IMG-DB
Gui Add, Text, x36 y89 w76 h14, Git.exe
Gui Add, Text, x36 y112 w76 h14, gh.exe
Gui Add, Text, x36 y134 w76 h14, makensis.exe
Gui Add, Text, x36 y152 w89 h14, Compiler Dir
Gui Add, Text, x36 y174 w91 h14, GitHub Master
Gui Add, Text, x36 y196 w96 h14, Git Project
Gui Add, Text, x36 y240 w87 h14, Website Dir
Gui Add, Text, x36 y220 w95 h14, Deployment Files
Gui Add, Text, x36 y266 w76 h14, Build Dir
Gui Add, Text, x36 y290 w75 h14, Source Dir
Gui Add, Text, x36 y313 w75 h14, Version.txt
Gui Add, Text, x36 y335 w75 h14, Portable Exe

Gui Font,Normal
Gui Add, StatusBar,, Status Bar
OnMessage(0x200, "WM_MOUSEMOVE")
Gui, Show, w391 h482, _DEV_GUI_
return
;};;;;;;;;;;;;;;;;;;;;;;;;;;;;;

INITCOMPLETE:
oldsize=
oldsha= 
olrlsdt=
vernum=	
getversf= %gitroot%\%GITUSER%.github.io\%RJPRJCT%\index.html

ifnotexist,%getversf%
	{
		FileDelete,ORIGHTML.html
		save= ORIGHTML.html
		URLFILE= https://%GITUSER%.github.io/%RJPRJCT%/index.html
		splitpath,save,svaf,svap
		exe_get(ARIA,URLFILE,svap,svaf,CURPID,cacheloc)
		;;DownloadFile(URLFILE, save, True, True)
		getversf= ORIGHTML.html
	}

Loop, Read, %getversf%
	{
		sklnum+=1
		getvern= 
		ifinstring,A_LoopReadLine,<h99>
			{
				stringgetpos,verstr,A_LoopReadLine,<h99>
				stringgetpos,endstr,A_LoopReadLine,</h99>
				strstr:= verstr + 6
				midstr:= (endstr - verstr - 5)
				stringmid,vernum,A_LoopReadLine,strstr,midstr
				if (midstr = 0)
					{
						vernum= 0.99.00.00
					}
				Loop,Parse,vernum,.
					{
						if A_LoopField is not digit
							{
								vernum= 0.99.00.00
							}
					}
				continue
			}
			ifinstring,A_LoopReadLine,<h88>
					{
						stringgetpos,verstr,A_LoopReadLine,<h88>
						FileReadLine,sklin,%SITEDIR%\index.html,%sklnum%
						getvern:= verstr+6
						StringMid,oldsize,sklin,%getvern%,4
						continue
					}
			ifinstring,A_LoopReadLine,<h87>
					{
						stringgetpos,verstr,A_LoopReadLine,<h87>
						FileReadLine,sklin,%SITEDIR%\index.html,%sklnum%
						getvern:= verstr+6
						StringMid,oldsize,sklin,%getvern%,4
						continue
					}
			ifinstring,A_LoopReadLine,<h77>
					{
						stringgetpos,verstr,A_LoopReadLine,<h77>
						FileReadLine,sklin,%SITEDIR%\index.html,%sklnum%
						getvern:= verstr+6
						StringMid,oldsha,sklin,%getvern%,40
						continue
					}
			ifinstring,A_LoopReadLine,<h66>
					{
						stringgetpos,verstr,A_LoopReadLine,<h66>
						FileReadLine,sklin,%SITEDIR%\index.html,%sklnum%
						getvern:= verstr+6
						StringMid,olrlsdt,sklin,%getvern%,18
						continue
					}	
			ifinstring,A_LoopReadLine,<h55>
					{
						stringgetpos,donat,A_LoopReadLine,<h55>
						FileReadLine,donit,%SITEDIR%\index.html,%sklnum%
						getvern:= donat+6
						StringMid,donation,donit,%getvern%,5
						continue
					}	
	}

if (vernum = "")
	{
		vernum= 0.99.00.00
	}
splitpath,gitapp,,gitappdir
splitpath,gitrls,,GITRLSDIR
;{;;;;;;;;;;;;;;;,,,,,,,,,, DEPLOYMENT MENU GUI,,,,,,,,,,;;;;;;;;;;;;;;;;;;;;;;;

Gui, Add, Edit, x8 y24 w469 h50 vPushNotes gPushNotes,%date% :%A_Space%
Gui, Add, Edit, x161 y151 w115 h21 vVernum gVerNum +0x2, %vernum%
Gui, Add, Button, x280 y154 w16 h16 vAddIncVer gAddIncVer,+
gui,font,bold
Gui, Add, Button, x408 y123 w75 h23 vCOMPILE gCOMPILE, DEPLOY
gui,font,normal
Gui, Add, Text, x8 y7, Git Push Description / changelog
Gui, Add, Button, x452 y106 w31 h17 vLogView gLogView,log
Gui, Add, CheckBox, x9 y75 h17 vGitPush gGitPush checked, Git Push
Gui, Add, CheckBox, x9 y94 h17 vServerPush gServerPush checked, Release Push
Gui, Add, CheckBox, x9 y112 h17 vSiteUpdate gSiteUpdate checked, Site Update
gui,font,bold
Gui, Add, Button, x408 y123 w75 h23 vCANCEL gCANCEL hidden, CANCEL
gui,font,normal
Gui, Add, Text, x308 y155, Version
Gui, Add, CheckBox, x204 y76 w114 h13 vINITINCL gINITINCL checked, Initialize-Include
;Gui, Add, CheckBox, x204 y95 w154 h13 vREPOBLD gREPOBLD, Repository Databases
Gui, Add, CheckBox, x204 y95 w154 h13 vDATBLD gDATBLD, ROM Databases
Gui, Add, CheckBox, x90 y95 w104 h13 vPortVer gPortVer checked %FIE%, Portable/Update
Gui, Add, CheckBox, x90 y76 w104 h13 vOvrStable gOvrStable %FIE% checked,Stable
Gui, Add, CheckBox, x90 y95 w154 h13 vDevlVer gDevlVer hidden, Development Version
Gui, Add, CheckBox, x90 y113 w154 h13 vIMGBLD gIMGBLD, Database Recompile
Gui, Add, Progress, x12 y135 w388 h8 vprogb -Smooth, 0

Gui, Add, StatusBar, x0 y151 w488 h18, Compiler Status
OnMessage(0x200, "WM_MOUSEMOVE")
Gui, Show, w488 h200,_DEV_GUI_
Return

;};;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


INITINCL:
INITINCL= 1
return

SKOPTRESET:
if (GITUSER = "")
	{
		gosub, CLNGSR
	}		
if (cntrst = 1)
	{
		if (GITUSER <> "")
			{
				iniwrite,%GITUSER%,%home%\skopt.cfg,GLOBAL,GITUSER
			}
		if (GITUSER <> "")
			{
				iniwrite,%GITMAIL%,%home%\skopt.cfg,GLOBAL,git_email
			}
		if (GITPASS <> "")
			{
				iniwrite,%GITPASS%,%home%\skopt.cfg,GLOBAL,git_password
			}
	}
skeltmp= %home%
iniwrite,%skeltmp%,%home%\skopt.cfg,GLOBAL,SKELD
bldtmp= %home%
iniwrite,%bldtmp%,%home%\skopt.cfg,GLOBAL,BUILDIR
BUILDIR= %bldtmp%
SKELD= %skeltmp%
GITUTST= 
GITPASS=
RJPRJCT= skeletonKey
iniwrite,%RJPRJCT%,%home%\skopt.cfg,GLOBAL,RJPRJCT
iniread,UPDTFILE,%home%\src\repos.set,GLOBAL,original_bnary
if ((UPDTFILE = "ERROR")or(UPDTFILE = ""))
	{
		UPDTFILE= %GITSWEB%/%GITUSER%/%RJPRJCT%/releases/download/portable/portable.zip			
	}
iniwrite,%UPDTFILE%,%home%\skopt.cfg,GLOBAL,UPDTFILE
iniread,UPDTURL,%home%\src\repos.set,GLOBAL,Version
if ((UPDTURL = "ERROR")or(UPDTFILE = ""))
	{
		UPDTURL= https://raw.githubusercontent.com/%GITUSER%/%RJPRJCT%/master/site/version.txt
	}
iniwrite,%UPDTURL%,%home%\skopt.cfg,GLOBAL,UPDTURL
iniread,arcsgg,%source%\arcorg.set,GLOBAL
Loop,parse,arcsgg,`r`n
	{
		if (A_LoopField = "")
			{
				continue
			}
		stringsplit,aug,A_LoopField,=
		stringreplace,ana,A_LoopField,%aug1%=,,
		uvar:= % %aug1%
		if (uvar = "")
			{
				%aug1%= %ana%
			}
	}
sklnum= 
vernum= 0.99.00.00
initchk= 	
iniwrite,%GITUSER%,%home%\skopt.cfg,GLOBAL,GITUSER		
GITMAIL= %GITUSER%@nomailaddy.org
iniwrite,%GITMAIL%,%home%\skopt.cfg,GLOBAL,git_email
IPLK= http://www.netikus.net/show_ip.html				
GITSRC= %GITWEB%/%GITUSER%/%RJPRJCT%
iniwrite,%GITSRC%,%home%\skopt.cfg,GLOBAL,GITSRC
SITEDIR= %home%\GitHub\%A_Username%.github.io\%RJPRJCT%
iniwrite,%SITEDIR%,%home%\skopt.cfg,GLOBAL,SITEDIR
GITROOT=%home%\GitHub
GITD= %GITROOT%\%RJPRJCT%
iniwrite,%GITD%,%home%\skopt.cfg,GLOBAL,GITD
iniwrite,%GITROOT%,%home%\skopt.cfg,GLOBAL,GITROOT
DEPL=%home%\GitHub\%RJPRJCT%.deploy
iniwrite,%DEPL%,%home%\skopt.cfg,GLOBAL,GITROOT
if ((GITUSER <> "")&&(GITUSER <> A_Username))
	{
		SITEDIR=%home%\GitHub\%GITUSER%.github.io\%RJPRJCT%
	}
iniwrite,%SITEDIR%,%home%\skopt.cfg,GLOBAL,GITROOT
Loop,parse,LKDIRS,|
	{
		if (A_LoopField = "")
			{
				continue
			}
		Loop,Files,%A_LoopField%\*,RFD
			{
				ktmp= Ahk2Exe.exe
				if (instr(A_LoopfileFullPath,ktmp)&&(AHKDIR = ""))
					{
						splitpath,A_LoopFileFullPath,,AHKDIR
						iniwrite,%AHKDIR%,%home%\skopt.cfg,GLOBAL,AHKDIR
					}
				ktmp= %RJPRJCT%.deploy				
				If (instr(A_LoopfileFullPath,ktmp)&&(DEPL = ""))
					{
						DEPL= %A_LoopFileFullPath%
						iniwrite,%DEPL%,%home%\skopt.cfg,GLOBAL,GITROOT
					}			
				ktmp= git.exe	
				if (instr(A_LoopfileFullPath,ktmp)&&(GITAPP = ""))
					{
						GITAPP= %A_LoopFileFullPath%
						iniwrite,%GITAPP%,%home%\skopt.cfg,GLOBAL,GITAPP
					}
				ktmp= gh.exe
				if (instr(A_LoopfileFullPath,ktmp)&&(GITRLS = ""))
					{
						GITRLS= %A_LoopfileFullPath%
						iniwrite,%GITRLS%,%home%\skopt.cfg,GLOBAL,GITRLS
					}
				ktmp= makensis.exe
				if (instr(A_LoopfileFullPath,ktmp)&&(NSIS = ""))
					{
						NSIS= %A_LoopfileFullPath%
						iniwrite,%NSIS%,%home%\skopt.cfg,GLOBAL,NSIS
					}
			}
	}	
return


;{;;;;;;;;;;;;;;   RESET BUTTON  ;;;;;;;;;;;;;;;;
IReset:
gui,submit,nohide
RJPRJCT= skeletonKey
gosub,CLNGSR
guicontrol,,txtGIT,(not set) git.exe
guicontrol,,ilogin,%GITUSER%
guicontrol,,ipass,
guicontrol,,itoken,	
guicontrol,,txtrls,(not set) gh.exe
guicontrol,,txtnsis,(not set) makensis.exe
guicontrol,,txtahk,(not set) Ahk2Exe.exe
guicontrol,,txtgpd,%home%\GitHub
guicontrol,,txtgsd,%home%\GitHub\%RJPRJCT%
guicontrol,,txtgwd,%home%\GitHub\%GITUSER%.github.io
guicontrol,,txtsrc,%home%
guicontrol,,txtbld,%home%
guicontrol,,txtdpl,%home%\GitHub\%RJPRJCT%.deploy
guicontrol,,iurl,http://www.netikus.net/show_ip.html
iniread,UPDTFILE,%home%\src\repos.set,BINARIES,original_bnary
if ((UPDTFILE = "ERROR")or(UPDTFILE = ""))
	{
		UPDTFILE= %GITSWEB%/%GITUSER%/%RJPRJCT%/releases/download/portable/portable.zip			
	}
iniread,UPDTURL,%SKELD%\src\repos.set,GLOBAL,Version
if ((UPDTURL = "ERROR")or(UPDTFILE = ""))
	{
		UPDTURL= https://raw.githubusercontent.com/%GITUSER%/%RJPRJCT%/master/site/version.txt
	}
guicontrol,,uver,%UPDTFILE%
guicontrol,,uflu, %UPDTURL% 
guicontrol,,HOSTINGURL, %GITSWEB%/%GITUSER%
guicontrol,,REPODATS,REPODATS
guicontrol,,ROMDATS,ROMDATS
guicontrol,,IMGDATS,IMGDATS
guicontrol,,ialth, %GITSWEB%/%GITUSER%
if (optionONE = "DEV")
	{
		guicontrol,,ialth, %optionTWO%
	}
filedelete,%home%\skopt.cfg
return

;};;;;;;;;;;;;;;;;;;;

;{;;;;;;;;;;;;;; COMPLETE SETUP & INITIALIZE ;;;;;;;;;;;;;
ICONTINUE:
nocont= 
stv= 
if (GITUSER = "")
	{
		SB_SetText("github user not defined")
		return
	}
if (GITMAIL = "")
	{
		SB_SetText("github email not defined")
		return
	}
if (GITPASS = "")
	{
		SB_SetText("password not defined")
		return
	}
if !FileExist(GITAPP)
	{
		SB_SetText("git.exe not defined")
		return
	}
if !FileExist(GITRLS)
	{
		SB_SetText("gh.exe not defined")
		return
	}
if !FileExist(NSIS)
	{
		SB_SetText("makensis.exe not defined")
		return
	}
if !FileExist(AHKDIR)
	{
		SB_SetText("Ahk2exe.exe not defined")
		return
	}
if !FileExist(SKELD)
	{
		SB_SetText("source directory not defined")
		return
	}
if ((DEPL = "") or (DEPL = "ERROR") or (GITROOT = "") or (GITROOT = "ERROR") or (GITD = "") or (GITD = "ERROR") or (SITEDIR = "") or (SITEDIR = "ERROR"))
	{
		SB_SetText("Ensure All Fields are populated")
		return
	}
if !FileExist(GITROOT)
	{
		FileCreateDir,%GITROOT%
	}
if !FileExist(GITD)
	{
		FileCreateDir,%GITD%
		FileCreateDir,%GITD%\src
		FileCreateDir,%GITD%\bin
		FileCreateDir,%GITD%\site
		FileCreateDir,%GITD%\site\img
		FileCopy,%SKELD%\src\repos.set,%GITD%\bin,1
		FileCopy,%SKELD%\src\*.ahk,%GITD%\src,1
		FileCopy,%SKELD%\src\*.set,%GITD%\src,1
		FileCopy,%SKELD%\site\img\*,%GITD%\site\img,1
		FileCopy,%SKELD%\site\*,%GITD%\site,1
	}
if !FileExist(SITEDIR)
	{
		FileCreateDir,%SITEDIR%
		FileCreateDir,%SITEDIR%\img
		FileCopy,%SKELD%\site\img\*,%SITEDIR%\img,1
		FileCopy,%SKELD%\site\*,%SITEDIR%,1
	}
if !FileExist(DEPL)
	{
		FileCreateDir,%DEPL%
	}
if !FileExist(BUILDIR)
	{
		BUILDIR= %SKELD%
	}
Gui,Destroy
goto, INITCOMPLETE
;};;;;;;;;;;;;;;;;;;;;;;;;;;;

;{;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  ENVIRONMENT DETCTION BUTTON  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SelDXB:
autoinstall=

if (RJPRJCT = "")
	{
		SB_SetText("git project name must be set to detect project environment")
		autoinstall=
		return
	}
if (GITUSER = "")
	{
		SB_SetText("github username must be set to detect project environment")
		autoinstall=
		return
	}
Msgbox,3,Quick-Setup,This tool can automatically install and initialize a development environment in:`n%home%`n`nProceed? 
ifmsgbox,No
	{
		return
	}
ifmsgbox,Cancel
	{
		return
	}
autoinstall= 1	
GITAV= GIT_%ARCH%
GITRV= Git_Release_%ARCH%
BLDITEMS=%GITAV%|%GITRV%|AutoHotkey|NSIS
Loop,parse,BLDITEMS,|
	{
		BLIT= %A_LoopField%
		iniread,nwurl,%SKELD%\src\BuildTools.set,BUILDENV,%BLIT%
		%dwnlsi%URL= %nwurl%
		splitpath,nwurl,nwurlf
		Loop,LKDIRS,|
			{
				Loop,Files,%A_LoopFileFullPath%\*,R
					{
						if (BLIT = GITAV)
							{
								ifExist,%A_LoopFileFullPath%\git.exe
									{
										GITAPP= %A_LoopFileFullPath%\git.exe
										iniwrite,%A_LoopFileFullPath%\git.exe,%home%\skopt.cfg,GLOBAL,GITAPP
									}
							}
						if (BLIT = GITRV)
							{
								ifExist,%A_LoopFileFullPath%\gh.exe
									{
										GITRLS= %A_LoopFileFullPath%\gh.exe
										iniwrite,%A_LoopFileFullPath%\gh.exe,%home%\skopt.cfg,GLOBAL,GITRLS
										break
									}
							}
						if (BLIT = "AutoHotkey")
							{
								ifExist,%A_LoopFileFullPath%\Ahk2exe.exe
									{
										_AHKDIR= %A_LoopFileFUllPAth%\Ahk2exe.exe
										splitpath,_AHKDIR,AHKFN,AHKDIR	
										iniwrite,%AHKDIR%,%home%\skopt.cfg,GLOBAL,AHKDIR
									}
							}
						if (BLIT = "NSIS")
							{
								ifExist,%A_LoopFileFullPath%\makensis.exe
									{
										NSIS= %A_LoopFileFullPath%\makensis.exe
										iniwrite,%A_LoopFileFullPath%\makensis.exe,%home%\skopt.cfg,GLOBAL,NSIS
										break
									}		
							}
					}
			}
		if !FileExist(GITAPP)
			{
				gosub, GetGitz
			}
		if !FileExist(GITRLS)
			{
				gosub, DwnRls
			}
		if !FileExist(AHKDIR)
			{
				gosub, GetAHKZ
			}
		if !FileExist(NSIS)
			{
				gosub, GetNSIS
			}
	}
if (SKELD = "")
	{
		SKELD= %home%
		guicontrol,,txtSRC,%SKELD%
		iniwrite,%SKELD%,%home%\skopt.cfg,GLOBAL,SKELD
		guicontrol,,TxtGWD,%SKELD%
	}
if (BUILDIR = "")
	{
		BUILDIR= %home%
		guicontrol,,txtBLD,%BUILDIR%
		iniwrite,%BUILDIR%,%home%\skopt.cfg,GLOBAL,BUILDIR
		guicontrol,,TxtBLD,%BUILDIR%
	}
if (GITROOT = "")
	{
		ifnotexist,%home%\GitHub\
			{
				GITROOT= %home%\GitHub\
			}
	}
iniwrite,%GITROOT%,%home%\skopt.cfg,GLOBAL,GITROOT
if (GITD = "")
	{				
		if (GITD = "")
			{
				GITD= %GITROOT%\%RJPRJCT%
			}
		ifnotexist,%GITROOT%\%RJPRJCT%\
			{
				guicontrol,,TxtGGSD,%GITD%
			}	
		if (GITSRC= "")
			{
				GITSRC= %GITWEB%/%gituser%/%RJPRJCT%
			}
		iniwrite,%GITD%,%home%\skopt.cfg,GLOBAL,Git_Directory	
		iniwrite,%GITSRC%,%home%\skopt.cfg,GLOBAL,GITSRC
	}
SITEDIR= %GITROOT%\%gituser%.github.io\%RJPRJCT%
iniwrite,%SITEDIR%,%home%\skopt.cfg,GLOBAL,SITEDIR
guicontrol,,TxtGWD,%SITEDIR%
DEPL= %GITROOT%\%RJPRJCT%.deploy
iniwrite,%DEPL%,%home%\skopt.cfg,GLOBAL,GITROOT
guicontrol,,TxtDPL,%DEPL%
if (UPDTFILE = "")
	{
		UPDTFILE= %GITSWEB%/%gituser%/%RJPRJCT%/releases/download/portable/portable.zip
		iniwrite,%UPDTFILE%,%home%\skopt.cfg,GLOBAL,UPDTFILE
		guicontrol,,UFLU,%UPDTFILE%
	}
if (UPDTURL = "")
	{
		UPDTURL= https://raw.githubusercontent.com/%gituser%/%RJPRJCT%/master/site/version.txt
	}
iniwrite,%UPDTURL%,%home%\skopt.cfg,GLOBAL,UPDTURL
guicontrol,,UVER,%UPDTURL%
autoinstall=		
return	
;};;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

IEmail:
gui,submit,nohide
guicontrolget,IEMAIL,,IEMAIL
GITMAIL= IEMAIL
SB_SetText("Enter the email used for your github account.")
if (IEMAIL = "")
	{
		GITMAIL= %A_Username%@nomailaddy.org
		IEMAIL= %A_Username%@nomailaddy.org
		guicontrol,,IEMAIL,%IEMAIL%
	}
iniwrite,%IEMAIL%,%home%\skopt.cfg,GLOBAL,git_email
return


RJPRJCT:
gui,submit,nohide
guicontrolget,RJPRJCT,,RJPRJCT
return

RJPRJCTSET:
guicontrolget,RJPRJCT,,RJPRJCT
stringreplace,RJPRJCT,RJPRJCT,%A_Space%,_,All
stringreplace,RJPRJCT,RJPRJCT,:,,All
stringreplace,RJPRJCT,RJPRJCT,;,,All
stringreplace,RJPRJCT,RJPRJCT,-,,All
stringreplace,RJPRJCT,RJPRJCT,.,,All
stringreplace,RJPRJCT,RJPRJCT,|,,All
stringreplace,RJPRJCT,RJPRJCT,{,,All
stringreplace,RJPRJCT,RJPRJCT,},,All
stringreplace,RJPRJCT,RJPRJCT,(,,All
stringreplace,RJPRJCT,RJPRJCT,),,All
stringreplace,RJPRJCT,RJPRJCT,[,,All
stringreplace,RJPRJCT,RJPRJCT,],,All
stringreplace,RJPRJCT,RJPRJCT,=,,All
stringreplace,RJPRJCT,RJPRJCT,*,,All
stringreplace,RJPRJCT,RJPRJCT,^,,All
stringreplace,RJPRJCT,RJPRJCT,`,,,All
stringreplace,RJPRJCT,RJPRJCT,`%,,All
stringreplace,RJPRJCT,RJPRJCT,+,,All
stringreplace,RJPRJCT,RJPRJCT,>,,All
stringreplace,RJPRJCT,RJPRJCT,<,,All
stringreplace,RJPRJCT,RJPRJCT,&,,All
stringreplace,RJPRJCT,RJPRJCT,$,,All
stringreplace,RJPRJCT,RJPRJCT,#,,All
stringreplace,RJPRJCT,RJPRJCT,~,,All
stringreplace,RJPRJCT,RJPRJCT,!,,All
stringreplace,RJPRJCT,RJPRJCT,/,,All
stringreplace,RJPRJCT,RJPRJCT,\,,All
stringreplace,RJPRJCT,RJPRJCT,?,,All
stringreplace,RJPRJCT,RJPRJCT,@,,All
guicontrol,,RJPRJCT,%RJPRJCT%
if (RJPRJCT = "")
	{
		SB_SetText("Set The Name of your Project")
		RJPRJCT= skeletonKey
		guicontrol,,RJPRJCT,%RJPRJCT%
		return
	}

iniwrite,%RJPRJCT%,%home%\skopt.cfg,GLOBAL,RJPRJCT	
iniread,UPDTFILE,%SKELD%\src\repos.set,BINARIES,original_bnary
if ((UPDTFILE = "ERROR")or(UPDTFILE = ""))
	{
		UPDTFILE= %GITSWEB%/%GITUSER%/%RJPRJCT%/releases/download/portable/portable.zip			
	}

iniread,UPDTURL,%SKELD%\src\repos.set,GLOBAL,Version
if ((UPDTURL = "ERROR")or(UPDTFILE = ""))
	{
		UPDTURL= https://raw.githubusercontent.com/%GITUSER%/%RJPRJCT%/master/site/version.txt
	}

guicontrol,,UVER,%UPDTURL%
guicontrol,,UFLU,%UPDTFILE%
if (!fileExist(GITROOT)or(GITROOT = ""))
	{
		filecreatedir,%home%\GitHub
		GITROOT=%home%\GitHub
	}

guicontrol,,txtGPD,%GITROOT%
GITD=%GITROOT%\%RJPRJCT%
iniwrite,%GITD%,%home%\skopt.cfg,GLOBAL,GITD
guicontrol,,TxtGSD,%GITD%
GITSRC=%GITWEB%/%gituser%/%RJPRJCT%

iniwrite,%GITSRC%,%home%\skopt.cfg,GLOBAL,GITSRC
guicontrol,,txtGWD,%SITEDIR%

if (!fileExist(SITEDIR)or(SITEDIR = ""))
	{
		SITEDIR=%GITROOT%\%GITUSER%.github.io\%RJPRJCT%
		iniwrite,%SITEDIR%,%home%\skopt.cfg,GLOBAL,SITEDIR
	}
guicontrol,,txtGWD,%SITEDIR%
if (!fileExist(DEPL)or(DEPL = ""))
	{
		DEPL= %GITROOT%\%RJPRJCT%.deploy
		iniwrite,%DEPL%,%home%\skopt.cfg,GLOBAL,DEPL
	}
guicontrol,,txtDPL,%DEPL%

if (!fileExist(SKELD)or	(SKELD = ""))
	{
		SKELD= %home%
		iniwrite,%SKELD%,%home%\skopt.cfg,GLOBAL,SKELD
	}
guicontrol,,TxtSRC,%SKELD%

if (!fileExist(BUILDIR)or(BUILDIR = ""))
	{
		BUILDIR= %home%
		iniwrite,%BUILDIR%,%home%\skopt.cfg,GLOBAL,BUILDIR
	}

guicontrolget,HOSTINGURL,,HOSTINGURL
if (HOSTINGURL = "")
	{
		HOSTINGURL=%GITSWEB%/%GITUSER%
	}
iniwrite,%HOSTINGURL%,%home%\skopt.cfg,GLOBAL,HOSTINGURL
guicontrol,,HOSTINGURL, %HOSTINGURL%

guicontrolget,REPODATS,,REPODATS
if (REPODATS = "")
	{
		REPODATS=%GITSWEB%/%GITUSER%/REPODATS/releases/download
	}
iniwrite,%REPODATS%,%home%\skopt.cfg,GLOBAL,REPODATS
guicontrol,,REPODATS,%REPODATS%

guicontrolget,ROMDATS,,ROMDATS
if (ROMDATS = "")
	{
		ROMDATS= %GITSWEB%/%GITUSER%/ROMDATS/releases/download
	}
iniwrite,%ROMDATS%,%home%\skopt.cfg,GLOBAL,ROMDATS
guicontrol,,ROMDATS,%ROMDATS%

guicontrolget,IMGDATS,,IMGDATS
if (IMGDATS = "")
	{
		IMGDATS= %GITSWEB%/%GITUSER%/IMGDATS/releases/download
	}
iniwrite,%IMGDATS%,%home%\skopt.cfg,GLOBAL,IMGDATS
guicontrol,,IMGDATS,%IMGDATS%

guicontrolget,ialth,,ialth
if (ialth = "")
	{
		ialth= %GITSWEB%/GITUSER
	}
iniwrite,%ialth%,%home%\skopt.cfg,GLOBAL,ialth
guicontrol,,ialth,%ialth%

iniwrite,%RJPRJCT%,%home%\skopt.cfg,GLOBAL,RJPRJCT
SB_SetText(" The project " RJPRJCT " name has been set.")
return


IURL:
gui,submit,nohide
guicontrolget,IURL,,IURL
SB_SetText("Enter the url of the file which contains your internet ip-address")
if (IRUL = "")
	{
		IURL= http://www.netikus.net/show_ip.html
		guicontrol,,IURL,%IURL%
	}

iniwrite,%IURL%,%home%\skopt.cfg,GLOBAL,net_ip
return

UFLU:
gui,submit,nohide
guicontrolget,UFLU,,UFLU
if (GITUSER = "")
	{
		SB_SetText("Set a github username first")
		return
	}
UFLU= %GITSWEB%/%GITUSER%/%RJPRJCT%/releases/download/portable/portable.zip			
guicontrol,,UFLU,%UFLU%
if (UFLU = "")
	{
		UFLU= %GITSWEB%/%gituser%/%RJPRJCT%/releases/download/portable/portable.zip
	}
guicontrol,,UFLU,%UFLU%
iniwrite,%UFLU%,%home%\skopt.cfg,GLOBAL,UPDTFILE
return

GitGPass:
InputBox, GITPASST , Git-Password, Input your github password,HIDE , 180, 140, , , ,, %GITPASST% 
if (GITPASST = "")
	{
		GITPASS= *******
		iniwrite,*******,%home%\skopt.cfg,GLOBAL,Git_password
		return
	}
SRCDD= 
GITPASS= %GITPASST%	
iniwrite, %GITPASS%,%home%\skopt.cfg,GLOBAL,Git_password
return

ILogin:
gui,submit,nohide
guicontrolget,GITUSER,,ILogin
if (GITUSER = "")
	{
		SB_SetText("You must enter a username to continue")
		inidelete,%home%\skopt.cfg,GLOBAL,GITUSER
		return
	}
iniwrite, %GITUSER%,%home%\skopt.cfg,GLOBAL,GITUSER
guicontrol,,uVer,https://raw.githubusercontent.com/%gituser%/%RJPRJCT%/master/site/version.txt
iniwrite,%uVer%,%home%\skopt.cfg,GLOBAL,UPDTURL
guicontrol,,uFLU,%GITSWEB%/%gituser%/%RJPRJCT%/releases/download/portable/portable.zip
iniwrite,%uFLU%,%home%\skopt.cfg,GLOBAL,UPDTFILE
GITSRC= %GITWEB%/%GITUSER%/%RJPRJCT%
iniwrite,%GITSRC%,%home%\skopt.cfg,GLOBAL,GITSRC
if (!fileExist(GITROOT)or(GITROOT = ""))
	{
		filecreatedir,%home%\GitHub
		GITROOT=%home%\GitHub
	}
guicontrol,,txtGPD,%GITROOT%

if (!fileExist(SITEDIR)or(SITEDIR = ""))
	{
		SITEDIR=%home%\GitHub\%GITUSER%.github.io\%RJPRJCT%
		iniwrite,%SITEDIR%,%home%\skopt.cfg,GLOBAL,SITEDIR
	}
guicontrol,,txtGWD,%SITEDIR%
if (!fileExist(GITD)or(GITD = ""))
	{
		GITD=%home%\GitHub\%RJPRJCT%
		iniwrite,%GITD%,%home%\skopt.cfg,GLOBAL,GITD
	}
guicontrol,,txtGSD,%GITD%
if (!fileExist(DEPL)or(DEPL = ""))
	{
		DEPL= %GITROOT%\%RJPRJCT%.deploy
		iniwrite,%DEPL%,%home%\skopt.cfg,GLOBAL,GITROOT
	}
guicontrol,,txtDPL,%DEPL%
if (!fileExist(SKELD)or	(SKELD = ""))
	{
		SKELD= %home%
		iniwrite,%SKELD%,%home%\skopt.cfg,GLOBAL,SKELD
	}
guicontrol,,TxtSRC,%SKELD%
if (!fileExist(BUILDIR)or(BUILDIR = ""))
	{
		BUILDIR= %home%
		iniwrite,%BUILDIR%,%home%\skopt.cfg,GLOBAL,BUILDIR
	}
guicontrol,,TxtBLD,%BUILDIR%
return

UVER:
gui,submit,nohide
guicontrolget,UVER,,UVER
if (UVER = "")
	{
		UVER= https://raw.githubusercontent.com/%GITUSER%/%RJPRJCT%/master/site/version.txt
	}
if (GITUSER = "")
	{
		UVER= https://raw.githubusercontent.com/%GITUSER%/%RJPRJCT%/master/site/version.txt
	}
guicontrol,,UVER,%UVER%
iniwrite,%UVER%,%home%\skopt.cfg,GLOBAL,UPDTURL
return

SelGPD:
gui,submit,nohide
GitRoot:
gitrttmp= %home%
ifexist,%gitrttmp%\GitHub
	{
		gitrttmp= %home%\GitHub
	}
FileSelectFolder, GITROOTT,*%gitrttmp% ,1,Select The GitHub Root Directory (contains all projects)
if (GITROOTT = "")
	{
		inidelete,%home%\skopt.cfg,GLOBAL,GITROOT
		guicontrol,,txtGPD, (not set) Github-Projects-Directory
		return
	}
GITROOT:= GITROOTT
splitpath,GITROOTT,GITROOTTFN
ifnotinstring,GITROOTTFN,GitHub
	{
		Loop, %GITROOTT%\*,2
			{
				ifinstring,A_LoopFilename,GitHub
					{
						GITROOTT= %A_LoopFileFullPath%
						GITROOT:= GITROOTT
						iniwrite, %GITROOT%,%home%\skopt.cfg,GLOBAL,GITROOT
						SB_SetText("Github dir is " GITROOT " ")
						guicontrol,,txtGPD,%GITROOT%
						return
					}
			}
		Msgbox,3,Github Directory not found,A ''github'' directory was not found.`nWould you like to create it?
		ifmsgbox,Yes
			{
				filecreatedir, %GITROOTT%\GitHub
				if (ERRORLEVEL = 0)
					{
						GITROOTT= %GITROOTT%\GitHub
						GITROOT:= GITROOTT
					}
			}
		iniwrite, %GITROOT%,%home%\skopt.cfg,GLOBAL,GITROOT
		SB_SetText("Github dir is " GITROOT " ")
		guicontrol,,txtGPD,%GITROOT%
		return			
	}
guicontrol,,txtGPD,%GITROOT%
iniwrite, %GITROOT%,%home%\skopt.cfg,GLOBAL,GITROOT
SB_SetText("Github dir is " GITROOT " ")
return

CLNGSR:
stringreplace,GITUSER,A_Username,%A_Space%,,All
stringreplace,GITUSER,GITUSER,`;,,All
stringreplace,GITUSER,GITUSER,-,,All
stringreplace,GITUSER,GITUSER,.,,All
stringreplace,GITUSER,GITUSER,`{,,All
stringreplace,GITUSER,GITUSER,`},,All
stringreplace,GITUSER,GITUSER,(,,All
stringreplace,GITUSER,GITUSER,),,All
stringreplace,GITUSER,GITUSER,[,,All
stringreplace,GITUSER,GITUSER,],,All
stringreplace,GITUSER,GITUSER,=,,All
stringreplace,GITUSER,GITUSER,^,,All
stringreplace,GITUSER,GITUSER,`,,,All
stringreplace,GITUSER,GITUSER,`%,,All
stringreplace,GITUSER,GITUSER,+,,All
stringreplace,GITUSER,GITUSER,&,,All
stringreplace,GITUSER,GITUSER,$,,All
stringreplace,GITUSER,GITUSER,#,,All
stringreplace,GITUSER,GITUSER,~,,All
stringreplace,GITUSER,GITUSER,!,,All
stringreplace,GITUSER,GITUSER,@,,All
return

SelGWD:
GetSiteDir:
if (GITUSER = "")
	{
		SB_SetText("username is not defined")
		guicontrol,focus,ILogin
		return
	}	
gui,submit,nohide
SB_SetText("Usually ..\ " gitroot "\" gituser ".github.io\$RJPRJCT$")
STLOCtmp= %GITROOT%
FileSelectFolder, STLOCT,*%STLOCtmp%,1,Select The WebSite Projects' html Directory.
if (STLOCT = "")
	{
		guicontrol,,txtGWD,(not set) Github-Site-Directory
		inidelete,%home%\skopt.cfg,GLOBAL,SITEDIR
		return
	}
SITEDIR= %STLOCT%	
iniwrite, %SITEDIR%,%home%\skopt.cfg,GLOBAL,SITEDIR
guicontrol,,txtGWD,%SITEDIR%
return


SelDPL:
gui,submit,nohide
SB_SetText("The directory in which binaries are compiled token.")
GetDepl:
DEPL=
depltmp= %home%\GitHub
ifexist, %GITROOT%
	{
		depltmp= %GITROOT%
	}
FileSelectFolder, DEPLT,*%depltmp% ,1,Select The Deployment Directory
if (DEPLT = "")
	{
		guicontrol,,txtDPL,(not set) Deployment-Directory
		inidelete,%home%\skopt.cfg,GLOBAL,DEPL
		return
	}
splitpath,DEPLT,depln
ifnotinstring,depln,.deploy
	{
		Loop, %DEPLT%\*,2
			{
				ifinstring,A_LoopFileName,%RJPRJCT%.deploy
					{
						DEPLT= %A_LoopFileFullPath%
						DEPL= %DEPLT%
						iniwrite,%DEPL%,%home%\skopt.cfg,GLOBAL,DEPL
						guicontrol,,txtDPL,%DEPL%
						return
					}
			}
	}
DEPL= %DEPLT%
splitpath,DEPLT,depln
if (DEPLN <> RJPRJCT . ".deploy")
	{
		DEPL= %DEPLT%\%RJPRJCT%.deploy
		filecreatedir,%DEPL%
	}
ifnotexist,%DEPL%\
	{
		inidelete,%home%\skopt.cfg,GLOBAL,DEPL
		guicontrol,,txtDPL,(not set) Deployment-Directory
		
		return
	}
iniwrite,%DEPL%,%home%\skopt.cfg,GLOBAL,DEPL
guicontrol,,txtDPL,%DEPL%
return

SelAHK:
gui,submit,nohide
GetComp:
Loop,parse,LKDIRS,|
	{
		ifexist, %A_LoopField%\AutoHotkey\Compiler\
			{
				comptmp= %A_LoopField%\AutoHotkey\Compiler
				break
			}
	}
FileSelectFile, AHKDIT,3,%comptmp%\Ahk2Exe.exe,Select AHK2Exe,*.exe
if (AHKDIT = "")
	{
		guicontrol,,txtAHK,(not set) Ahk2exe.exe
		
		inidelete,%home%\skopt.cfg,GLOBAL,AHKDIR
		return
	}
splitpath,AHKDIT,,AHKDIR
iniwrite, %AHKDIR%,%home%\skopt.cfg,GLOBAL,AHKDIR
guicontrol,,txtAHK,%AHKDIR%\Ahk2Exe.exe
return

SelBld:
gui,submit,nohide
FileSelectFolder, BUILDT,*%home% ,1,Select The BUILD Directory
if (BUILDT = "")
	{
		guicontrol,,txtBld,(not set) Build-Directory
		inidelete,%home%\skopt.cfg,GLOBAL,BUILDIR
		return
	}
splitpath,BUILDT,BUILDTFN
BUILDIR:= BUILDT
guicontrol,,txtBLD,%BUILDIR%
iniwrite, %BUILDIR%,%home%\skopt.cfg,GLOBAL,BUILDIR
if (SKELD = GITD)
	{
		SB_SetText(It is recommended to keep your BUILD and github directories separate)
	}
return

SelSRC:
gui,submit,nohide
SB_SetText("Usually the working project directory")

GetSrc:
FileSelectFolder, SKELT,*%home% ,1,Select The project Directory
if (SKELT = "")
	{
		guicontrol,,txtBLD,(not set) project Directory
		inidelete,%home%\skopt.cfg,GLOBAL,SKELD
		return
	}
Loop, %SKELT%\src\Setup.ahk
	{
		skelexists= 1
	}
if (skelexists = 1)
	{
		SKELD:= SKELT
		guicontrol,,txtSRC,%SKELD%
		iniwrite, %SKELD%,%home%\skopt.cfg,GLOBAL,SKELD
		if (SKELD = GITD)
			{
				SB_SetText(It is recommended to keep your source and github directories separate)
			}
		if (BUILDIR = "")
			{
				BUILDIR= %SKELD%
				guicontrol,,txtBLD,%SKELD%
				iniwrite,%BUILDIR%,%home%\skopt.cfg,GLOBAL,BUILDIR
			}
		return
	}	
Msgbox,3,Not-Found,Project was not found.`nRetry?
ifmsgbox,Yes
	{
		goto,SelSRC
	}
guicontrol,,txtSRC,(not set) Source Directory
inidelete,%home%\skopt.cfg,GLOBAL,SKELD

return

IToken:
gui,submit,nohide
guicontrolget,GITPAT,,IToken

if (GITPAT <> "")
	{
		iniwrite, %GITPAT%,%home%\skopt.cfg,GLOBAL,git_token
		return
	}
inidelete,%home%\skopt.cfg,GLOBAL,git_token
return

GetGPAC:
GITPATT= 
envGet, GITPATT, GITHUB_TOKEN
InputBox, GITPATT , Git-PAC, Input your git token, , 230, 140, , , ,,%GITPATT%
if (GITPAT <> "")
	{
		if (GITPATT = "")
			{
				envGet, GITPATT, GITHUB_TOKEN
				SB_SetText(" Git Access token is " GITPAT " ")
			}
	}
GITPAT= %GITPATT%	
iniwrite, %GITPAT%,%home%\skopt.cfg,GLOBAL,git_token
SB_SetText(" Git Access token is " GITPAT " ")
return


IPass:
gui,submit,nohide
guicontrolget,GITPASS,,IPass
if (GITPASS <> "")
	{
		
		iniwrite, %GITPASS%,%home%\skopt.cfg,GLOBAL,Git_password
		return
	}
inidelete,%home%\skopt.cfg,GLOBAL,Git_password
return

GetGPass:
InputBox, GITPASST , Git-Password, Input your github password,HIDE , 180, 140, , , ,, %GITPASST%
if (GITPASS <> "")
	{
		if (GITPASST = "")
			{
				GITPASST= *******
				SB_SetText(" Git Password is " ******* " ")
			}
	}
GITPASS= %GITPASST%	
iniwrite, %GITPASS%,%home%\skopt.cfg,GLOBAL,Git_password
return

GetGUSR:
GITUSERT= 
InputBox, GITUSERT , Git-Username, Input your git username, , 180, 140, , , ,, %a_username%
if (GITUSER <> "")
	{
		if (GITUSERT = "")
			{
				SB_SetText(" Git Username is " GITUSER " ")
				return
			}
	}
GITUSER= %GITUSERT%	
iniwrite, %GITUSER%,%home%\skopt.cfg,GLOBAL,GITUSER
return


SelRls:
gui,submit,nohide
GetRls:
GITRLST=
grltmp= %GITAPPDIR%
FileSelectFile,GITRLST,3,%grltmp%\gh.exe,Select github-release,*.exe
GITRLST:
if (GITRLST = "")
	{
		grltmp= 
		guicontrol,,TxtGit,(not set) gh.exe
		return
	}
GITRLS= %GITRLST%
iniwrite, %GITRLS%,%home%\skopt.cfg,GLOBAL,GITRLS

SB_SetText(" Github Release is " GITRLS "")
guicontrol,,TxtRls,%GITRLS%
return

getSCI:
gui,submit,nohide
SCIRT=
FileSelectFile,SCIRT,3,%scitmp%,Select SciTE,*.exe
if (SCIRT = "")
	{
		return
	}
SCITL= %SCIRT%
iniwrite,%SCITL%,%home%\skopt.cfg,GLOBAL,SciTE4AutoHotkey
SB_SetText(" SciTE4AutoHotkey " SCITL "")
return


SelNSIS:
gui,submit,nohide
Loop,parse,LKDIRS,|
	{
		ifexist, %A_LoopField%\NSIS
			{
				nsisapdtmp= %A_LoopField%\NSIS
				break
			}
	}
ifnotexist, %nsisapdtmp%
	{
		nsisapdtmp= 
	}
FileSelectFile, NSIST,3,%nsisapdtmp%\makensis.exe,Select the makensis.exe,*.exe
nsisapptmp= 
if (NSIST = "")
	{
		guicontrol,,txtNSIS,(not set) makensis.exe
		inidelete,%home%\skopt.cfg,GLOBAL,NSIS
		return
	}
NSIS= %NSIST%
splitpath, NSIS,,nsisappd
iniwrite, %NSIS%,%home%\skopt.cfg,GLOBAL,NSIS
guicontrol,,txtNSIS,%NSIS%

return


SelGit:
gui,submit,nohide
GetAPP:
gitapdtmp=
Loop,parse,LKDIRS,|
	{
		ifexist,%A_LoopField%\git\bin\git.exe
			{
				gitapdtmp= %A_LoopField%\git\bin
				break
			}
	}
FileSelectFile, GITAPPT,3,%gitapdtmp%\git.exe,Select the git.exe,*.exe
gitapptmp= 
if (GITAPPT = "")
	{
		inidelete,%home%\skopt.cfg,GLOBAL,GITAPP
		return
	}
GITAPP= %GITAPPT%
splitpath, gitapp,,gitappdir
iniwrite, %GITAPP%,%home%\skopt.cfg,GLOBAL,GITAPP
guicontrol,,txtGIT,%GITAPP%
return

SelGSD:
gui,submit,nohide
gittmp= %gitroot%\%RJPRJCT%
if (GITUSER = "")
	{
		SB_SetText("username is not defined")
		return
	}
if (GITROOT = "")
	{
		SB_SetText("github root is not defined")
		return
	}	
GetGit:
FileSelectFolder,GITT,*%gitroot%,1,Select The Github Project Directory.
if (GITT = "")
	{
		return
	}
splitpath,gitt,gittn
if (gittn <> RJPRJCT)
	{
		SB_SetText("Github Project directory does not match project name")
	}
if ((GITT = BUILDIR)or(GITT = SKELD))
	{
		SB_SetText("Github project directory should not be your source or build directories")
	}
GITD:= GITT
GITSRC= %GITWEB%/%gituser%/%RJPRJCT%
iniwrite, %GITD%,%home%\skopt.cfg,GLOBAL,GITD
IniWrite,%GitSRC%,%home%\skopt.cfg,GLOBAL,GITSRC	
guicontrol,,txtGSD,%GITD%	
return
;{;;;;;;;;;;;;;;;;;;;;;;;;;;   DOWNLOAD APPS  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DwnRls:
gui,submit,nohide
iniread,GRLURL,%SKELD%\src\BuildTools.set,BUILDENV,Github_Release_%ARCH%
splitpath,GRLURL,grlfn
grlsv= %home%\downloaded\%grlfn%
ifnotexist,%grlsv%
	{
		splitpath,gitapp,,gitappdir
		grltmp= %GITAPPDIR%
		SETUPTOG= disable
		gosub, SETUPTOG
		splitpath,grlsv,svaf,svap
		exe_get(ARIA,GRLURL,svap,svaf,CURPID,cacheloc)
		SETUPTOG= enable
		gosub, SETUPTOG
		sleep, 1200
		ifnotexist,%grlsv%
			{
				Msgbox,3,Not Found,%grlsv% not found.`nRETRY?
				ifmsgbox,Yes
					{
						goto,DwnRls
					}
			}
	}
ifnotexist, %grlsv%
	{
		inidelete,%home%\skopt.cfg,GLOBAL,GITRLS
		
		return
	}
GRLK=
GRLL=
grltmp= %binhome%\Git
if (autoinstall = 1)
	{
		GRLL= %grltmp%
		goto, GRLLSEL
	}
FileselectFolder,GRLL,*%grltmp%,0,Location to extract gh.exe
GRLLSEL:
if (GRLL = "")
	{
		inidelete,%home%\skopt.cfg,GLOBAL,GITRLS
		
		guicontrol,,TxtGit,(not set) gh.exe
		return
	}
SETUPTOG= disable
gosub, SETUPTOG
SB_SetText(" Extracting github-release to " GITRLS "")
Runwait, "%binhome%\7za.exe" x -y "%grlsv%" -O"%GRLL%",,%rntp%
Sleep, 1500
SETUPTOG= enable
gosub, SETUPTOG

GITRLS= %GRLL%\bin\gh.exe
iniwrite, %GITRLS%,%home%\skopt.cfg,GLOBAL,GITRLS
guicontrol,,TxtRLS,%GITRLS%
SB_SetText(" Github-release is " GITRLS "")
return

DwnNSIS:
gui,submit,nohide
GetNSIS:
iniread,nsisurl,%SKELD%\src\BuildTools.set,BUILDENV,NSIS
splitpath,nsisurl,nsisf
nsisv= %home%\downloaded\%nsisf%
ifnotexist, %home%\downloaded\%nsisf%
	{				
		
		SETUPTOG= disable
		gosub, SETUPTOG
		splitpath,nsisv,svaf,svap
		exe_get(ARIA,nsisurl,svap,svaf,CURPID,cacheloc)
		SETUPTOG= enable
		gosub, SETUPTOG
		sleep, 1200
	}
ifnotexist, %nsisv%
	{
		gitapdtmp= 
		Msgbox,3,not found,%nsisv% not found.`nRETRY?
		ifmsgbox,yes
			{
				goto, getNSIS
			}
		inidelete,%home%\skopt.cfg,GLOBAL,NSIS
		guicontrol,,txtNSIS,(not set) makensis.exe
		
		return
	}
NSISD= 
NSISDT= 
NSIS= 
NSISDT= %binhome%
if (autoinstall = 1)
	{
		NSIST= %NSISDT%
		goto, NSISTSEL
	}
FileSelectFolder, NSIST,*%NSISDT%,0,Location to extract the NSIS programs.
if (NSIST = "")
	{
		inidelete,%home%\skopt.cfg,GLOBAL,NSIS
		guicontrol,,txtNSIS,(not set) makensis.exe
		
		return
	}
NSISTSEL:	
SB_SetText("extracting nsis to " NSIS " ")
SETUPTOG= disable
gosub, SETUPTOG
Runwait, "%binhome%\7za.exe" x -y "%nsisv%" -O"%NSIST%",,%rntp%
SETUPTOG= enable
gosub, SETUPTOG
Loop,%NSIST%\*makensis.exe,0,1
	{		
		NSIS= %A_LoopFileFullPath%
		break
	}
iniwrite, %NSIS%,%home%\skopt.cfg,GLOBAL,NSIS
SB_SetText("makensis.exe is " NSIS " ")
guicontrol,,txtNSIS,%NSIS%

return

DwnSCI:
iniread,SCIURL,%SKELD%\src\BuildTools.set,BUILDENV,SciTE4AutoHotkey
splitpath,SCIURL,scifn
scisv= %cacheloc%\%scifn%
ifnotexist,%scisv%
	{
		scitmp= %binhome%
		SETUPTOG= disable
		gosub, SETUPTOG
		splitpath,scisv,svaf,svap
		exe_get(ARIA,SCIURL,svap,svaf,CURPID,cacheloc)
		SETUPTOG= enable
		gosub, SETUPTOG
		sleep, 1200
	}
ifnotexist,%scisv%
	{
		scitmp= 
		Msgbox,3,Not Found,%scisv% not found.`nRETRY?
		ifmsgbox,Yes
			{
				gosub,DwnSCI
			}
		return
	}
SCIK=
SCIL=
scitmp= %binhome%
FileselectFolder,SCIL,*%scitmp%,0,Location to extract SciTE4AutoHotkey
if (SCIL = "")
	{
		guicontrol,,txtRLS,gh.exe
		
		return
	}
SB_SetText(" Extracting scite to " SCITL "")
SETUPTOG= disable
gosub, SETUPTOG
Runwait, "%binhome%\7za.exe" x -y "%scisv%" -O"%SCIL%",,%rntp%
SETUPTOG= enable
gosub, SETUPTOG
SCITL= %SCIL%\SciTE.exe
iniwrite,%SCITL%,%home%\skopt.cfg,GLOBAL,SciTE4AutoHotKey
SB_SetText(" SciTE4AutoHotkey is " SCITL "")
guicontrol,,txtRLS,%SCITL%

return


DwnGit:
gui,submit,nohide
GetGITZ:

iniread,gitzurl,%SKELD%\src\BuildTools.set,BUILDENV,GIT_%ARCH%
splitpath,gitzurl,gitzf
gitzsv= %home%\downloaded\%gitzf%
gitapdtmp= %binhome%
ifnotexist, %gitzsv%
	{
		SETUPTOG= disable
		gosub, SETUPTOG
		splitpath,gitzsv,svaf,svap
		exe_get(ARIA,gitzurl,svap,svaf,CURPID,cacheloc)
		;;DownloadFile(gitzurl, gitzsv, False, True)
		SETUPTOG= enable
		gosub, SETUPTOG
		sleep, 1200
	}
ifexist, %gitzsv%
	{
		GITAPP= 
		GITAPPT=
		if (autoinstall = 1)
			{
				GITAPPT= %gitapdtmp%
				goto, GITZSL
			}
		FileSelectFolder, GITAPPT,*%gitapdtmp%,0,Location to extract the Git programs.
		GITZSL:
		ifinstring,GITAPPT,git
			{
				splitpath,GITAPPT,,gitappdir
				GITAPPT= %gitappdir%
			}
		if (GITAPPT = "")
			{
				gitapdtmp= 
				return
			}
		GITAPPT.= "\Git"
		SB_SetText(" Extracting Git to " GITAPPT "")
		Runwait, "%binhome%\7za.exe" x -y "%gitzsv%" -O"%GITAPPT%",,%rntp%
		SETUPTOG= disable
		gosub, SETUPTOG
		SETUPTOG= enable
		gosub, SETUPTOG
		GITAPP= %GITAPPT%\bin\Git.exe
		splitpath, gitapp,,gitappdir
		guicontrol,,txtGIT,%GITAPP%
		iniwrite, %GITAPP%,%home%\skopt.cfg,GLOBAL,GITAPP
		return
	}
gitapdtmp= 
Msgbox,3,not found,%gitzsv% not found.`nRETRY?
ifmsgbox,yes
	{
		gosub, getGitz
	}	
return


DwnAHK:
gui,submit,nohide
GetAHKZ:

iniread,AHKURL,%SKELD%\src\BuildTools.set,BUILDENV,AutoHotkey
splitpath,AHKURL,ahksvf
ahksv= %cacheloc%\%ahksvf%
ifnotexist, %ahksv%
	{
		ahktmp= %binhome%
		SETUPTOG= disable
		gosub, SETUPTOG
		splitpath,ahksv,svaf,svap
		exe_get(ARIA,AHKURL,svap,svaf,CURPID,cacheloc)
		;;DownloadFile(AHKURL, ahksv, False, True)
		SETUPTOG= enable
		gosub, SETUPTOG
		sleep, 1200
	}
ifnotexist, %ahksv%
	{
		ahktmp= 
		Msgbox,3,Not Found,%ahksv% not found.`nRETRY?
		ifmsgbox,Yes
			{
				goto,GetAHKZ
			}
		inidelete,%home%\skopt.cfg,GLOBAL,AHKDIR
		
		guicontrol,,txtAHK,(not set) Ahk2Exe.exe
		return
	}
AHKDIR= 
ahktmp= %binhome%
if (autoinstall = 1)
	{
		AHKDIT= %ahktmp%
		goto, AHKDITSL
	}
FileSelectFolder, AHKDIT,*%ahktmp%,0,Location to extract the AutoHotkey Programs.
if (AHKDIT = "")
	{
		inidelete,%home%\skopt.cfg,GLOBAL,AHKDIR
		
		guicontrol,,txtAHK,(not set) Ahk2Exe.exe
		return
	}
AHKDITSL:
splitpath,AHKDIT,ahktstn
ifnotinstring,ahktstn,AutoHotkey
	{
		AHKDIT.= "\AutoHotKey"
	}
SB_SetText("Extacting to " AHKDIR " ")
SETUPTOG= disable
gosub, SETUPTOG
Runwait, "%binhome%\7za.exe" x -y "%ahksv%" -O"%AHKDIT%",,%rntp%
SETUPTOG= enable
gosub, SETUPTOG
AHKDIR= %AHKDIT%\Compiler
iniwrite, %AHKDIR%,%home%\skopt.cfg,GLOBAL,AHKDIR

SB_SetText("AutoHotkey Compiler Directory is " AHKDIR " ")
guicontrol,,txtAHK,%AHKDIR%\Ahk2Exe.exe
return

GetBld:
BUILDIT= %BUILDIR%
ifnotexist, %bldtmp%
	{
		bldtmp= 
	}
FileSelectFolder, BUILDIT,*%bldtmp% ,1,Select The Build Directory
bldtmp= 
bldexists= 
if (BUILDIR <> "")
	{
		if (BUILDIT = "")
			{
				SB_SetText("BUILD dir is " BUILDIR " ")
				return
			}
	}
Loop,%BUILDIT%\src\Skey-Deploy.set
	{
		bldexists= 1
	}
if (bldexists = 1)
	{
		BUILDIR:= BUILDIT
		iniwrite, %BUILDIR%,%home%\skopt.cfg,GLOBAL,BUILDIR
		FileRead, nsiv,%BUILDIR%\src\Skey-Deploy.set
		StringReplace, nsiv, nsiv,[SOURCE],%SKELD%,All
		StringReplace, nsiv, nsiv,[INSTYP],-installer,All
		StringReplace, nsiv, nsiv,[BUILD],%BUILDIR%,All
		StringReplace, nsiv, nsiv,[DBP],%DEPL%,All
		StringReplace, nsiv, nsiv,skeletonkey,%RJPRJCT%,All
		StringReplace, nsiv, nsiv,[GIT_USER],%GITUSER%,All
		StringReplace, nsiv, nsiv,[CURV],%vernum%,All
		FileAppend, %nsiv%,%DEPL%\Skey-Deploy.nsi
		return
	}
Msgbox,3,Build Dir,Build Directory not found`nRetry?
IfMsgBox, Yes
	{
		gosub, GetBld
	}
filedelete, %home%\skopt.cfg
ExitApp

GetIpAddr:
gui,submit,nohide
IPLK= 
if (IPLKT = "")
	IPLKT= http://www.netikus.net/show_ip.html
inputbox,IPLK,Internet-IP-Address,Enter the url of the file which contains your internet ip-address,,345,140,,,,,%IPLKT%
if (IPLK = "")
	{
		IPLK= %IPLKT%
	}
IniWrite,%IPLK%,%home%\skopt.cfg,GLOBAL,net_ip
return

UpdateURL:
gui,submit,nohide
UPDTURL= 
if (UPDTURLT = "")
	{
		UPDTURLT= https://raw.githubusercontent.com/%GITUSER%/%RJPRJCT%/master/site/version.txt
	}
inputbox,UPDTURL,Version,Enter the url of the file which contains your update information,,345,140,,,,,%UPDTURLT%
if (UPDTURL = "")
	{
		UPDTURLT= https://raw.githubusercontent.com/%GITUSER%/%RJPRJCT%/master/site/version.txt
		UPDTURL= %UPDTURLT%
	}
IniWrite,%UPDTURL%,%home%\skopt.cfg,GLOBAL,UPDTURL
return

UpdateFILE:
gui,submit,nohide
UPDTFILE= 
if (UPDTFILET = "")
	{
		UPDTFILET= %GITSWEB%/%gituser%/%RJPRJCT%/releases/download/portable/portable.zip	
	}
inputbox,UPDTFILE,Version,Enter the url of the file which contains your update information,,345,140,,,,,%UPDTFILET%
if (UPDTFILE = "")
	{
		UPDTFILET= %GITSWEB%/%gituser%/%RJPRJCT%/releases/download/portable/portable.zip
		UPDTFILE= %UPDTFILET%
	}
IniWrite,%UPDTFILE%,%home%\skopt.cfg,GLOBAL,UPDTFILE
return

GitSRC:
gui,submit,nohide
GitSRC= 
if (GitSRCT = "")
	{
		GitSRCT= %GITWEB%/%GITUSER%/%RJPRJCT%
	}

inputbox,GitSRC,Git Repo,Enter the url for the project's git repo,,345,140,,,,,%GitSRCT%
if (GitSRC = "")
	{
		GitSRCT= %GITWEB%/%GITUSER%/%RJPRJCT%
		GitSRC= %GitSRCT%
	}

IniWrite,%GitSRC%,%home%\skopt.cfg,GLOBAL,GITSRC
return

VerNum:
gui,submit,nohide
guicontrolget,vernum,,vernum
return

;{;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   DEPLOYMENT TOOL BUTTONS  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SelDir:
gui,submit,nohide
if (SRCDD = "Git-User")
	{
		gosub, GetGUSR
		if (GITUSER = "")
			{
				gosub, CLNGSR
			}
	}
if (GITPAT = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
	{
		msgbox,1,,Git Personal Access Token must be set to deploy executables.,5
		gosub, GetGPAC
	}
if (SRCDD = "Source")
	{
		skeltmp= %home%
		gosub, GetSrc
	}
if (SRCDD = "Git.exe")
	{	
		Loop,parse,LKDIRS,|
			{			
				gitapdtmp= %A_LoopField%\git\bin
				ifnotexist, %gitapptmp%
					{
						gitapdtmp= %binhome%
					}
				gosub, GetAPP
			}
	}
if (SRCDD = "GitRoot")
	{
		gitrttmp= %home%\GitHub
		gosub, GitRoot
	}
if (SRCDD = "Site")
	{
		STLOCtmp= %GITROOT%\%GITUSER%.github.io
		gosub, GetSiteDir
	}
if (SRCDD = "Compiler")
	{
		Loop,parse,LKDIRS,|
			{
				ahktmp= %A_LoopField%
				comptmp= %A_LoopField%
				ifexist, %A_LoopField%\AutoHotkey\Compiler
					{
						comptmp=%A_LoopField%\AutoHotkey\Compiler
					}
				gosub, GetComp
			}			
	}
if (SRCDD = "Project")
	{
		gittmp= %home%\GitHub
		ifexist, %GITROOT%\%RJPRJCT%
			{
				gittmp= %GITROOT%\%RJPRJCT%
			}
		gosub, GetGit
	}
if (SRCDD = "SciTE4AutoHotkey")
	{
		scitmp= %binhome%
		gosub, GetSCI
	}
if (SRCDD = "Deployment")
	{
		depltmp= %DEPL%
		gosub, GetDepl
	}
if (SRCDD = "github-release")
	{
		splitpath,gitapp,,gitrlstmp
		gosub, GetRls
	}
if (SRCDD = "Build")
	{
		gosub, GetBld
	}
if (SRCDD = "NSIS")
	{
		nsitmp= %binhome%\NSIS
		nstmp= %binhome%\NSIS\makensis.exe
		ifexist, %ProgramFilesX86%\NSIS\makensis.exe
			{
				nsitmp= %ProgramFilesX86%\NSIS
				nstmp= %ProgramFilesX86%\NSIS\makensis.exe
			}
		ifexist, %binhome%\NSIS
			{
				nsimp= %binhome%\NSIS
				nstmp= %binhome%\NSIS\makensis.exe
			}
		ifnotexist, %nsitmp%
			{
				nsitmp= %binhome%
			}
		gosub, SelNSIS
	}
INIT= 
return

AddIncVer:
gui,submit,nohide
guicontrolget,vernum,,vernum
stringsplit,vernad,vernum,.
nven:= vernad4+1
stringleft,vernap,vernad4,1
if (vernap = 0)
	{
		nven= 0%nven%
	}
if (vernad4 = 99)
	{
		nven= 00
		if (vernad3 = 99)
			{
				nven= x
			}
			else {
				vernad3+=1
			}
	}
	
vernum:= vernad1 . "." vernad2 . "." vernad3 . "." nven
guicontrol,,VerNum,%vernum%
return

PortVer:
gui,submit,nohide

return

OvrStable:
gui,submit,nohide
return

DevlVer:
gui,submit,nohide
return

DATBLD:
gui,submit,nohide
return

REPOBLD:
gui,submit,nohide
return

IMGBLD:
gui,submit,nohide
return

PushNotes:
gui,submit,nohide
guicontrolget, PushNotes,,PushNotes
ifinstring,pushnotes,$
	{
		stringgetpos,verstr,pushnotes,$
		stringgetpos,endstr,pushnotes,.00
		if (ErrorLevel <> "")
			{
				strstr:= verstr + 2
				midstr:= (endstr - verstr - 1)
				stringmid,donation,pushnotes,strstr,midstr
				SB_SetText(" $" donation " found")
			}
	}
return

ServerPush:
gui,submit,nohide

return

GitPush:
gui,submit,nohide
guicontrolget,GITPUSH,,GITPUSH
return

SiteUpdate:
gui,submit,nohide
return


READSKOPT:
Loop, Read, %home%\skopt.cfg
	{
		curvl1= 
		curvl2= 
		stringsplit, curvl, A_LoopReadLine,=
		stringreplace,curlz,A_LoopReadLine,%curvl1%=,,All
		if (curvl1 = "GITUSER")
				{
					if ((curlz <> "")&&(curlz <> "ERROR"))
						{
							GITUSER= %curlz%
						}
				}
		if (curvl1 = "git_password")
				{	
					if ((curlz <> "")&&(curlz <> "ERROR"))
						{
							GITPASS= %curlz%
						}
				}
		if (curvl1 = "git_token")
				{
					if ((curlz <> "")&&(curlz <> "ERROR"))
						{
							GITPAT= %curlz%
						}
				}
		if (curvl1 = "GITAPP")
				{
					if ((curlz <> "")&&(curlz <> "ERROR"))
						{
							GITAPP= %curlz%
						}
				}		
		if (curvl1 = "GITRLS")
				{
					if ((curlz <> "")&&(curlz <> "ERROR"))
						{
							GITRLS= %curlz%
						}
				}
		if (curvl1 = "NSIS")
				{
					if ((curlz <> "")&&(curlz <> "ERROR"))
						{
							NSIS= %curlz%
						}
				}
		if (curvl1 = "AHKDIR")
				{
				if ((curlz <> "")&&(curlz <> "ERROR"))
					{
						AHKDIR= %curlz%
					}
			}
		if (curvl1 = "GITROOT")
				{
					if ((curlz <> "")&&(curlz <> "ERROR"))
						{
							GITROOT= %curlz%
						}
				}
		if (curvl1 = "SKELD")
				{
				if ((curlz <> "")&&(curlz <> "ERROR"))
					{
						SKELD= %curlz%
					}
			}
		if (curvl1 = "GITD")
				{
					if ((curlz <> "")&&(curlz <> "ERROR"))
						{
							GITD= %curlz%
						}
				}
		if (curvl1 = "SITEDIR")
				{
					if ((curlz <> "")&&(curlz <> "ERROR"))
						{
							SITEDIR= %curlz%
						}
				}
		if (curvl1 = "GITROOT")
				{
				if ((curlz <> "")&&(curlz <> "ERROR"))
					{
						DEPL= %curlz%
					}
			}
		if (curvl1 = "UPDTURL")
				{
					if ((curlz <> "")&&(curlz <> "ERROR"))
						{
							UPDTURL= %curlz%
						}
				}
		if (curvl1 = "UPDTFILE")
				{
					if ((curlz <> "")&&(curlz <> "ERROR"))
						{
							UPDTFILE= %curlz%
						}
				}
		if (curvl1 = "RJPRJCT")
				{
					if ((curlz <> "")&&(curlz <> "ERROR"))
						{
							RJPRJCT= %curlz%
						}
				}
		if (curvl1 = "git_email")
				{
					if ((curlz <> "")&&(curlz <> "ERROR"))
						{
							IEMAIL= %curlz%
							GITMAIL= %curlz%
						}
				}
		if (curvl1 = "BUILDIR")
				{
				if ((curlz <> "")&&(curlz <> "ERROR"))
					{
						BUILDIR= %curlz%
					}
				}
		if (curvl1 = "GITSRC")
				{
					if ((curlz <> "")&&(curlz <> "ERROR"))
						{
							GITSRC= %curlz%
						}
				}
		if (curvl1 = "IALTH")
				{
					if ((curlz <> "")&&(curlz <> "ERROR"))
						{
							IALTH= %curlz%
						}
				}
		if (curvl1 = "IMGDATS")
				{
					if ((curlz <> "")&&(curlz <> "ERROR"))
						{
							IMGDATS= %curlz%
						}
				}
		if (curvl1 = "REPODATS")
				{
					if ((curlz <> "")&&(curlz <> "ERROR"))
						{
							REPODATS= %curlz%
						}
				}
		if (curvl1 = "ROMDATS")
				{
					if ((curlz <> "")&&(curlz <> "ERROR"))
						{
							ROMDATS= %curlz%
						}
				}
		if (curvl1 = "HOSTINGURL")
				{
					if ((curlz <> "")&&(curlz <> "ERROR"))
						{
							HOSTINGURL= %curlz%
						}
				}
	}
return

IALTH:
gui,submit,nohide
guicontrolget,IALTH,,IALTH
if (IALTH = "")
	{
		iniread,IALTHv,%SKELD%\src\arcorg.set,GLOBAL,IALTH
		if ((IALTHv = "")or(IALTHv = "ERROR"))
			{	
				IALTHv= 
				guicontrol,,IALTH,%IALTHv%
			}
		IALTH= %IALTHv%
		IniWrite,%IALTH%,%home%\skopt.cfg,GLOBAL,IALTH
		return	
	}
if (IALTH = "")
	{
		IALTH= %GITWEB%/romjacket
		guicontrol,,IALTH,%IALTH%
	}
IniWrite,%IALTH%,%home%\skopt.cfg,GLOBAL,IALTH
return

IMGDATS:
gui,submit,nohide
guicontrolget,IMGDATS,,IMGDATS
if (IMGDATS = "")
	{
		ROMDATS= %GITWEB%/%GITUSER%/IMGDATS/releases/download
		guicontrol,,IMGDATS,%IMGDATS%	
	}
IniWrite,%IMGDATS%,%home%\skopt.cfg,GLOBAL,IMGDATS
return

ROMDATS:
gui,submit,nohide
guicontrolget,ROMDATS,,ROMDATS
if (ROMDATS = "")
	{
		ROMDATS= ROMDATS
		guicontrol,,ROMDATS,%ROMDATS%	
	}
IniWrite,%ROMDATS%,%home%\skopt.cfg,GLOBAL,ROMDATS
return

REPODATS:
gui,submit,nohide
guicontrolget,REPODATS,,REPODATS
IniWrite,%REPODATS%,%home%\skopt.cfg,GLOBAL,REPODATS
if (REPODATS = "")
	{
		REPODATS= %GITSWEB%/%GITUSER%/REPODATS/releases/download
		guicontrol,,REPODATS,%REPODATS%	
	}
IniWrite,%REPODATS%,%home%\skopt.cfg,GLOBAL,REPODATS
return

HOSTINGURL:
gui,submit,nohide
guicontrolget,HOSTINGURL,,HOSTINGURL
iniread,HOSTINGURLv,%SKELD%\src\arcorg.set,GLOBAL,HOSTINGURL
if (HOSTINGURL = "")
	{
		if (GITUSER = "")
			{
				SB_SetText("username is not defined.")
				guicontrol,,HOSTINGURL,%HOSTINGURLv%
				return
			}
		IniWrite,%reponum1%,%home%\skopt.cfg,GLOBAL,HOSTINGURL
		HOSTINGURL= %GITSWEB%/%gituser%
		IniWrite,%IALTH%,%home%\skopt.cfg,GLOBAL,IALTH
		guicontrol,,HOSTINGURL,%HOSTINGURL%
	}
IniWrite,%HOSTINGURL%,%home%\skopt.cfg,GLOBAL,HOSTINGURL
return

/*
HOSTINGURL:
gui,submit,nohide
guicontrolget,HOSTINGURLT,,HOSTINGURL
HOSTINGURL= 
UPDTFILE= %GITWEB%/%GITUSER%/%RJPRJCT%/releases/download/nodats
if (REPORURLT = "")
	{
		iniread,HOSTINGURLT,%SKELD%\src\arcorg.set,GLOBAL,HOSTINGURL
		UPDTFILE= %REPORULT%/%RJPRJCT%/releases/download/nodats
		HOSTINGURL= %UPDTFILE%
	}
inputbox,HOSTINGURL,Repository-URL,Enter the base-url of the file-repository,,345,140,,,,,%HOSTINGURL%
if (HOSTINGURL = "")
	{
		HOSTINGURL= %HOSTINGURLT%
		UPDTFILE= %UPDTFILE%
	}
guicontrol,,HOSTINGURL,%HOSTINGURL%	
IniWrite,%HOSTINGURL%,%home%\skopt.cfg,GLOBAL,HOSTINGURL
return
*/

LogView:
ifexist,%DEPL%\deploy.log
	{
		Run,Notepad "%DEPL%\deploy.log"
		return
	}
SB_SetText("Log Not Found")
return

;{;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   RESET  BUTTON  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;};;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;};;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;{;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  DEPLOYMENT PROCEDURES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
COMPILE:
filedelete,%DEPL%\deploy.log
BCANC= 
gui,submit,nohide
compiling= 1
guicontrol,hide,COMPILE
guicontrol,show,CANCEL
guicontrolget,REPOBLD,,REPOBLD
guicontrolget,DATBLD,,DATBLD
guicontrolget,IMGBLD,,IMGBLD
guicontrolget,GITPUSH,,GITPUSH
guicontrolget,SERVERPUSH,,SERVERPUSH
guicontrolget,SITEUPDATE,,SITEUPDATE
guicontrolget,INITINCL,,INITINCL
guicontrolget,PORTVER,,PORTVER
guicontrol,disable,RESDD
guicontrol,disable,OvrStable
guicontrol,disable,ResB
guicontrol,disable,SrcDD
guicontrol,disable,SelDir
guicontrol,disable,PushNotes
guicontrol,disable,VerNum
guicontrol,disable,GitPush
guicontrol,disable,ServerPush
guicontrol,disable,SiteUpdate
guicontrol,disable,IMGBLD
guicontrol,disable,ROMDATS
guicontrol,disable,REPODATS
guicontrol,disable,PortVer
guicontrol,disable,INITINCL
guicontrol,disable,DevlVer

readme= 
FileMove,%SKELD%\ReadMe.md, %SKELD%\ReadMe.bak,1
FileRead,readme,%SKELD%\src\ReadMe.set
StringReplace,readme,readme,[CURV],%vernum%
StringReplace,readme,readme,skeletonkey,%RJPRJCT%
StringReplace,readme,readme,[GIT_USER],%GITUSER%
StringReplace,readme,readme,[VERSION],%date% %timestring%
FileAppend,%readme%,%SKELD%\ReadMe.md
FileCopy,%SKELD%\ReadMe.md,site,1

arcorgv= 
FileMove,%SKELD%\src\themes.set, %SKELD%\themes.bak,1
FileMove,%SKELD%\src\arcorg.set, %SKELD%\arcorg.bak,1
FIleRead,skthemes,%SKELD%\src\Themes.put
FIleRead,arcorgv,%SKELD%\src\arcorg.put
StringReplace,skthemes,skthemes,[IALTH],%IALTH%,All
StringReplace,skthemes,skthemes,[HOSTINGURL],%HOSTINGURL%,All
StringReplace,arcorgv,arcorgv,[UPDATEFILE],%UPDTFILE%,All
StringReplace,arcorgv,arcorgv,[IALTH],%IALTH%,All
StringReplace,arcorgv,arcorgv,[HOSTINGURL],%HOSTINGURL%,All
StringReplace,arcorgv,arcorgv,[ROMDB],%ROMDATS%,All
StringReplace,arcorgv,arcorgv,[REPODATS],%REPODATS%,All
StringReplace,arcorgv,arcorgv,[SOURCEHOST],%UPDTURL%,All
StringReplace,arcorgv,arcorgv,[IPLK],%IPLK%,All
StringReplace,arcorgv,arcorgv,[CURV],%vernum%,All
FileAppend,%arcorgv%,%SKELD%\src\arcorg.set
FileAppend,%skthemes%,%SKELD%\src\themes.set

FileDelete, %SKELD%\bin\%RJPRJCT%.exe
FileMove, %SKELD%\src\working.ahk, %SKELD%\src\%RJPRJCT%.tmp,1
sktmp= 
sktmc= 
sktmv= 
exrtc= |
Loop,Files,%SKELD%\bin\*.exe
	{
		extrc.= A_LoopFileName . "?"
	}
extrc.= "|\..\|"
iniwrite,https://github.com/%GITUSER%/%RJPRJCT%/releases/download/portable/portable.zip%exrtc%,%source%\arcorg.set,REPOSITORIES,originalBinary
iniwrite,https://github.com/%GITUSER%/%RJPRJCT%,%source%\arcorg.set,GLOBAL,SOURCEHOST
FileRead, sktmp,%SKELD%\src\%RJPRJCT%.tmp
iniwrite,%date% %TimeString%,%source%\arcorg.set,GLOBAL,Version
iniwrite,%UPDTFILE%,%source%\arcorg.set,GLOBAL,UPDATEFILE
iniwrite,%HOSTINGURL%,%source%\arcorg.set,GLOBAL,HOSTINGURL
StringReplace,sktmc,sktmp,[VERSION],%date% %TimeString%,All
StringReplace,sktmv,sktmc,[CURV],%vernum%
StringReplace,sktmv,sktmc,skeletonkey,%RJPRJCT%
stringreplace,sktmv,sktmv,`/`*  `;`;[DEBUGOV],,All
stringreplace,sktmv,sktmv,`*`/  `;`;[DEBUGOV],,All
FileAppend,%sktmv%,%SKELD%\src\working.ahk
FileDelete,%SKELD%\src\%RJPRJCT%.tmp

FileDelete, %SKELD%\src\Update.exe
FileDelete,%SKELD%\src\Update.tmp
FileMove,%SKELD%\src\Update.ahk,%SKELD%\src\Update.tmp,1
uptmp= 
uptmc= 
uptmv= 
FileRead, uptmp,%SKELD%\src\Update.tmp
StringReplace,uptmc,uptmp,[VERSION],%date% %TimeString%,All
StringReplace,uptmv,uptmc,[CURV],%vernum%
StringReplace,uptmv,uptmc,skeletonkey,%RJPRJCT%
stringreplace,uptmv,uptmv,`/`*  `;`;[DEBUGOV],,All
stringreplace,uptmv,uptmv,`*`/  `;`;[DEBUGOV],,All
FileAppend,%uptmv%,%SKELD%\src\Update.ahk
FileDelete,%SKELD%\src\Update.tmp
FileDelete, %SKELD%\bin\init.exe
FileDelete,%SKELD%\src\init.tFileMove,%SKELD%\src\init.ahk,%SKELD%\src\init.tmp,1
intmp= 
intmc= 
intmv= 
FileRead, intmp,%SKELD%\src\init.tmp
StringReplace,intmc,intmp,[VERSION],%date% %TimeString%,All
StringReplace,intmv,intmc,[CURV],%vernum%
StringReplace,intmv,intmc,skeletonkey,%RJPRJCT%
stringreplace,intmv,intmv,`/`*  `;`;[DEBUGOV],,All
stringreplace,intmv,intmv,`*`/  `;`;[DEBUGOV],,All
FileAppend,%intmv%,%SKELD%\src\init.ahk
FileDelete,%SKELD%\src\init.tmp
if (BCANC = 1)
	{
		SB_SetText(" Cancelling Compile ")
		guicontrol,,progb,0
		;Sleep, 500
		compiling= 
		return
	}

SB_SetText(" Compiling ")
if (OvrStable = 1)
	{
		ifexist, %DEPL%\%RJPRJCT%-installer.exe
			{
				FileMove, %DEPL%\%RJPRJCT%-installer.exe, %DEPL%\%RJPRJCT%-installer.exe.bak,1
			}
		IsSrc= 
		ifexist, %SKELD%\bin\SKey-Deploy.exe
			{
				FileMove, %SKELD%\bin\SKey-Deploy.exe, %SKELD%\bin\SKey-Deploy.exe.bak,1
				if (errorlevel <> 0)
					{
						IsSrc= 1
					}
			}
	}

if (INITINCL = 1)
	{		
		RunWait, %comspec% /c echo.##################  COMPILE UPDATER  ######################## >>"%DEPL%\deploy.log", ,%rntp%	
		runwait, %comspec% /c " "%AHKDIR%\Ahk2Exe.exe" /in "%SKELD%\src\Update.ahk" /out "%SKELD%\bin\Update.exe" /icon "%SKELD%\img\Update.ico" /bin "%AHKDIR%\Unicode 32-bit.bin" >>"%DEPL%\deploy.log"", %SKELD%,%rntp%	
		RunWait, %comspec% /c echo.##################  COMPILE INITIALIZER  ######################## >>"%DEPL%\deploy.log", ,%rntp%	
		runwait, %comspec% /c " "%AHKDIR%\Ahk2Exe.exe" /in "%SKELD%\src\init.ahk" /out "%SKELD%\bin\Init.exe" /icon "%SKELD%\img\helper.ico" /bin "%AHKDIR%\Unicode 32-bit.bin" >>"%DEPL%\deploy.log"", %SKELD%,%rntp%	
		RunWait, %comspec% /c echo.##################  COMPILE %RJPRJCT%  ######################## >>"%DEPL%\deploy.log", ,%rntp%	
		runwait, %comspec% /c " "%AHKDIR%\Ahk2Exe.exe" /in "%SKELD%\src\working.ahk" /out "%SKELD%\bin\%RJPRJCT%.exe" /icon "%SKELD%\site\key.ico" /bin "%AHKDIR%\Unicode 32-bit.bin" >>"%DEPL%\deploy.log"", %SKELD%,%rntp%
		RunWait, %comspec% /c echo.########################################## >>"%DEPL%\deploy.log", ,%rntp%	
		FileCopy, %DEPL%\%RJPRJCT%.exe,%SKELD%,1
		portableincludes=
		Loop,files,%SKELD%\bin\*,F
			{
				if ((A_LoopFileExt = "txt")or(A_LoopFileExt = "exe")or(A_LoopFileExt = "bat"))
					{
					stringreplace,ain,A_LoopFileFullPath,%home%\,,All
						portableincludes.= ain . "|"
					}
			}
		Loop,files,%SKELD%\src\*,F
			{
				if ((A_LoopFileExt = "set")or(A_LoopFileExt = "ahk")or(A_LoopFileExt = "put"))
					{
					stringreplace,ain,A_LoopFileFullPath,%home%\,,All
						portableincludes.= ain . "|"
					}
			}
		Loop,files,%SKELD%\rj\*,FR
			{
				if ((A_LoopFileExt = "amgp")or(A_LoopFileExt = "xpadderprofile")or(A_LoopFileExt = "ret")or(A_LoopFileExt = "set"))
					{
					stringreplace,ain,A_LoopFileFullPath,%home%\,,All
						portableincludes.= ain . "|"
					}
			}
		Loop,files,%SKELD%\img\*,F
			{
				if ((A_LoopFileExt = "ico")or(A_LoopFileExt = "png"))
					{
					stringreplace,ain,A_LoopFileFullPath,%home%\,,All
						portableincludes.= ain . "|"
					}
			}
		portableincludes.= home . "\" . Readme.md
	}	

if (OvrStable = 1)
	{
		Process, exist, Skey-Deploy.exe
		if (ERRORLEVEL = 1)
			{
				SB_SetText("You should not compile this tool with the compiled Skey-Deploy.exe executable")
			}
		if (isSrc <> 1)
			{
				FileMove, %SKELD%\bin\SKey-Deploy.exe, %SKELD%\bin\SKey-Deploy.exe.bak,1
				RunWait, %comspec% /c echo.###################  COMPILE DEPLOYER  ####################### >>"%DEPL%\deploy.log", ,%rntp%
				runwait, %comspec% /c " "%AHKDIR%\Ahk2Exe.exe" /in "%SKELD%\src\Skey-Deploy.ahk" /out "%SKELD%\bin\Skey-Deploy.exe" /icon "%SKELD%\img\Sharp - X1.ico" /bin "%AHKDIR%\Unicode 32-bit.bin" >>"%DEPL%\deploy.log"", %SKELD%,%rntp%
				RunWait, %comspec% /c echo.########################################## >>"%DEPL%\deploy.log", ,%rntp%
			}		
	}				
guicontrol,,progb,15
FileDelete,%SKELD%\*.lpl
FileDelete,%SKELD%\*.tmp
guicontrol,,progb,20
if (PortVer = 1)
	{		
		SB_SetText(" Building portable ")
		COMPLIST= 
		if (PBOV <> 1)
			{
				FileDelete, %DEPL%\%RJPRJCT%D.zip
				RunWait, %comspec% /c echo.##################  CREATE PORTABLE ZIP  ######################## >>"%DEPL%\deploy.log", ,%rntp%	
				Loop,parse,portableincludes,|
					{
						runwait, %comspec% /c " "%BUILDIR%\bin\7za.exe" a -tzip "%DEPL%\portable.zip" "%A_LoopField%" >>"%DEPL%\deploy.log"", %SKELD%,%rntp%					
					}
				RunWait, %comspec% /c echo.########################################## >>"%DEPL%\deploy.log", ,%rntp%	
				sleep, 1000
			}
	}
guicontrol,,progb,35
if (BCANC = 1)
	{
		SB_SetText(" Cancelling Development Build ")
		guicontrol,,progb,0
		gosub, canclbld
		compiling= 
		return
	}	
if (GitPush = 1)
	{
		ifinstring,pushnotes,|
			{
				stringsplit,ebeb,pushnotes,|
				TAGLINE= %ebeb2%				
			}
			else {
				TAGLINE= A unified interface for ROMs, emulators and frontends.
			}
		ifinstring,pushnotes,$
			{
				stringgetpos,verstr,pushnotes,$
				stringgetpos,endstr,pushnotes,.00
				if (ErrorLevel <> "")
					{
						strstr:= verstr + 2
						midstr:= (endstr - verstr - 1)
						stringmid,donation,pushnotes,strstr,midstr
						SB_SetText(" $" donation " found")
					}
			}
		If (PushNotes = "")
			{
				PushNotes= %date% %TimeString%
				Loop, Read, %getversf%
					{
						sklnum+=1
						getvern= 
						ifinstring,A_LoopReadLine,$
							{
								stringgetpos,verstr,A_LoopReadLine,$
								stringgetpos,endstr,A_LoopReadLine,.00
								if (ErrorLevel <> "")
									{			
										strstr:= verstr + 2
										midstr:= (endstr - verstr - 1)
										stringmid,donation,A_LoopReadLine,strstr,midstr
										if (midstr = [PAYPAL])
											{
												donation= 00.00
											}
										if (donation = "[PAYPAL].00")
											{
												donation= 00.00
											}
										SB_SetText(" $" donation " found")
										break
											
									}
							}
								continue
					}
			}
		if (donation = "")
			{
				donation= 00.00				
			}
		FileAppend, mkdir "%GITD%\gam"`n,%DEPL%\!gitupdate.cmd
		FileAppend, mkdir "%GITD%\bin"`n,%DEPL%\!gitupdate.cmd
		FileAppend, mkdir "%GITD%\rj\scrapeArt"`n,%DEPL%\!gitupdate.cmd
		FileAppend, mkdir "%GITD%\rj\ES"`n,%DEPL%\!gitupdate.cmd
		FileAppend, mkdir "%GITD%\rj\PG"`n,%DEPL%\!gitupdate.cmd
		FileAppend, mkdir "%GITD%\rj\RF"`n,%DEPL%\!gitupdate.cmd
		FileAppend, mkdir "%GITD%\rj\emuCfgs"`n,%DEPL%\!gitupdate.cmd
		FileAppend, mkdir "%GITD%\rj\KODI\ADVL"`n,%DEPL%\!gitupdate.cmd
		FileAppend, mkdir "%GITD%\rj\KODI\AEL"`n,%DEPL%\!gitupdate.cmd
		FileAppend, mkdir "%GITD%\rj\KODI\IAGL"`n,%DEPL%\!gitupdate.cmd
		FileAppend, mkdir "%GITD%\rj\KODI\RCB"`n,%DEPL%\!gitupdate.cmd
		FileAppend, mkdir "%GITD%\img"`n,%DEPL%\!gitupdate.cmd
		FileAppend, mkdir "%GITD%\site"`n,%DEPL%\!gitupdate.cmd
		FileAppend, mkdir "%GITD%\src"`n,%DEPL%\!gitupdate.cmd
		FileAppend, del /s /q "%GITD%\rj\netArt\*"`n,%DEPL%\!gitupdate.cmd
		FileAppend, rd /s/q "%GITD%\rj\netArt"`n,%DEPL%\!gitupdate.cmd
		FileAppend, rd /s/q "%GITD%\rj\sysCfgs"`n,%DEPL%\!gitupdate.cmd
		FileAppend, del /q "%GITD%\rj\*.tdb"`n,%DEPL%\!gitupdate.cmd
		FileAppend, del /q "%GITD%\rj\*.tmp"`n,%DEPL%\!gitupdate.cmd
		FileAppend, del /q "%GITD%\rj\*.ini"`n,%DEPL%\!gitupdate.cmd
		FileAppend, del /q "%GITD%\rj\ES\*.zip"`n,%DEPL%\!gitupdate.cmd
		FileAppend, del /q "%GITD%\rj\PG\*.zip"`n,%DEPL%\!gitupdate.cmd
		FileAppend, del /q "%GITD%\rj\RF\*.zip"`n,%DEPL%\!gitupdate.cmd
		FileAppend, del /q "%GITD%\rj\ES\*.cfg"`n,%DEPL%\!gitupdate.cmd
		FileAppend, del /q "%GITD%\rj\PG\*.cfg"`n,%DEPL%\!gitupdate.cmd
		FileAppend, del /q "%GITD%\rj\RF\*.cfg"`n,%DEPL%\!gitupdate.cmd
		FileAppend, del /q "%GITD%\rj\ES\*.txt"`n,%DEPL%\!gitupdate.cmd
		FileAppend, del /q "%GITD%\rj\PG\*.txt"`n,%DEPL%\!gitupdate.cmd
		FileAppend, del /q "%GITD%\rj\RF\*.txt"`n,%DEPL%\!gitupdate.cmd
		FileAppend, del /q "%GITD%\rj\ES\*.ini"`n,%DEPL%\!gitupdate.cmd
		FileAppend, del /q "%GITD%\rj\PG\*.ini"`n,%DEPL%\!gitupdate.cmd
		FileAppend, del /q "%GITD%\rj\RF\*.ini"`n,%DEPL%\!gitupdate.cmd
		FileAppend, robocopy "rj" "%GITD%\rj" /s /e /w:1 /r:1 /xf "*.bak" "*.ini" "*.tdb" "*.tmp" "*.jak" /xd "ES" "RF" "PG" "scrapeArt" "netArt" "syscfgs"`n,%DEPL%\!gitupdate.cmd
		FileAppend, robocopy "img" "%GITD%\img" /s /e /w:1 /r:1`n,%DEPL%\!gitupdate.cmd
		FileAppend, robocopy "rj\emucfgs" "%GITD%\rj\emuCfgs" /s /e /w:1 /r:1`n,%DEPL%\!gitupdate.cmd
		FileAppend, copy /y "site\index.html" "%GITD%\site"`n,%DEPL%\!gitupdate.cmd
		FileAppend, copy /y "src\*.bat" "%GITD%\src"`n,%DEPL%\!gitupdate.cmd
		FileAppend, copy /y "bin\*.txt" "%GITD%\bin"`n,%DEPL%\!gitupdate.cmd
		FileAppend, copy /y "src\*.ahk" "%GITD%\src"`n,%DEPL%\!gitupdate.cmd
		FileAppend, copy /y "rj\KODI\RCB\*.set" "%GITD%\rj\KODI\RCB"`n,%DEPL%\!gitupdate.cmd
		FileAppend, copy /y "rj\KODI\AEL\*.set" "%GITD%\rj\KODI\AEL"`n,%DEPL%\!gitupdate.cmd
		FileAppend, copy /y "rj\KODI\IAGL\*.set" "%GITD%\rj\KODI\IAGL"`n,%DEPL%\!gitupdate.cmd
		FileAppend, copy /y "rj\KODI\AEL\*.set" "%GITD%\rj\KODI\AEL"`n,%DEPL%\!gitupdate.cmd
		FileAppend, copy /y "img\*.ico" "%GITD%\img"`n,%DEPL%\!gitupdate.cmd
		FileAppend, copy /y "img\*.png" "%GITD%\img"`n,%DEPL%\!gitupdate.cmd
		FileAppend, copy /y "ReadMe.md" "%GITD%"`n,%DEPL%\!gitupdate.cmd
		FileAppend, copy /y "site\ReadMe.md" "%GITD%\site"`n,%DEPL%\!gitupdate.cmdvv
		FileAppend, copy /y "site\version.txt" "%GITD%\site"`n,%DEPL%\!gitupdate.cmd
		FileAppend, del /q "%GITD%\%RJPRJCT%.exe"`n,%DEPL%\!gitupdate.cmd
		FileAppend, copy /y "src\*.put" "%GITD%\src"`n,%DEPL%\!gitupdate.cmd
		guicontrol,,progb,65
	}
if (BCANC = 1)
	{
		SB_SetText(" Cancelling Stable Overwrite ")
		guicontrol,,progb,0
		gosub, canclbld
		compiling= 
		return
	}

if (OvrStable = 1)
	{
		SB_SetText(" overwriting stable ")
		if (BUILT <> 1)
			{
				gosub, BUILDING
			}
	}		

guicontrol,,progb,70	
if (BCANC = 1)
	{
		SB_SetText(" Cancelling Server Upload ")
		guicontrol,,progb,0
		gosub, canclbld
		compiling= 
		return
	}		
if (IMGBLD = 1)
	{
		GRARDT= %GITSWEB%/%gituser%/%IMGDATS%/releases/download
		StringReplace,arcorgv,arcorgv,[IMGDATS],%GRARDT%,All	
	}
if (DATBLD = 1)
	{
		ROMDATOADD=
		Loop, files,%BUILDIR%\dats\*,D
			{
				RMDATNM= %A_LoopfileName%
				ROMDATOADD.= A_LoopFileLongPath . "|"
			}
		GRARBV= %GITSWEB%/%gituser%/%ROMDATS%/releases/download
		StringReplace,arcorgv,arcorgv,[DATSRC],%GRARBV%,All
	}
if (REPOBLD = 1)
	{
		REPOPATH=
		Loop, files,%BUILDIR%\gam\*,D
			{
				REPONM= %A_LoopfileName%
				stringreplace,REPONM,REPONM,%A_Space%,_,All
				stringreplace,REPONM,REPONM,-,_,All
				stringreplace,REPONM,REPONM,`,_,All
				stringreplace,REPONM,REPONM,),_,All
				stringreplace,REPONM,REPONM,(,_,All
				stringreplace,REPONM,REPONM,!,_,All
				stringreplace,REPONM,REPONM,[,_,All
				stringreplace,REPONM,REPONM,],_,All
				stringreplace,REPONM,REPONM,;,_,All
				stringreplace,REPONM,REPONM,.,_,All
				stringreplace,REPONM,REPONM,@,_,All
				REPOROOT= % REPONM_%A_Index%
				if (REPOROOT = "")
					{
						REPOROOT= %REPONM%
					}
				iniwrite,%REPOROOT%,%SKELD%\src\arcorg.set,SOURCES,%REPONM%
				stringupper,UPARCNM,REPONM
				iniwrite,%GRARBV%/%UPARCNM%/%A_LoopFileName%.7z,%SKELD%\src\arcorg.set,SOURCES,%REPONM%:SET
			}
	}

if (ServerPush = 0)
	{
		buildnum= 
		sha1:= olsha 
		RDATE:= olrlsdt
		dvms:= olsize
		olnan1= 
		olnan2= 
		olnan3= 
		olnan4= 
		olnan5= 
		stringsplit, olnan,olrlsb,-
		date= %olnan2%-%olnan3%-%olnan4% 
		if (olnan5 <> "")
			{
				buildnum= -%olnan5%
			}
	}
if (ServerPush = 1)
	{
		if (SiteUpdate = 1)
			{		
				SB_SetText(" Updating the website ")
				RDATE= %date% %timestring%
				if (DBOV = 1)
					{
						RDATE= reverted
					}
				if (PBOV = 1)
					{
						RDATE= reverted
					}
				if (SBOV = 1)
					{
						RDATE= reverted
					}
			}
		FileMove, %DEPL%\site\index.html, %DEPL%\index.bak,1
		FileRead,skelhtml,%BUILDIR%\site\index.html
		StringReplace,skelhtml,skelhtml,[CURV],%vernum%,All
		StringReplace,skelhtml,skelhtml,[TAGLINE],%tagline%,All
		FileDelete,%BUILDIR%\insts.sha1
		
		if (OvrStable = 1)
			{				
				ifExist, %DEPL%\%RJPRJCT%-installer.exe
					{
						CrCFLN= %DEPL%\%RJPRJCT%-installer.exe
						gosub, SHA1GET
						if (SBOV = 1)
							{
								ApndSHA= reverted
							}
						if (DBOV = 1)
							{
								ApndSHA= reverted
							}
					}
				ifExist, %DEPL%\%RJPRJCT%-%date%%buildnum%.zip
					{
						FileGetSize,dvlsize,%DEPL%\%RJPRJCT%-%date%%buildnum%.zip, K
						dvps:= dvlsize / 1000
						StringLeft,dvms,dvps,4
						if (DBOV = 1)
							{
								dvms= reverted
							}
						if (SBOV = 1)
							{
								dvms= reverted
							}
					}
				guicontrol,,progb,90
				StringReplace,skelhtml,skelhtml,[RSHA1],%ApndSHA%,All
				StringReplace,skelhtml,skelhtml,[WEBURL],http://%GITUSER%.github.io,All
				StringReplace,skelhtml,skelhtml,[PAYPAL],%donation%
				StringReplace,skelhtml,skelhtml,[GITSRC],%GITSRC%,All
				StringReplace,skelhtml,skelhtml,[REVISION],%GITWEB%/%gituser%/%RJPRJCT%/releases/download/Installer/Installer.zip,All
				StringReplace,skelhtml,skelhtml,[PORTABLE],%GITSWEB%/%gituser%/%RJPRJCT%/releases/download/portable/portable.zip,All						
				StringReplace,skelhtml,skelhtml,[GITUSER],%gituser%,All
				StringReplace,skelhtml,skelhtml,[RELEASEPG],%GITSWEB%/%gituser%/%RJPRJCT%/releases,All
				StringReplace,skelhtml,skelhtml,[ART_ASSETS],%GITSWEB%/%gituser%/%RJPRJCT%/releases/download/ART_ASSETS/ART_ASSETS.7z,All						
				StringReplace,skelhtml,skelhtml,[RDATE],%RDATE%,All
				StringReplace,skelhtml,skelhtml,[RSIZE],%dvms%,All
				StringReplace,skelhtml,skelhtml,[RSIZE2],%dvmg%,All
				StringReplace,skelhtml,skelhtml,[DBSIZE],%DATSZ%,All
				FileDelete,%SITEDIR%\index.html
				ifnotexist, %SITEDIR%
					{
						FileCreateDir,%SITEDIR%
						FileCreateDir,%SITEDIR%\img						
						FileCopy,%SKELD%\site\*,%SITEDIR%\			
						FileCopy,%SKELD%\site\img\*,%SITEDIR%\img
					}
				FileAppend,%skelhtml%,%SITEDIR%\index.html
				RunWait, %comspec% /c echo.##################  GIT UPDATE  ######################## >>"%DEPL%\deploy.log", ,%rntp%
				SB_SetText(" committing changes to git ")
				RunWait, %comspec% /c " "%DEPL%\!gitupdate.cmd" "site-commit" >>"%DEPL%\deploy.log"",%BUILDIR%,%rntp%
				FileAppend, "%PushNotes%`n",%DEPL%\changelog.txt

				SB_SetText(" source changes pushed to master ")				
				StringReplace,PushNotes,PushNotes,",,All
				;"
				FileDelete, %DEPL%\sitecommit.cmd
				FileAppend,pushd "%gitroot%\%GITUSER%.github.io"`n,%DEPL%\sitecommit.cmd
				FileAppend,copy /y "%BUILDIR%\site\Global-Launch-Menu.png" "%gitroot%\%GITUSER%.github.io\%RJPRJCT%"`n,%DEPL%\sitecommit.cmd
				FileAppend,copy /y "%BUILDIR%\site\*.otf" "%gitroot%\%GITUSER%.github.io\%RJPRJCT%"`n,%DEPL%\sitecommit.cmd
				FileAppend,copy /y "%BUILDIR%\site\*.ttf" "%gitroot%\%GITUSER%.github.io\%RJPRJCT%"`n,%DEPL%\sitecommit.cmd
				FileAppend,copy /y "%BUILDIR%\site\key.ico" "%gitroot%\%GITUSER%.github.io\%RJPRJCT%"`n,%DEPL%\sitecommit.cmd
				FileAppend,copy /y "%BUILDIR%\site\img\*.png" "%gitroot%\%GITUSER%.github.io\%RJPRJCT%"`n,%DEPL%\sitecommit.cmd
				FileAppend,copy /y "%BUILDIR%\site\img\*.svg" "%gitroot%\%GITUSER%.github.io\%RJPRJCT%"`n,%DEPL%\sitecommit.cmd
				FileAppend,copy /y "%BUILDIR%\site\tip.png" "%gitroot%\%GITUSER%.github.io\%RJPRJCT%"`n,%DEPL%\sitecommit.cmd
				FileAppend,copy /y "%BUILDIR%\site\ReadMe.md" "%gitroot%\%GITUSER%.github.io\%RJPRJCT%"`n,%DEPL%\sitecommit.cmd
				FileAppend,copy /y "%BUILDIR%\site\version.txt" "%gitroot%\%GITUSER%.github.io\%RJPRJCT%"`n,%DEPL%\sitecommit.cmd

				RunWait, %comspec% /c echo.##################  SITE COMMIT  ######################## >>"%DEPL%\deploy.log", ,%rntp%
				RunWait, %comspec% /c " "%DEPL%\sitecommit.cmd" "site-commit" >>"%DEPL%\deploy.log"",%BUILDIR%,%rntp%
				RunWait, %comspec% /c echo.########################################## >>"%DEPL%\deploy.log", ,%rntp%
				SB_SetText(" Uploading to server ")
			}
		
		FileDelete, %DEPL%\!gitupdate.cmd
		if (GitPush = 1)
			{
				FileDelete,%GITD%\ReadMe.md
				FileAppend,%readme%,%GITD%\ReadMe.md
				FileAppend,pushd "%GITD%"`n,%DEPL%\gpush.cmd
				fileappend,git -C "%GITD%" init`n,%DEPL%\gpush.cmd
				FileAppend,git config --local credential.helper wincred`n,%DEPL%\gpush.cmd
				fileappend,git config --local user.name %GITUSER%`n,%DEPL%\gpush.cmd
				fileappend,git config --local user.email %GITMAIL%`n,%DEPL%\gpush.cmd
				fileappend,gh config set git_protocol https`n,%DEPL%\gpush.cmd
				fileappend,gh auth login -w --scopes repo`,delete_repo`n,%DEPL%\gpush.cmd
				FileAppend,"%gitappdir%\..\mingw64\libexec\git-core\git-credential-manager-core.exe" configure`n,%DEPL%\gpush.cmd
				FileAppend,gh repo create %RJPRJCT% --public --source="%GITD%"`n,%DEPL%\gpush.cmd
				fileappend,git add .`n,%DEPL%\gpush.cmd
				fileappend,git remote add %RJPRJCT% %GITWEB%/%GITUSER%/%RJPRJCT%`n,%DEPL%\gpush.cmd
				FileAppend,git commit -a -m "%PushNotes%"`n,%DEPL%\gpush.cmd
				FileAppend,git push -f --all %RJPRJCT%`n,%DEPL%\gpush.cmd
				fileappend,popd`n,%DEPL%\gpush.cmd
			}
		
		if (SiteUpdate = 1)
			{
				FileDelete,%SITEDIR%\ReadMe.md
				FileAppend,%readme%,%SITEDIR%\ReadMe.md
				FileAppend,pushd "%GITROOT%\%GITUSER%.github.io"`n,%DEPL%\gpush.cmd
				fileappend,git -C "%GITROOT%\%GITUSER%.github.io" init`n,%DEPL%\gpush.cmd
				if (GitPush <> 1)
					{
						FileAppend,git config --local credential.helper wincred`n,%DEPL%\gpush.cmd
						fileappend,git config --local user.name %GITUSER%`n,%DEPL%\gpush.cmd
						fileappend,git config --local user.email %GITMAIL%`n,%DEPL%\gpush.cmd	
						fileappend,gh config set git_protocol https`n,%DEPL%\gpush.cmd
						fileappend,gh auth login -w --scopes repo`,delete_repo`n,%DEPL%\gpush.cmd
						FileAppend,"%gitappdir%\..\mingw64\libexec\git-core\git-credential-manager-core.exe" configure`n,%DEPL%\gpush.cmd					
					}
				FileAppend,gh repo create %GITUSER%.github.io --public --source="%GITROOT%\%GITUSER%.github.io"`n,%DEPL%\gpush.cmd
				FileAppend,git add "%RJPRJCT%"`n,%DEPL%\gpush.cmd
				FileAppend,pushd "%GITROOT%\%GITUSER%.github.io\%RJPRJCT%"`n,%DEPL%\gpush.cmd
				FileAppend,git add .`n,%DEPL%\gpush.cmd
				fileappend,git remote add %GITUSER%.github.io %GITWEB%/%GITUSER%/%GITUSER%.github.io`n,%DEPL%\gpush.cmd		
				FileAppend,git commit -a -m "%PUSHNOTES%"`n,%DEPL%\gpush.cmd
				FileAppend,git push -f --all %GITUSER%.github.io`n,%DEPL%\gpush.cmd
			}
		
		SB_SetText(" Uploading binaries to server ")
		if (PortVer = 1)
			{
				FileAppend,pushd "%GITD%"`n,%DEPL%\gpush.cmd
				FileAppend,gh release delete portable -y`n,%DEPL%\gpush.cmd
				FileAppend,gh release create portable -t "portable" -n "" "%DEPL%\portable.zip"`n,%DEPL%\gpush.cmd
			}

		if (OvrStable = 1)
			{
				FileAppend,pushd "%GITD%"`n,%DEPL%\gpush.cmd
				FileAppend,gh release delete Installer -y`n,%DEPL%\gpush.cmd
				FileAppend,gh release create Installer -t "Installer" -n "" "%DEPL%\%RJPRJCT%.zip"`n`n,%DEPL%\gpush.cmd
			}
		
		guicontrol,,progb,80
		if (GitPush = 1)
			{
				RunWait, %comspec% /c echo.###################  GIT DEPLOYMENT PUSH  ####################### >>"%DEPL%\deploy.log", ,%rntp%
				RunWait, %comspec% /c " "gpush.cmd" >>"%DEPL%\deploy.log"",%DEPL%,
				RunWait, %comspec% /c echo.########################################## >>"%DEPL%\deploy.log", ,%rntp%
			}
	}
	
guicontrol,,progb,15
FileDelete,%SKELD%\*.lpl
FileDelete,%SKELD%\*.tmp
guicontrol,,progb,20
if (IMGBLD = 1)
	{		
		SB_SetText(" Recompiling Image Databases ")
		Loop, %GITD%\rj\scrapeArt\*.7z
			{
				RunWait, %comspec% /c echo.##################  CREATE METADATA  ######################## >>"%DEPL%\deploy.log", ,%rntp%	
				runwait, %comspec% /c " "%BUILDIR%\bin\7za.exe" a -t7z "ART_ASSETS.7z" "%A_LoopFileFullPath%" >>"%DEPL%\deploy.log"",%DEPL%,%rntp%
				RunWait, %comspec% /c echo.########################################## >>"%DEPL%\deploy.log", ,%rntp%	
			}
	}
if (REPOBLD = 1)
	{
		SB_SetText(" Compiling ROM Repo Databases ")
		repolsts= 
		Loop, %BUILDIR%\gam\*,2
			{
				RunWait, %comspec% /c echo.##################  CREATE GAMFILES  ######################## >>"%DEPL%\deploy.log", ,%rntp%
				runwait, %comspec% /c " "%BUILDIR%\bin\7za.exe" a -t7z "%A_LoopFileName%.7z" "%A_LoopFileFullPath%" >>"%DEPL%\deploy.log"",%DEPL%,%rntp%
				RunWait, %comspec% /c echo.########################################## >>"%DEPL%\deploy.log", ,%rntp%
			}	

	}
if (DATBLD = 1)
	{
		SB_SetText(" Compiling ROM Databases ")
		repolsts= 
		Loop,Files %BUILDIR%\dats\*,D
			{
				RunWait, %comspec% /c echo.##################  CREATE ROMDAT ARCHIVES  ######################## >>"%DEPL%\deploy.log", ,%rntp%
				runwait, %comspec% /c " "%BUILDIR%\bin\7za.exe" a -tzip "%A_LoopFileName%.zip" "%A_LoopFileFullPath%" >>"%DEPL%\deploy.log"",%DEPL%,%rntp%
				RunWait, %comspec% /c echo.########################################## >>"%DEPL%\deploy.log", ,%rntp%
			}	
	}
if (PortVer = 1)
	{		
		SB_SetText(" Building portable ")
		COMPLIST= 
		if (PBOV <> 1)
			{
				FileDelete, %DEPL%\%RJPRJCT%.zip
				RunWait, %comspec% /c echo.##################  CREATE PORTABLE ZIP  ######################## >>"%DEPL%\deploy.log", ,%rntp%
				Loop,parse,portableincludes,|
					{
						runwait, %comspec% /c ""%BUILDIR%\bin\7za.exe" a -tzip "%DEPL%\portable.zip" "%A_LoopField%" >>"%DEPL%\deploy.log"", %SKELD%,%rntp%					
					}
				RunWait, %comspec% /c echo.########################################## >>"%DEPL%\deploy.log", ,%rntp%	
				sleep, 1000
			}
	}
guicontrol,,progb,100
SB_SetText(" Complete ")
gosub, canclbld
guicontrol,,progb,0

guicontrol,enable,OvrStable
guicontrol,enable,RESDD
guicontrol,enable,ResB
guicontrol,enable,SrcDD
guicontrol,enable,SelDir
guicontrol,enable,PushNotes
guicontrol,enable,VerNum
guicontrol,enable,GitPush
guicontrol,enable,ServerPush
guicontrol,enable,SiteUpdate
guicontrol,enable,IMGBLD
guicontrol,enable,REPODATS
guicontrol,enable,PortVer
guicontrol,enable,INITINCL
guicontrol,enable,DevlVer
guicontrol,hide,CANCEL
guicontrol,show,COMPILE
guicontrol,,progb,0
compiling= 
return


BUILDING:
BUILT= 1
ifexist, %DEPL%\%RJPRJCT%D.zip
	{
		FileDelete, %DEPL%\%RJPRJCT%D.zip
	}
ifexist, %DEPL%\%RJPRJCT%K.zip
	{
		FileDelete, %DEPL%\%RJPRJCT%K.zip
	}
ifexist, %DEPL%\%RJPRJCT%-installer.exe
	{
		FileDelete, %DEPL%\%RJPRJCT%-installer.exe
	}
ifexist, %DEPL%\Skey-Deploy.nsi
	{
		FileDelete, %DEPL%\Skey-Deploy.nsi
	}

FileRead, nsiv,%BUILDIR%\src\Skey-Deploy.set
StringReplace, nsiv, nsiv,[GIT_USER],%GITUSER%,All
StringReplace, nsiv, nsiv,skeletonkey,%RJPRJCT%,All
StringReplace, nsiv, nsiv,[INSTYP],-installer,All
StringReplace, nsiv, nsiv,[SOURCE],%SKELD%,All
StringReplace, nsiv, nsiv,[BUILD],%BUILDIR%,All
StringReplace, nsiv, nsiv,[DBP],%DEPL%,All
StringReplace, nsiv, nsiv,[CURV],%vernum%,All
FileAppend, %nsiv%, %DEPL%\Skey-Deploy.nsi
SB_SetText("Building Installer")
FileDelete,%DEPL%\%RJPRJCT%-Installer.exe.bak
RunWait, %comspec% /c echo.###################  DEPLOYMENT LOG FOR %date%  ####################### >>"%DEPL%\deploy.log", ,%rntp%
RunWait,"%NSIS%" "%DEPL%\Skey-Deploy.nsi",,hide
;NSITST:= cmdret(nsicommand)
sleep,1500
RunWait, %comspec% /c echo.########################################## >>"%DEPL%\deploy.log", ,%rntp%
CrCFLN= %DEPL%\%RJPRJCT%-installer.exe
BLDERROR= 
rebldchk:
ifnotexist, %DEPL%\%RJPRJCT%-installer.exe
	{
		bldchk+= 1
		if (bldchk < 4)
			{
				sleep, 1500
				goto, rebldchk
			}
		BLDERROR= 1
	}
gosub, SHA1GET
nchash:= ApndSHA
BLDCHKSZ= 0
ifexist, %DEPL%\%RJPRJCT%-installer.exe
	{
		FileGetSize, BLDCHKSZ,%DEPL%\%RJPRJCT%-installer.exe,M
		if BLDCHKSZ < 2
			{
				BLDERROR= 1
			}
	}
if (BLDERROR = 1)
	{
		MsgBox,3,,HALT.,Installer build failed,`nOpenLog?
		ifMsgBox, Yes
			{
				Run,notepad "%DEPL%\deploy.log",,
			}
		ifMsgbox, Cancel
			{
				goto, cancel
			}	
	}
FileDelete, %SKELD%\site\version.txt
FileAppend, %date% %timestring%=%nchash%=%vernum%,%SKELD%\site\version.txt
buildnum= 
buildtnum= 1
Loop, %DEPL%\%RJPRJCT%-%date%*.zip
	{
		buildnum+=1
	}

if (buildnum <> "")
	{
		buildnum= -%buildnum%
	}	

RunWait, %comspec% /c echo.##################  CREATE INSTALLER ######################## >>"%DEPL%\deploy.log", ,%rntp%
RunWait, %comspec% /c " "%BUILDIR%\bin\7za.exe" a "%DEPL%\%RJPRJCT%K.zip" "%DEPL%\%RJPRJCT%-installer.exe" >>"%DEPL%\deploy.log"", %BUILDIR%,%rntp%
RunWait, %comspec% /c echo.########################################## >>"%DEPL%\deploy.log", ,%rntp%
if (DevlVer = 1)
	{
		if (DBOV <> 1)
			{
				FileMove,%DEPL%\%RJPRJCT%K.zip, %DEPL%\%RJPRJCT%.zip,1	
				FileMove,%DEPL%\%RJPRJCT%K.zip, %DEPL%\%RJPRJCT%.zip,1
			}
	}
if (OvrStable = 1)
	{
				if (SBOV <> 1)
					{
						FileCopy,%DEPL%\%RJPRJCT%K.zip, %DEPL%\%RJPRJCT%-%date%%buildnum%.zip,1
						ifExist, %DEPL%\%RJPRJCT%.zip
							{
								FileMove,%DEPL%\%RJPRJCT%.zip, %DEPL%\%RJPRJCT%.zip.bak,1
							}
						FileMove,%DEPL%\%RJPRJCT%K.zip, %DEPL%\%RJPRJCT%.zip,1
					}
	}
return
;};;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;{;;;;;;;;;;;;;;;;;;;  FUNCTIONS  ;;;;;;;;;;;;;;;;;;;;;;;;;;

SETUPTOG:
Loop,Parse,setupguiitems,|
	{
		guicontrol,%SETUPTOG%,%A_LoopField%
	}
return

CANCEL:
gui,submit,nohide
msgbox,8452,Cancel,Are you sure you wish to cancel the deployment?,10
ifmsgbox,Yes
	{
		BCANC= 1
		guicontrol,enable,PushNotes
		guicontrol,enable,VerNum
		guicontrol,enable,GitPush
		guicontrol,enable,ServerPush
		guicontrol,enable,SiteUpdate
		guicontrol,enable,PortVer
		guicontrol,enable,INITINCL
		guicontrol,enable,DevlVer
		guicontrol,enable,RESDD
		guicontrol,enable,ResB
		guicontrol,enable,SrcDD
		guicontrol,enable,SelDir
		guicontrol,hide,CANCEL
		guicontrol,show,COMPILE
		guicontrol,,progb,0
		SB_SetText(" Operation Cancelled ")
		return
	}
return

canclbld:

return

esc::
DEVGUID:= WinActive("_DEV_GUI_")
if (DEVGUID <> 0)
{
	FDME:= 8452
	quitnum+=1
	if (quitnum = 3)
		{
			FDME:= 8196
		}
	if (quitnum > 3)
		{
			goto, QUITOUT
		}
	sleep,250
	if (compiling = 1)
		{
			goto, CANCEL
		}
	msgbox,% FDME,Exiting, Would you like to close the publisher?
	ifmsgbox, yes
		{
			gosub, QUITOUT
		}
	ifmsgbox, no
		{
			DWNCNCL= 
			return
		}
	return
}
Return

SHA1GET:
ApndSHA= % FileSHA1( CrCFLN )
FileSHA1(sFile="", cSz=4) {
 cSz := (cSz<0||cSz>8) ? 2**22 : 2**(18+cSz), VarSetCapacity( Buffer,cSz,0 ) ; 09-Oct-2012
 hFil := DllCall( "CreateFile", Str,sFile,UInt,0x80000000, Int,3,Int,0,Int,3,Int,0,Int,0 )
 IfLess,hFil,1, Return,hFil
 hMod := DllCall( "LoadLibrary", Str,"advapi32.dll" )
 DllCall( "GetFileSizeEx", UInt,hFil, UInt,&Buffer ),    fSz := NumGet( Buffer,0,"Int64" )
 VarSetCapacity( SHA_CTX,136,0 ),  DllCall( "advapi32\A_SHAInit", UInt,&SHA_CTX )
 Loop % ( fSz//cSz + !!Mod( fSz,cSz ) )
   DllCall( "ReadFile", UInt,hFil, UInt,&Buffer, UInt,cSz, UIntP,bytesRead, UInt,0 )
 , DllCall( "advapi32\A_SHAUpdate", UInt,&SHA_CTX, UInt,&Buffer, UInt,bytesRead )
 DllCall( "advapi32\A_SHAFinal", UInt,&SHA_CTX, UInt,&SHA_CTX + 116 )
 DllCall( "CloseHandle", UInt,hFil )
 Loop % StrLen( Hex:="123456789ABCDEF0" ) + 4
  N := NumGet( SHA_CTX,115+A_Index,"Char"), SHA1 .= SubStr(Hex,N>>4,1) SubStr(Hex,N&15,1)
Return SHA1, DllCall( "FreeLibrary", UInt,hMod )
}
StringLower,ApndSHA,ApndSHA
return

QUITOUT:
WinGet, PEFV,PID,_DEV_GUI_
Process, close, %PEFV%
GuiEscape:
GuiClose:
ExitApp
DownloadFile(UrlToFile, _SaveFileAs, Overwrite := True, UseProgressBar := True) {
		FinalSize= 
	
      If (!Overwrite && FileExist(_SaveFileAs))
		  {
			FileSelectFile, _SaveFileAs,S, %_SaveFileAs%
			if !_SaveFileAs 
			  return
		  }

      If (UseProgressBar) {
          
            SaveFileAs := _SaveFileAs
          
            try WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
			catch {
			}
          
            try WebRequest.Open("HEAD", UrlToFile)
            catch {
			}
			try WebRequest.Send()
			catch {
			}
          
			try FinalSize := WebRequest.GetResponseHeader("Content-Length") 
			catch {
				FinalSize := 1
			}
			SetTimer, DownloadFileFunction_UpdateProgressBar, 100
		
 
      }
    
      UrlDownloadToFile, %UrlToFile%, %_SaveFileAs%
    
      If (UseProgressBar) {
          Progress, Off
          SetTimer, DownloadFileFunction_UpdateProgressBar, Off
      }
      return

      DownloadFileFunction_UpdateProgressBar:
    
      try CurrentSize := FileOpen(_SaveFileAs, "r").Length 
	  catch {
			}
			
      try CurrentSizeTick := A_TickCount
    catch {
			}
			
      try Speed := Round((CurrentSize/1024-LastSize/1024)/((CurrentSizeTick-LastSizeTick)/1000)) . " Kb/s"
	  catch {
			}
    
      LastSizeTick := CurrentSizeTick
      try LastSize := FileOpen(_SaveFileAs, "r").Length
    catch {
			}
	
      try PercentDone := Round(CurrentSize/FinalSize*100)
    catch {
			}
			
	 if (PercentDone > 100)
		{
			PercentDone= 
		}
	 SB_SetText(" " Speed " " updtmsg " at " . PercentDone . `% " " CurrentSize " bytes completed")
	Guicontrol, ,progb, %PercentDone%
      return
  }
Guicontrol, ,progb, 0
return

exe_get($ARIA = "", $URL = "", $TARGET = "", $FNM = "", $SAG = "", $CACHESTAT = "")
	{
		Global $exeg_pid
		StringReplace, $URL, $URL, "&", "^&", All
		$CMD = "%$ARIA%" --always-resume=false --http-no-cache=true --allow-overwrite=true --stop-with-process=%$SAG% --check-certificate=false --truncate-console-readout=false --dir="%$TARGET%" --out="%$FNM%" "%$URL%" 1>"%$CACHESTAT%\%$FNM%.status" 2>&1
		Run, %comspec% /c "%$CMD%",,hide,$exeg_pid
		Process, Exist, %$exeg_pid%
		$lastline = 
		while ErrorLevel != 0
			{
				Loop Read, %$CACHESTAT%\%$FNM%.status
					{
						L = %A_LoopReadLine%						
						if ( InStr(L, `%) != 0 )
							{
								StringSplit, DownloadInfo, L, (`%,
								StringLeft, L1, DownloadInfo2, 3								
								if ( L1 = "100" )
									{
										Guicontrol, ,utlPRGA, 0
										Guicontrol, ,ARCDPRGRS, 0
										Guicontrol, ,DWNPRGRS, 0
										Guicontrol, ,FEPRGA, 0
										Break
									}
							}
						if ( InStr(L, `%) = 0 )
							{	
								L = 0
							}
					}
				if ( L1 is digit )
				Guicontrol, ,utlPRGA, %L1%
				Guicontrol, ,ARCDPRGRS, %L1%
				Guicontrol, ,DWNPRGRS, %L1%
				Guicontrol, ,FEPRGA, %L1%
				Process, Exist, %$exeg_pid%
				Sleep, 50
			}
		sleep 200
		FileGetSize, d_size, %$TARGET%\%$FNM%
		if d_size > 0
			{
				FileDelete, %$CACHESTAT%\%$FNM%.status
				Return true
			}
		else
			{
				MsgBox,0,Error, There was a problem accessing the server.`nCheck status file for details.
				FileDelete, %$CACHESTAT%\%$FNM%.status
				Return false
			}
	}
return

CmdRet(sCmd, callBackFuncObj := "", encoding := ""){
   static HANDLE_FLAG_INHERIT := 0x00000001, flags := HANDLE_FLAG_INHERIT
		, STARTF_USESTDHANDLES := 0x100, CREATE_NO_WINDOW := 0x08000000
		
   (encoding = "" && encoding := "cp" . DllCall("GetOEMCP", "UInt"))
   DllCall("CreatePipe", "PtrP", hPipeRead, "PtrP", hPipeWrite, "Ptr", 0, "UInt", 0)
   DllCall("SetHandleInformation", "Ptr", hPipeWrite, "UInt", flags, "UInt", HANDLE_FLAG_INHERIT)
   
   VarSetCapacity(STARTUPINFO , siSize :=    A_PtrSize*4 + 4*8 + A_PtrSize*5, 0)
   NumPut(siSize              , STARTUPINFO)
   NumPut(STARTF_USESTDHANDLES, STARTUPINFO, A_PtrSize*4 + 4*7)
   NumPut(hPipeWrite          , STARTUPINFO, A_PtrSize*4 + 4*8 + A_PtrSize*3)
   NumPut(hPipeWrite          , STARTUPINFO, A_PtrSize*4 + 4*8 + A_PtrSize*4)
   
   VarSetCapacity(PROCESS_INFORMATION, A_PtrSize*2 + 4*2, 0)

   if !DllCall("CreateProcess", "Ptr", 0, "Str", sCmd, "Ptr", 0, "Ptr", 0, "UInt", true, "UInt", CREATE_NO_WINDOW
							  , "Ptr", 0, "Ptr", 0, "Ptr", &STARTUPINFO, "Ptr", &PROCESS_INFORMATION)
   {
	  DllCall("CloseHandle", "Ptr", hPipeRead)
	  DllCall("CloseHandle", "Ptr", hPipeWrite)
	  throw "CreateProcess is failed"
   }
   DllCall("CloseHandle", "Ptr", hPipeWrite)
   VarSetCapacity(sTemp, 4096), nSize := 0
   while DllCall("ReadFile", "Ptr", hPipeRead, "Ptr", &sTemp, "UInt", 4096, "UIntP", nSize, "UInt", 0) {
	  sOutput .= stdOut := StrGet(&sTemp, nSize, encoding)
	  ( callBackFuncObj && callBackFuncObj.Call(stdOut) )
   }
   DllCall("CloseHandle", "Ptr", NumGet(PROCESS_INFORMATION))
   DllCall("CloseHandle", "Ptr", NumGet(PROCESS_INFORMATION, A_PtrSize))
   DllCall("CloseHandle", "Ptr", hPipeRead)
   Return sOutput
}

WM_MOUSEMOVE(){
	static CurrControl, PrevControl, _TT
	CurrControl := A_GuiControl
	If (CurrControl <> PrevControl)
		{
			SetTimer, DisplayToolTip, -300
			PrevControl := CurrControl
		}
	return

	DisplayToolTip:
	try
			ToolTip % %CurrControl%_TT
	catch
			ToolTip
	SetTimer, RemoveToolTip, -2000
	return

	RemoveToolTip:
	ToolTip
	return
}
;};;;;;;;;;;;;;


;};;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
