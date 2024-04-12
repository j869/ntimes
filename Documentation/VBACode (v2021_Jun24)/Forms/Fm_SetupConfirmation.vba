Private Sub CancelButton_Click()
       Me.Hide
       Call logDataEntry("Fm_SetupConfirmation > Cancelled by user - Setup Failed!")
      ' Parent.Hide
       ClearSetup2
       Fm_Welcome.Show
       End   'Exit Sub

End Sub


Private Sub ClearSetup2()
    'copy of routine from Fm_Timesheet_Setup
    Dim N As Integer
    For N = 1 To 17
        Range("LastName").Cells(N) = ""
    Next
    For N = 1 To 15
        Range("PaidHours").Cells(N) = ""
    Next
    Sheets("Timesheet").Range("Office") = ""
    Call logDataEntry("Timesheet setup values cleared")
End Sub

Private Sub CheckBox1_Click()
    If OKButton.Enabled = True Then
      OKButton.Enabled = False
    Else
      OKButton.Enabled = True
    End If
    
End Sub

Private Sub Label2_Click()
Call logDataEntry("User viewing help on Warnawi")
ActiveWorkbook.FollowHyperlink Address:="http://warnawi.parks.vic.gov.au/employeecentre/myemployment/Pages/Completing-and-submitting-timesheets.aspx", NewWindow:=True

End Sub


Private Sub OKButton_Click()
    If CheckBox1 = True Then
        Unload Me
    End If

End Sub



Private Sub UserForm_Activate()
  TextBox1.Value = "If you are sure all of your information is correct, click OK to complete setting up your timesheet."
  TextBox1.Value = TextBox1.Value & vbCr & vbCr & "Setup process can only be completed once in any given financial year.  For any setup changes, please contact IT."
  TextBox1.Value = TextBox1.Value & vbCr & "Please refrain from deleting timesheets as you will not be able to recover it."
  TextBox1.Value = TextBox1.Value & vbCr & vbCr & "Click Restart to start over."
  
'Setup process can only be completed once in any given financial year. For any setup changes, please contact IT. Please refrain from deleting timesheets as you will not be able to recover it
  
End Sub


