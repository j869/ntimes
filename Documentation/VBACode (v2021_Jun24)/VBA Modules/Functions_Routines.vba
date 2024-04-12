Option Explicit

Function GetFolder() As String
Dim fldr As FileDialog
Dim sItem As String
Dim strPath As String
Set fldr = Application.FileDialog(msoFileDialogFolderPicker)
With fldr
    .Title = "Select where your printed timesheet will be stored"
    .AllowMultiSelect = False
    .InitialFileName = strPath
    If .Show <> -1 Then GoTo NextCode
    sItem = .SelectedItems(1)
End With
NextCode:
GetFolder = sItem
Set fldr = Nothing
End Function

Sub ToggleFundSrcCol()
    If Columns(FundCol).Hidden Then
        Columns(FundCol).Hidden = False
    Else
        Columns(FundCol).Hidden = True
    End If
    
End Sub

Sub UnlockTimesheet()
    If GetPassword("Please enter the unlock passcode ") = "pvts" Then
    
        Application.ScreenUpdating = False
        Dim currentSheet As String
        currentSheet = ActiveSheet.Name
        
        Sheets("Timesheet").Unprotect Password:=Pword
        Sheets("Timesheet").Activate
        'Columns("V:Z").EntireColumn.Hidden = False
        Range(Columns(EntryDateCol), Columns(RWECol)).EntireColumn.Hidden = False
        ActiveWindow.DisplayHeadings = True
        
        Sheets("Work Life Balance").Unprotect Password:=Pword
        Sheets("Work Life Balance").Activate
        ActiveWindow.DisplayHeadings = True
        
        Sheets("Admin").Unprotect Password:=Pword
        Sheets("Admin").Activate
        ActiveWindow.DisplayHeadings = True
        
        Sheets("Activity").Unprotect Password:=Pword
        Sheets("Activity").Activate
        ActiveWindow.DisplayHeadings = True
        
        
        Sheets("PV").Unprotect Password:=Pword
        Sheets("PV").Select
        Sheets("PV").Cells(1, 1).Select
        ActiveWindow.DisplayHeadings = True
        
        ActiveWindow.DisplayWorkbookTabs = True
        Application.DisplayFormulaBar = True
        Application.ExecuteExcel4Macro "SHOW.TOOLBAR(""Ribbon"",True)"
        
        Sheets(currentSheet).Activate
        Application.ScreenUpdating = True
    
    Else
        MsgBox "Incorrect Password or user cancel", vbExclamation, MsgCaption
    End If

    If Environ("username") = "jmaher" Then   'regain ctrl key
        Dim oCtrl As Office.CommandBarControl
        'Enable all Cut menus
             For Each oCtrl In Application.CommandBars.FindControls(ID:=21)
                    oCtrl.Enabled = True
             Next oCtrl
             
        'Enable all Copy menus
             For Each oCtrl In Application.CommandBars.FindControls(ID:=19)
                    oCtrl.Enabled = True
             Next oCtrl
            Application.CellDragAndDrop = True
            
        'Show Tabs, Formula bar and Ribbon
        ActiveWindow.DisplayWorkbookTabs = True
        Application.DisplayFormulaBar = True
        Application.ExecuteExcel4Macro "SHOW.TOOLBAR(""Ribbon"",true)"
        Dim N As Long
        For N = 1 To 100000000: Next
    End If

End Sub

Sub LockTimesheet()
Exit Sub
        Application.ScreenUpdating = False
        Dim currentSheet As String
        currentSheet = ActiveSheet.Name
        
        Sheets("Timesheet").Activate
        ActiveSheet.Unprotect Password:=Pword
        ActiveSheet.Shapes("UpdateIcon").Top = 5 'Park Update icon
        ActiveSheet.Shapes("UpdateIcon").Visible = False
        ActiveWindow.DisplayHeadings = False
        'Columns("V:Z").EntireColumn.Hidden = True
        Range(Columns(EntryDateCol), Columns(RWECol)).EntireColumn.Hidden = True
        ActiveSheet.Protect Password:=Pword, UserInterfaceOnly:=True, DrawingObjects:=True, Contents:=True, Scenarios:=True
        
        Sheets("Work Life Balance").Activate
        ActiveSheet.Unprotect Password:=Pword
        ActiveWindow.DisplayHeadings = False
        ActiveSheet.Protect Password:=Pword, UserInterfaceOnly:=True, DrawingObjects:=True, Contents:=True, Scenarios:=True
        ActiveSheet.EnableSelection = xlUnlockedCells
        
        Sheets("Admin").Activate
        ActiveSheet.Unprotect Password:=Pword
        ActiveWindow.DisplayHeadings = False
        ActiveSheet.Protect Password:=Pword, UserInterfaceOnly:=True, DrawingObjects:=True, Contents:=True, Scenarios:=True
        
        Sheets("Activity").Activate
        ActiveSheet.Unprotect Password:=Pword
        ActiveWindow.DisplayHeadings = False
        ActiveSheet.Protect Password:=Pword, UserInterfaceOnly:=True, DrawingObjects:=True, Contents:=True, Scenarios:=True
        
        Sheets("PV").Select
        Cells(1, 1).Select
        ActiveWindow.DisplayHeadings = False
        ActiveSheet.Protect Password:=Pword, UserInterfaceOnly:=True, DrawingObjects:=True, Contents:=True, Scenarios:=True
        ActiveSheet.EnableSelection = xlUnlockedCells
        
        Sheets(currentSheet).Activate
        Application.ScreenUpdating = True
        
        'Hide the Ribbon (Called by Workbook Open)
        ActiveWindow.DisplayWorkbookTabs = False
        Application.DisplayFormulaBar = False
        Application.ExecuteExcel4Macro "SHOW.TOOLBAR(""Ribbon"",False)"
        
End Sub



