    Dim TempFileName As String


Private Sub UserForm_Activate()
    With Fm_Print
      .StartUpPosition = 0
      .Left = Fm_Timesheet_Options.Left + 150
      .Top = Fm_Timesheet_Options.Top + 75
    End With
    DoEvents

    CommandButton1.SetFocus
End Sub


Private Sub CommandButton1_Click() 'PRINT
    Dim hideVariances As Boolean
    
    If Columns(LeaveCol).Hidden Then hideVariances = True: Range(Columns(LeaveCol), Columns(CommentsCol)).EntireColumn.Hidden = False
    
        MsgBox "PRINT TIMESHEET" & vbCr & vbCr & _
        "When you click 'OK' a 'folder select' window will open. " & vbCr & _
        "Navigate to the folder where you want a printout of your " & vbCr & _
        "timesheet to be saved, then click 'OK'", vbInformation, MsgCaption

    
    On Error GoTo Print_Error
    TempFileName = GetFolder()
    If TempFileName = vbNullString Then
        Me.Hide
        MsgBox "Print Timesheet Cancelled.", vbExclamation, MsgCaption
        Exit Sub
    End If
    TempFileName = TempFileName & "\" & Range("TimesheetTitle") & " " & Format(Now(), "(hhmmddmmyy)") & ".pdf"
    'TempFileName = "I:\Timesheet " & Range("TimesheetTitle") & " " & Format(Now(), "(hhmmddmmyy)") & ".pdf"
    If Application.Version >= 14 Then 'export as PDF to I drive
    
            ActiveSheet.ExportAsFixedFormat Type:=xlTypePDF, FileName:= _
            TempFileName, Quality:=xlQualityStandard, IncludeDocProperties:=True, _
             IgnorePrintAreas:=False, OpenAfterPublish:=False
    
            MsgBox "Your timesheet has been printed and saved" & vbCr & vbCr & _
            "The file name is: " & TempFileName & vbCr & vbCr & _
            "Please send a copy of the PDF file to you supervisor and retain a copy for your records.", vbInformation, MsgCaption
    Else
        ActiveSheet.PrintOut Copies:=1, ActivePrinter:="CutePDF Writer" ', preview:=True
    End If

    If hideVariances Then Range(Columns(LeaveCol), Columns(CommentsCol)).EntireColumn.Hidden = True
    Me.Hide
    Exit Sub
    
Print_Error:
    MsgBox "An error occured printing your timesheet " & vbCr & vbCr & Err.Description, vbExclamation, MsgCaption

End Sub

Private Sub CommandButton2_Click() 'Email Timesheet
    Dim OutApp As Object
    Dim OutMail As Object
    
    MsgBox "PRINT & EMAIL TIMESHEET" & vbCr & vbCr & _
    "When you click 'OK' a 'folder select' window will open. " & vbCr & _
    "Navigate to the folder where you want a printout of your " & vbCr & _
    "timesheet to be saved, then click 'OK'", vbInformation, MsgCaption
    
    TempFileName = GetFolder()
    If TempFileName = vbNullString Then
        Me.Hide
        MsgBox "Email Timesheet Cancelled.", vbExclamation, MsgCaption
        Exit Sub
    End If
    TempFileName = TempFileName & "\" & Range("TimesheetTitle") & " " & Format(Now(), "(hhmmddmmyy)") & ".pdf"
    'TempFileName = "I:\Timesheet " & Range("TimesheetTitle") & " " & Format(Now(), "(hhmmddmmyy)") & ".pdf"
    
    On Error GoTo MailErr
    
    ActiveSheet.ExportAsFixedFormat Type:=xlTypePDF, FileName:= _
    TempFileName, Quality:=xlQualityStandard, IncludeDocProperties:=True, _
    IgnorePrintAreas:=False, OpenAfterPublish:=False

    Set OutApp = CreateObject("Outlook.Application")
    Set OutMail = OutApp.CreateItem(0)

    With OutMail
        .To = ""
        .CC = ""
        .BCC = ""
        .Subject = "Timesheet for approval"
        .Body = Range("FirstName") & " " & Range("LastName") & _
        " (" & Range("Position") & ") Timesheet for the " & _
        Range("TimesheetMode") & " " & Range("CurrentPeriod") & " attached for approval."
        .Attachments.Add TempFileName
        ' You can add other files by uncommenting the following statement.
        '.Attachments.Add ("C:\test.txt")
        'THE EMAIL CAN BE EITHER SENT OR DISPLAYED
        '.Send
        .Display
    End With

    Set OutMail = Nothing
    Set OutApp = Nothing

    
    Me.Hide
    Exit Sub
MailErr:
    Me.Hide
    MsgBox "An error occurred mailing your Timesheet." & vbCr & vbCr & Err.Description, vbExclamation, MsgCaption
    
End Sub

Private Sub CommandButton3_Click()
    Me.Hide
End Sub
