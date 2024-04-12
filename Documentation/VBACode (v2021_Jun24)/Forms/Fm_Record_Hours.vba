Option Explicit

Dim ThisDay As Date
Dim CurRow As Integer 'Currently selected Row
Dim PaidHours As Single 'Paid Hours on selected day
Dim RecHrsActivating As Boolean
Dim Calculating As Boolean
Dim FormReady As Boolean
Dim VarianceVisible As Boolean
Dim variance As Single
Dim CommentRequired As Boolean
Const VarianceOption = "Custom Variance"

Private Sub UserForm_Activate()
    Dim DayNum As Integer
    Dim N As Integer
    
    With Fm_Record_Hours
      .StartUpPosition = 0
      .Left = Application.Left + (0.5 * Application.Width) - (0.5 * .Width)
      .Top = Application.Top + (0.5 * Application.Height) - (0.5 * .Height)
    End With
    DoEvents
    
    'Tab order will set focus to AssistantButton
    If Not ActiveSheet.Name = "Timesheet" Then Me.Hide: MsgBox "Illegal Form Activate event!", vbExclamation, MsgCaption: Exit Sub
    
    Application.ScreenUpdating = False
    RecHrsActivating = True
    CurRow = ActiveCell.row
    ThisDay = Cells(CurRow, DateCol)
    DayNum = GetPeriodDayNumber(ThisDay)
    
    HideVariance
    DayLabel = Format(ThisDay, "dddd")
    DateLabel = Format(ThisDay, "dd / MMM / yyyy")
    StartTimeBox = ""
    FinishTimeBox = ""
    BreakLabel.Caption = "0:00"
    ExtraBreakBox = ""
    TotalHoursLabel.Caption = "0:00"
    LocationBox = ""
    ActivityBox = ""
    VarianceTypeBox = ""
    PaidHours = Range("PaidHours").Cells(DayNum)
    
    If PaidHours = 0 _
        And Weekday(ThisDay, 2) > 5 _
        And Range("Takes_RDOs") = "yes" Then
        PaidHours = GetWeekendHours()
    End If
    
    'Is this a public Holiday? NOTE: There can be no Variance on a Public Holiday. All hours are paid
    If PubHol Then   'PubHol is a global boolean set by Select Activity Form
        ShowPublicHoliday
        HolidayLabel.Caption = "Public Holiday : " & GetPublicHoliday(ThisDay)
        If PenaltyBox.ListCount = 0 Then
            PenaltyBox.AddItem ("Extra Pay Option") 'default
            PenaltyBox.AddItem ("Accrued Time Option")
        End If
        PenaltyBox = PenaltyBox.List(0) 'default
    Else
            HidePublicHoliday
    End If
    
    If Range("VarianceFormat") = "decimal" Then
        Lb_NormalHours_2 = Format(PaidHours, "0.00") 'Can be 0
    Else
        Lb_NormalHours_2 = Format(PaidHours / 24, "h:mm") 'Can be 0
    End If
    
    N = 2
    LocationBox.Clear
    While Range("MyLocationList").Cells(N, 1) <> ""
        LocationBox.AddItem GetLocationName(Range("MyLocationList").Cells(N, 1))
        N = N + 1
    Wend
    
    If LocationBox.ListCount = 0 Then 'should never happen
        LocationBox.AddItem GetLocationName(Range("WorkCentre"))
    End If
    
    'Load default location (if it is in LocationBox List)
    If Range("DefaultLocation") <> "" Then
        LocationBox = Range("DefaultLocation")
        If Not LocationBox.MatchFound Then LocationBox = ""
    End If
    
    'Load Activities
    ActivityBox.Clear
    Select Case Caller
        Case 1: 'Fire & Emergency call
             ActivityBox.AddItem (Fm_EmergencyResponse.DutyBox)
             ActivityBox = Fm_EmergencyResponse.DutyBox
             Lb_MoreActivities.Visible = False 'Hidden for an F&E caller
             Lb_NewActivity.Visible = False
         Case Else: 'PV Work day
            N = 2
            While Range("ActivityList").Cells(N, 1) <> ""
                If Range("ActivityList").Cells(N, 14) = "open" Then ActivityBox.AddItem (Range("ActivityList").Cells(N, 1))
                N = N + 1
            Wend
             Lb_MoreActivities.Visible = True
             Lb_NewActivity.Visible = True
    End Select
    
    'Load Default start time
    If Range("NormalStart") <> "" Then
        StartTimeBox = Range("NormalStart")
        If StartTimeBox.MatchFound Then
                CalculateFinishTime
                CalculateWorkedHours
        Else
                StartTimeBox = ""
        End If
    End If
    FundLabel = GetFundSourceName(Range("PVFundSource"))
    CheckForm
    FindFocus
    RecHrsActivating = False
    Application.ScreenUpdating = True