Public Sub CalculateTimesheetSummary(i As Integer) 'Update timesheet summary at bottom of timesheet
    'NOTE i is used only to hide the routine
        Dim SD, ED As Date
        Dim ATCarried As Single 'Accrued time carried
        Dim TIL As Single
        Dim AT As Single 'Accrued Time
        Dim N, RDOCarried, WeekendDaysWorked, RDOs As Integer
        Dim RecDate As Date
        Dim sh1 As Worksheet
        Dim TimeStr  As String
    'Get the start date of the displayed timesheet
    N = Range("StartDate").row
    While Rows(N).Hidden
        N = N + 1
    Wend
    SD = Cells(N, DateCol) 'Start Date
    
    'Get the end date of the displayed timesheet
    While Not Rows(N).Hidden And N < Range("EndDate").row + 1
        N = N + 1
    Wend
    ED = Cells(N - 1, DateCol) 'End Date
    
    '-------------------------------------------------
        
    Set sh1 = Sheets("Timesheet")
    WeekendDaysWorked = 0: RDOs = 0: AT = 0: TIL = 0
    ATCarried = Val(Range("ATCarried"))
    RDOCarried = Val(Range("RDOCarried"))
        
    ' Calculate opening balance for AT, RDOs as of PeriodStart Date------------------
    N = Range("StartDate").row
    While sh1.Cells(N, DateCol) < SD
        If sh1.Cells(N, ATCol) <> "" Then ATCarried = ATCarried + TextToTime(sh1.Cells(N, ATCol))
        If sh1.Cells(N, TILCol) <> "" Then TIL = TIL + TextToTime(sh1.Cells(N, TILCol))
            
        'Get Weekend days worked and RDO totals
        If Weekday(sh1.Cells(N, DateCol), 2) > 5 Then
            If sh1.Cells(N, RWECol) = 1 Then WeekendDaysWorked = WeekendDaysWorked + 1 'Count weekend days worked (for RDO purposes)
        Else
            If Val(sh1.Cells(N, CatagoryCol)) = 6 Then RDOCarried = RDOCarried - 1 'Count RDOs
        End If
        N = N + 1
    Wend
        
    ATCarried = ATCarried + TIL 'This is the AT OPENING for the displayed period
    Range("Timesheet_Summary").Cells(2, 7) = TimeToText(ATCarried, 0) 'Always H:MM
    TIL = 0
        
    RDOCarried = RDOCarried + WeekendDaysWorked
    Range("Timesheet_Summary").Cells(8, 7) = RDOCarried 'Opening RDO Balance
    WeekendDaysWorked = 0
         
    '----------------- Now, Calculate totals for displayed period -----------
    While sh1.Cells(N, DateCol) <= ED And N < Range("EndDate").row + 1
        If sh1.Cells(N, ATCol) <> "" Then AT = AT + TextToTime(sh1.Cells(N, ATCol))
        If sh1.Cells(N, TILCol) <> "" Then TIL = TIL + TextToTime(sh1.Cells(N, TILCol))
            
        If Weekday(sh1.Cells(N, DateCol), 2) > 5 Then
            If sh1.Cells(N, RWECol) = 1 Then WeekendDaysWorked = WeekendDaysWorked + 1 'Count weekend days worked (for RDO purposes)
        Else
            If Val(sh1.Cells(N, CatagoryCol)) = 6 Then RDOs = RDOs + 1 'Count RDOs
        End If
            
        N = N + 1
    Wend
        
    Range("Timesheet_Summary").Cells(3, 7) = TimeToText(AT, 0)
    Range("Timesheet_Summary").Cells(4, 7) = TimeToText(TIL, 0)
    Range("Timesheet_Summary").Cells(5, 7) = TimeToText(ATCarried + AT + TIL, 0)
        
    Range("Timesheet_Summary").Cells(8, 7) = RDOCarried
    Range("Timesheet_Summary").Cells(9, 7) = WeekendDaysWorked
    Range("Timesheet_Summary").Cells(10, 7) = RDOs
    Range("Timesheet_Summary").Cells(11, 7) = RDOCarried + WeekendDaysWorked - RDOs
        

End Sub

Function GetWeekendHours() As Single
        'returns weekend hours if weekend hours are anywhere on the PaidHours Table
        'or returns the highest hours value for a weekday
        Dim T1 As Single
       
        T1 = 0
        If Val(Range("PaidHours").Cells(1)) > 0 Then T1 = Val(Range("PaidHours").Cells(1))
        If Val(Range("PaidHours").Cells(7)) > T1 Then T1 = Val(Range("PaidHours").Cells(7))
        If Val(Range("PaidHours").Cells(8)) > T1 Then T1 = Val(Range("PaidHours").Cells(8))
        If Val(Range("PaidHours").Cells(14)) > T1 Then T1 = Val(Range("PaidHours").Cells(14))
        If T1 > 0 Then GetWeekendHours = T1 Else GetWeekendHours = 7.6
End Function



Function ActivityExists(ActivityName As String) As Boolean
        'Check for duplicate name
        Dim N% 'Integer
        N = 2
        Do While Range("ActivityList").Cells(N, 1) <> ""
            If LCase(ActivityName) = LCase(Range("ActivityList").Cells(N, 1)) Then ActivityExists = True: Exit Do
            N = N + 1
        Loop
End Function

Function PadString(S As String, N As Integer) As String
    While Len(S) < N
        S = S & " "
    Wend
    PadString = S
End Function

Function GetPublicHoliday(D As Date) As String
    Dim N As Integer
    For N = 1 To Range("PublicHolidays").Cells.Count
        If Range("PublicHolidays").Cells(N) = D Then
            GetPublicHoliday = Range("PublicHolidays").Cells(N, 0)
            Exit For
        End If
    Next
End Function

Function IsPublicHoliday(D As Date) As Boolean
    Dim N As Integer
    IsPublicHoliday = False
    For N = 1 To Range("PublicHolidays").Cells.Count
        If Range("PublicHolidays").Cells(N) = D Then
            IsPublicHoliday = True
            Exit For
        End If
    Next
End Function

Function GetPeriodDayNumber(D As Date) As Integer
'Get the day number in a pay period for a given date
    Dim N As Integer
    N = 1
    While Range("PeriodTable").Cells(N, 3) < D
        N = N + 1
    Wend
    GetPeriodDayNumber = DateDiff("d", Range("PeriodTable").Cells(N), D) + 1
End Function

Function GetPassword(C As String) As String
    Fm_Password.Label1.Caption = C
    Fm_Password.Show
    GetPassword = Fm_Password.PasswordBox

End Function

Function TextToTime(T As String) As Single
'Convert a time string e.g. "4:25" to single precision integer
    If T = vbNullString Then TextToTime = 0: Exit Function
    
     Dim IsNeg As Boolean
     Dim colon As Integer
     Dim M, Hours, mins As Single
    
    
    If Left(T, 1) = "-" Then
        IsNeg = True
        T = Right(T, Len(T) - 1) 'remove negative sign
    Else
        IsNeg = False
    End If
    
    If InStr(T, ":") > 0 Then
   
        'Is there a colon?
        colon = InStr(T, ":") 'get location of the colon in the string
        If colon = 0 Then colon = Len(T) + 1: T = T & ":00" 'eg user typed '12' instead of 12:00
        Hours = Val(Left(T, colon - 1))
        If Hours > 23 Then Hours = 0
        mins = Val(Right(T, Len(T) - colon))
        If mins > 59 Then mins = 0
        M = Hours * 60
        M = M + mins
        If IsNeg Then M = M * -1
        TextToTime = M / 60
    Else
        Hours = Round(CSng(T), 2)
        If IsNeg Then Hours = Hours * -1

        'mins = Round(Hours - Fix(T), 2)
        TextToTime = Hours
    End If
End Function

