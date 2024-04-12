Option Explicit
Dim CurRow As Integer
Dim Initing As Boolean





Private Sub UserForm_Activate()
    Initing = True
    With Fm_EmergencyResponse
      .StartUpPosition = 0
      .Left = Application.Left + (0.5 * Application.Width) - (0.5 * .Width)
      .Top = Application.Top + (0.5 * Application.Height) - (0.5 * .Height)
    End With
    DoEvents
    
    Dim ThisDay As Date
    Dim N As Integer
    DutyBox.Clear
    DutyBox = ""
    Timebox.Clear
    Timebox = ""
    CheckBox1.Value = False: CheckBox1.Visible = False
    CheckBox2.Value = False: CheckBox2.Visible = False
    CurRow = ActiveCell.row
    
    N = 2
    While Range("ActivityList").Cells(N, 1) <> ""
            If Range("ActivityList").Cells(N, 14) = "er" Then DutyBox.AddItem (Range("ActivityList").Cells(N, 1))
            N = N + 1
    Wend
    Initing = False
   
End Sub

Private Sub DutyBox_Click()
    If Initing Then Exit Sub
    If DutyBox.MatchFound Then
        Timebox.SetFocus
    End If
End Sub

Private Sub Timebox_Enter()
    'Initing = True
    If DutyBox.MatchFound Then
        Timebox.Clear
        If Left(DutyBox.Text, 8) = "Rest Day" Then
            Timebox.AddItem ("N/A")
            Timebox = ""
            'FinishButton.SetFocus
        Else
            Timebox.AddItem ("Yes")
            Timebox.AddItem ("No")
            Timebox = ""
        End If
    End If
    'Initing = False
End Sub
Private Sub Timebox_Click()
    If Initing Then Exit Sub
    If Timebox.MatchFound Then
        If Timebox = "Yes" Then
            If Range("Takes_RDOs") = "yes" And Weekday(Cells(CurRow, DateCol), 2) > 5 Then
                    CheckBox1.Visible = True
                    CheckBox2.Visible = True
            End If
        Else
                CheckBox1.Value = False: CheckBox1.Visible = False
                CheckBox2.Value = False: CheckBox2.Visible = False
        End If
        FinishButton.SetFocus
    End If
End Sub

Private Sub FinishButton_Click()
        If Not DutyBox.MatchFound Then
            MsgBox "Please select duty from the dropdown list", vbExclamation, MsgCaption
            DutyBox = ""
            DutyBox.SetFocus
            Exit Sub
        End If
        If Not Timebox.MatchFound Then
            MsgBox "Please indicate if your work hours have been recorded by a timekeeper", vbExclamation, MsgCaption
            Timebox = ""
            Timebox.SetFocus
            Exit Sub
        End If
    '-----------------------------------
    If Timebox = "No" And Left(DutyBox.Text, 8) <> "Rest Day" Then 'Hand over to Fm_Record_Hours
        Me.Hide
        Fm_Record_Hours.Show
        Exit Sub
    End If
    '-----------------------------------
    Application.ScreenUpdating = False
    ClearTimesheetRow (CurRow)
    Cells(CurRow, CommentsCol).Font.Color = DarkRed
    Cells(CurRow, CommentsCol) = "Time recorded in IRIS"
    Cells(CurRow, LocationIDCol) = Range("WorkCentre")
    Cells(CurRow, LocationCol).Font.Color = DarkRed
    Cells(CurRow, LocationCol) = "Emergency Readiness / Response"
    Cells(CurRow, ActivityCol).Font.Color = DarkRed
    Cells(CurRow, ActivityCol) = DutyBox 'this is always a listed activity
    Cells(CurRow, EntryDateCol) = Date
    Cells(CurRow, FundCol) = "000"
    If Left(DutyBox.Text, 8) = "Rest Day" Then Cells(CurRow, DutyCol) = 0 Else Cells(CurRow, DutyCol) = 1
    Cells(CurRow, CatagoryCol) = 2  'Emergency Response
    If Cells(CurRow, StatusCol) = "saved" Or Cells(CurRow, StatusCol) = "updated" Then
        Cells(CurRow, StatusCol) = "updated"
    Else
        Cells(CurRow, StatusCol) = "entered"
    End If
    If CheckBox1 And CheckBox2 Then
        Cells(CurRow, RWECol) = 1
        Cells(CurRow, CommentsCol) = "Rostered Workday"
    End If
    UpdateWorkLifeBalance (GetPeriod(Cells(CurRow, DateCol)))
    'Call CalculateTimesheetSummary(GetStartDate(), GetEndDate(CurRow))
    Call CalculateTimesheetSummary(0)
    Fm_EmergencyResponse.Hide
    Application.ScreenUpdating = True

End Sub

Private Sub ReturnButton_Click()
    Me.Hide
    Fm_Select_Activity.Show
End Sub


