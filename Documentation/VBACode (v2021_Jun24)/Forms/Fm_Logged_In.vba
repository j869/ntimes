
Option Explicit


Private Sub CommandButton1_Click()
    Me.Hide
End Sub

Private Sub Label2_Click()

End Sub

Private Sub UserForm_Activate()
    Dim e, Greeting As String

    With Fm_Logged_In
      .StartUpPosition = 0
      .Left = Application.Left + (0.5 * Application.Width) - (0.5 * .Width)
      .Top = Application.Top + (0.5 * Application.Height) - (0.5 * .Height)
    End With
    
    Label1 = ""
    Label2 = "Connecting to Timesheet database...."
    Label3.ForeColor = &HC00000 'blue
    Label3 = ""
    CommandButton1.Enabled = False
    DoEvents
    
    Label3 = "Updating Public Holidays and PV Program List": DoEvents
    UpdatePublicHolidayList (0)
    UpdateProgramList (0) 'This will also check the database connection
    If Not ProgramListUpToDate Then
        Label3.ForeColor = &HC0& 'red
        Label3 = "NOT Connected to Timesheet Database"
        Image2.Visible = False
        Image1.Visible = True
        
    Else
        Label3.ForeColor = &H8000& 'green
        Label3 = "Connected to Timesheet Database."
        Image2.Visible = True
        Image1.Visible = False
    End If
    

    Sheets("PV").InformationButton.Enabled = True
    Sheets("PV").WorkLifeButton.Enabled = True
    Sheets("PV").TimesheetButton.Enabled = True

    Select Case Format(Now(), "HH")
        Case Is < 12
            Greeting = "Good morning "
        Case Is > 17
            Greeting = "Good evening "
        Case Is > 11
            Greeting = "Good Afternoon "
    End Select
    Label1 = Greeting & Range("FirstName") & "."

    Label2 = "Your password has been verified. Your timesheet is ready for use."
    CommandButton1.Enabled = True

End Sub

Private Sub UserForm_Terminate()

End Sub