Function TimeToText(T As Single, F As Integer) As String 'F=Format Flag, 0=HMS, 1=Dec/HMS depending on user option [Range("VarianceFormat")]
    If F = 1 And Range("VarianceFormat") = "decimal" Then
        TimeToText = Format(T, "0.00")
    Else
            'if the number is negative, return "-" prefix
            Dim H, M, R As String
            Dim S As Single
            S = T
            If S < 0 Then R = "-": S = S * -1 Else R = ""
            H = Format(CStr(Fix(S)), "0")
            S = Round(S - Fix(S), 2)
            M = Format(S * 60, "00")
            TimeToText = R & H & ":" & M
    End If
    'JJJJ
End Function

Function GetPeriod(D As Date) As Integer
'Get the pay period number for a given date
    Dim p As Integer
    
    p = Month(D)
        If p > 6 Then
            GetPeriod = p - 6
        Else
            GetPeriod = p + 6
        End If
End Function


Function GetFundSourceNumber(S As String) As String
   Dim N As Integer
   N = 2
    GetFundSourceNumber = "000" 'Default return value
    Do While Range("FundSourceList").Cells(N, 1) <> ""
        If Range("FundSourceList").Cells(N, 2) = S Then
            GetFundSourceNumber = Range("FundSourceList").Cells(N, 1)
            Exit Do
        End If
        N = N + 1
    Loop
End Function

Function GetFundSourceName(S As String) As String
    Dim N As Integer
    N = 2
    Do While Range("FundSourceList").Cells(N, 1) <> ""
        If S = Range("FundSourceList").Cells(N, 1) Then
            GetFundSourceName = Range("FundSourceList").Cells(N, 2)
            Exit Do
        End If
        N = N + 1
    Loop
End Function

Function GetProgramName(S As String) As String
    Dim N As Integer

    N = 2
    Do While Range("ProgramList").Cells(N, 2) <> ""
        If S = Range("ProgramList").Cells(N, 2) Then
            S = Range("ProgramList").Cells(N, 3)
            Exit Do
        End If
        N = N + 1
    Loop
    N = 2
    Do While Range("ProgramList").Cells(N, 2) <> ""
        If S = Range("ProgramList").Cells(N, 2) Then
            GetProgramName = PadString(Range("ProgramList").Cells(N, 1), 5) & " " & Range("ProgramList").Cells(N, 2) & " " & Range("ProgramList").Cells(N, 4)
            Exit Do
        End If
        N = N + 1
    Loop

End Function


Function ActivityIsUsed(ActivityName As String) As Boolean
    Dim row As Integer
    row = Sheets("Timesheet").Range("StartDate").row
    Do While IsDate(Sheets("Timesheet").Cells(row, DateCol))
        If Sheets("Timesheet").Cells(row, ActivityCol) = ActivityName Then ActivityIsUsed = True: Exit Do
        row = row + 1
    Loop
    
End Function

Function getActivityRowNumber(ActivityName As String) As Integer
        Dim N As Integer
        
        getActivityRowNumber = 0
        N = 2
        Do While Range("ActivityList").Cells(N, 1) <> ""
                If Range("ActivityList").Cells(N, 1) = ActivityName Then
                getActivityRowNumber = N
                Exit Do
                End If
                N = N + 1
        Loop
End Function

Function GetLocationID(L As String) As Long
    Dim N As Integer
    GetLocationID = 0
    N = 2
    Do While Range("PVLocationList").Cells(N, 1) <> ""
        If L = Range("PVLocationList").Cells(N, 2) Then
            GetLocationID = Range("PVLocationList").Cells(N)
            Exit Do
        End If
        N = N + 1
    Loop
End Function

Function GetLocationName(L As Long) As String
    Dim N As Integer
    GetLocationName = ""
    N = 2
    Do While Range("PVLocationList").Cells(N, 1) <> ""
        If L = Range("PVLocationList").Cells(N, 1) Then
            GetLocationName = Range("PVLocationList").Cells(N, 2)
            Exit Do
        End If
        N = N + 1
    Loop
End Function


Public Sub ClearSetup()
    'based on ClearSetup2() from Fm_Timesheet_Setup
    Dim N, R As Integer
    Dim ws As Worksheet
    Set ws = ActiveSheet
    Application.EnableEvents = False
    
    Sheets("Admin").Select: Range("LastName").Select
    For N = 1 To 17
        Range("LastName").Cells(N).Select
        Range("LastName").Cells(N) = ""
    Next
    For N = 1 To 15
        Range("PaidHours").Cells(N).Select
        Range("PaidHours").Cells(N) = ""
    Next
    'Sheets("Timesheet").Range("Office") = ""
    Range("AutoCalculateHours") = "yes"     'B24
    Range("TimesheetMode") = "Month"        'B25
    Range("CurrentPeriod") = "July"         'B26
    Range("AdvanceEntry") = "14"            'B27
    Range("ATMax") = "0.4"                  'B28
    Range("ATLimit") = "500"                'B29
    Range("B30") = "0"                      'B30 RDO Minimum
    Range("PVFundSource") = "000"           'B31
    Range("TSVersion") = "1.0"              'B32
    Range("VarianceFormat") = "hh:mm"       'B33
    
    Sheets("Timesheet").Select
    If Environ("username") = "jmaher" Then      'clear test data
        For R = Range("StartDate").row To Range("EndDate").row
            If Cells(R, EntryDateCol) <> "" Then  'timesheet data on this row
                Range(Cells(R, 4), Cells(R, 29)).ClearContents
            End If
            DoEvents
        Next R
    End If
    ws.Select
    Application.StatusBar = False
    Application.EnableEvents = True
    
    Sheets("PV").TimesheetButton.Enabled = False
    Sheets("PV").WorkLifeButton.Enabled = False
    Sheets("PV").InformationButton.Enabled = True
    
    Call logDataEntry("ClearSetup() > Timesheet setup values cleared")
End Sub

Public Sub ClearTimesheetRow(R As Integer)
    Dim C As Integer
    If ActiveSheet.Name <> "Timesheet" Then Exit Sub
If R >= Range("StartDate").row And R <= Range("EndDate").row Then
    For C = StartCol To ActivityCol
            Sheets("Timesheet").Cells(R, C).ClearContents
    Next
    Sheets("Timesheet").Cells(R, DutyCol).ClearContents 'On/Off Duty (for conditional format)
    Sheets("Timesheet").Cells(R, CatagoryCol).ClearContents 'Activity Number (1=PV Work, 2 = Emerg Resp etc)
    Sheets("Timesheet").Cells(R, RWECol).ClearContents 'Rostered Weekend day worked
Else
    MsgBox "Incorrect call to ClearTimesheetRow", vbExclamation, MsgCaption
End If
End Sub

