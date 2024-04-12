


Private Sub Label4_Click()
Call logDataEntry("User viewing help on Warnawi")
ActiveWorkbook.FollowHyperlink Address:="http://warnawi.parks.vic.gov.au/employeecentre/myemployment/Pages/Completing-and-submitting-timesheets.aspx", NewWindow:=True
End Sub

Private Sub UserForm_Activate()
    With Fm_VarianceFormatSetup
      .StartUpPosition = 0
      .Left = Application.Left + (0.5 * Application.Width) - (0.5 * .Width)
      .Top = Application.Top + (0.5 * Application.Height) - (0.5 * .Height)
    End With
    OptionDecimal.Value = False
    OptionHHMM.Value = False
    ContinueButton.Enabled = False
    DoEvents

    
End Sub

Private Sub OptionDecimal_Click()
    If OptionDecimal Then ContinueButton.Enabled = True
End Sub

Private Sub OptionHHMM_Click()
    If OptionHHMM Then ContinueButton.Enabled = True
End Sub

Private Sub ContinueButton_Click()
    Me.Hide
End Sub

Private Sub UserForm_Terminate()
    'user clicked the X at the top right of the form
    Call logDataEntry("Fm_VarianceFormatSetup > UserForm_Terminate() > Cancelled by user - Setup Failed!")
    Range("LastName") = ""
    Call LockTimesheet
    End

End Sub

