Option Explicit


Dim Activating As Boolean
Dim Pw As String


Private Sub NameLabel_Click()

End Sub

Private Sub UserForm_Activate()
    
    With Fm_Welcome
      .StartUpPosition = 0
      .Left = Application.Left + (0.5 * Application.Width) - (0.5 * .Width)
      .Top = Application.Top + (0.5 * Application.Height) - (0.5 * .Height)
      .Height = 189
    End With
    Label2.Caption = ""
    NameLabel.Caption = ""
    DoEvents
    
    Activating = True
    PasswordBox = ""
    Pw = ""

    If Range("LastName") = "" Then 'The timesheet has not been setup
        NameLabel.Caption = "Click 'OK' to setup this timesheet"
    Else
        NameLabel.Caption = Range("FirstName") & " " & Range("LastName")
        Label2.Caption = "This timesheet belongs to:"
        Me.Height = 220 'reveal password box
        PasswordBox.SetFocus
    End If
    Activating = False
    
End Sub

Private Sub CommandButton1_Click()

    If Range("LastName") = "" Then 'so show setup form
        UpdateProgramList (0)
        If Not ProgramListUpToDate Then
            MsgBox "Cannot connect to Oracle. Unable to setup timesheet.", vbExclamation, MsgCaption
            Me.Hide
            Exit Sub
        End If
        UpdatePublicHolidayList (0)
        
        Me.Hide
        Fm_Timesheet_Setup.Show 'Setup a new timesheet
        Exit Sub
    End If
    '------------------------------------------------------------------
    'The timesheet is setup and a password has been entered
    If Pw = Range("Pkey") Then Me.Hide: Fm_Logged_In.Show: Exit Sub
    '------------------------------------------------------------------
    
    'The password is incorrect
    If MsgBox("Incorrect password. Would you like to try again?.", vbYesNo, MsgCaption) = vbYes Then
        Activating = True
        Pw = ""
        PasswordBox = ""
        PasswordBox.SetFocus
        Activating = False
        Exit Sub
    Else
        Me.Hide
    End If
        
End Sub


Private Sub PasswordBox_Change()
    Dim k As String
    Dim Is_Text As Boolean
    
    If Activating Then Exit Sub
    If PasswordBox = "" Then Exit Sub
    Is_Text = False
    k = Right(PasswordBox.Text, 1)
    Activating = True
            If (Asc(k) >= 65 And Asc(k) <= 90) Or (Asc(k) >= 97 And Asc(k) <= 122) Then Is_Text = True
            If IsNumeric(k) Or Is_Text Then
                PasswordBox.Text = Left(PasswordBox.Text, Len(PasswordBox.Text) - 1) & "l"
                Pw = Pw & k
            Else
                PasswordBox.Text = Left(PasswordBox.Text, Len(PasswordBox.Text) - 1)
            End If
    Activating = False

End Sub


Private Sub PasswordBox_Exit(ByVal Cancel As MSForms.ReturnBoolean)
Call CommandButton1_Click
End Sub
