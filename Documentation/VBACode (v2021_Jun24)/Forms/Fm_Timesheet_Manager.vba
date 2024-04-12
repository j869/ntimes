Option Explicit



Private Sub HelpButton_Click()
Fm_Help.Show
End Sub

Private Sub UserForm_Activate()
    With Fm_Timesheet_Manager
      .StartUpPosition = 0
      .Left = Application.Left + (0.5 * Application.Width) - (0.5 * .Width)
      .Top = Application.Top + (0.5 * Application.Height) - (0.5 * .Height)
    End With
    DoEvents
    
    If Range("LastName") = "" Then
        PasswordButton.Enabled = False
        InfoButton.Enabled = False
        LocationsButton.Enabled = False
    Else
        PasswordButton.Enabled = True
        InfoButton.Enabled = True
        LocationsButton.Enabled = True
    End If
    
End Sub

Private Sub InfoButton_Click()
    Fm_Timesheet_Info.Show
End Sub

Private Sub LocationsButton_Click()
    Fm_Location_Manager.Show
End Sub

Private Sub ActivitiesButton_Click()
    Fm_Activity_Manager.Show
End Sub

Private Sub PasswordButton_Click()
Change_Password
End Sub

Private Sub CloseButton_Click()
    Me.Hide
End Sub

Private Sub Change_Password()
    Dim p As String
    p = GetPassword("Enter your current password")
    If p = Range("Pkey") Then
        p = GetPassword("Enter your new password")
    Else
        MsgBox "Incorrect password", vbExclamation, MsgCaption
        Exit Sub
    End If
    
    If p = "" Then 'user cancelled or didn't enter a password
        MsgBox "Change password cancelled", vbExclamation, MsgCaption
        Exit Sub
    End If
    
    If p = GetPassword("Retype your new password") Then
        Range("Pkey") = p
        MsgBox "Your password has been changed", vbInformation, MsgCaption
    Else
        MsgBox "Error. The password you retyped did not match your new password." & vbCr & _
        "Your password has not been changed.", vbExclamation, MsgCaption
    End If

End Sub


