Option Explicit



Private Sub ReminderBox_Change()
    If Len(ReminderBox.Text) > 255 Then
        ReminderBox.Text = Left(ReminderBox.Text, 255)   'chg200506 for new year template
    End If
End Sub

Private Sub UserForm_Activate()
    
    With Fm_Leave_Other
      .StartUpPosition = 0
      .Left = Application.Left + (0.5 * Application.Width) - (0.5 * .Width)
      .Top = Application.Top + (0.5 * Application.Height) - (0.5 * .Height)
    End With
    DoEvents
    
    ReminderBox = ""
End Sub

Private Sub ReturnButton_Click()
   Me.Hide
    Fm_Select_Activity.Show
End Sub

Private Sub FinishButton_Click()
    If Trim(ReminderBox) = "" Then
        MsgBox "Please enter your reason for taking the day off", vbExclamation, MsgCaption
        Exit Sub
    End If
    Dim CurRow As Integer
    CurRow = ActiveCell.row
    
    Application.ScreenUpdating = False
    
    ClearTimesheetRow (CurRow)
    

    Cells(CurRow, LeaveCol) = "-" & TimeToText(Range("PaidHours").Cells(GetPeriodDayNumber(Cells(CurRow, DateCol))), 0)
    Cells(CurRow, LocationIDCol) = Range("WorkCentre")
    Cells(CurRow, ActivityCol) = "Leave (subject to approval)"
    Cells(CurRow, ActivityCol).Font.Color = RGB(51, 51, 255)
    Cells(CurRow, LocationCol) = "Leave"
    Cells(CurRow, LocationCol).Font.Color = RGB(51, 51, 255)
    Cells(CurRow, CommentsCol) = ReminderBox
    Cells(CurRow, CommentsCol).Font.Color = RGB(51, 51, 255)
    Cells(CurRow, EntryDateCol) = Date
    Cells(CurRow, DutyCol) = 0 'off duty
    Cells(CurRow, CatagoryCol) = 4  'Other Leave
    If Weekday(Cells(CurRow, DateCol), 2) > 5 And Range("Takes_RDOs") = "yes" Then Cells(CurRow, RWECol) = 1
    If Cells(CurRow, StatusCol) = "saved" Or Cells(CurRow, StatusCol) = "updated" Then
            Cells(CurRow, StatusCol) = "updated"
    Else
            Cells(CurRow, StatusCol) = "entered"
    End If
    Cells(CurRow, FundCol) = "000"
    Me.Hide
    
    UpdateWorkLifeBalance (GetPeriod(Cells(CurRow, DateCol)))
        
    'Call CalculateTimesheetSummary(GetStartDate(), GetEndDate(ActiveCell.row))
    Call CalculateTimesheetSummary(0)
    Application.ScreenUpdating = True
    
    Call DuplicateTimesheet(CurRow + 0, CurRow + 1, DayCountBox.Value - 1)
    
    MsgBox "Your leave has been recorded on your timesheet." & vbCr & _
            "Please ensure you complete a leave application in the FaP system.", vbInformation, MsgCaption


End Sub

