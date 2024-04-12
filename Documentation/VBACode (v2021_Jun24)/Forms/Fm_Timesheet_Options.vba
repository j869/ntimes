Option Explicit


Dim Activating As Boolean
Dim FirstRow As Integer
Dim LastRow As Integer


Private Sub UserForm_Activate()
    With Fm_Timesheet_Options
      .StartUpPosition = 0
      .Left = Application.Left + (0.5 * Application.Width) - (0.5 * .Width)
      .Top = Application.Top + (0.5 * Application.Height) - (0.5 * .Height)
    End With
    Me.Height = 115
    CloseButton.Top = 20
    DownButton.Visible = True: UpButton.Visible = False
    DoEvents
    
    Dim M As String
    Dim N As Integer
    
    Activating = True
    If Columns(LeaveCol).Hidden Then
        CommandButton2.Caption = "SHOW Variances"
    Else
        CommandButton2.Caption = "HIDE Variances"
    End If
    
    If Range("VarianceFormat") = "decimal" Then
        OptionDecimal.Value = True
    Else
        OptionHHMM.Value = True
    End If
    
    FirstRow = Range("StartDate").row
    LastRow = Range("EndDate").row
    ActivityBox = ""
    
    PeriodBox = Range("CurrentPeriod") 'This is what the timesheet currently displays
    If PeriodBox = "" Then PeriodBox = "July": Range("CurrentPeriod") = "July": Range("TimesheetMode") = "Month"
    M = Range("TimesheetMode")
    Select Case M
        Case "Month"
            OptionMonth.Value = True
            PeriodLabel = "Month of"
            PeriodBox.RowSource = "MonthTable"
        Case "Pay Period"
            OptionFortnight.Value = True
            PeriodLabel = "Period commencing"
            PeriodBox.RowSource = "PeriodTable"
        Case "Year"
            OptionYear.Value = True
            PeriodLabel = "Year"
            PeriodBox.RowSource = ""
            PeriodBox.AddItem (FinYear)
    End Select
    
    ActivityBox.Clear
    For N = Range("StartDate").row To Range("EndDate").row
        ActivityBox = Cells(N, ActivityCol)
        If ActivityBox <> "" And Not ActivityBox.MatchFound Then ActivityBox.AddItem (ActivityBox)
    Next
    ActivityBox = ""
    
    If Rows(Range("TitleBlock").row).Hidden Then
        ShowTitleBlock
        DisplayTimesheet
        ScrollToTop
    End If
    
    Activating = False
End Sub

Private Sub CommandButton2_Click()
    If Activating Then Exit Sub
    If CommandButton2.Caption = "SHOW Variances" Then
        Columns(LeaveCol).Hidden = False
        Columns(TILCol).Hidden = False
        Columns(ATCol).Hidden = False
        Columns(OTCol).Hidden = False
        Columns(CSCol).Hidden = False
        Columns(CommentsCol).Hidden = False
        CommandButton2.Caption = "HIDE Variances"
    Else
        Columns(LeaveCol).Hidden = True
        Columns(TILCol).Hidden = True
        Columns(ATCol).Hidden = True
        Columns(OTCol).Hidden = True
        Columns(CSCol).Hidden = True
        Columns(CommentsCol).Hidden = True
        CommandButton2.Caption = "SHOW Variances"
        If Columns(ActiveCell.Column).Hidden Then
            Cells(ActiveCell.row, DateCol).Select
        End If
    End If

End Sub

Private Sub OptionDecimal_Click()
    If Activating Then Exit Sub
'DISPLAY HOURS (decimal)
    
    Dim R As Integer
    Range("VarianceFormat") = "decimal"
    For R = Range("StartDate").row To Range("EndDate").row
        If Cells(R, ATCol) <> "" Then Cells(R, ATCol) = TextToTime(Cells(R, ATCol)): Cells(R, ATCol) = TimeToText(Cells(R, ATCol), 1)
        If Cells(R, TILCol) <> "" Then Cells(R, TILCol) = TextToTime(Cells(R, TILCol)): Cells(R, TILCol) = TimeToText(Cells(R, TILCol), 1)
        If Cells(R, LeaveCol) <> "" Then Cells(R, LeaveCol) = TextToTime(Cells(R, LeaveCol)): Cells(R, LeaveCol) = TimeToText(Cells(R, LeaveCol), 1)
        If Cells(R, OTCol) <> "" Then Cells(R, OTCol) = TextToTime(Cells(R, OTCol)): Cells(R, OTCol) = TimeToText(Cells(R, OTCol), 1)
        If Cells(R, CSCol) <> "" Then Cells(R, CSCol) = TextToTime(Cells(R, CSCol)): Cells(R, CSCol) = TimeToText(Cells(R, CSCol), 1)
    Next
    Range("VarianceHeader") = "Variance to Work Hours : (Decimal)"
    'Call CalculateTimesheetSummary(0)