End Sub

Private Sub FundButton_Click()
    Fm_FundSource_Change.Show
    If Fm_FundSource_Change.FundBox.Text <> "" Then
        FundLabel = Fm_FundSource_Change.FundBox.Text
        Range("PVFundSource") = GetFundSourceNumber(FundLabel)
    End If
    FindFocus
End Sub

Private Sub FundLabel_Click()
 Call FundButton_Click
End Sub

Private Sub Label12_Click() 'Activity Label
    Dim N As Integer
    If Caller = 1 Then Exit Sub
    N = 2
    ActivityBox.Clear
    While Range("ActivityList").Cells(N, 1) <> ""
        If Range("ActivityList").Cells(N, 14) = "open" Then ActivityBox.AddItem (Range("ActivityList").Cells(N, 1))
        N = N + 1
    Wend
    ActivityBox.DropDown
End Sub

Private Sub Label13_Click() 'Location Label
    Dim N As Integer
    N = 2
    LocationBox.Clear
    While Range("MyLocationList").Cells(N, 1) <> ""
        LocationBox.AddItem (GetLocationName(Range("MyLocationList").Cells(N, 1))) '***NEW*** LocationListMod
        N = N + 1
    Wend
    LocationBox.DropDown
End Sub

Private Sub AssistantButton_Click()
    Fm_Timesheet_Assistant.Show
    Call UserForm_Activate
End Sub

Private Sub StartTimeBox_Click()
    If RecHrsActivating Then Exit Sub
    RecHrsActivating = True
    CalculateFinishTime
    CalculateWorkedHours
    CheckForm
    FindFocus
    RecHrsActivating = False

End Sub

Private Sub StartTimeBox_AfterUpdate()
    'This event is caused when the control looses focus, so it should NOT set focus or call a routine which will set focus
    If RecHrsActivating Then Exit Sub
    If StartTimeBox = "" Then CheckForm: Exit Sub
    
    If Not StartTimeBox.MatchFound Then
        StartTimeBox = Format(TextToTime(StartTimeBox) / 24, "h:mm") 'this format will not allow time > 23:59
    End If
    CalculateFinishTime
    CalculateWorkedHours
    CheckForm
End Sub

Private Sub FinishTimeBox_Click()
    If RecHrsActivating Then Exit Sub
    RecHrsActivating = True
    CalculateWorkedHours
    CheckForm
    FindFocus
    RecHrsActivating = False
End Sub

Private Sub FinishTimeBox_AfterUpdate()
    If RecHrsActivating Then Exit Sub
    If FinishTimeBox = "" Then Exit Sub
    If Not FinishTimeBox.MatchFound Then
        FinishTimeBox = Format(TextToTime(FinishTimeBox) / 24, "h:mm")
    End If
    
    CalculateWorkedHours
    CheckForm
FindFocus
End Sub

Private Sub ExtraBreakBox_Click()
    If RecHrsActivating Then Exit Sub
    RecHrsActivating = True
    CalculateWorkedHours
    CheckForm
    FindFocus
    RecHrsActivating = False
End Sub

Private Sub ExtraBreakBox_AfterUpdate()
    If RecHrsActivating Then Exit Sub
    If Not ExtraBreakBox.MatchFound Then ExtraBreakBox = Format(TextToTime(ExtraBreakBox) / 24, "h:mm")
    CalculateWorkedHours
    CheckForm
FindFocus
End Sub

Private Sub ActivityBox_Change()
    If RecHrsActivating Then Exit Sub
    CheckForm
    FindFocus
End Sub

Private Sub LocationBox_Change()
    If RecHrsActivating Then Exit Sub
    CheckForm
    FindFocus
End Sub

Private Sub PenaltyBox_Click()
    If RecHrsActivating Then Exit Sub
    CalculateWorkedHours
    CheckForm
    FindFocus
End Sub

Private Sub VarianceTypeBox_Click()
    If RecHrsActivating Then Exit Sub
    If Calculating Then Exit Sub
    
    CheckForm
    FindFocus
End Sub

Private Sub CommentBox_Change()
    If RecHrsActivating Then Exit Sub
    If Len(CommentBox.Text) > 255 Then
        CommentBox.Text = Left(CommentBox.Text, 255)  'chg200506 for new year template
    End If
    CheckForm
End Sub

Private Sub PenaltyBox_change()
    If Len(PenaltyBox.Text) > 255 Then
        PenaltyBox.Text = Left(PenaltyBox.Text, 255)   'chg200506 for new year template
    End If
