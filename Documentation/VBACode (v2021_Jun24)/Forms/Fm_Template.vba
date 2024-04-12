






Private Sub Label2_Click()
Call logDataEntry("User viewing help on Warnawi")
ActiveWorkbook.FollowHyperlink Address:="http://warnawi.parks.vic.gov.au/employeecentre/myemployment/Pages/Completing-and-submitting-timesheets.aspx", NewWindow:=True

End Sub


Private Sub TextBox1_Change()

End Sub

Private Sub UserForm_Activate()
    With Fm_Template
      .StartUpPosition = 0
      .Left = Application.Left + (0.5 * Application.Width) - (0.5 * .Width)
      .Top = Application.Top + (0.5 * Application.Height) - (0.5 * .Height)
    End With
    'TextBox1.Text = "You forgot to rename your timesheet. We'll help you with this in a moment." & vbCr & "But first find out where your team are saving their timesheets."
    TextBox1.Text = "You forgot to rename your timesheet." & vbCr & vbCr & "Please rename your timesheet and save it in appropriate folder by clicking OK button below. " & vbCr & "Visit 'Help' for details."
    DoEvents

End Sub

Private Sub OKButton_Click()
        Dim wbNewName As String    'file path + workbook name (inc file ext)
        Dim sDefaultPath As String
        Me.Hide
        
        'force user to rename and save timesheet
        'vDefaultPath = "O:\PVgroups\Timesheets\2020-21\WorkCentres\"
        vDefaultPath = "\\MLFILES2\PV-Data\PVgroups\Timesheets\2020-21\WorkCentres\"    'UNC mapping works at a network level and avoids problems with mapped drives on local PC's
        Do
            wbNewName = Application.GetSaveAsFilename(vDefaultPath & Replace(ActiveWorkbook.Name, "Template", Environ("username")), "Excel Macro Enabled Workbook (*.xlsm), *.xlsm)", 1)
            'wbNewName = Application.GetSaveAsFilename("\\MLFILES2\PV-Data\PVgroups\Timesheets\2020-21\WorkCentres\" & Replace(ActiveWorkbook.Name, "Template", Environ("username")), "Excel Macro Enabled Workbook (*.xlsm), *.xlsm)", 1)
            wbNewPath = Left(wbNewName, InStrRev(wbNewName, "\", -1) - 1)
            If wbNewName = "False" Then
                Call logDataEntry("Fm_Template > OKButton_Click() > User clicked cancel")
                Exit Do
            End If
            If InStr(LCase(wbNewName), "template") = 0 And InStr(1, LCase(wbNewPath), LCase("PVgroups\Timesheets\2020-21\WorkCentres\")) > 0 Then
                Application.EnableEvents = False
                Call logDataEntry("Fm_Template > OKButton_Click() > Attempting to save workbook as: " & wbNewName)
                ActiveWorkbook.SaveAs (wbNewName)
                Application.EnableEvents = True
                Exit Do
            End If
            If InStr(LCase(wbNewName), "template") > 0 Then
                MsgBox "You cannot keep TEMPLATE in the file name. Please try again."
                Call logDataEntry("Fm_Template > OKButton_Click() > Fail: Nonstandard file name." & wbNewName)
            End If
            If InStr(1, LCase(wbNewPath), LCase("PVgroups\Timesheets\2020-21\WorkCentres\")) = 0 Then
                MsgBox "Non standard folder, please save under an applicable folder or consult your supervisor or a team member"
                Call logDataEntry("Fm_Template > OKButton_Click() > Fail: Nonstandard folder " & wbNewName)
            End If
        Loop
        
Exit Sub

'testing
'ActiveWorkbook.SaveAs ("O:\PVgroups\Timesheets\2020-21\WorkCentres\Melbourne Division\Corporate\Infrastructure and IT\IT\Template PV Timesheet 2020-21 (V1.5).xlsm")

    'ThisWorkbook.Close
End Sub

Private Sub UserForm_Terminate()
    'user clicked the X at the top right of the form
    Call logDataEntry("Fm_Template > UserForm_Terminate() > Cancelled by user - Setup Failed!")
    Range("LastName") = ""
    Call LockTimesheet
    End

End Sub
