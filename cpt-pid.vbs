Set WshShell = WScript.CreateObject("WScript.Shell")
Set logwrite=CreateObject("Scripting.FileSystemObject").OpenTextFile("D:\code-fun\CPT\log.txt",2,true)
for x= 1 to 2
logwrite.WriteLine("--------****---------")
Next
logwrite.Close
Set Processes = GetObject("winmgmts:\\.\root\CIMV2")
cmdopen = True
cmd = "CPT_batch.exe"
WshShell.Run(cmd)
WScript.Sleep 1000
WshShell.AppActivate(cmd)

'FORMATTED OUTPUT
msg=131
For i = 1 To Len(msg)
		'WshShell.AppActivate Process.ProcessId
		WshShell.SendKeys Mid(Msg, i, 1)
Next
WshShell.SendKeys "{ENTER}"
msg=2
For i = 1 To Len(msg)
		'WshShell.AppActivate Process.ProcessId
		WshShell.SendKeys Mid(Msg, i, 1)
Next
WshShell.SendKeys "{ENTER}"

Public x_Path
Public ye_out
Public xe_out
Public err_file
Public pid
Public pidfound
Public exec_comp
Public n_bound, s_bound, w_bound, e_bound
y_Path = "D:\code-fun\CPT\Y_FILE\NEM_YFILE.tsv"
x_folder ="D:\code-fun\CPT\NEM"
dim sstbound(11,3) 
sstbound(0,0)=0 : sstbound(0,1)=-10 : sstbound(0,2)= 270 : sstbound(0,3)=280 : sstbound(1,0)=6 : sstbound(1,1)=-6  : sstbound(1,2)=210 : sstbound(1,3)=270 : sstbound(2,0)=6 : sstbound(2,1)=-6 : sstbound(2,2)=190 : sstbound(2,3)=240 : sstbound(3,0)=6
sstbound(3,1)=-6 : sstbound(3,2)=160 : sstbound(3,3)=210 : sstbound(4,0)=26 : sstbound(4,1) =8 : sstbound(4,2) =80 : sstbound(4,3) =96 : sstbound(5,0) =26 : sstbound(5,1) =8 : sstbound(5,2) =40 : sstbound(5,3) =76 : sstbound(6,0) =-10 : sstbound(6,1) =-20 
sstbound(6,2) =100 : sstbound(6,3) =120 : sstbound(7,0) =10 : sstbound(7,1) =-10 : sstbound(7,2) =50 : sstbound(7,3) =70 : sstbound(8,0) =0 : sstbound(8,1) =-10 : sstbound(8,2) =90 : sstbound(8,3) =110 : sstbound(9,0) = 27 : sstbound(9,1) = -43 : sstbound(9,2) = 37
sstbound(9,3) = 115 : sstbound(10,0) = 46 : sstbound(10,1) = -46 : sstbound(10,2) = 119 : sstbound(10,3) = 282 : sstbound(11,0) = 27 : sstbound(11,1) = -45 : sstbound(11,2) = 30 : sstbound(11,3) = 293

dim ybound(3)
ybound(0)=14 : ybound(1)=8 : ybound(2)=76 : ybound(3)=81

dim chirpsbound(3)
chirpsbound(0) = 14 : chirpsbound(1) = 8 : chirpsbound(2) = 76: chirpsbound(3) = 81 
xminmode = 1 : xmaxmode = 13 : yminmode = 1 : ymaxmode = 13 : ccaminmode = 1 : ccamaxmode = 13

dim p1bound(3) : dim p2bound(3) : dim p3bound(3)
p1bound(0) = 45 : p1bound(1) = -45 :  p1bound(2) = 40 :  p1bound(3) = 120 
p2bound(0) = 45 : p2bound(1) = -45 :  p2bound(2) = 0 :  p2bound(3) = 290 
p3bound(0) = 90 : p3bound(1) = -90 :  p3bound(2) = 0 :  p3bound(3) = 360

Set objFSO = Createobject("Scripting.FileSystemObject")
Set oFolder = objFSO.GetFolder(x_folder)

Set logAppend = CreateObject("Scripting.FileSystemObject").OpenTextFile("D:\code-fun\CPT\log.txt",8,true)
pidfound =false
ShowSubfolders oFolder
logAppend.Close
WScript.Echo "finished"