End Sub

Private Sub ContinueButton_Click()
    Dim LocID As Long
    If VarianceTypeBox = VarianceOption Then
        Fm_Variance.Show
        If Not Fm_Variance.ContinueButtonClicked Then Exit Sub '(user cancelled)
    End If
    
    Application.ScreenUpdating = False
    
    ClearTimesheetRow (CurRow) 'Remove any existing data
    Select Case VarianceTypeBox
            Case "Time in Lieu"
                Cells(CurRow, TILCol) = TimeToText(variance, 1)
                
            Case "Accrued Time"
                Cells(CurRow, ATCol) = TimeToText(variance, 1)
                
            Case "Community Service"
                Cells(CurRow, CSCol) = TimeToText(variance, 1)
            
            Case "Overtime (subject to approval)"
                Cells(CurRow, OTCol) = TimeToText(variance, 1)
            
            
            Case "Leave (subject to approval)"
                Cells(CurRow, LeaveCol) = TimeToText(variance, 1)
           
            Case VarianceOption: 'VarianceOption is a constant declared in this module
                    If variance < 0 Then
                        If Fm_Variance.TextBox1 <> "" Then Cells(CurRow, TILCol) = "-" & Fm_Variance.TextBox1
                        If Fm_Variance.TextBox2 <> "" Then Cells(CurRow, LeaveCol) = "-" & Fm_Variance.TextBox2
                    Else
                        If Fm_Variance.TextBox1 <> "" Then Cells(CurRow, ATCol) = Fm_Variance.TextBox1 'Always Accrued Time in this box
                        If Fm_Variance.TextBox2 <> "" Then Cells(CurRow, OTCol) = Fm_Variance.TextBox2 'Always Overtime
                    End If
        End Select
    Me.Hide
    
    'record times on timesheet as text
    Cells(CurRow, StartCol) = StartTimeBox
    Cells(CurRow, FinishCol) = FinishTimeBox
    Cells(CurRow, BreakCol) = BreakLabel
    Cells(CurRow, ExtraCol) = ExtraBreakBox
    Cells(CurRow, TotalCol) = TotalHoursLabel
    Cells(CurRow, LocationCol) = LocationBox
    Cells(CurRow, LocationCol).Font.Color = RGB(0, 0, 0) 'black
    Cells(CurRow, ActivityCol) = ActivityBox 'this is always a listed activity
    Cells(CurRow, ActivityCol).Font.Color = RGB(0, 0, 0) 'black
    Cells(CurRow, CommentsCol).Font.Color = RGB(0, 0, 0) 'black
    
    'Check the LocationID number. If it is 0 (work from home etc) default to home workcentre
    LocID = GetLocationID(LocationBox) 'returns long
    If LocID < 100 Then LocID = Range("WorkCentre")
    Cells(CurRow, LocationIDCol) = LocID 'long
    
    Cells(CurRow, CommentsCol) = CommentBox
    Cells(CurRow, EntryDateCol) = Date
    If Left(ActivityBox, 8) = "Rest Day" Then Cells(CurRow, DutyCol) = 0 Else Cells(CurRow, DutyCol) = 1 'for conditional format
    Cells(CurRow, CatagoryCol) = 1 ' Activity Number (PV Duty)
    
    
    'Public Holiday - enter Comments and variance type
    If PubHol Then
        If variance > 0 Then 'the user chose extra time option
            Cells(CurRow, ATCol) = Format(variance / 24, "h:mm")
        End If
        Cells(CurRow, CommentsCol) = PenaltyBox
    End If
    
    
    If Cells(CurRow, StatusCol) = "saved" Or Cells(CurRow, StatusCol) = "updated" Then
        Cells(CurRow, StatusCol) = "updated"
    Else
        Cells(CurRow, StatusCol) = "entered"
    End If
    Cells(CurRow, FundCol) = Range("PVFundSource")
    
    'Add an RDO for the weekend day worked
    If Range("Takes_RDOs") = "yes" And Weekday(ThisDay, 2) > 5 Then
        Cells(CurRow, RWECol) = 1
    Else
        Cells(CurRow, RWECol).ClearContents
    End If
    
    UpdateWorkLifeBalance (GetPeriod(Cells(CurRow, DateCol))) 'Timesheet summary data for the period
    'Call CalculateTimesheetSummary(GetStartDate(), GetEndDate(ActiveCell.row))
    Call CalculateTimesheetSummary(0)

    Application.ScreenUpdating = True
   Cells(CurRow, DateCol).Select
End Sub