Public Sub UpdateWorkLifeBalance(period As Integer) 'Update work-life balance info for the period

    Dim N, Trow, Pd As Integer
    Dim ActivityNumber, WeekendsWorked As Integer
    Dim Var, VarV, ATBal As Single
    Dim sh1 As Worksheet
    Set sh1 = Sheets("Timesheet")
    
    '*****  Work Life Table Column References *****
    Const ND = 2 'Normal duty
    Const ER = 3 'Emergency Response
    Const OD = 4 'Off duty column
    Const AL = 5 'Annual Leave
    Const OL = 6 'Other Leave
    Const WE = 7 'Weekeend days worked
    Const RDO = 8 'rostered days off
    Const RDOB = 9 ' rostered days balance
    Const CS = 10 'Community Service
    Const OT = 11 'Overtime
    Const AT = 12 'Accrued Time
    Const TIL = 13 'Time in lieu
    Const ATB = 14 'At balance
    Const STAT = 15 ' status column ( saved, updated)
    Application.ScreenUpdating = False
    
    'clear the row for the period on the work-life balance sheet
    For N = 2 To 14
       Range("WorkTable").Cells(period, N).ClearContents
    Next
    
    Range("ATOpen") = TimeToText(Range("ATCarried"), 0) '0 = return as HH:MM
    Range("RDOOpen") = Range("RDOCarried")
    Range("WorkTable").Cells(period, STAT) = "updated" 'flag that row has been updated
    '-------------------------------------------------------------
    For Trow = Range("StartDate").row To Range("EndDate").row 'All timesheet rows
        Pd = GetPeriod(sh1.Cells(Trow, DateCol)) 'Period
        If Pd = period Then
                'Process any Variance
                'Time in lieu
                If sh1.Cells(Trow, TILCol) <> vbNullString Then
                    VarV = (TextToTime(sh1.Cells(Trow, TILCol)) / 24) * -1
                    Range("WorkTable").Cells(period, TIL) = Range("WorkTable").Cells(period, TIL) + VarV
                End If
                
                'Accrued Time
                If sh1.Cells(Trow, ATCol) <> vbNullString Then
                    VarV = TextToTime(sh1.Cells(Trow, ATCol)) / 24
                    Range("WorkTable").Cells(period, AT) = Range("WorkTable").Cells(period, AT) + VarV
                End If
                
                'Overtime
                If sh1.Cells(Trow, OTCol) <> vbNullString Then
                    VarV = TextToTime(sh1.Cells(Trow, OTCol)) / 24
                    Range("WorkTable").Cells(period, OT) = Range("WorkTable").Cells(period, OT) + VarV
                End If
                
                'Community Service
                If sh1.Cells(Trow, CSCol) <> vbNullString Then
                    VarV = TextToTime(sh1.Cells(Trow, CSCol)) / 24
                    Range("WorkTable").Cells(period, CS) = Range("WorkTable").Cells(period, CS) + (VarV)
                End If
                
                'Rostered Weekend days
                If sh1.Cells(Trow, RWECol) = 1 Then
                    Range("WorkTable").Cells(period, WE) = Val(Range("WorkTable").Cells(period, WE)) + 1 'weekend day worked
                End If

               'Type of Duty
                ActivityNumber = sh1.Cells(Trow, CatagoryCol)
                Select Case ActivityNumber
                    Case 1: 'PV Duty
                            Range("WorkTable").Cells(period, ND) = Val(Range("WorkTable").Cells(period, ND)) + 1 'Total days PV duty
                    Case 2: 'Emergency Response
                            Range("WorkTable").Cells(period, ER) = Val(Range("WorkTable").Cells(period, ER)) + 1
                    Case 3: 'Planned Leave
                            Range("WorkTable").Cells(period, AL) = Range("WorkTable").Cells(period, AL) + 1
                    Case 4: 'incidental Leave
                            Range("WorkTable").Cells(period, OL) = Val(Range("WorkTable").Cells(period, OL)) + 1
                    Case 5: 'Personal Time (Time in lieu)
                            
                    Case 6: 'RDO
                            Range("WorkTable").Cells(period, RDO) = Val(Range("WorkTable").Cells(period, RDO)) + 1 'RDO
                            Range("WorkTable").Cells(period, OD) = Val(Range("WorkTable").Cells(period, OD)) + 1 'Off Duty
                    Case Else
                            Range("WorkTable").Cells(period, OD) = Val(Range("WorkTable").Cells(period, OD)) + 1    'IF not PV work or ER work then must be off duty
                End Select
        End If
    Next
    
    Range("WorkTable").Cells(1, ATB) = Range("AtOpen") + Range("WorkTable").Cells(1, AT) - Range("WorkTable").Cells(1, TIL)
    
     'Changed RDO (below) to show RDOs for all staff (some staff change Rostered Duty during year)
    Range("WorkTable").Cells(1, RDOB) = Val(Range("RDOOpen")) + Val(Range("WorkTable").Cells(1, WE)) - Val(Range("WorkTable").Cells(1, RDO))
    
    WeekendsWorked = Val(Range("WorkTable").Cells(1, WE))
    'Update WorkLife page
    For N = 2 To 12
            Range("WorkTable").Cells(N, ATB) = Range("WorkTable").Cells(N - 1, ATB) + Range("WorkTable").Cells(N, AT) - Range("WorkTable").Cells(N, TIL)
            Range("WorkTable").Cells(N, RDOB) = Val(Range("WorkTable").Cells(N - 1, RDOB)) + Val(Range("WorkTable").Cells(N, WE)) - Val(Range("WorkTable").Cells(N, RDO))
            WeekendsWorked = WeekendsWorked + Val(Range("WorkTable").Cells(N, WE))
    Next N
    'Update Admin page
    Range("RDOBalance") = Val(Range("WorkTable").Cells(12, RDOB))
    Range("ATBalance") = Range("WorkTable").Cells(12, ATB) * 24
    Range("WeekendsWorked") = WeekendsWorked
    Application.ScreenUpdating = True
End Sub