End Sub

Private Sub OptionHHMM_Click()
    If Activating Then Exit Sub
'DISPLAY HOURS (HH:MM)

    Dim R As Integer
    Range("VarianceFormat") = "hh:mm"
    For R = Range("StartDate").row To Range("EndDate").row
        If Cells(R, ATCol) <> "" Then Cells(R, ATCol) = TextToTime(Cells(R, ATCol)): Cells(R, ATCol) = TimeToText(Cells(R, ATCol), 1)
        If Cells(R, TILCol) <> "" Then Cells(R, TILCol) = TextToTime(Cells(R, TILCol)): Cells(R, TILCol) = TimeToText(Cells(R, TILCol), 1)
        If Cells(R, LeaveCol) <> "" Then Cells(R, LeaveCol) = TextToTime(Cells(R, LeaveCol)): Cells(R, LeaveCol) = TimeToText(Cells(R, LeaveCol), 1)
        If Cells(R, OTCol) <> "" Then Cells(R, OTCol) = TextToTime(Cells(R, OTCol)): Cells(R, OTCol) = TimeToText(Cells(R, OTCol), 1)
        If Cells(R, CSCol) <> "" Then Cells(R, CSCol) = TextToTime(Cells(R, CSCol)): Cells(R, CSCol) = TimeToText(Cells(R, CSCol), 1)
    Next
    Range("VarianceHeader") = "Variance to Work Hours : (HH:MM)"
    'Call CalculateTimesheetSummary(0)
End Sub



Private Sub OptionFortnight_Click()
    If Activating Then Exit Sub
    Dim N As Integer
    If Rows(Range("TitleBlock").row).Hidden Then ShowTitleBlock
    Range("TimesheetMode") = "Pay Period"
    PeriodLabel = "Period commencing"
    PeriodBox.RowSource = "PeriodTable"
    
     Select Case Date
        Case Is < Range("StartDate"):
            PeriodBox = PeriodBox.List(0) 'first pay period
        Case Is >= Range("EndDate")
            PeriodBox = PeriodBox.List(PeriodBox.ListCount - 1) 'Last Payperiod
        Case Else
             N = 1
            While CDate(Range("PeriodTable").Cells(N)) + 14 < Date
                N = N + 1
            Wend
            PeriodBox = PeriodBox.List(N - 1)
        End Select
        'PeriodBox_Change event redraws the timesheet
End Sub

Private Sub OptionMonth_Click()
    If Activating Then Exit Sub
    If Rows(Range("TitleBlock").row).Hidden Then ShowTitleBlock
    Range("TimesheetMode") = "Month"
    PeriodLabel = "Month of "
    PeriodBox.RowSource = "MonthTable"
    Select Case Date
        Case Is < Range("StartDate")
            PeriodBox = "July"   'This causes PeriodBox_change event
        Case Is > Range("EndDate")
            PeriodBox = "June"  'This causes PeriodBox_change event
        Case Else
            PeriodBox = MonthName(Month(Date), False)
    End Select
        'PeriodBox_Change event redraws the timesheet
End Sub

Private Sub OptionYear_Click()
    If Activating Then Exit Sub
    If Rows(Range("TitleBlock").row).Hidden Then ShowTitleBlock
    Dim CurrentDayRow As Integer
    Range("TimesheetMode") = "Year"
    PeriodLabel = "Year"
    PeriodBox.RowSource = ""
    PeriodBox.Clear
    PeriodBox.AddItem (FinYear)
    PeriodBox = FinYear
    'PeriodBox_Change event redraws the timesheet

    CurrentDayRow = DateDiff("d", Range("StartDate"), Date)
    
    Select Case CurrentDayRow
        Case Is < 1: Cells(Range("StartDate").row, 2).Select 'Start date of timesheet
        Case Is > 366: Cells(Range("EndDate").row, 2).Select 'Last Day of timesheet
        Case Else: Cells(CurrentDayRow + Range("StartDate").row, 2).Select 'Current Date
    End Select
End Sub


Private Sub DownButton_Click()
    Me.Height = 310
    CloseButton.Top = 255
    DownButton.Visible = False: UpButton.Visible = True
