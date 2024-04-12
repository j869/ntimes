
Option Explicit
Dim DataUpdateOK As Boolean


Private Sub Workbook_Open()  'this fires before Workbook_Activate()
    Dim shp As Object
    Dim bTS As Boolean, bWL As Boolean, bInfo As Boolean
    Dim OpenMsg As String
    Dim dlgFileSaveAs As Dialog
    Dim txtFileName As String
    Dim wb As Workbook
    Dim applicationCanClose As Boolean
    TemplateFile = False
    Dim i As Integer
    'call logDataEntry("Version: 2019-12-18")   'OLEDB date issues fixed with change to OpenPVTSConnection()
    'Call logDataEntry("Version: 2019-12-23")   'increased debugging for duplicate entries in UpdateDatabaseRecords()
    'Call logDataEntry("Version: 2019-12-23")    'add [saved at] time to notes column in UpdateDatabaseRecords()
    'Call logDataEntry("Version: 2021-06-01 (" & Format(Range("TSVersion"), "00.00") & ")")   'deal with connection failures in setup form, force user to save UNDER workcentres (not in workcentre folder), add ClearSetup2 to FM_SetupConfirmation, fix daycountbox to default to 1
    'Call logDataEntry("Version: 2021-06-05 (" & Format(Range("TSVersion"), "00.00") & ")")     'Development complete, (adminErr01) Fm_Help corrected last year 2019 to 2020,  (setupErr005) define fail case when invalid user is selected, (setupErr006) click X to close window exits gracefully, (userError002) GUI changed on Fm_Leave_Other     (see O:\PVgroups\Timesheets\Information\Technical Documentation\2020-2021 Scratch pad area\200605 Testing new template\200605 testing result.txt
    'Call logDataEntry("Version: 2021-06-05 (" & Format(Range("TSVersion"), "00.00") & ")")     '1st round Testing complete
    'Call logDataEntry("Version: 2021-06-10 (" & Format(Range("TSVersion"), "00.00") & ")")     'Correcting bugs from 1st round testing
    'Call logDataEntry("Version: 2021-06-11 (" & Format(Range("TSVersion"), "00.00") & ")")     'team testing bugs fixed: fm_SetupConfirmation, AT aggrement cannot be 'no', changes to wording,
    'Call logDataEntry("Version: 2021-06-12 (" & Format(Range("TSVersion"), "00.00") & ")")     ' points to connection 11g.xlsm
    'Call logDataEntry("Version: 2021-06-17 (" & Format(Range("TSVersion"), "00.00") & ")")     ' extra logging for non-metro cup holiday (Leonie said this was a common problem - proposed a coded solution for next year), addition of vDefaultPath variable in tm_template, Stuart advised that we have 26 pay periods rather than 27 this year
    Call logDataEntry("Version: 2021 Jun24 (" & Format(Range("TSVersion"), "00.00") & ")")     ' added assetID to logging
    Call logDataEntry("AssetID:" & Environ("COMPUTERNAME"))
    
    
    'remove before release
'    If Now() < #6/23/2020# Then
'      If MsgBox("2020-21 Template has not been released.  Continue?", vbYesNo) = vbNo Then    'Environ("USERNAME") <> "jmaher" Then    '
'          Application.EnableEvents = False
'          Application.DisplayAlerts = False
'          ActiveWorkbook.Save
'          ThisWorkbook.Saved = True
'          ActiveWorkbook.Close savechanges:=False
'          Set Application.ThisWorkbook = Nothing
'          Application.Quit
'      End If
'    Else
'      Range("AdvanceEntry") = 41
'    End If
    
    'chg180412 - test if button error  - version 11Apr18 13:09
    On Error GoTo err_trap
    bTS = Abs(Sheets("PV").TimesheetButton.Height - 28.5) > 5 Or Abs(Sheets("PV").TimesheetButton.Width - 166.5) > 5
    bWL = Abs(Sheets("PV").WorkLifeButton.Height - 28.5) > 5 Or Abs(Sheets("PV").WorkLifeButton.Width - 166.5) > 5
    bInfo = Abs(Sheets("PV").InformationButton.Height - 28.5) > 5 Or Abs(Sheets("PV").InformationButton.Width - 166.5) > 5
    On Error GoTo 0
    If bTS Or bWL Or bInfo Then
err_trap:
        
        If True Then   'unlock timesheet
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
        End If

        For i = Sheets("PV").Shapes.Count To 4 Step -1
            Sheets("PV").Shapes(i).Delete
        Next i
        For i = 1 To 1000
            DoEvents
        Next i
        
        'TimesheetButton
        ActiveSheet.OLEObjects.Add(ClassType:="Forms.CommandButton.1", Link:=False _
            , DisplayAsIcon:=False, Left:=120, Top:=191.25, Width:=166.5, Height:=28.5 _
            ).Name = "TimesheetButton"
        Sheets("PV").Shapes("TimesheetButton").OLEFormat.Object.Object.Caption = "Go to my Timesheet"
        Sheets("PV").Shapes("TimesheetButton").OLEFormat.Object.Enabled = False
        'WorkLifeButton
        ActiveSheet.OLEObjects.Add(ClassType:="Forms.CommandButton.1", Link:=False _
            , DisplayAsIcon:=False, Left:=120, Top:=224.25, Width:=166.5, Height:=28.5 _
            ).Name = "WorkLifeButton"
        Sheets("PV").Shapes("WorkLifeButton").OLEFormat.Object.Object.Caption = "Work / Life Balance"
        Sheets("PV").Shapes("WorkLifeButton").OLEFormat.Object.Enabled = False
        'InformationButton
        ActiveSheet.OLEObjects.Add(ClassType:="Forms.CommandButton.1", Link:=False _
            , DisplayAsIcon:=False, Left:=120, Top:=258.75, Width:=166.5, Height:=28.5 _
            ).Name = "InformationButton"
        ActiveSheet.Shapes("InformationButton").OLEFormat.Object.Object.Caption = "Timesheet Manager"
        ActiveSheet.Shapes("InformationButton").OLEFormat.Object.Enabled = False
        
        For i = 1 To 1000
            DoEvents
        Next i
        'Call LockTimesheet
        MsgBox "An error occurred. You must close all excel workbooks and reopen the timesheet.", vbCritical, "Interface Error"
        Call logDataEntry("Recovered from Error Chg180212: Layout rebuilt.")
        Application.EnableEvents = False
        Application.DisplayAlerts = False
        ActiveWorkbook.Save
        ThisWorkbook.Saved = True
        ThisWorkbook.Application.Quit   'stops vba running, the following lines never have a chance to run
        ActiveWorkbook.Close savechanges:=False
        Set Application.ThisWorkbook = Nothing
        Application.Quit
    Else
        Call logDataEntry("Opening... " & ActiveWorkbook.FullName)
        
        'TimesheetButton
        Set shp = Sheets("PV").TimesheetButton
        With shp
            .Enabled = False
            With .Font
                .Name = "Calibri"
                .Size = 14
                .Bold = True
            End With
        End With
        'WorkLifeButton
        Set shp = Sheets("PV").WorkLifeButton
        With shp
            .Enabled = False
            With .Font
                .Name = "Calibri"
                .Size = 14
                .Bold = True
            End With
        End With
        'InformationButton
        Set shp = Sheets("PV").InformationButton
        With shp
            .Enabled = False
            With .Font
                .Name = "Calibri"
                .Size = 14
                .Bold = True
            End With
        End With
        
    End If
        
    Sheets("PV").WorkLifeButton.Enabled = False
    Sheets("PV").TimesheetButton.Enabled = False
    Sheets("PV").InformationButton.Enabled = False
    LockTimesheet
    Sheets("PV").Select
    
    If InStr(LCase(ThisWorkbook.Name), "template") > 0 Then
        Fm_Template.Show    'attempt to rename template
    End If
    
    If InStr(LCase(ThisWorkbook.Name), "template") > 0 Then
        TemplateFile = True
        Call logDataEntry("Failed to save timesheet as per instructions. Current location is: " & ActiveWorkbook.FullName)
        MsgBox "Exiting. Please try again."
        Application.EnableEvents = False
        Application.DisplayAlerts = False
        ThisWorkbook.Saved = True
        ThisWorkbook.Application.Quit
        End
    ElseIf InStr(1, LCase(ActiveWorkbook.Path), LCase("D:\")) = 0 Then      'chg180521 - prevent users saving on home drive
        Call logDataEntry("Workbook residing in unapproved folder " & ActiveWorkbook.FullName)
        MsgBox "Please save your Timesheet under 'O:\PVGROUPS\Timesheets\2020-21\WorkCentres'. ", vbCritical
    Else
        Sheets("PV").InformationButton.Enabled = True
        DoEvents
        Fm_Welcome.Show
    End If
    
End Sub




Private Sub Workbook_Activate()
    Application.OnKey "{F3}", ""
    Application.OnKey "+{F3}", "" 'Shift F3
    Application.OnKey "^{F3}", "" 'Ctl F3
    Application.OnKey "{F5}", "" 'F5
    Application.OnKey "+{F5}", "" 'Shift F5
    
    Dim oCtrl As Office.CommandBarControl

'Disable all Cut menus
     For Each oCtrl In Application.CommandBars.FindControls(ID:=21)
            oCtrl.Enabled = False
     Next oCtrl
     
'Disable all Copy menus
     For Each oCtrl In Application.CommandBars.FindControls(ID:=19)
            oCtrl.Enabled = False
     Next oCtrl

'Disable CellDragAndDrop
    Application.CellDragAndDrop = False
    
'Hide Ribbon
    ActiveWindow.DisplayWorkbookTabs = False
    Application.DisplayFormulaBar = False
    Application.ExecuteExcel4Macro "SHOW.TOOLBAR(""Ribbon"",False)"

    
    
End Sub

Private Sub Workbook_Deactivate()

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

End Sub

Private Sub Workbook_BeforeClose(Cancel As Boolean)
    Dim User_ID As String
    If Range("LastName") = "" Then
      ThisWorkbook.Saved = True   'timesheet not set up
    Else
      'chg180413 - lost data bug: copy a snapshot of the workbook to ErrorLogs folder
      On Error Resume Next   'dont fail on this code
      Dim fso As Scripting.FileSystemObject
      Set fso = New Scripting.FileSystemObject   'under Options > Tools > References > Microsoft Scripting Runtime
      If Range("PersonID") = "" Then User_ID = Environ("USERNAME") Else User_ID = Format(Range("PersonID"), "000000")
      Call fso.CopyFile(ActiveWorkbook.FullName, "O:\PVgroups\Timesheets\Issues list\Error Logs\" & User_ID & "_bak.xlsm", True)
      If Err.Number = 0 Then
        Call logDataEntry("Backup successful")
      Else
        Call logDataEntry("Failed to save to " & "O:\PVgroups\Timesheets\Issues list\Error Logs\" & User_ID & "_bak.xlsm" & " (" & Err.Number & " - " & Err.Description & ")")
      End If
      On Error GoTo 0
    End If
    
End Sub

Private Sub Workbook_SheetSelectionChange(ByVal Sh As Object, ByVal Target As Range)
    With Application
        .CellDragAndDrop = False
        .CutCopyMode = False 'Clear clipboard
    End With
    
End Sub
'_________________________________________________________________________________

Private Sub Workbook_BeforeSave(ByVal SaveAsUI As Boolean, Cancel As Boolean)
    'Application.StatusBar = "Saving..."

    
    If SaveAsUI Then
        'MsgBox "Workbook_BeforeSave 'SaveAsUi' DISABLED. Enable prior to release": GoTo Cont
        MsgBox " Cannot use 'Save-As' option. Please click 'Save' to save your timesheet", vbExclamation, MsgCaption
        Cancel = True
        Exit Sub
    End If
Cont:
    If Range("LastName") <> "" Then
        UpdateDatabaseRecords
        If Not DataUpdateOK Then
            MsgBox "Thank you, your timesheet has been saved." & vbCr & vbCr & _
            "NOTE: Your information cannot be sent to Oracle at this time.", vbInformation, MsgCaption
            Call logDataEntry("UPDATE FAILURE > Your information connot be sent to Oracle at this time. " & ActiveWorkbook.FullName & ", AssetID:" & Environ("computerName"))
        Else
            MsgBox "Thank you, your timesheet has been saved.", vbInformation, MsgCaption
            Call logDataEntry("KILL")
        End If
    End If
    
    Sheets("PV").Select
    Application.GoTo Reference:=Range("a1"), Scroll:=True

End Sub

Private Sub UpdateDatabaseRecords()
'Need to refresh Program list here as Programs are remaped during save
'Remapping is necessary so that any changes to the Program Table, are applied when saving Program data
    If SetupRun Then DataUpdateOK = True: Exit Sub 'The timesheet has just been setup, no need to update
    Dim Rec As Integer
    Dim Hours As Single
    Dim catagory As Integer
    Dim Cmd, Status, OraDate As String
    Dim SavedOK As Boolean
    Dim WorkDate As Date
    Dim recordsAffected As Long
    Dim errMessage As String
    
    DataUpdateOK = True
    If Range("LastName") = "" Then
      Call logDataEntry("UpdateDatabaseRecords > Timesheet not set up (LastName=null) > Failed.")
      DataUpdateOK = True: Exit Sub      'Not setup
    End If
    
    If LCase(Range("TSVersion")) = "test" Then DataUpdateOK = True: Exit Sub
    
    If Not ProgramListUpToDate Then UpdateProgramList (0)
    If Not ProgramListUpToDate Then
      Call logDataEntry("UpdateDatabaseRecords > ProgramList Not UpToDate > Failed.")
      DataUpdateOK = False
      Exit Sub 'Must not be able to connect. Error message will be displayed on return as DataUpdateOK = False
    End If
    
    Call OpenPVTSConnection(tmode)
    If Not ConOpen Then
      Call logDataEntry("UpdateDatabaseRecords > Cannot connect to database > Failed.")
      DataUpdateOK = False
      Exit Sub 'Error message will be displayed on return as DataUpdateOK = False
    End If
    
    On Error GoTo OraFail
    '------ Update Labour records -----
    'Test each timesheet row, If it is marked "entered" or "updated", save the data.
    For Rec = Range("StartDate").row To Range("EndDate").row
            OraDate = Format(Sheets("Timesheet").Cells(Rec, DateCol), "dd-mmm-yyyy")
            Status = Sheets("Timesheet").Cells(Rec, StatusCol)
            If LCase(Status) = "saved" Or Status = "" Or WorkDate > Now() Then GoTo Next_Rec 'no need to save
            
            'Status must be "entered" or "updated"
            If LCase(Status) = "updated" Then
                Cmd = "UPDATE PV_TS_LABOUR_T "
                Cmd = Cmd & "SET STATUS = 'closed' "
                Cmd = Cmd & "WHERE Person_ID = " & Range("PersonID") & " "
                Cmd = Cmd & "AND WORK_DATE = To_Date('" & OraDate & "','DD-MON-YYYY')"
                conn.Execute Cmd, recordsAffected
'                Call logDataEntry("      SQL(" & Rec & ") > " & Cmd & " (" & recordsAffected & " records affected)")
                Call logDataEntry("      SQL(" & Rec & ") > " & Cmd & " (" & IIf(recordsAffected < 1, "Error: Should have more than ", "") & recordsAffected & " records affected)")
                 
                Cmd = "DELETE from PV_TS_TIMESHEET_T "
                Cmd = Cmd & "where WORK_DATE = To_Date('" & OraDate & "','DD-MON-YYYY') "
                Cmd = Cmd & "AND PERSON_ID =  " & Range("PersonID") & " "
                conn.Execute Cmd, recordsAffected
'                Call logDataEntry("      SQL(" & Rec & ") > " & Cmd & " (" & recordsAffected & " records affected)")
                Call logDataEntry("      SQL(" & Rec & ") > " & Cmd & " (" & IIf(recordsAffected < 1, "Error: Should have more than ", "") & recordsAffected & " records affected)")
            End If
    'Save the Timesheet entry to the timesheet table
            Cmd = "INSERT INTO PV_TS_TIMESHEET_T "
            Cmd = Cmd & "(PERSON_ID, "
            Cmd = Cmd & " WORK_DATE, "
            Cmd = Cmd & " TIME_START, "
            Cmd = Cmd & " TIME_FINISH, "
            Cmd = Cmd & " TIME_LUNCH, "
            Cmd = Cmd & " TIME_EXTRA_BREAK, "
            Cmd = Cmd & " TIME_TOTAL, "
            Cmd = Cmd & " TIME_ACCRUED, "
            Cmd = Cmd & " TIME_TIL, "
            Cmd = Cmd & " TIME_LEAVE, "
            Cmd = Cmd & " TIME_OVERTIME, "
            Cmd = Cmd & " TIME_COMM_SVS, "
            Cmd = Cmd & " T_COMMENT, "
            Cmd = Cmd & " LOCATION_ID, "
            Cmd = Cmd & " FUND_SRC, "
            Cmd = Cmd & " ACTIVITY, "
            Cmd = Cmd & " NOTES, "
            Cmd = Cmd & " ENTRY_DATE, "
            Cmd = Cmd & " ON_DUTY, "
            Cmd = Cmd & " DUTY_CATAGORY, "
            Cmd = Cmd & " STATUS, "
            Cmd = Cmd & " RWE_DAY) "
                    
            Cmd = Cmd & "VALUES "
            Cmd = Cmd & " (" & Range("PersonID") & ", " 'Number PERSON_ID
            Cmd = Cmd & " '" & OraDate & "', " ' Date WORK_DATE
            Cmd = Cmd & " '" & Sheets("Timesheet").Cells(Rec, StartCol) & "', " 'Text TIME_START
            Cmd = Cmd & " '" & Sheets("Timesheet").Cells(Rec, FinishCol) & "', " 'Text TIME_FINISH
            Cmd = Cmd & " '" & Sheets("Timesheet").Cells(Rec, BreakCol) & "', " 'Text TIME_LUNCH
            Cmd = Cmd & " '" & Sheets("Timesheet").Cells(Rec, ExtraCol) & "', " 'Text
            Cmd = Cmd & " '" & Sheets("Timesheet").Cells(Rec, TotalCol) & "', " 'Text TIME_TOTAL
            Cmd = Cmd & " '" & Sheets("Timesheet").Cells(Rec, ATCol) & "', " 'Text
            Cmd = Cmd & " '" & Sheets("Timesheet").Cells(Rec, TILCol) & "', " 'Text TIME_TIL
            Cmd = Cmd & " '" & Sheets("Timesheet").Cells(Rec, LeaveCol) & "', " 'Text
            Cmd = Cmd & " '" & Sheets("Timesheet").Cells(Rec, OTCol) & "', " 'Text TIME_OVERTIME
            Cmd = Cmd & " '" & Sheets("Timesheet").Cells(Rec, CSCol) & "', " 'Text
           'Cmd = Cmd & " '" & Replace(Sheets("Timesheet").Cells(Rec, CommentsCol), "'", "''") & "', " 'Text T_COMMENT
            Cmd = Cmd & " '" & Left(Replace(Sheets("Timesheet").Cells(Rec, CommentsCol), "'", "''"), 255) & "', " 'Text T_COMMENT              'restricted length of comment May2020 as per chg200506
            Cmd = Cmd & " " & Val(Sheets("Timesheet").Cells(Rec, LocationIDCol)) & ", " 'Number
            Cmd = Cmd & " '" & Sheets("Timesheet").Cells(Rec, FundCol) & "', " 'Text
            Cmd = Cmd & " '" & Replace(Sheets("Timesheet").Cells(Rec, ActivityCol), "'", "''") & "', " 'Text
            'Cmd = Cmd & " '" & Replace(Sheets("Timesheet").Cells(Rec, NotesCol), "'", "''") & "', " 'Text
            Cmd = Cmd & " '" & Replace(Sheets("Timesheet").Cells(Rec, NotesCol), ")'", "''") & " (Saved " & Format(Now(), "DD-MMM-YY HH:MM:SS") & ")', " 'Text
            Cmd = Cmd & " '" & Format(Sheets("Timesheet").Cells(Rec, EntryDateCol), "dd-mmm-yyyy") & "', " 'Date
            Cmd = Cmd & " " & CInt(Sheets("Timesheet").Cells(Rec, DutyCol)) & ", " 'Number
            Cmd = Cmd & " " & CInt(Sheets("Timesheet").Cells(Rec, CatagoryCol)) & ", " 'Number
            Cmd = Cmd & " 'saved', " 'Text
            Cmd = Cmd & " " & CInt(Sheets("Timesheet").Cells(Rec, RWECol)) & ") " 'Number
            conn.Execute Cmd, recordsAffected
            Call logDataEntry("      SQL(" & Rec & ") > " & Cmd & " (" & recordsAffected & " records affected)")
            If recordsAffected = 0 Then GoTo OraFail
            
        'Status is either "entered" or "updated"
            SavedOK = True    'save the next timesheet unless code fails
            catagory = Val(Sheets("Timesheet").Cells(Rec, CatagoryCol)) 'Either 1,2,3,4,5,6 or 7
            Select Case catagory
                Case 1: 'PV Work day
                    Call logDataEntry("UpdateDatabaseRecords > Case 1: 'PV Work day")
                    'There are always hours recorded for PV labour
                    'Get the hours then call SaveLabourRecords
                    Hours = TextToTime(Sheets("Timesheet").Cells(Rec, TotalCol)) 'Not affected by Variance display
                    If Hours > 0 Then SavedOK = SaveLabourRecords(Rec, Hours)

                    
                Case 2: 'ER
                    Call logDataEntry("UpdateDatabaseRecords > Case 2: 'ER")
                    'No hours are recorded on the timesheet for ER labour
                    'PV pays for normal work hours ONLY
                    'So if normal work hours = 0 on a weekday, then DEPI pay, consequently there is no labour to save
                    'If it is a weekend day, if an RDO was earned, PV is paying normal hours for the day
                    
                    If Sheets("Timesheet").Cells(Rec, RWECol) = 1 Then
                        Hours = GetWeekendHours() 'ALWAYS returns a decimal value
                    Else
                        Hours = Range("PaidHours").Cells(GetPeriodDayNumber(Sheets("Timesheet").Cells(Rec, DateCol)))
                    End If
                    If Hours > 0 Then SavedOK = SaveLabourRecords(Rec, Hours)
                    
                    
                Case 3, 4: 'Leave HOURS MUST ALWAYS be > 0 . {No Hours, No Leave)
                    Call logDataEntry("UpdateDatabaseRecords > Case 3, 4: 'Leave HOURS")
                    Hours = TextToTime(Sheets("Timesheet").Cells(Rec, LeaveCol))
                    Hours = Abs(Hours)
                    If Hours > 0.25 Then SavedOK = SaveLabourRecords(Rec, Hours)
                    
                'Case 4: 'LEAVE - Hours must ALWAYS be > 0 . {No Hours, No Leave)
                '    Hours = TextToTime(Sheets("Timesheet").Cells(Rec, LeaveCol))
                '    Hours = Abs(Hours)
                '    If Hours > 0 Then SavedOK = SaveLabourRecords(Rec, Hours)
                    
                Case 5: 'TIL
                    Call logDataEntry("UpdateDatabaseRecords > Case 5: 'TIL")
                    'No labour to record.
                    
                Case 6: 'RDO
                    Call logDataEntry("UpdateDatabaseRecords > Case 6: 'RDO")
                    'No labour to record.
                    
                Case 7: 'PERSONAL TIME - DAY OFF
                    Call logDataEntry("UpdateDatabaseRecords > Case 7: 'PERSONAL TIME - DAY OFF")
                    'No labour to record.
                    
            End Select
            If Not SavedOK Then
              Call logDataEntry("UpdateDatabaseRecords > SavedOK=False > (Row=" & Rec & ") - Error" & Err.Number & ": " & Err.Description & " > SQL: " & Cmd & " (" & recordsAffected & " records affected)")
            Else
              Sheets("Timesheet").Cells(Rec, StatusCol) = "saved"
            End If
            
        If False Then
OraFail:
          errMessage = Err.Number & ": " & Err.Description
          DataUpdateOK = False
          Call logDataEntry("UpdateDatabaseRecords > OraFail > (Row=" & Rec & ") - Error" & errMessage & " > SQL: " & Cmd & " (" & recordsAffected & " records affected)")
          MsgBox errMessage
          errMessage = ""
          Err.Clear
        End If
Next_Rec:
    Next Rec
    
    
    On Error GoTo UpdateError
    If True Then    'False for offline timesheets
        
        ' ----- Now update Work Life data -----
        'Test each work/life balance row and update if marked "updated"
    
        Dim p As Integer
        For p = 1 To 12
            Cmd = "UPDATE PV_TS_WORKLIFE_T "
            Cmd = Cmd & "SET "
            Cmd = Cmd & "LOCATION_ID= " & Range("WorkCentre") & ", " 'This is the current "Home" location '***NEW***
            Cmd = Cmd & "DAYS_PV_DUTY=" & CInt(Range("WorkLife").Cells(p, 2)) & ", "
            Cmd = Cmd & "DAYS_ER_DUTY=" & CInt(Range("WorkLife").Cells(p, 3)) & ", "
            Cmd = Cmd & "DAYS_OFF_DUTY=" & CInt(Range("WorkLife").Cells(p, 4)) & ", "
            Cmd = Cmd & "DAYS_ANNUAL_LEAVE=" & CInt(Range("WorkLife").Cells(p, 5)) & ", "
            Cmd = Cmd & "DAYS_OTHER_LEAVE=" & CInt(Range("WorkLife").Cells(p, 6)) & ", "
            Cmd = Cmd & "DAYS_WE_DUTY=" & CInt(Range("WorkLife").Cells(p, 7)) & ", "
            Cmd = Cmd & "DAYS_ROSTERED_OFF=" & CInt(Range("WorkLife").Cells(p, 8)) & ", "
            Cmd = Cmd & "DAYS_RDO_BALANCE=" & CInt(Range("WorkLife").Cells(p, 9)) & ", "
            Cmd = Cmd & "HOURS_SPONSORED=" & Round(Range("WorkLife").Cells(p, 10), 2) & ",  "
            Cmd = Cmd & "HOURS_OVERTIME=" & Round(Range("WorkLife").Cells(p, 11), 2) & ", "
            Cmd = Cmd & "HOURS_ACCRUED=" & Round(Range("WorkLife").Cells(p, 12), 2) & ", "
            Cmd = Cmd & "HOURS_IN_LIEU=" & Round(Range("WorkLife").Cells(p, 13), 2) & ", "
            Cmd = Cmd & "HOURS_AT_BALANCE=" & Round(Range("WorkLife").Cells(p, 14), 2) & ", "
            Cmd = Cmd & "PV_ROLE= '" & Replace(Range("Position"), "'", "''") & "', "
            Cmd = Cmd & "ER_ROLE= '" & Replace(Range("FireRole"), "'", "''") & "' "
            Cmd = Cmd & "WHERE PERSON_ID = '" & Range("PersonID") & "' " 'MOD MOD MOD
            Cmd = Cmd & "AND PERIOD = " & p & " "
            Cmd = Cmd & "AND FINANCIAL_YEAR = '" & OraFinYear & "'"
            conn.Execute Cmd, recordsAffected
            Call logDataEntry("      SQL > " & Cmd & " (" & recordsAffected & " records affected)")
            Range("WorkLife").Cells(p, 15) = "saved"
        Next p
        
    'Now save employee dynamic information (last updated, rdo balance, file location, password etc)
    
        Cmd = "UPDATE PV_TS_USER_T "
        Cmd = Cmd & "SET "
        Cmd = Cmd & "LAST_UPDATE='" & Format(Date, "dd-mmm-yyyy") & "' , "
        Cmd = Cmd & "AT_BALANCE=" & Range("ATBalance") & ", "
        Cmd = Cmd & "AT_OPEN=" & Range("ATCarried") & ", "
        Cmd = Cmd & "RDO_BALANCE=" & Range("RDOBalance") & ", "
        Cmd = Cmd & "RDO_OPEN=" & Range("RDOCarried") & ", "
        Cmd = Cmd & "START_DATE='" & Format(Range("StartDate"), "dd-mmm-yyyy") & "' , "
        Cmd = Cmd & "FILE_LOCATION='" & Replace(ThisWorkbook.Path & "\" & ThisWorkbook.Name, "'", "''") & "', "
        Cmd = Cmd & "PASSWORD='" & Range("Pkey") & "' "
        Cmd = Cmd & "WHERE PERSON_ID = '" & Range("PersonID") & "'" 'MOD MOD MOD
        conn.Execute Cmd, recordsAffected
        Call logDataEntry("      SQL > " & Cmd & " (" & recordsAffected & " records affected)")
    End If
    
    conn.Close
    Set conn = Nothing
    'DataUpdateOK = True    'modified 7Jun jm -       DataUpdateOK defaults to true and is changed when an error occurs
Exit Sub

UpdateError:
    errMessage = Err.Number & ": " & Err.Description
    DataUpdateOK = False
    Call logDataEntry("UpdateDatabaseRecords > UpdateError > Error" & errMessage & " > SQL: " & Cmd & " (" & recordsAffected & " records affected)")
    MsgBox errMessage
    If conn.State <> 0 Then conn.Close
    Set conn = Nothing

End Sub


 Function SaveLabourRecords(Rec As Integer, Hours As Single) As Boolean
    Dim row, col, prog As Integer
    Dim ActivityRowNumber As Integer
    Dim ProgNum As String
    Dim Cmd, FundSourceNumber As String
    Dim sh1 As Worksheet
    Dim sh2 As Worksheet
    Dim TotalTime, Percent As Single
    Dim recordsAffected As Long
    
    Set sh1 = Sheets("Activity")
    Set sh2 = Sheets("Timesheet")
    
    ActivityRowNumber = getActivityRowNumber(sh2.Cells(Rec, ActivityCol)) 'Get the Activity list row number
    If ActivityRowNumber = 0 Then Exit Function 'Just incase the activity is unknown (fail-safe)
    
    
    row = Range("ActivityList").row + ActivityRowNumber - 1 'this is the sheet row number of the activity
    col = Range("ActivityList").Column 'this is the sheet column of the activity list
    FundSourceNumber = sh2.Cells(Rec, FundCol) 'string
            
    For prog = 1 To 6
        ProgNum = sh1.Cells(row, col + (prog * 2) - 1)
        If ProgNum = "" Then GoTo Next_Prog ' less than 6 programs in the activity
                    
        ProgNum = Get_Program_Map_To(ProgNum)
        Percent = sh1.Cells(row, col + (prog * 2))
        TotalTime = Hours * Percent
        If Round(TotalTime, 2) = 0 Then GoTo Next_Prog 'Just incase (fail-safe)
            'Save the data
        Cmd = "INSERT INTO PV_TS_LABOUR_T "
        Cmd = Cmd & "(WORK_DATE, "
        Cmd = Cmd & " ENTRY_DATE, "
        Cmd = Cmd & " STATUS, "
        Cmd = Cmd & " Person_ID, "
        Cmd = Cmd & " PROGRAM_ID, "
        Cmd = Cmd & " FUND_SOURCE_NUMBER, "
        Cmd = Cmd & " HOURS, "
        Cmd = Cmd & " LOCATION_ID) "
        Cmd = Cmd & "VALUES "
        Cmd = Cmd & " ('" & Format(sh2.Cells(Rec, DateCol), "dd-mmm-yyyy") & "', "
        Cmd = Cmd & "  '" & Format(sh2.Cells(Rec, EntryDateCol), "dd-mmm-yyyy") & "', "
        Cmd = Cmd & "  'open', "
        Cmd = Cmd & "  '" & Range("PersonID") & "', "
        Cmd = Cmd & "  '" & ProgNum & "', "
        Cmd = Cmd & "  '" & FundSourceNumber & "', "
        Cmd = Cmd & "   " & TotalTime & ", "
        Cmd = Cmd & "   " & Val(Cells(Rec, LocationIDCol)) & ")"
        conn.Execute Cmd, recordsAffected
        Call logDataEntry("      SQL > " & Cmd & " (" & recordsAffected & " records affected)")
        If recordsAffected = 0 Then GoTo OraFail:
Next_Prog:
    Next prog
            
    SaveLabourRecords = True
    
Exit Function
OraFail:
        Call logDataEntry("SaveLabourRecords > OraFail > Error" & Err.Number & ": " & Err.Description)
        Call logDataEntry("      Failed SQL > " & Cmd & " (" & recordsAffected & " records affected)")

End Function