Public Sub LoadPersonInformation(uID As Long) 'V7.8b
    Dim Cmd, RWE, RWER As String
    Dim TotalHours As Single
    Dim N As Integer
    InfoLoadedOK = False
    Call OpenPVTSConnection(tmode)
    If Not ConOpen Then Exit Sub
    On Error GoTo dberr
    
     Set RS = New Adodb.Recordset
     Cmd = "select * from tmsheet.pv_employee_hours_v "
     Cmd = Cmd & "WHERE PERSON_ID = " & uID & ""
     RS.Open Cmd, conn, adOpenStatic, adLockReadOnly
     If RS.RecordCount <> 1 Then
         'This is an error situation. Alert user
             RS.Close: conn.Close
             Set conn = Nothing: Set RS = Nothing
             MsgBox "Critical: You must contact the Service Desk. " & vbCr & "PERSON_ID = " & uID & " NOT found in VIEW pv_employee_hours. " & vbCr & "No employee record not found. Request an 'offline template'. ", vbExclamation, MsgCaption
             Call logDataEntry("LoadPersonInformation > Sub Failed: Unable to identify user (pv_employee_hours).  SQL > " & Cmd & " (" & ActiveWorkbook.FullName & ")")
             Exit Sub
     End If
     If IsNull(RS.Fields("W1_Day1_Hours")) Then Range("PaidHours").Cells(1) = 0 Else Range("PaidHours").Cells(1) = Round(Val(RS.Fields("W1_Day1_Hours")), 2)
     If IsNull(RS.Fields("W1_Day2_Hours")) Then Range("PaidHours").Cells(2) = 0 Else Range("PaidHours").Cells(2) = Round(Val(RS.Fields("W1_Day2_Hours")), 2)
     If IsNull(RS.Fields("W1_Day3_Hours")) Then Range("PaidHours").Cells(3) = 0 Else Range("PaidHours").Cells(3) = Round(Val(RS.Fields("W1_Day3_Hours")), 2)
     If IsNull(RS.Fields("W1_Day4_Hours")) Then Range("PaidHours").Cells(4) = 0 Else Range("PaidHours").Cells(4) = Round(Val(RS.Fields("W1_Day4_Hours")), 2)
     If IsNull(RS.Fields("W1_Day5_Hours")) Then Range("PaidHours").Cells(5) = 0 Else Range("PaidHours").Cells(5) = Round(Val(RS.Fields("W1_Day5_Hours")), 2)
     If IsNull(RS.Fields("W1_Day6_Hours")) Then Range("PaidHours").Cells(6) = 0 Else Range("PaidHours").Cells(6) = Round(Val(RS.Fields("W1_Day6_Hours")), 2)
     If IsNull(RS.Fields("W1_Day7_Hours")) Then Range("PaidHours").Cells(7) = 0 Else Range("PaidHours").Cells(7) = Round(Val(RS.Fields("W1_Day7_Hours")), 2)
     If IsNull(RS.Fields("W2_Day1_Hours")) Then Range("PaidHours").Cells(8) = 0 Else Range("PaidHours").Cells(8) = Round(Val(RS.Fields("W2_Day1_Hours")), 2)
     If IsNull(RS.Fields("W2_Day2_Hours")) Then Range("PaidHours").Cells(9) = 0 Else Range("PaidHours").Cells(9) = Round(Val(RS.Fields("W2_Day2_Hours")), 2)
     If IsNull(RS.Fields("W2_Day3_Hours")) Then Range("PaidHours").Cells(10) = 0 Else Range("PaidHours").Cells(10) = Round(Val(RS.Fields("W2_Day3_Hours")), 2)
     If IsNull(RS.Fields("W2_Day4_Hours")) Then Range("PaidHours").Cells(11) = 0 Else Range("PaidHours").Cells(11) = Round(Val(RS.Fields("W2_Day4_Hours")), 2)
     If IsNull(RS.Fields("W2_Day5_Hours")) Then Range("PaidHours").Cells(12) = 0 Else Range("PaidHours").Cells(12) = Round(Val(RS.Fields("W2_Day5_Hours")), 2)
     If IsNull(RS.Fields("W2_Day6_Hours")) Then Range("PaidHours").Cells(13) = 0 Else Range("PaidHours").Cells(13) = Round(Val(RS.Fields("W2_Day6_Hours")), 2)
     If IsNull(RS.Fields("W2_Day7_Hours")) Then Range("PaidHours").Cells(14) = 0 Else Range("PaidHours").Cells(14) = Round(Val(RS.Fields("W2_Day7_Hours")), 2)
     
     TotalHours = Range("PaidHours").Cells(1) + Range("PaidHours").Cells(2) + Range("PaidHours").Cells(3) _
     + Range("PaidHours").Cells(4) + Range("PaidHours").Cells(5) + Range("PaidHours").Cells(6) _
     + Range("PaidHours").Cells(7) + Range("PaidHours").Cells(8) + Range("PaidHours").Cells(9) _
     + Range("PaidHours").Cells(10) + Range("PaidHours").Cells(11) + Range("PaidHours").Cells(12) _
     + Range("PaidHours").Cells(13) + Range("PaidHours").Cells(14)
    Range("TotalHours") = Round(TotalHours, 2)
    
    RWE = RS.Fields("ROSTER_WEEKEND")
    If Len(RWE) > 4 Then 'Rostered
         RWE = Right(RWE, Len(RWE) - 4)
         If Len(RWE) > 2 Then RWE = Left(RWE, 2)
         N = Val(RWE)
         If N = 0 Then N = 1 'if N=1 then Rostered employee working 'As Worked' weekends
     Else
         N = 0 'Non-Rostered employee
     End If
     Range("RosteredDays") = N
     RS.Close
     Call logDataEntry("LoadPersonInformation > Rostered days OK: " & Range("RosteredDays") & " (" & ActiveWorkbook.FullName & ")")
    '--------           ---------------
    
    Cmd = "select Last_Name, First_Name, Job_Title, Office_ID, OFFICE "
    Cmd = Cmd & "FROM PV_EMPLOYEE_DETAILS_MV "
    Cmd = Cmd & "WHERE Person_ID = " & uID & ""
    RS.Open Cmd, conn, adOpenStatic, adLockReadOnly
        If RS.RecordCount <> 1 Then
            'This is an error situation. Alert user
                RS.Close
                conn.Close
                Set conn = Nothing: Set RS = Nothing
                MsgBox "Critical: You must contact the Service Desk. " & vbCr & "PERSON_ID = " & uID & " NOT found in VIEW pv_employee_details_mv. " & vbCr & "No employee record not found. Request an 'offline template'. ", vbExclamation, MsgCaption
                Call logDataEntry("LoadPersonInformation > Sub Failed: Cannot identify user (PV_EMPLOYEE_DETAILS_MV).  SQL > " & Cmd & " (" & ActiveWorkbook.FullName & ")")
                Exit Sub
        End If
        
        Range("FirstName") = RS.Fields("First_Name")
        Range("LastName") = RS.Fields("Last_Name")
        Range("Position") = RS.Fields("Job_Title")
        Range("WorkCentre") = RS.Fields("Office_ID")
        Range("Office") = RS.Fields("OFFICE")
        Range("PersonID") = uID
    RS.Close
    conn.Close
    Set conn = Nothing: Set RS = Nothing
     InfoLoadedOK = True
    Call logDataEntry("LoadPersonInformation > Done. InfoLoadedOK = True (" & ActiveWorkbook.FullName & ")")
    Exit Sub
dberr:
    If conn.State <> 0 Then conn.Close
    Set conn = Nothing: Set RS = Nothing
    MsgBox "Timesheet Error " & Err.Description, vbInformation, MsgCaption
    Call logDataEntry("LoadPersonInformation > Sub Failed: " & MsgCaption & " - " & Err.Description & " (" & ActiveWorkbook.FullName & ")")