End Sub

Private Sub upButton_Click()
   
    Dim p As String
    Activating = True
    Me.Height = 115
    CloseButton.Top = 20
    If Rows(Range("TitleBlock").row).Hidden Then ShowTitleBlock
    
    DownButton.Visible = True: UpButton.Visible = False
    FirstRow = 15
    LastRow = Range("EndDate").row
    Activating = True
    ActivityBox = ""
    PeriodBox = Range("CurrentPeriod") 'This is what the timesheet currently displays
    If PeriodBox = "" Then PeriodBox = "July": Range("CurrentPeriod") = "July": Range("TimesheetMode") = "Month"
    p = Range("TimesheetMode")
    Select Case p
        Case "Month"
            OptionMonth.Value = True
            PeriodLabel = "Month of"
            PeriodBox.RowSource = "MonthTable"
        Case "Pay Period"
            OptionFortnight.Value = True
            PeriodLabel = "Period commencing"
            PeriodBox.RowSource = "PeriodTable"
        Case "Year"
            OptionYear.Value = True
            PeriodLabel = "Year"
            PeriodBox.RowSource = ""
            PeriodBox.AddItem (FinYear)
    End Select
    DisplayTimesheet
    ScrollToTop
    
    Activating = False
    
End Sub

Private Sub PeriodBox_change()
    If Activating Then Exit Sub
    Range("CurrentPeriod") = PeriodBox.Text

    DisplayTimesheet
    ScrollToTop
    CloseButton.SetFocus
End Sub

'Show the month or period selected by the user
Sub DisplayTimesheet()
    Dim V, N As Integer
    Application.ScreenUpdating = False
    CancelTimeEntry = False 'Allow timesheet data entry
    'Find the start and end dates
   Dim SD As Date
   Dim ED As Date
    If Range("TimesheetMode") = "Month" Then
        For N = 1 To Range("MonthTable").Cells.Count
            If PeriodBox = Range("MonthTable").Cells(N) Then
                SD = Range("MonthTable").Cells(N, 2)
                ED = Range("MonthTable").Cells(N, 3)
                Exit For
            End If
        Next
        Call showTimesheet_(SD, ED)
    
    ElseIf Range("TimesheetMode") = "Pay Period" Then
        For N = 1 To Range("PeriodTable").Cells.Count
            If CDate(PeriodBox) = Range("PeriodTable").Cells(N) Then
                SD = Range("PeriodTable").Cells(N, 2)
                ED = Range("PeriodTable").Cells(N, 3)
                Exit For
            End If
        Next
        Call showTimesheet_(SD, ED)

    Else 'Year
        Rows(FirstRow & ":" & LastRow).Select
        Selection.EntireRow.Hidden = False
            
        If Date < Range("StartDate") Then
            Cells(Range("StartDate").row, 3).Select
        ElseIf Date > Range("EndDate") Then
            Cells(Range("EndDate").row, 3).Select
        Else
            V = DateDiff("d", Range("StartDate"), Date) + Range("StartDate").row
                Cells(V, 3).Select
        End If
        SD = Range("StartDate")
        ED = Range("EndDate")
        

    End If
    
    'Call CalculateTimesheetSummary(SD, ED)
    Call CalculateTimesheetSummary(0)
    Application.ScreenUpdating = True
End Sub

Private Sub showTimesheet_(S As Date, e As Date)
    Dim R As Integer
    Sheets("Timesheet").Rows(FirstRow & ":" & LastRow).Select
    Selection.EntireRow.Hidden = True
    For R = FirstRow To LastRow
        If Cells(R, DateCol) >= S And Cells(R, DateCol) <= e Then Rows(R).EntireRow.Hidden = False
        If Cells(R, DateCol) > e Then Exit For
    Next
    Range("C7").Select
End Sub


Private Sub OptionLeaveDays_Click() 'Annual Leave
If Activating Then Exit Sub
CancelTimeEntry = True
Dim R As Integer
Activating = True
HideTitleBlock
PeriodBox = ""

Application.ScreenUpdating = False
    
    Rows(FirstRow & ":" & LastRow).Select
    Selection.EntireRow.Hidden = True
    For R = FirstRow To LastRow
        If Cells(R, CatagoryCol) = 3 Or Cells(R, CatagoryCol) = 4 Then Rows(R).EntireRow.Hidden = False
    Next
    ScrollToTop
    Application.ScreenUpdating = True
    Activating = False

End Sub

