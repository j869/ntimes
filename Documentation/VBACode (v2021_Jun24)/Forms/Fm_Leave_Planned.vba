Option Explicit

Dim ALActivating As Boolean

Private Sub UserForm_Activate()
    With Fm_Leave_Planned
      .StartUpPosition = 0
      .Left = Application.Left + (0.5 * Application.Width) - (0.5 * .Width)
      .Top = Application.Top + (0.5 * Application.Height) - (0.5 * .Height)
    End With
    DoEvents
    
    ALActivating = True
        OptionButton1.Value = False
        DayCountBox = "1"
        ContinueButton.Enabled = False
    ALActivating = False
End Sub

Private Sub CancelButton_Click()
    Me.Hide
    Fm_Select_Activity.Show
End Sub

Private Sub OptionButton1_Click()
    If ALActivating Then Exit Sub
    'Frame1.Visible = False
    'Frame2.Visible = True
    'DayCountBox = "1"
    ContinueButton.Enabled = True
End Sub


Private Sub ContinueButton_Click()
    Dim Cmt As String
    Dim X, P1, P2, N, R, CurRow As Integer
    
    CurRow = ActiveCell.row
    
    R = CurRow
    N = Val(DayCountBox)
    If N = 0 Then N = 1
    Do While N > 0
            If Cells(R, ActivityCol) <> "" Then
                        If MsgBox("You have already filled in your timesheet for one or more workdays in this leave period." & vbCr & _
                        "If you continue this information will be changed." & vbCr & _
                        "Do you want to continue?", vbYesNo, MsgCaption) = vbNo Then
                                    Exit Sub
                        Else
                                    Exit Do
                        End If
            End If
            R = R + 1: If R > Range("EndDate").row Then Exit Do
            While IsPublicHoliday(Cells(R, DateCol)) Or Range("PaidHours").Cells(GetPeriodDayNumber(Cells(R, DateCol))) = 0
                    R = R + 1: If R > Range("EndDate").row Then Exit Do
            Wend
            N = N - 1
    Loop
    
    R = CurRow
    Application.ScreenUpdating = False
    P1 = GetPeriod(Cells(R, DateCol))
    N = Val(DayCountBox): If N = 0 Then N = 1
    Do While N > 0
            P2 = GetPeriod(Cells(R, DateCol))
            ClearTimesheetRow (R)
            Cells(R, LeaveCol) = "-" & TimeToText(Range("PaidHours").Cells(GetPeriodDayNumber(Cells(R, DateCol))), 0)
            Cells(R, LocationIDCol) = Range("WorkCentre")
            Cells(R, ActivityCol) = "Approved Leave"
            Cells(R, ActivityCol).Font.Color = RGB(51, 51, 255)
            Cells(R, LocationCol) = "Leave"
            Cells(R, LocationCol).Font.Color = RGB(51, 51, 255)
            Cells(R, CommentsCol) = ""
            Cells(R, CommentsCol).Font.Color = RGB(51, 51, 255)
            Cells(R, EntryDateCol) = Date
            Cells(R, DutyCol) = 0 'off duty
            Cells(R, CatagoryCol) = 3  'Approved leave
            
            If Cells(R, StatusCol) = "saved" Or Cells(R, StatusCol) = "updated" Then
                Cells(R, StatusCol) = "updated"
            Else
                Cells(R, StatusCol) = "entered"
            End If
            Cells(R, FundCol) = "000"
            R = R + 1: If R > Range("EndDate").row Then Exit Do
            While IsPublicHoliday(Cells(R, DateCol)) Or Range("PaidHours").Cells(GetPeriodDayNumber(Cells(R, DateCol))) = 0
                    R = R + 1: If R > Range("EndDate").row Then Exit Do
            Wend
            N = N - 1
    Loop
    
    For X = P1 To P2
    UpdateWorkLifeBalance (X)
    Next
    'Call CalculateTimesheetSummary(GetStartDate(), GetEndDate(ActiveCell.row))
    Call CalculateTimesheetSummary(0)
    Me.Hide
    Application.ScreenUpdating = True
    
End Sub


