Option Explicit



Sub PrintWLB()

    If Application.Version >= 14 Then 'export as PDF to I drive
            On Error GoTo Print_Error
            
            ActiveSheet.ExportAsFixedFormat Type:=xlTypePDF, FileName:= _
            "I:\ Work-Life " & Sheets("Timesheet").Range("TimesheetTitle") & " " & Format(Now(), "dd-mmm-yy") & ".pdf", Quality:=xlQualityStandard, IncludeDocProperties:=True, _
             IgnorePrintAreas:=False, OpenAfterPublish:=False
            MsgBox "Your Work-Life form has been printed to a PDF file and saved on your 'I:' Drive", vbInformation, MsgCaption
    Else
            On Error GoTo Print_Error
            ActiveSheet.PrintOut Copies:=1, ActivePrinter:="CutePDF Writer"
    End If
    Exit Sub
    
Print_Error:
    If MsgBox("An error occured printing your timesheet to PDF" & vbCr & "Would you like to print to your default printer?", vbYesNo, MsgCaption) = vbYes Then
        ActiveSheet.PrintOut
    End If

End Sub
