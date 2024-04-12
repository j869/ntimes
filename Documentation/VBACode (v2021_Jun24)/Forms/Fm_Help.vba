Private Sub Label1_Click()
    Dim Link As String
    On Error GoTo NotAvailable
    Link = "O:\PVgroups\Timesheets\Information\Presentations\2021\Parks Victoria Timesheet 2020-21 (User Guide).pptx"
    ActiveWorkbook.FollowHyperlink Address:=Link, NewWindow:=True
    Me.Hide
    Exit Sub
NotAvailable:
        MsgBox "The file " & Link & "could not be found.", vbExclamation

End Sub

Private Sub Label2_Click()
    Dim Link As String
    On Error GoTo NotAvailable
    Link = "O:\PVgroups\Timesheets\Information\Presentations\2021\Parks Victoria Timesheet 2020-21 (Setup Guide).pptx"
    ActiveWorkbook.FollowHyperlink Address:=Link, NewWindow:=True
    Me.Hide
    Exit Sub
NotAvailable:
        MsgBox "The file " & Link & "could not be found.", vbExclamation
End Sub

Private Sub Label3_Click()
    Dim Link As String
    On Error GoTo NotAvailable
    Link = "O:\PVgroups\Timesheets\Information\Presentations\2021\Parks Victoria Timesheet 2020-21 (Admin Guide).pptx"
    ActiveWorkbook.FollowHyperlink Address:=Link, NewWindow:=True
    Me.Hide
    Exit Sub
NotAvailable:
        MsgBox "The file " & Link & "could not be found.", vbExclamation
    
End Sub

Private Sub UserForm_Activate()
    With Fm_Help
      .StartUpPosition = 0
      .Left = Application.Left + (0.5 * Application.Width) - (0.5 * .Width)
      .Top = Application.Top + (0.5 * Application.Height) - (0.5 * .Height)
    End With
End Sub


