' StoreCommandResultsInTheClipboard.vbs
'
' Description:
'    - Determines what the shell prompt is.
'    - Enters a loop, continuously setting the Windows Clipboard to the
'      text of each command entered on the remote system.
'    - To stop the script, choose "Cancel" from SecureCRT's main Script menu.
'
' Supported Arguments (change script's behavior to match your preferences):
'    /CaptureStartingEOL:True|False     If specified as True, the leading
'                                       line ending character sequence is
'                                       captured and included in the clipboard
'                                       as part of the output of the command.
'                                       If not specified, or set to False, the
'                                       leading EOL character sequence is
'                                       OMITTED from the output that is stored
'                                       in the clipboard.
'
'    /CaptureTrailingEOL:True|False     If specified as True, the trailing
'                                       EOL character sequence is captured and
'                                       included in the clipboard as part of the
'                                       output of the command.
'                                       If not specified, or set to False, the
'                                       trailing EOL character sequence is
'                                       OMITTED from the output that is stored
'                                       in the clipboard.
'                                       
'    /CaptureOnlyCmdOutput: True|False  If specified as True (default), only the
'                                       command output will be copied to the
'                                       Clipboard. If specified as False, both
'                                       the command issued and the results are
'                                       copied to the Clipboard.
'                                       
'        /WriteToFile:PathToOutputFile  If this option is present, the script
'                                       will write the results to the file
'                                       specified in the PathToOutputFile
'                                       value.
'
' Try not to miss any data
crt.Screen.Synchronous = True
' Also, don't capture escape sequences
crt.Screen.IgnoreEscape = True

g_bCaptureStartingEOL = True
g_bCaptureTrailingEOL = True
g_bCopyOnlyCmdResults = False
g_strOutputFile = ""
    