Private Sub OptionRosteredDaysOff_Click() 'Rostered Days Off
If Activating Then Exit Sub
CancelTimeEntry = True
Dim R As Integer
Activating = True
HideTitleBlock
PeriodBox = ""

Application.ScreenUpdating = False

    Rows(FirstRow & ":" & LastRow).Select
    Selection.EntireRow.Hidden = True
    For R = FirstRow To LastRow
        If Cells(R, CatagoryCol) = 6 Then Rows(R).EntireRow.Hidden = False
    Next
    ScrollToTop
    Application.ScreenUpdating = True
    Activating = False

End Sub

Private Sub OptionPublicHolidays_Click() 'Public Holidays

If Activating Then Exit Sub
CancelTimeEntry = True

Dim R, N As Integer
Activating = True
HideTitleBlock
PeriodBox = ""

Application.ScreenUpdating = False

    Rows(FirstRow & ":" & LastRow).Select
    Selection.EntireRow.Hidden = True
    For R = FirstRow To LastRow
        For N = 0 To Range("PublicHolidays").Rows.Count - 1
             If Cells(R, DateCol) = Range("PublicHolidays").Cells(N) Then Rows(R).EntireRow.Hidden = False
        Next
    Next
    ScrollToTop
    Application.ScreenUpdating = True
    Activating = False

End Sub

Private Sub OptionERDays_Click() 'Emergency Response
If Activating Then Exit Sub
CancelTimeEntry = True

Dim R As Integer
HideTitleBlock
Activating = True
PeriodBox = ""

Application.ScreenUpdating = False

    Rows(FirstRow & ":" & LastRow).Select
    Selection.EntireRow.Hidden = True
    For R = FirstRow To LastRow
        If Cells(R, CatagoryCol) = 2 Then Rows(R).EntireRow.Hidden = False
    Next
    ScrollToTop
    Application.ScreenUpdating = True
    Activating = False
End Sub

Private Sub OptionWeekendDays_Click() 'Weekend days

    If Activating Then Exit Sub
    CancelTimeEntry = True

    Dim R As Integer
    Activating = True
    PeriodBox = ""
    HideTitleBlock
    Application.ScreenUpdating = False
    
        Rows(FirstRow & ":" & LastRow).Select
        Selection.EntireRow.Hidden = True
        For R = FirstRow To LastRow
            If Weekday(Cells(R, DateCol), 2) > 5 Then Rows(R).EntireRow.Hidden = False
        Next
        ScrollToTop
        Application.ScreenUpdating = True
        Activating = False
End Sub

Private Sub OptionPVWork_Click() 'PV Work Day

If Activating Then Exit Sub
CancelTimeEntry = True

Dim R As Integer
Activating = True
PeriodBox = ""
HideTitleBlock
Application.ScreenUpdating = False

    Rows(FirstRow & ":" & LastRow).Select
    Selection.EntireRow.Hidden = True
    For R = FirstRow To LastRow
        If Cells(R, CatagoryCol) = 1 Then Rows(R).EntireRow.Hidden = False
    Next
    ScrollToTop
    Application.ScreenUpdating = True
    Activating = False
End Sub

Private Sub ActivityBox_Click()
    If Activating Then Exit Sub
    CancelTimeEntry = True

    Activating = True
    Dim R As Integer
    HideTitleBlock
    PeriodBox = ""
    Application.ScreenUpdating = False

    If ActivityBox <> "" Then
        Rows(FirstRow & ":" & LastRow).Select
        Selection.EntireRow.Hidden = True
        For R = FirstRow To LastRow
            If Cells(R, ActivityCol) = ActivityBox Then Rows(R).EntireRow.Hidden = False
        Next
    End If
    ScrollToTop
    Application.ScreenUpdating = True
    Activating = False
End Sub


Private Sub CloseButton_Click()
    Me.Hide
End Sub

Private Sub ScrollToTop()
Dim R As Integer
    For R = FirstRow To LastRow
        If Not Rows(R).Hidden Then
            Application.GoTo ActiveSheet.Cells(R, 1), True
            Exit For
        End If
    Next

End Sub


Private Sub CommandButton1_Click() 'PRINT
    Me.Hide
    Fm_Print.Show
End Sub

Private Sub ShowTitleBlock()
Dim N As Integer
N = Range("TitleBlock").row
Rows(N & ":" & N + 16).Hidden = False
End Sub

Private Sub HideTitleBlock()
Dim N As Integer
N = Range("TitleBlock").row
Rows(N & ":" & N + 16).Hidden = True
End Sub

