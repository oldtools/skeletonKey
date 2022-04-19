#NoEnv
#SingleInstance Force
#Persistent
SetBatchLines -1

home= %A_ScriptDir%
Splitpath,A_ScriptDir,tstidir,tstipth
if ((tstidir = "src")or(tstidir = "bin")or(tstidir = "binaries"))
	{
		home= %tstipth%
	}
source= %home%\src
binhome= %home%\bin
SetWorkingDir, %home%
skelupdf= %1%
iniread,cacheloc,%home%\Settings.ini,GLOBAL,temp_location
inapp= 
if (skelupdf <> "")
	{
		inapp= 1
		goto, skelupdf
	}
FileDelete,%cacheloc%\version.txt
ARCORG= %source%\Arcorg.set
ifexist, %home%\Arcorg.ini
	{
		ARCORG= %home%\Arcorg.ini
	}
IniRead,sourceHost,%ARCORG%,GLOBAL,SOURCEHOST
IniRead,UPDATEFILE,%ARCORG%,GLOBAL,UPDATEFILE
IniRead,RELEASE,%ARCORG%,GLOBAL,VERSION
getVer:
URLDownloadToFile, %sourceHost%,%cacheloc%\version.txt
ifnotexist, version.txt
	{
		MsgBox,4,Not Found,Update Versioning File not found.`nRetry?
		ifMsgBox, Yes
			{
				goto, getVer
			}
		return
	}
FileReadLine,DATECHK,%cacheloc%\version.txt,1
stringsplit,VERCHKC,DATECHK,=
if (VERCHKC1 <> RELEASE)
	{
		msgbox,4,Update, Update available`n%VERCHKC1%`nWould you like to update [RJ_PROJ]?
		IfMsgBox, yes
			{
				gosub, getupdate
				guicontrol,enable,UpdateSK
				return
			}
		ifmsgbox, no
			{
				exitapp
				return
			}
	}
return

getupdate:
upcnt=
loop, %cacheloc%\[RJ_PROJ]*.zip
	{
		upcnt+=1
	}
URLFILE= %UPDATEFILE%
save= %cacheloc%\[RJ_PROJ]%upcnt%.zip
DownloadFile(URLFILE, save, True, True)
ifexist,%save%
	{
		Process, close, Skey-Deploy.exe
		Process, close, [RJ_PROJ].exe
		Runwait, %comspec% cmd /c "%binhome%\7za.exe x -y "%save%" -O"`%CD`%" ",,hide
		if (ERRORLEVEL <> 0)
			{
				MsgBox,3,Update Failed,Update not found.`n    Retry?
				ifMsgBox, Yes
					{
						goto, getupdate
					}
				exitapp
			}
		Run, [RJ_PROJ].exe
		exitapp
	}
	else {
		MsgBox,3,Update Failed,Update not found.`nRetry?
		ifMsgBox, Yes
			{
				goto, getupdate
			}
		exitapp
	}
return

skelupdf:
TrayTip, Update, Extracting Update.`n[RJ_PROJ] will restart,999,48
Runwait, %comspec% /c "%binhome%\7za.exe" x -y "%skelupdf%" -O"`%CD`%",,hide
if (ERRORLEVEL <> 0)
	{
		MsgBox,,ERROR,Update Failed,3
	}
if (inapp = 1)
	{
		Run, [RJ_PROJ].exe
	}	
exitapp

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
			PercentDone= 0
		}
	progress, %PercentDone%
		return
	}
progress, off
exitapp
return