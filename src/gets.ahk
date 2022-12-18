met_get($ARIA = "", $URL = "", $TARGET = "", $FNM = "", $SAG = "", $CACHESTAT = "", $METRANGE = "", $TORRANGE = "", $TORINDEX = "")
	{
		Global $exeg_pid
		StringReplace, $URL, $URL, "&", "^&", All
		torv=
		torx= 1
		EINX= --index-out=1="%$FNM%"
		ifinstring,$TORINDEX,|
			{
				torx= 
				EINX= 
				Loop,Parse,$TORINDEX,|
					{
						if (torx <> "")
							{
								torx.= ","
							}
						torv= %A_LoopField%
						Loop,parse,$FNM,|
							{
								EINX.= "--index-out=" . torv . "=" . "" .  A_LoopField . "" . A_Space
							}
						torx.= A_LoopField	
					}
			}
		TRINC= --select-file=%torx%
		$CMD = "%$ARIA%" -V --seed-time=0.0 --bt-stop-timeout=30 --check-certificate=false --bt-remove-unselected-file=true --dht-listen-port=%$METRANGE% --listen-port=%$TORRANGE% --dir="%$TARGET%" %TRINC% %EINX% --bt-save-metadata=true --stop-with-process=%$SAG% --truncate-console-readout=false %$URL% 1>"%$CACHESTAT%\torrent.status" 2>&1
		Run, %comspec% /c "%$CMD%",,hide,$exeg_pid
		Process, Exist, %$exeg_pid%
		$lastline = 
		torcplt= 
		while ErrorLevel != 0
			{
				Loop Read, %$CACHESTAT%\torrent.status
					{
						L = %A_LoopReadLine%						
						if ( InStr(L, `%) != 0 )
							{
								StringSplit, DownloadInfo, L, (`%,
								StringLeft, L1, DownloadInfo2, 3
								stringsplit,tosb,DownloadInfo1,/%A_Space%
								stringsplit,spr,DownloadInfo3,%A_Space%:,]
								SB_SetText("" spr5 "ps " tosb2 "/" tosb3 " [" spr7 "]")
								if ( L1 = "100" )
									{
										Guicontrol, ,utlPRGA, 0
										Guicontrol, ,ARCDPRGRS, 0
										Guicontrol, ,DWNPRGRS, 0
										Guicontrol, ,FEPRGA, 0
										torcplt= 1
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
		process, exist, %$exeg_pid%
		torproc= %ERRORLEVEL%
		if (torcplt = 1)
			{
				return
			}
		if ((torcplt = "")&&(torproc = 0))
			{
				FileDelete, %$CACHESTAT%\torrent.status
				Return true
			}
		else
			{
				sevbr= 
				MsgBox,0,Error, There was a problem accessing the server.`nCheck status file for details.,3
				torfail= 1
				FileDelete, %$CACHESTAT%\torrent.status
				Return false
			}
	}
exe_get($ARIA = "", $URL = "", $TARGET = "", $FNM = "", $SAG = "", $CACHESTAT = "")
	{
		Global $exeg_pid
		StringReplace, $URL, $URL, "&", "^&", All
		$CMD = "%$ARIA%" -x16 -s16 -j16 -k1M --always-resume=true --enable-http-pipelining=true --retry-wait=3 --http-no-cache=false --http-accept-gzip=true --allow-overwrite=true --stop-with-process=%$SAG% --truncate-console-readout=false --check-certificate=false --dir="%$TARGET%" --out="%$FNM%" "%$URL%" 1>"%$CACHESTAT%\%$FNM%.status" 2>&1
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
								stringsplit,tosb,DownloadInfo1,/%A_Space%
								stringsplit,spr,DownloadInfo3,%A_Space%:,]
								SB_SetText("" spr5 "ps " tosb2 "/" tosb3 " [" spr7 "]")
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
				SB_SetText(" " FNM ".status being deleted")
				if ((batchdl = 1)or(LOGGING = 1))
					{
						FileRead,statdel,%$CACHESTAT%\%$FNM%.status
						;;fileappend,%statdel%,%$CACHESTAT%\%$FNM%.log
						fileappend,%statdel%,%$FNM%.log
						statdel= 					
					}
					else {
						FileDelete, %$CACHESTAT%\%$FNM%.status
					}
				Return false
			}
	}
exen_get($ARIA = "", $URL = "", $TARGET = "", $FNM = "", $SAG = "", $CACHESTAT = "")
	{
		Global $exeg_pid
		StringReplace, $URL, $URL, "&", "^&", All
		;;$CMD = "%$ARIA%" --always-resume=false --http-no-cache=true --allow-overwrite=true --stop-with-process=%$SAG% --truncate-console-readout=false --check-certificate=false --dir="%$TARGET%" --out="%$FNM%" "%$URL%" 1>"%$CACHESTAT%\%$FNM%.status" 2>&1
		$CMD = "%$ARIA%" -i uri.txt 1>"%$CACHESTAT%\%$FNM%.status" 2>&1
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
								stringsplit,tosb,DownloadInfo1,/%A_Space%
								stringsplit,spr,DownloadInfo3,%A_Space%:,]
								SB_SetText("" spr5 "ps " tosb2 "/" tosb3 " [" spr7 "]")
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
				FileDelete, uri.txt
				Return true
			}
		else
			{
				SB_SetText(" " FNM ".status being deleted")
				FileRead,statdel,%$CACHESTAT%\%$FNM%.status
				;;fileappend,%statdel%,%$CACHESTAT%\%$FNM%.log
				fileappend,%statdel%,%$FNM%.log
				statdel=				
				FileDelete, %$CACHESTAT%\%$FNM%.status
				FileDelete, uri.txt
				Return false
			}
	}
DownloadFile(UrlToFile, _SaveFileAs, Overwrite := True, UseProgressBar := True)
	{
		FinalSize=
		guicontrol,,CLRNETP,x
		If (!Overwrite && FileExist(_SaveFileAs))
		  {
			FileSelectFile, _SaveFileAs,S, %_SaveFileAs%
			if !_SaveFileAs
			  return
		  }
		If (UseProgressBar)
			{
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
		If (UseProgressBar)
			{
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
		Guicontrol, ,utlPRGA, %PercentDone%
		Guicontrol, ,ARCDPRGRS, %PercentDone%
		Guicontrol, ,DWNPRGRS, %PercentDone%
		Guicontrol, ,FEPRGA, %PercentDone%
		return
	}