Private Sub Lb_MoreActivities_Click()
    Dim N As Integer
    If Caller = 1 Then Exit Sub 'Called from F&E, only one activity available
    ActivityBox.Clear
    N = 2
    While Range("ActivityList").Cells(N, 1) <> ""
        If Range("ActivityList").Cells(N, 14) = "closed" Or Range("ActivityList").Cells(N, 14) = "open" Then ActivityBox.AddItem (Range("ActivityList").Cells(N, 1))
        N = N + 1
    Wend
    ActivityBox.DropDown

End Sub

Private Sub Lb_MoreLocations_Click()
    Dim N As Integer
    LocationBox.Clear
    N = 2
    While Range("PVLocationList").Cells(N, 1) <> ""
        LocationBox.AddItem (Range("PVLocationList").Cells(N, 2))
        N = N + 1
    Wend
    LocationBox.DropDown

End Sub

Private Sub Lb_NewActivity_Click()
    Fm_Activity_New.Show
    If Fm_Activity_New.ActivityNameBox <> "" Then
        ActivityBox.AddItem (Fm_Activity_New.ActivityNameBox)
        ActivityBox = Fm_Activity_New.ActivityNameBox
        CheckForm
    End If

End Sub

Private Sub CalculateWorkedHours()
'This will populate the break, total hours and variance boxs

Dim TempVar As String
Dim ST As Single ' Start Time
Dim FT As Single ' Finish Time
Dim BR As Single ' Break
Dim EB As Single ' Extra Break
Dim WorkedHours As Single ' Total Hours Worked

    If StartTimeBox = "" Or FinishTimeBox = "" Then Exit Sub
    Calculating = True 'Disable click events (Extra break, Variance)
    '-----------------------------------------------------------------------------
    ST = TextToTime(StartTimeBox) ' convert Start Time string to single
    FT = TextToTime(FinishTimeBox) 'Finish Time
    If ExtraBreakBox <> "" Then
        EB = TextToTime(ExtraBreakBox)
        If Not ExtraBreakBox.MatchFound Then ExtraBreakBox = Format(EB / 24, "h:mm")
    Else
        EB = 0
    End If
    
    If FT < ST Then FT = FT + 24 'Finished on the following day
    WorkedHours = FT - ST
    If WorkedHours > 5 Then
        BR = 0.5
        BreakLabel = "0:30"
    Else
        BR = 0
        BreakLabel = "0:00"
    End If
        
    WorkedHours = FT - ST - BR - EB 'this is always positive
    TotalHoursLabel = Format(WorkedHours / 24, "h:mm")
    '-----------------------------------------------------------------------------
    'CALCULATE VARIANCE
    If PubHol Then
            If PenaltyBox <> PenaltyBox.List(0) Then 'Accrued Time Option Selected
                 variance = WorkedHours
                 If variance > 7.6 Then variance = 7.6 'Change requested by Tony Duras
            Else 'Extra Pay Option Selected
                variance = 0
            End If
            
    Else 'NOT PUBLIC HOLIDAY
            variance = Round(WorkedHours - PaidHours, 2)
            If Abs(variance) > 0.01 Then 'There is a variance (either + or -)
                ShowVariance
                VarianceTypeBox.Clear
                VarHoursLabel = Format(variance / 24, "h:mm") 'Show the Variance time
                
                'Short day ---------------------------------
                If variance < 0 Then
                    VarHoursLabel = "- " & VarHoursLabel
                    If Range("ATBalance") >= Abs(variance) Then
                        'Sufficient TIL so show TIL Option
                        VarianceTypeBox.AddItem ("Time in Lieu")
                    End If
                    VarianceTypeBox.AddItem ("Leave (subject to approval)")
                    If Range("ATBalance") > 0 Then
                        VarianceTypeBox.AddItem (VarianceOption)
                    End If
                    VarianceTypeBox = VarianceTypeBox.List(0)
               
                Else 'Long day ---------------------------------
                    If LCase(Range("ATAgreement")) = "yes" Then 'And Range("ATBalance") < Range("ATLimit") Then
                        VarianceTypeBox.AddItem ("Accrued Time")
                    End If
                    VarianceTypeBox.AddItem ("Overtime (subject to approval)")
                    VarianceTypeBox.AddItem ("Community Service")
                End If
                
                If Not VarianceTypeBox.MatchFound Then VarianceTypeBox = VarianceTypeBox.List(0)
            Else  'NO VARIANCE
                variance = 0
                VarianceTypeBox = ""
                HideVariance
            End If
    End If
    Calculating = False
End Sub