Sub ShowSubFolders(Folder)
    For Each Subfolder in Folder.SubFolders
        Set objFolder = objFSO.GetFolder(Subfolder.Path)
        Set colFiles = objFolder.Files
		 For Each oFile in colFiles
			
			if (objFSO.GetExtensionName(oFile.Name)) =  "tsv" then
			'logAppend.Writeline(oFile)
				x_file=oFile.Name
				x_Path=oFile.Path
				o_Path = pathOfFile(x_Path)
				o_file = left(x_file,Len(x_file)-4)
				'WshShell.popup   x_Path & "  :  "& x_file & " : " & o_Path &"  :  " & o_file, 20
				if InStr(o_Path,"SST") > 0 Then
				o_filenum = CInt(o_file) - 1
				End if
				err_file=x_Path
				if Not objFSO.FolderExists(o_Path & "out") Then
					objFSO.CreateFolder(o_Path & "out")
				end if
			
				if InStr(o_Path,"SST") > 0 Then
					n_bound = sstbound(o_filenum,0) : s_bound = sstbound(o_filenum,1) :	w_bound = sstbound(o_filenum,2) : e_bound = sstbound(o_filenum,3)
				Elseif InStr(o_Path,"P1") > 0 Then
					n_bound = p1bound(0) : s_bound = p1bound(1) : w_bound = p1bound(2) : e_bound = p1bound(3)
				Elseif InStr(o_Path,"P2") > 0 Then
					n_bound = p2bound(0) : s_bound = p2bound(1) : w_bound = p2bound(2) : e_bound = p2bound(3)
				Elseif InStr(o_Path,"P3") > 0 Then
					n_bound = p3bound(0) : s_bound = p3bound(1) : w_bound = p3bound(2) : e_bound = p3bound(3)
				Elseif InStr(x_Path,"CHIRPS") > 0 Then
					n_bound = chirpsbound(0) : s_bound = chirpsbound(1) : w_bound = chirpsbound(2) : e_bound = chirpsbound(3)
				Elseif InStr(x_Path,"precip") > 0 Then
					n_bound = 14 : s_bound = 8 : w_bound = 76 : e_bound = 81
				Else 
					n_bound = "" : s_bound = "" : w_bound = "" : e_bound = ""
				End if
				ye_out = o_Path & "out\ye_"& o_file & ".txt"
				xe_out = o_Path & "out\xe_"& o_file & ".txt"
				Set colItems = Processes.ExecQuery("SELECT * from Win32_Process WHERE Name = '" & cmd & "'")
				wc=colItems.Count - 1
				pid = colItems.ItemIndex(wc).Processid
				if colItems.Count > 10 Then
				WScript.Sleep 100000
				End if
				'Wscript.echo(pid)
				if Not (objFSO.FileExists(ye_out) And objFSO.FileExists(xe_out)) Then 'or InStr(x_Path,"JULYAUGUSTSEPTEMBER") > 0) Then
				'WshShell.popup   x_Path & "  :  "& x_file & " : " & o_Path &"  :  " & o_file, 20
				Execute_cpt
				if Not exec_comp Then
				logAppend.Writeline(err_file)
				End if
				enter_cpt
				Else
				logAppend.Writeline("Done," & err_file)
				End If
			End if
			
	Next
        ShowSubFolders Subfolder
    Next
End Sub

