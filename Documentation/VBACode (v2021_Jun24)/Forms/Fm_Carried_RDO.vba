Option Explicit

Private Sub Label16_Click()

End Sub

Private Sub Label2_Click()
Call logDataEntry("User viewing help on Warnawi")
ActiveWorkbook.FollowHyperlink Address:="http://warnawi.parks.vic.gov.au/employeecentre/myemployment/Pages/Completing-and-submitting-timesheets.aspx", NewWindow:=True

End Sub

Private Sub UserForm_Activate()
    With Fm_Carried_RDO
      .StartUpPosition = 0
      .Left = Application.Left + (0.5 * Application.Width) - (0.5 * .Width)
      .Top = Application.Top + (0.5 * Application.Height) - (0.5 * .Height)
    End With

    'TextBox1 = ""
End Sub

Private Sub ContinueButton_Click()

    If Not IsNumeric(TextBox1) Then
        MsgBox "Please enter a number in the RDO carried box", vbExclamation, MsgCaption
        Exit Sub
    End If
    Range("RDOCarried") = Val(TextBox1)
    Range("RDOBalance") = Val(TextBox1)
    Me.Hide
End Sub

Private Sub TextBox1_Change()
    If TextBox1 = "" Then Exit Sub
    If Not IsNumeric(Left(TextBox1, 1)) Then
        TextBox1 = Right(TextBox1, Len(TextBox1) - 1)
    End If
        If Len(TextBox1) > 2 Then TextBox1 = Left(TextBox1, 2)

End Sub


Private Sub UserForm_Terminate()
    TextBox1 = ""
    'user clicked the X at the top right of the form
    Call logDataEntry("Fm_Carried_RDO > UserForm_Terminate() > Cancelled by user - Setup Failed!")
    Range("LastName") = ""
    Call LockTimesheet
    End

End Sub


