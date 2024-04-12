Option Explicit

Private Sub ContinueButton_Click()
    Dim H As Single
    If TextBox1 = "" And TextBox2 = "" Then
        MsgBox "Please enter your carried over Accrued Time", vbExclamation, MsgCaption
        TextBox1.SetFocus
        Exit Sub
    End If

    If TextBox1 = "" Then TextBox1 = "0"
    If TextBox2 = "" Then TextBox2 = "0"
        
    H = Val(TextBox1)
    H = H + Round(Val(TextBox2 / 60), 2) 'Convert AT carried to decimal hours
    Range("ATCarried") = Round(H, 2)
    Range("ATBalance") = Round(H, 2)
    Me.Hide
End Sub


Private Sub Label2_Click()
Call logDataEntry("User viewing help on Warnawi")
ActiveWorkbook.FollowHyperlink Address:="http://warnawi.parks.vic.gov.au/employeecentre/myemployment/Pages/Completing-and-submitting-timesheets.aspx", NewWindow:=True

End Sub

Private Sub TextBox1_Change()
    If TextBox1 = "" Then Exit Sub
    If Not IsNumeric(Right(TextBox1, 1)) Then
        TextBox1 = Left(TextBox1, Len(TextBox1) - 1)
    End If
End Sub



Private Sub TextBox2_Change()
    If TextBox2 = "" Then Exit Sub
    If Not IsNumeric(Right(TextBox2, 1)) Then
        TextBox2 = Left(TextBox2, Len(TextBox2) - 1)
    End If
    
    If Len(TextBox2) > 2 Then TextBox2 = Left(TextBox2, 2)
    If Val(TextBox2) > 59 Then
        MsgBox "Illegal value", vbExclamation, MsgCaption
        TextBox2 = ""
    End If
    
    
End Sub

Private Sub UserForm_Activate()
    With Fm_Carried_AT
      .StartUpPosition = 0
      .Left = Application.Left + (0.5 * Application.Width) - (0.5 * .Width)
      .Top = Application.Top + (0.5 * Application.Height) - (0.5 * .Height)
    End With

End Sub

Private Sub UserForm_Terminate()
    TextBox1 = ""
    TextBox2 = ""

    'user clicked the X at the top right of the form
    Call logDataEntry("Fm_Carried_AT > UserForm_Terminate() > Cancelled by user - Setup Failed!")
    Range("LastName") = ""
    Call LockTimesheet
    End

End Sub