Function pathOfFile(fileName) 
    posn = InStrRev(fileName, "\")
    If posn > 0 Then
        pathOfFile = Left(filename, posn)
    Else
        pathOfFile = ""
    End If
End Function


Function sendkey(Msg)
	Set colItems = Processes.ExecQuery("SELECT * from Win32_Process WHERE Name = '" & cmd & "'")
	for i=0 to colItems.Count-1
		if colItems.ItemIndex(i).Processid = pid Then
			pidfound=True 
			Exit for
		Else 
			pidfound=false
		End if
	Next
	If colItems.Count = 0 Then
				'WScript.Echo "Process not found : " & x_Path
				'Wscript.Quit
				logAppend.Writeline(err_file)
				err_file=""
				cmdopen =  False
	End If
	if Not pidfound Then
		logAppend.Writeline(err_file)
		err_file=""
		cmdopen = False
	End if
		For each process in colItems
			'Wscript.echo(Process.ProcessId)
			if Process.ProcessId = pid Then
				For i = 1 To Len(Msg)
					WshShell.AppActivate Process.ProcessId
					WshShell.SendKeys Mid(Msg, i, 1)
			Next
			'WScript.Sleep 1
			End if
			Next
End Function

Function Sendenter
	Set colItems = Processes.ExecQuery("SELECT * from Win32_Process WHERE Name = '" & cmd & "'")
	For each process in colItems
	if Process.ProcessId = pid Then
	WshShell.AppActivate process.ProcessId
	WshShell.SendKeys "{ENTER}"
	WScript.Sleep 100
	End If
	Next
End function

Function Execute_cpt
	if Not cmdopen Then
	cmdopen = True
	exec_comp=False
	Exit function
	End if	

	'CCA
	sendkey(611)
	Sendenter

	'X-file
	sendkey(1)
	Sendenter
	WScript.Sleep 100

	sendkey(x_Path)
	Sendenter
	WScript.Sleep 100
	
	'WshShell.popup x_Path, 5
	
	if InStr(x_Path,"NINO") = 0 Then
	if ((InStr(x_Path,"WIND") > 0) and (InStr(x_Path,"850-500-250"))) Then
		repeat = 6
	elseif InStr(x_Path,"WIND") > 0 Then
		repeat = 2
	elseif InStr(x_Path,"850-500-250") > 0 Then 
		repeat = 3
	else
		repeat = 1
	End if
	for x = 1 to repeat
		sendkey(n_bound)
		Sendenter

		sendkey(s_bound)
		Sendenter

		sendkey(w_bound)
		Sendenter

		sendkey(e_bound)
		Sendenter
	Next
		sendkey(xminmode)
		Sendenter

		sendkey(xmaxmode)
		Sendenter
	End if
	
	WScript.Sleep 200

	if Not cmdopen Then
	cmdopen = True
	exec_comp=False
	Exit function
	End if

	'y File
	sendkey(2)
	Sendenter

	sendkey(y_Path)
	Sendenter

	sendkey(ybound(0))
	Sendenter

	sendkey(ybound(1))
	Sendenter

	sendkey(ybound(2))
	Sendenter

	sendkey(ybound(3))
	Sendenter

	sendkey(yminmode)
	Sendenter

	sendkey(ymaxmode)
	Sendenter

	if Not cmdopen Then
	cmdopen = True
	exec_comp=False
	Exit function
	End if
	'caa modes
	if InStr(x_Path,"NINO") = 0 Then
	sendkey(ccaminmode)
	Sendenter

	sendkey(ccamaxmode)
	Sendenter
	End if

	if Not cmdopen Then
	cmdopen = True
	exec_comp=False
	Exit function
	End if
	'climatalogical period
	sendkey(532)
	Sendenter

	sendkey(1981)
	Sendenter

	sendkey(2020)
	Sendenter 
	WScript.Sleep 100

	sendkey("Y")
	Sendenter
	WScript.Sleep 200
	
	sendkey(554)
	Sendenter
	WScript.Sleep 20
	sendkey(2)
	Sendenter
	

	sendkey(541)
	Sendenter

	sendkey(311)
	Sendenter
	if Not cmdopen Then
	exec_comp=False
	Exit function
	End if
	if InStr(x_Path,"NINO") = 0 Then
	WScript.Sleep 7000
	Else
	WScript.Sleep 1000
	End IF
	'output


	sendkey(111)
	Sendenter

	sendkey(301)
	Sendenter

	sendkey(xe_out)
	Sendenter
    
	WScript.Sleep 500
	sendkey(311)
	Sendenter
	

	sendkey(ye_out)
	Sendenter

	sendkey(0)
	Sendenter
	'WshShell.SendKeys "{ENTER}"

	sendkey(0)
	Sendenter
	exec_comp=True

End Function

Function enter_cpt
	cmd = "CPT_batch.exe"
	WshShell.Run cmd
	WScript.Sleep 100
	'WshShell.AppActivate cmd
end function