End Sub


Public Function ImportActivities(FileLocation As String) As Boolean
'---------------------------------------------------------------
    '1st Activity Row = 8
    'Activity Columns = 2 to 15
    'Import data saved on Sheets("PV")
    'STOP import when 1st column = "Approved Leave"
'---------------------------------------------------------------

    Dim NotImported As String
    Dim ImportComplete As Boolean
    Dim ImportPath, FileName, FilePath, Address As String
    Dim R, N, row, Column As Integer
    Dim ImportData As Variant
    Dim ActivityName As String
    Const SheetName = "Activity"
    Dim sh1 As Worksheet
    Set sh1 = Sheets("Activity")
    
    NotImported = vbNullString
        
    On Error GoTo ImpErr
    
    If Dir(FileLocation, vbDirectory) = vbNullString Then FileLocation = vbNullString
    If FileLocation = vbNullString Then
        Dim getFile As Variant
        MsgBox "IMPORT ACTIVITIES" & vbCr & vbCr & _
        "When you click 'OK' a file location window will open." & vbCr & _
        "Navigate to the folder where the Timesheet you want" & vbCr & _
        "to import Activities from is located, select the Timesheet" & vbCr & _
        "file then click 'Open'", vbInformation, MsgCaption
        getFile = Application.GetOpenFilename("Image Files (*.xlsm),*.xlsm", , "Please select the Timesheet file to open", , "False")
       
        If getFile = "" Or getFile = False Then      'Exit if user cancelled
            MsgBox "Activity import cancelled", vbExclamation, MsgCaption
            Call logDataEntry("ImportActivities > User failed to select a file from the dialog. ")
            ImportActivities = True
            Exit Function
        End If
        FileLocation = CStr(getFile)
    End If
    N = InStrRev(FileLocation, "\"): If N = 0 Then Exit Function 'ERROR
    ImportPath = Left(FileLocation, N)
    FileName = Right(FileLocation, Len(FileLocation) - N)
     
    Column = 2
     
    row = 8 ' Row of first Activity in Timesheet.
    Address = Cells(row - 1, Column).Address
    ActivityName = GetData(ImportPath, FileName, SheetName, Address)
    If Left(ActivityName, 3) <> "BOF" Then
        MsgBox "Cannot locate Activity List in source file. Cannot continue.", vbExclamation, MsgCaption
        Call logDataEntry("ImportActivities > Failed to locate Activity List in source file. Cannot continue. [" & ImportPath & "\" & FileName & "]" & SheetName & "!" & Address & "")
        Exit Function
    End If
    Application.ScreenUpdating = False
GetActivity:
    Column = 2
    Address = Cells(row, Column).Address
    ActivityName = GetData(ImportPath, FileName, SheetName, Address)
    If ActivityName = "Approved Leave" Then GoTo IComplete 'All custom activiries have been imported
    If ActivityExists(ActivityName) Then
        NotImported = NotImported & vbCr & ActivityName
        row = row + 1
        GoTo GetActivity
    End If
    'insert a new activity row
    sh1.Range("B" & row & ":O" & row).Insert Shift:=xlDown
    sh1.Cells(row, 2) = ActivityName
    For Column = 3 To 14 'Activity columns
        Address = Cells(row, Column).Address
        ImportData = GetData(ImportPath, FileName, SheetName, Address)
        If Not (ImportData = 0 Or ImportData = vbNullString) Then
            If Column Mod 2 <> 0 Then
                sh1.Cells(row, Column) = Get_Program_Map_To(CStr(ImportData))
            Else
                sh1.Cells(row, Column) = ImportData
            End If
        End If
    Next Column
    sh1.Cells(row, 15) = "open"
    row = row + 1
    If Not ImportComplete Then GoTo GetActivity
IComplete:
    Application.ScreenUpdating = True
    ImportActivities = True
    Call logDataEntry("ImportActivities > Done. ImportActivities = True. Source " & ImportPath & "\" & FileName & "")
    If NotImported <> vbNullString Then
      Call logDataEntry("ImportActivities > The following activities were not imported as they already exist:" & NotImported & " (" & ActiveWorkbook.FullName & ")")
      MsgBox "The following activities were not imported as they already exist:" & vbCr & NotImported, vbInformation, MsgCaption
    End If
    Exit Function
    
ImpErr:
    ImportActivities = False
    Application.ScreenUpdating = True
    Call logDataEntry("ImportActivities > Sub Failed (" & FileLocation & ") " & ImportPath & "\" & FileName & ", " & ActiveWorkbook.FullName)

End Function

Private Function GetData(Path, File, Sheet, Address)
    Dim Data$
    Data = "'" & Path & "[" & File & "]" & Sheet & "'!" & _
    Range(Address).Range("A1").Address(, , xlR1C1)
    GetData = ExecuteExcel4Macro(Data)
End Function

Function Get_Program_Map_To(S As String) As String
'Returns remapped Program number.
'If the Program number cannor be found then the value passed is returned
    Get_Program_Map_To = S
    Dim N As Integer
    N = 2
    Do While Range("ProgramList").Cells(N, 2) <> ""
        If Range("ProgramList").Cells(N, 2) = S Then
            Get_Program_Map_To = Range("ProgramList").Cells(N, 3)
            Exit Do
        End If
        N = N + 1
    Loop
End Function


Sub UpdateProgramList(i As Integer) ' i used to hide routine ONLY

    Dim Cmd As String
    Dim X, C, R As Integer

        If LCase(Range("TSVersion")) = "test" Then
            ProgramListUpToDate = True
            Exit Sub
        End If
        OpenPVTSConnection (tmode)
        If Not ConOpen Then Exit Sub
       On Error GoTo oraerror
       
       Application.ScreenUpdating = False
            'Get the program list from the server
            
            Cmd = "SELECT Program_Output, Program_ID, Map_To,Program_Name from TMSHEET.PV_TS_PROGRAM_T"
            Cmd = Cmd & " ORDER BY Program_Output, Program_ID"
            
            Set RS = New Adodb.Recordset
            RS.Open Cmd, conn, adOpenStatic, adLockReadOnly
            If RS.RecordCount > 0 Then
                R = Range("ProgramList").row + 1
                C = Range("ProgramList").Column
                
                While Sheets("Admin").Cells(R, C) <> ""
                    Sheets("Admin").Cells(R, C).ClearContents
                    Sheets("Admin").Cells(R, C + 1).ClearContents
                    Sheets("Admin").Cells(R, C + 2).ClearContents
                    Sheets("Admin").Cells(R, C + 3).ClearContents
                    R = R + 1
                Wend
                        
                Sheets("Admin").Cells(Range("ProgramList").row + 1, C).CopyFromRecordset RS
                ProgramListUpToDate = True
            Else
                MsgBox "Program List not available "
            End If
            RS.Close: Set RS = Nothing
            conn.Close: Set conn = Nothing
            Application.ScreenUpdating = True
            Exit Sub
            
oraerror:
        If conn.State <> 0 Then conn.Close
        Set conn = Nothing: Set RS = Nothing
        Application.ScreenUpdating = True
        MsgBox "Program list update error", vbExclamation, MsgCaption
End Sub

Sub UpdatePublicHolidayList(i As Integer) ' i used to hide routine ONLY

    Dim Cmd As String
    Dim N, X, Holcol, HolRow, DayRow As Integer
    
    'if ispublicholiday
    If LCase(Range("TSVersion")) = "test" Then
        HolidayListUpToDate = True
        Exit Sub
    End If
    HolidayListUpToDate = False
    OpenPVTSConnection (tmode)
    If Not ConOpen Then Exit Sub
    
    Set RS = New Adodb.Recordset
    Application.ScreenUpdating = False
    
    On Error GoTo oraerror
    
    'Get the public Holiday list from the server
            
    Cmd = "SELECT HolidayName, HolidayDate "
    Cmd = Cmd & "from PV_TS_PublicHolidays_T "
    Cmd = Cmd & "WHERE HolidayDate  >= to_date('01-Jul-2020','DD-MON-YYYY') and HolidayDate <= to_date('30-Jun-2021','DD-MON-YYYY') "
    Cmd = Cmd & "ORDER BY HolidayDate "
       
    RS.Open Cmd, conn, adOpenStatic, adLockReadOnly
    N = RS.RecordCount
    
    If N > 0 Then
        Holcol = Sheets("Admin").Range("PublicHolidays").Column
        HolRow = Sheets("Admin").Range("PublicHolidays").row
        While Sheets("Admin").Cells(HolRow, Holcol) <> "" ' R = Range("PublicHolidays").row To Range("PublicHolidays").row + Range("PublicHolidays").Rows.Count - 2
            Sheets("Admin").Cells(HolRow, Holcol - 1).ClearContents
            Sheets("Admin").Cells(HolRow, Holcol).ClearContents
            HolRow = HolRow + 1
        Wend
        
        Sheets("Admin").Cells(Range("PublicHolidays").row, Holcol - 1).CopyFromRecordset RS
    
        RS.Close: Set RS = Nothing
        conn.Close: Set conn = Nothing
    
        DayRow = Sheets("Timesheet").Range("StartDate").row
        
        While Sheets("Timesheet").Cells(DayRow, DateCol) <> ""
            If IsDate(Sheets("Timesheet").Cells(DayRow, DateCol)) Then
                If IsPublicHoliday(Sheets("Timesheet").Cells(DayRow, DateCol)) Then
                    If Sheets("Timesheet").Cells(DayRow, NotesCol) = "" Then
                        Sheets("Timesheet").Cells(DayRow, NotesCol) = GetPublicHoliday(Sheets("Timesheet").Cells(DayRow, DateCol))
                    End If
                End If
            End If
             DayRow = DayRow + 1
        Wend
    
        
        HolidayListUpToDate = True
    
    Else
        Call logDataEntry("UpdatePublicHolidayList() > " & "Public Holiday list update failed: No data found in [PV_TS_PublicHolidays_T]")
        MsgBox "NOTE: Public Holiday List not updated. "
    End If
    
    Application.ScreenUpdating = True
    Exit Sub
            
oraerror:
    Call logDataEntry("UpdatePublicHolidayList() > " & "Public Holiday list update failed: " & Err.Description)
    If conn.State <> 0 Then conn.Close
    Set conn = Nothing: Set RS = Nothing
    Application.ScreenUpdating = True
    MsgBox "Public Holiday list update error" & vbCr & Err.Description, vbExclamation, MsgCaption
End Sub


Sub logDataEntry(logValue, Optional saveToFile = False)  'Functions_Routines
    'chg180413  trying to catch lost data bug - 24Apr18
    Dim directory As String
    Dim logFile, logFileNetworkFailure As String
    Dim User_ID As String
    Static errorRecords As String
    Dim tmpLine As String
    
    'check user name
    If Range("PersonID") = "" Or Range("WorkTable").Cells(1, 14) = 0 Then     '(ATBal = 0)
      User_ID = Environ("USERNAME")     'setup logging does not get deleted
    Else
      User_ID = Format(Range("PersonID"), "000000")
    End If
    
    'check dir exists
    directory = "O:\PVgroups\Timesheets\Issues list\Error Logs"    'UNC mapping works at a network level and avoids problems with local drive mapping
    If Dir(directory, vbDirectory) = "" Then
        directory = ActiveWorkbook.Path
    ElseIf logValue = "KILL" Then        'check if log file exists in user directory (happens when network is down)
        logFileNetworkFailure = ActiveWorkbook.Path & "\" & User_ID & "_log.txt"
        If Dir(logFileNetworkFailure, vbDirectory) <> "" Then
            Open logFileNetworkFailure For Input As #2
            errorRecords = errorRecords & Input(LOF(2), 2)
            Close #2
        End If
    End If
    
    logFile = directory & "\" & User_ID & "_log.txt"
    
    On Error Resume Next   ' dont error if file is locked for editing
    Open logFile For Append As #1
         errorRecords = errorRecords & Environ("USERNAME") & "," & Format(Now(), "dd-mmm-yy hh:mm:ss") & "," & logValue & vbCrLf
         If saveToFile Then Print #1, errorRecords
    Close #1
    
    If logValue = "KILL" Then
        'check for, and preserve errors in existing log file
        Open logFile For Input As #1
          Do Until EOF(1)
            Line Input #1, tmpLine
            If InStr(1, LCase(tmpLine), "error") > 0 Or InStr(1, LCase(tmpLine), "fail") Then
              errorRecords = errorRecords & vbCrLf & tmpLine
            End If
          Loop
        Close #1
        Kill logFile
        If errorRecords <> "" Then
          tmpLine = Environ("USERNAME") & "," & Format(Now(), "dd-mmm-yy hh:mm:ss") & ",KILL logging file - UpdateDatabaseRecords() successfully updated Oracle without error."
          Open logFile For Output As #1
               Print #1, errorRecords & vbCrLf & tmpLine
          Close #1
        End If
    End If
    On Error GoTo 0
    
    Exit Sub
err_trap:
    Call logDataEntry("logDataEntry() > Failed.")
End Sub



Sub LoadLocationList()
    Dim Cmd As String
    Dim C, R, N, W As Integer
    Dim defaultID As Long
    Dim Match As Boolean
        If LCase(Range("TSVersion")) = "test" Then Exit Sub
        Call OpenPVTSConnection(tmode)
        If Not ConOpen Then Exit Sub
        
       On Error GoTo oraerror
       defaultID = GetLocationID(Range("DefaultLocation"))    'chg170926


       Application.ScreenUpdating = False
            'Get the location list from the server
            Cmd = "SELECT DISTINCT LOCATION_ID, LOCATION_CODE FROM TMSHEET.PV_LOCATION_MV"
            Cmd = Cmd & " ORDER BY LOCATION_CODE"
            Set RS = New Adodb.Recordset
            RS.Open Cmd, conn, adOpenStatic, adLockReadOnly
            If RS.RecordCount > 0 Then
            
                R = Range("PVLocationList").row + 1
                C = Range("PVLocationList").Column
                While Sheets("Admin").Cells(R, C) <> ""
                    Sheets("Admin").Cells(R, C).ClearContents
                    Sheets("Admin").Cells(R, C + 1).ClearContents
                    R = R + 1
                Wend
                
                Sheets("Admin").Cells(Range("PVLocationList").row + 1, C).CopyFromRecordset RS
                
                N = 2
                While Range("PVLocationList").Cells(N, 1) <> "": N = N + 1:  Wend
                Range("PVLocationList").Cells(N, 1) = 1: Range("PVLocationList").Cells(N, 2) = "Work from Home"
                N = N + 1
                Range("PVLocationList").Cells(N, 1) = 2: Range("PVLocationList").Cells(N, 2) = "Other Agency Office"
                N = N + 1
                Range("PVLocationList").Cells(N, 1) = 3: Range("PVLocationList").Cells(N, 2) = "F&E Deployment"
                N = N + 1
                Range("PVLocationList").Cells(N, 1) = 4: Range("PVLocationList").Cells(N, 2) = "Remote Location"
                
                'Check if "Default Location" in Timesheet Assistant is up to date (or deleted)
                Range("DefaultLocation") = GetLocationName(defaultID)     'chg170926
                'Check "My Locations" for and changes / deletes
                N = 2
                While Range("MyLocationList").Cells(N, 1) <> ""
                    W = 2
                    Do While Range("PVLocationList").Cells(W, 1) <> ""
                        If Range("PVLocationList").Cells(W, 1) = Range("MyLocationList").Cells(N, 1) Then
                            Match = True
                            Exit Do
                        End If
                        W = W + 1
                    Loop
                    If Not Match Then
                        Sheets("Admin").Range("MyLocationList").Cells(N, 1).Delete Shift:=xlUp
                    End If
                    N = N + 1
                Wend
                LocationListUpToDate = True
                
            Else
                Call logDataEntry("LoadLocationList > Fail > Cannot find Location list on server")
                MsgBox "Cannot find Location list on server", vbExclamation, MsgCaption
            End If
            RS.Close
            conn.Close
            Set conn = Nothing: Set RS = Nothing
            Application.ScreenUpdating = True
            Exit Sub
            
oraerror:
        If conn.State <> 0 Then conn.Close
        Set conn = Nothing: Set RS = Nothing
        
        Application.ScreenUpdating = True
        Call logDataEntry("LoadLocationList > Location list update failed > ")
        MsgBox "Location list update error", vbExclamation, MsgCaption
End Sub


Sub AdminDuplicate()
        Dim R As Integer
        Dim numberOfDaysToDuplicate As String
        Sheets("Timesheet").Select
        R = ActiveCell.row
        
        'admin 'duplicate any timesheet' function
        numberOfDaysToDuplicate = InputBox("How many days to duplicate?")
        Call DuplicateTimesheet(R * 1, R + 1, numberOfDaysToDuplicate)

        
End Sub
Public Sub DuplicateTimesheet(CurRow As Integer, BeginRow As Integer, DayCountBox As String)
   'Changes to:
   ' - Fm_Leave_Other
   ' - Functions_Routines
    
    Dim Cmt As String
    Dim X, P1, P2, N, R As Integer
    Call logDataEntry("Sub DuplicateTimesheet(),CurRow=" & CurRow & ",DayCountBox=" & DayCountBox)
    
    'CurRow = ActiveCell.row
    R = BeginRow
    N = Val(DayCountBox)
    'If N = 0 Then N = 1
    Do While N > 0
            If Cells(R, ActivityCol) <> "" Then
                        If MsgBox("You have already filled in your timesheet for one or more workdays in this period." & vbCr & _
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
    
    R = BeginRow
    Application.ScreenUpdating = False
    P1 = GetPeriod(Cells(R, DateCol))
    N = Val(DayCountBox)      ': If N = 0 Then N = 1
    Do While N > 0
            P2 = GetPeriod(Cells(R, DateCol))
            ClearTimesheetRow (R)
            
            'Cells(R, DateCol) = Cells(CurRow, DateCol)
            Cells(R, StartCol) = Cells(CurRow, StartCol)
            Cells(R, FinishCol) = Cells(CurRow, FinishCol)
            Cells(R, BreakCol) = Cells(CurRow, BreakCol)
            Cells(R, ExtraCol) = Cells(CurRow, ExtraCol)
            Cells(R, TotalCol) = Cells(CurRow, TotalCol)
            Cells(R, ATCol) = Cells(CurRow, ATCol)
            Cells(R, TILCol) = Cells(CurRow, TILCol)
            Cells(R, LeaveCol) = Cells(CurRow, LeaveCol)
            Cells(R, OTCol) = Cells(CurRow, OTCol)
            Cells(R, CSCol) = Cells(CurRow, CSCol)
            Cells(R, CommentsCol) = Cells(CurRow, CommentsCol)
            Cells(R, CommentsCol).Font.Color = RGB(51, 51, 255)
            Cells(R, LocationIDCol) = Cells(CurRow, LocationIDCol)
            Cells(R, FundCol) = Cells(CurRow, FundCol)
            Cells(R, LocationCol) = Cells(CurRow, LocationCol)
            Cells(R, LocationCol).Font.Color = Cells(CurRow, LocationCol).Font.Color
            Cells(R, ActivityCol) = Cells(CurRow, ActivityCol)
            Cells(R, ActivityCol).Font.Color = Cells(CurRow, ActivityCol).Font.Color
            Cells(R, NotesCol) = Cells(CurRow, NotesCol)
            
            Cells(R, StandbyCol) = Cells(CurRow, StandbyCol)
            Cells(R, 23) = Cells(CurRow, 23)     'Fatigue column
            Cells(R, EntryDateCol) = Date
            Cells(R, DutyCol) = Cells(CurRow, DutyCol)
            Cells(R, CatagoryCol) = Cells(CurRow, CatagoryCol)
            If Cells(R, StatusCol) = "saved" Or Cells(R, StatusCol) = "updated" Then
                Cells(R, StatusCol) = "updated"
            Else
                Cells(R, StatusCol) = "entered"
            End If
            Cells(R, RWECol) = Cells(CurRow, RWECol)
            
            'Range(Cells(R, 1), Cells(R, 29)).Value = Range(Cells(CurRow, 1), Cells(CurRow, 29)).Value       'duplicate currect record
            
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
    Application.ScreenUpdating = True
    
End Sub