Private Sub CheckForm()
    FormReady = True
    If StartTimeBox = "" Then FormReady = False: StartTimeBox.BackColor = Red Else StartTimeBox.BackColor = Buff
    If FinishTimeBox = "" Then FormReady = False: FinishTimeBox.BackColor = Red Else FinishTimeBox.BackColor = Buff
    If variance <> 0 Then
        If Not PubHol Then
            If Not VarianceTypeBox.MatchFound Then FormReady = False: VarianceTypeBox.BackColor = Red Else VarianceTypeBox.BackColor = Buff
        End If
        IsCommentRequired
        If CommentRequired And Trim(CommentBox) = "" Then FormReady = False: CommentBox.BackColor = Red Else CommentBox.BackColor = Buff
    End If
    If Not ActivityBox.MatchFound Then FormReady = False: ActivityBox.BackColor = Red Else ActivityBox.BackColor = Buff
    If Not LocationBox.MatchFound Then FormReady = False: LocationBox.BackColor = Red Else LocationBox.BackColor = Buff
    
    
    
    If FormReady Then
        ContinueButton.Enabled = True
    Else
        ContinueButton.Enabled = False
    End If
End Sub

Private Sub CalculateFinishTime()
   If LCase(Range("AutoCalculateHours")) = "yes" And PaidHours > 0 Then
        If PaidHours > 5 Then  'Max 5 hours work without unpaid 1/2 hour break
            FinishTimeBox = Format((TextToTime(StartTimeBox) + PaidHours + 0.5) / 24, "h:mm") 'this format will not allow time > 23:59
        Else
            FinishTimeBox = Format((TextToTime(StartTimeBox) + PaidHours) / 24, "h:mm") 'this format will not allow time > 23:59
        End If
    End If

End Sub

Private Sub FindFocus()
    If FormReady Then ContinueButton.SetFocus: Exit Sub
    If StartTimeBox = "" Then StartTimeBox.SetFocus:  Exit Sub
    If FinishTimeBox = "" Then FinishTimeBox.SetFocus:  Exit Sub
    If LocationBox = "" Then LocationBox.SetFocus:  Exit Sub
    
    If ActivityBox = "" Then ActivityBox.SetFocus:  Exit Sub
    If VarianceVisible Then CommentBox.SetFocus:  Exit Sub
    
     AssistantButton.SetFocus

End Sub

Private Sub ShowVariance()
    Me.Height = 184
    VarianceVisible = True
    VarianceTypeBox.Top = Me.Height - 79
    VarHoursLabel.Top = VarianceTypeBox.Top
    VarianceLabel.Top = Me.Height - 81
    CommentBox.Top = VarianceTypeBox.Top
    CommentLabel.Top = VarianceLabel.Top
    CancelButton.Top = Me.Height - 54
    ContinueButton.Top = CancelButton.Top
    AssistantButton.Top = CancelButton.Top
    FundButton.Top = CancelButton.Top
    FundLabel.Top = CancelButton.Top + 12
End Sub

Private Sub HideVariance()
    Me.Height = 159
    VarianceVisible = False
    VarianceTypeBox.Top = Me.Height + 30
    VarianceLabel.Top = Me.Height + 30
    VarHoursLabel.Top = Me.Height + 30
    CommentBox = ""
    CommentBox.Top = Me.Height + 30
    CommentLabel.Top = Me.Height + 30
    CancelButton.Top = Me.Height - 56
    ContinueButton.Top = CancelButton.Top
    AssistantButton.Top = CancelButton.Top
    FundButton.Top = CancelButton.Top
    FundLabel.Top = CancelButton.Top + 12
End Sub

Private Sub ShowPublicHoliday()
    PenaltyBox.Visible = True
    HolidayLabel.Visible = True
    Lb_NormalHours_1.Visible = False
    Lb_NormalHours_2.Visible = False

End Sub

Private Sub HidePublicHoliday()
    PenaltyBox.Visible = False
    HolidayLabel.Visible = False
    Lb_NormalHours_1.Visible = True
    Lb_NormalHours_2.Visible = True
End Sub

Private Sub CancelButton_Click()
    Me.Hide
    Fm_Select_Activity.Show
End Sub

Private Sub IsCommentRequired()
    Dim CR As Boolean
    CR = False
    If Not PubHol Then
        CommentRequired = True: CR = True
        If VarianceTypeBox = "Accrued Time" Or VarianceTypeBox = "Time in Lieu" Then
            If Abs(variance) <= Range("ATMax") Then CommentRequired = False: CR = False
        End If
    Else
        CommentRequired = False
        Exit Sub
    End If
    If CR Then
        CommentLabel.ForeColor = DarkRed
    Else
        CommentLabel.ForeColor = Black
    End If
End Sub