SetBoolArgValueIfPresent "CaptureStartingEOL", g_bCaptureStartingEOL
SetBoolArgValueIfPresent "CaptureTrailingEOL", g_bCaptureTrailingEOL
SetBoolArgValueIfPresent "CopyOnlyCmdResults", g_bCopyOnlyCmdResults
SetStringArgValueIfPresent "WriteToFile", g_strOutputFile

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Sub Main()
    If Not crt.Session.Connected Then
        crt.Dialog.MessageBox _
            "This script requires an active connection to a remote machine."
        Exit Sub
    End If
    
    strPrompt = GetShellPrompt
    
    ' Determine what the shell prompt is...
    If crt.Dialog.MessageBox( _
        "Until you cancel this script (or until disconnected), the text " & _
        "results of each command will be automatically copied to the " & _
        "Clipboard." & _
        vbcrlf & vbcrlf & _
        "Your shell prompt was detected as being: """ & strPrompt & """" & _
        vbcrlf & vbcrlf & _
        "Note: if your prompt includes dynamic information (such as your " & _
        "current working directory) that is regularly updated with " & _
        "certain commands, this script will continue to capture data " & _
        "until either the original prompt appears or until the session " & _
        "is disconnected.", _
        "SecureCRT Script: Clipboard Command Result Storage Activated", _
        vbOkCancel) <> vbOk Then Exit Sub

    strCmdResults = ""
    ' Now that we know what the prompt is, and the user has pressed OK,
    ' we'll loop waiting for the prompt to appear.
    Do
        If g_bCopyOnlyCmdResults Then
            If WaitForACommandToBeSent <> True Then Exit Do
        End If
        
        ' Let's use a wrapper function to call ReadString()
        ' to capture everything that we receive from the
        ' remote machine between each occurrence of the
        ' shell prompt.  The reason for the wrapper is to be
        ' able to gracefully handle a potential case where the
        ' connection might go away while we're waiting.
        If Not CaptureCommandResults(strPrompt, strCmdResults) Then Exit Do
        
        ' Now store the rectified data into the Windows Clipboard...
        crt.Clipboard.Text = strCmdResults
        If g_strOutputFile <> "" Then WriteToFile(strCmdResults)
    Loop
    
    crt.Session.SetStatusText "Script Ended."
    crt.Sleep 350
    crt.Session.SetStatusText "Ready"
End Sub

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Function WaitForACommandToBeSent()
    crt.Session.SetStatusText "Waiting for a command to be sent..."
    
    strWhatToWaitFor = vbcrlf
    
    On Error Resume Next
        crt.Screen.WaitForString strWhatToWaitFor
        nError = Err.Number
        strErr = Err.Description
    On Error Goto 0 
    
    If nError <> 0 Then
        WaitForACommandToBeSent = False
    Else
        WaitForACommandToBeSent = True
    End If
    
    crt.Session.SetStatusText "Ready"
End Function

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Function CaptureCommandResults(strWhatToWaitFor, ByRef strOutput)
    crt.Session.SetStatusText "Capturing command results..."
    
    strOutput = ""
    strDataReceived = ""
    ' For performance reasons, we read up to either an EOL indicator
    ' or the prompt.  Otherwise, for commands that generate a lot of
    ' output, the performance of the script could be adversely affected.
    Do
        On Error Resume Next
        strDataReceived = crt.Screen.ReadString(_
            vbcrlf, _
            strWhatToWaitFor)
        nError = Err.Number
        strErr = Err.Description
        On Error Goto 0
        strOutput = strOutput & vbcrlf & strDataReceived
        If crt.Screen.MatchIndex = 2 Then Exit Do
        If nError <> 0 Then Exit Do
    Loop
    
    ' Some devices like Cisco PIX return lines terminated by LFCR,
    ' which is backwards from what Windows really needs in the
    ' clipboard. We'll look for these and simply replace them with
    ' the correct CRLF sequence:
    strOutput = Replace(strOutput, vbcr, "")
    strOutput = Replace(strOutput, vblf, vbcrlf)
    
    If Not g_bCaptureStartingEOL Then
        If Left(strOutput, 2) = vbcrlf Then
            strOutput = Mid(strOutput, 3)
        End If
    End If
    
    If Not g_bCaptureTrailingEOL Then
        If Right(strOutput, 2) = vbcrlf Then
            strOutput = Left(strOutput, Len(strOutput) - 2)
        End If
    End If
    
    If nError <> 0 Then
        CaptureCommandResults = False
    Else
        CaptureCommandResults = True
    End If
    

    crt.Session.SetStatusText "Ready"
End Function

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Function GetLineLeftOfCursor()
' Just a wrapper around a single Screen.Get call, but since the function call
' is so long, it's easier to think of it in terms of "get that portion of the
' current line that's to the left of the current cursor position".
    GetLineLeftOfCursor = crt.Screen.Get(_
        crt.Screen.CurrentRow, _
        1, _
        crt.Screen.CurrentRow, _
        crt.Screen.CurrentColumn - 1)
End Function

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Function GetShellPrompt()
    crt.Session.SetStatusText "Detecting shell prompt..."

    bSynchBefore = crt.Screen.Synchronous
    crt.Screen.Synchronous = False
    crt.Screen.Send vbcr
    ' Wait for at least 1/4 second to go by w/o receiving any data to the
    ' screen.  You may need to adjust this value (250 ms) to work best for
    ' the speed/latency of the connection medium you're using.
    WaitForScreenContentsToStopChanging 250
    GetShellPrompt = GetLineLeftOfCursor
    
    ' Restore synchronous attrib of the Screen object, if necessary
    If bSynchBefore Then crt.Screen.Synchronous = True
    
    crt.Session.SetStatusText "Ready"
End Function

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Sub WaitForScreenContentsToStopChanging(nMsDataReceiveWindow)
    ' This function relies on new data received being different from the
    ' data that was already received.  It won't work if, as one example, you
    ' have a screenful of 'A's and more 'A's arrive (because one screen
    ' "capture" will look exactly like the previous screen "capture").
    Dim nStartTime, bOrig, strInitText
    
    ' Store Synch flag for later restoration
    bOrig = crt.Screen.Synchronous
    ' Turn Synch off since speed is of the essence; we'll turn it back on (if
    ' it was already on) at the end of this function
    crt.Screen.Synchronous = False
    
    strLastScreen = crt.Screen.Get(_
        1,_
        1,_
        crt.Screen.Rows,_
        crt.Screen.Columns)
    Do
        crt.Sleep nMsDataReceiveWindow
        
        strNewScreen = crt.Screen.Get(_
            1,_
            1,_
            crt.Screen.Rows,_
            crt.Screen.Columns)
        If strNewScreen = strLastScreen Then Exit Do

        strLastScreen = strNewScreen
    Loop
    
    ' Restore the Synch setting
    crt.Screen.Synchronous = bOrig
End Sub

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Sub SetBoolArgValueIfPresent(strArgName, ByRef bValue)
    For nIndex = 0 To crt.Arguments.Count - 1
        strArg = crt.Arguments(nIndex)
        
        ' Create a regular expression we'll use to pattern-match.
        Set re = New RegExp
        re.Global = True
        re.IgnoreCase = True
        re.MultiLine = True
        re.Pattern = "\/*" & strArgName & "\:(true|false|yes|no|0|1|on|off)"
        If re.Test(strArg) Then
            strValue = LCase(re.Execute(strArg)(0).Submatches(0))
            Select Case strValue
                Case "true", "yes", "on", "1"
                    bValue = True
                Case "false", "no", "off", "0"
                    bValue = False
                Case Else
                    crt.Dialog.MessageBox _
                        "Warning.  Unknown value specified for arg '" & _
                        strArgName & "':" & vbcrlf & vbcrlf & vbtab & strValue
            End Select
        End If
    Next
End Sub

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Sub SetStringArgValueIfPresent(strArgName, ByRef strValue)
    For nIndex = 0 To crt.Arguments.Count - 1
        strArg = crt.Arguments(nIndex)
        
        ' Create a regular expression we'll use to pattern-match.
        Set re = New RegExp
        re.Global = True
        re.IgnoreCase = True
        re.MultiLine = True
        re.Pattern = "\/*" & strArgName & "\:""*([^""\r\n]+)""*"
        If re.Test(strArg) Then
            strValue = Trim(re.Execute(strArg)(0).Submatches(0))
        End If
    Next
End Sub

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Sub WriteToFile(strData)
    If g_strOutputFile = "" Then
        crt.Session.SetStatusText "Unable to write to file. No filename specified."
        Exit Sub
    End If
    Const ForReading = 1
    Const ForWriting = 2
    Const ForAppending = 8
    Set fso = CreateObject("Scripting.FileSystemObject")
    Set objFile = fso.OpenTextFile(g_strOutputFile, ForAppending, True)
    objFile.Write(strData)
    objFile.Close
End Sub