Option Explicit

Dim OptionDev As Boolean

Private Sub lblHelp_Click()
Call logDataEntry("User viewing help on Warnawi")
ActiveWorkbook.FollowHyperlink Address:="http://warnawi.parks.vic.gov.au/employeecentre/myemployment/Pages/Completing-and-submitting-timesheets.aspx", NewWindow:=True

End Sub

Private Sub NameBox_KeyDown(ByVal KeyCode As MSForms.ReturnInteger, ByVal Shift As Integer)
  If KeyCode = 13 Then Call GetNames
End Sub

Private Sub UserForm_Activate() 'Called from Fm_Welcome ONLY
    With Fm_Timesheet_Setup
      .StartUpPosition = 0
      .Left = Application.Left + (0.5 * Application.Width) - (0.5 * .Width)
      .Top = Application.Top + (0.5 * Application.Height) - (0.5 * .Height)
    End With
    DoEvents
    
    ContinueButton.Enabled = False
    NameBox = ""
    ResultCombo.Clear
    ResultCombo = ""
    Me.Height = 111

End Sub

Private Sub CancelButton_Click()
    Call logDataEntry("Fm_Timesheet_Setup > CancelButton_Click() > Cancelled by user - Setup failed! ")
    Me.Hide
    MsgBox "Setup Cancelled.  Please try again."
    ClearSetup2
    Fm_Welcome.Show
    End
End Sub

Private Sub UserForm_Terminate()
    'user clicked the X at the top right of the form
    Call logDataEntry("Fm_Timesheet_Setup > UserForm_Terminate() > Cancelled by user - Setup failed! ")
    Range("LastName") = ""
    Call LockTimesheet
    End

          
End Sub


Private Sub FindButton_Click()
If Trim(NameBox) = "" Then Exit Sub
    GetNames
End Sub

Private Sub GetNames() 'Find names that match NameBox and Load ResultCombo
    Dim Cmd As String
    Dim Recs As Integer
    Dim N As Variant
    'clearsheet
    Call OpenPVTSConnection(tmode)
     If Not ConOpen Then GoTo OraFail
    On Error GoTo setupErr
    '------------------------------------------------------------------------------------------
    'GET LIST of staff matching namebox criteria
    Cmd = "select Last_Name || ' ' || First_Name, OFFICE, Person_ID "           'NOTE '|' key (pipe) is CAPITAL '\'
    Cmd = Cmd & "FROM PV_EMPLOYEE_DETAILS_MV "
    Cmd = Cmd & " WHERE lower(Last_Name) like '%" & Replace(LCase(NameBox), "'", "''") & "%' "

    
    'Cmd = "Select  Full_Name, Location_Code, Person_ID "
    'Cmd = Cmd & " FROM pv_employee_mv"
    'Cmd = Cmd & " WHERE lower(full_name) like '%" & Replace(LCase(NameBox), "'", "''") & "%' "
    '--------------------------------------------------------------------------------------------
    
    
    Set RS = New Adodb.Recordset
    RS.Open Cmd, conn, adOpenStatic, adLockReadOnly
        
    Recs = RS.RecordCount
    If Recs > 0 Then
    
        Dim i As Single
        Dim MyArray() As String
    
        ReDim MyArray(Recs, 3) '3 columns in combobox
        RS.MoveFirst
        For i = 1 To Recs
            N = RS.Fields(0): If IsNull(N) Then N = "-"
            MyArray(i, 0) = N
            N = RS.Fields(1): If IsNull(N) Then N = "-"
            MyArray(i, 1) = N
            N = RS.Fields(2): If IsNull(N) Then N = "-"
            MyArray(i, 2) = CStr(N)
            RS.MoveNext
        Next i
    
        ResultCombo.List = MyArray

        ResultCombo.RemoveItem (0)
        If Recs = 1 Then ResultCombo = ResultCombo.List(0) Else ResultCombo = Recs & " records found. Please select from list"
        Me.Height = 196
    Else
            MsgBox "Cannot find any results for '" & NameBox & "'" & vbCr & _
            "Please try again", vbExclamation, MsgCaption
            ResultCombo.Clear
            NameBox.SetFocus
    End If
    RS.Close
    conn.Close
    Set conn = Nothing: Set RS = Nothing
    Exit Sub
    
OraFail:
    Call logDataEntry("GetNames > OraFail: Unable to connect to Oracle database. ")
    MsgBox "Unable to connect to Oracle database. ", vbExclamation, MsgCaption
Exit Sub
setupErr:
    Call logDataEntry("GetNames > OraFail: Error retrieving names from Oracle database. ")
    MsgBox "Error retrieving names from Oracle database. " & vbCr & "Error details:" & Err.Description, vbExclamation, MsgCaption
End Sub

Private Sub ResultCombo_Click()
    If ResultCombo.MatchFound Then ContinueButton.Enabled = True: ContinueButton.SetFocus

End Sub

Private Sub ContinueButton_Click()
    Dim User_ID As Long
    Dim p, Cmd, TempPW As String
    Dim TempATBal As Single
    Dim TempRDOBal As Integer
    Dim TempFileLocation As String
    Dim N As Integer
    Dim OK_To_Continue  As Boolean
    Dim OldTimesheetExists As Boolean
    Dim recordsAffected As Long
    
    OldTimesheetExists = False
    TempRDOBal = 0
    TempATBal = 0
    TempFileLocation = vbNullString
    
    If ResultCombo.ListIndex = -1 Then
        'entry not found in combo list values
        Call logDataEntry("Fm_Timesheet_Setup > Error with user specified ('" & ResultCombo.Value & "').  Retrying...")
        ResultCombo.Value = ""
        Exit Sub
    End If
    User_ID = CLng(ResultCombo.List(ResultCombo.ListIndex, 2))
    Call logDataEntry("Fm_Timesheet_Setup > Person_ID = " & User_ID & " (" & ActiveWorkbook.FullName & ")")
    'Range("PersonID") = User_ID
    Call OpenPVTSConnection(tmode)

    If Not ConOpen Then
        Me.Hide
        MsgBox "Unable to connect to database. Please ensure you are connected to the Parks Victoria network", vbExclamation, MsgCaption
        Call logDataEntry("Fm_Timesheet_Setup > Setup Failed: Unable to connect to database (" & ActiveWorkbook.FullName & ")")
        Exit Sub
    End If
    Set RS = New Adodb.Recordset
    
    On Error GoTo setupErr
    '----------------Check if a current (2020-21) timesheet exists -----------------------------------------
    Cmd = "Select  a.File_Location "
    Cmd = Cmd & " FROM PV_TS_USER_T a, PV_TS_WORKLIFE_T b "
    Cmd = Cmd & " WHERE a.Person_ID = b.Person_ID "
    Cmd = Cmd & " AND a.Person_ID = " & User_ID & " "
    Cmd = Cmd & " AND b.FINANCIAL_YEAR = '2020-21' "
    
    RS.Open Cmd, conn, adOpenStatic, adLockReadOnly
    If RS.RecordCount <> 0 Then
        MsgBox "A timesheet already exists for " & ResultCombo.Text & " located at " & RS.Fields("File_Location") & vbCr & vbCr & "Contact the help desk.", vbExclamation, MsgCaption
        Call logDataEntry("Fm_Timesheet_Setup > Fail > A timesheet already exists for " & ResultCombo.Text & " located at " & RS.Fields("File_Location") & ", Failsafe SQL>" & Cmd & " (" & ActiveWorkbook.FullName & ")")
        RS.Close: Set RS = Nothing
        conn.Close: Set conn = Nothing
        Exit Sub
    End If
    RS.Close
    
    '----------------Check if an old 2019-20 timesheet exists -----------------------------------------
    'Cmd = "Select  a.PASSWORD, a.AT_BALANCE, a.RDO_BALANCE, a.FILE_LOCATION "
    Cmd = "Select  a.* "
    Cmd = Cmd & " FROM PV_TS_USER_T a, PV_TS_WORKLIFE_T b "
    Cmd = Cmd & " WHERE a.Person_ID = b.Person_ID "
    Cmd = Cmd & " AND a.Person_ID = " & User_ID & " "
    Cmd = Cmd & " AND b.FINANCIAL_YEAR = '2019-20' "
    Cmd = Cmd & " AND b.PERIOD = 1 "
    RS.Open Cmd, conn, adOpenStatic, adLockReadOnly
    If RS.RecordCount <> 0 Then 'Old timesheet found
            OldTimesheetExists = True
            TempPW = RS.Fields("PASSWORD")
            TempATBal = RS.Fields("AT_BALANCE")
            TempRDOBal = RS.Fields("RDO_BALANCE")
            TempFileLocation = RS.Fields("FILE_LOCATION")
            'update PV_TS_USER_T SET LAST_UPDATE = '14/SEP/18', AT_OPEN = 16.32, Start_DATE = '01/Jul/18', File_Location = 'O:\PVgroups\Timesheets\2018-19\Workcentres\East Region\East Gippsland\Snowy Croajingolong\Orbost\Renee Solomon PV Timesheet 2018-19 (V1.0) - .xlsm' WHERE person_ID = 79332;
            Cmd = "update PV_TS_USER_T SET "
            Cmd = Cmd & "LAST_UPDATE = '" & Format(RS.Fields("LAST_UPDATE"), "dd/mmm/yy") & "', "
            Cmd = Cmd & "AT_BALANCE = " & RS.Fields("AT_BALANCE") & ", "
            Cmd = Cmd & "RDO_BALANCE = " & RS.Fields("RDO_BALANCE") & ", "
            Cmd = Cmd & "AT_OPEN = " & RS.Fields("AT_OPEN") & ", "
            Cmd = Cmd & "Start_DATE = '" & Format(RS.Fields("Start_DATE"), "dd/mmm/yy") & "', "
            Cmd = Cmd & "PASSWORD = '" & RS.Fields("PASSWORD") & "', "
            Cmd = Cmd & "File_Location = '" & RS.Fields("File_Location") & "', "
            Cmd = Cmd & "LOCATION_ID = '" & RS.Fields("LOCATION_ID") & "' "
            Cmd = Cmd & "WHERE person_ID = " & User_ID & ";"
            Call logDataEntry("Fm_Timesheet_Setup > Failsafe rollback SQL: " & """" & Cmd & """")
    End If
    RS.Close: Set RS = Nothing
    conn.Close: Set conn = Nothing
    Me.Hide
    '--------------------------------------------------------------------------------------------
    If OldTimesheetExists Then
        If MsgBox("Would you like to use the same timesheet password as last year?", vbYesNo, MsgCaption) = vbYes Then
            Range("PKey") = TempPW: GoTo UsedOldPassword
        End If
    End If
    'Get a password for this timesheet and save
GetNewPassword:
    p = GetPassword("Please enter a password for your timesheet")
    If p = "" Then
        If MsgBox("You have not entered a password. Would you like to try again?", vbYesNo, MsgCaption) = vbYes Then
            GoTo GetNewPassword
        Else
            Call logDataEntry("Fm_Timesheet_Setup > Setup Failed: Password [" & p & "] entered. (" & ActiveWorkbook.FullName & ")")
            MsgBox "Timesheet setup has been cancelled.", vbExclamation, "No password entered"
            Me.Hide: ClearSetup2: Exit Sub
        End If
    End If
    If p <> GetPassword("Please re-type your password") Then
        Call logDataEntry("Fm_Timesheet_Setup > The passwords you typed do not match.")
        MsgBox "The passwords you typed do not match", vbExclamation, MsgCaption:
        GoTo GetNewPassword
    End If
    Range("PKey") = p
    Call logDataEntry("Fm_Timesheet_Setup > Password OK.")
    
UsedOldPassword:

    '--------------------------------------------------------------------------------------------
    'Get Personal Information
    
    LoadPersonInformation (User_ID)
    
    '--------------------------------------------------------------------------------------------
    
    If Not InfoLoadedOK Then 'This is an error condition
        'ABANDON SETUP
        MsgBox "Timesheet setup failed.", vbExclamation, MsgCaption
        Call logDataEntry("Fm_Timesheet_Setup > LoadPersonInformation > Setup Failed: " & User_ID & ", " & ActiveWorkbook.FullName & "")
        Me.Hide: ClearSetup2: Exit Sub
    End If
    Call logDataEntry("Fm_Timesheet_Setup > LoadPersonInformation > OK: " & User_ID & ", " & ActiveWorkbook.FullName & "")
    
    Range("MyLocationList").Cells(2, 1) = Range("WorkCentre")
    If Range("MyLocationList").Cells(2, 1) = "" Then 'This is an error condition (No location data for user)
        'ABANDON SETUP
        MsgBox "Workcentre information unavailable, timesheet setup failed.", vbExclamation, MsgCaption
        ClearSetup2
        Me.Hide
        Call logDataEntry("Fm_Timesheet_Setup > Workcentre information unavailable. Setup Failed: " & User_ID & " (" & ActiveWorkbook.FullName & ")")
        Exit Sub
    End If
    Call LoadLocationList      'added 2019-07-15
    Call logDataEntry("Fm_Timesheet_Setup > Workcentre information OK")
    
     '---------------- Rostered Days Carried -------------------
    Range("RDOCarried") = 0 'default
    Range("RDOBalance") = 0 'default
    Range("Takes_RDOs") = "no" 'default
    
     If Range("RosteredDays") <> 0 Then
            If Range("TotalHours") < 76 Then
                If MsgBox("Do you take 'Rostered Days Off' for weekend days worked?", vbYesNo, MsgCaption) = vbNo Then GoTo SkipRDO
            End If
        Range("Takes_RDOs") = "yes"
        If TempRDOBal < 0 Then TempRDOBal = 0 'don't allow negative balance to be carried
        Fm_Carried_RDO.TextBox1 = TempRDOBal 'data from old timesheet
        Fm_Carried_RDO.Show 'Get RDOs Carried
     End If
    Call logDataEntry("Fm_Timesheet_Setup > RDOBalance OK = " & TempRDOBal & " ")
     
SkipRDO:
     '-----------------  Accrued Time ---------------
        Range("ATCarried") = 0
        Range("ATBalance") = 0
        Range("ATAgreement") = "no" 'default
        If MsgBox("Do you accrue time for extra hours worked?", vbYesNo, MsgCaption) = vbYes Then
            Range("ATAgreement") = "yes"
            If TempATBal < 0 Then TempATBal = 0 'Don't allow negative balance to be carried
            Fm_Carried_AT.TextBox1 = Fix(TempATBal)
            Fm_Carried_AT.TextBox2 = Format((TempATBal - Fix(TempATBal)) * 60, "00")
            Fm_Carried_AT.Show
            Call logDataEntry("Fm_Timesheet_Setup > ATBalance OK = " & TempATBal & " ")
        Else
            Range("ATAgreement") = "no"
            TempATBal = 0
            Call logDataEntry("Fm_Timesheet_Setup > No AT agreement.  ATBalance = " & TempATBal & " ")
        End If
    
    '-------------------- Cup Day -------------------
    Dim cday As String
    Dim cupday As Date
    If MsgBox(" Is Melbourne Cup day a public holiday in your area?", vbYesNo, "Cup day holiday") = vbNo Then
retry:
        cday = InputBox("Please enter your cup day holiday (dd/mmm/yyyy) ", MsgCaption, "3/Nov/2020")
            If Not IsDate(cday) Then MsgBox "Cannot identify date. Please try again.", vbExclamation, MsgCaption: GoTo retry
            cupday = CDate(cday)
            'If cupday < Range("StartDate") Or cupday > Range("EndDate") Then MsgBox "The Date is out of range. Please try again.", vbExclamation, MsgCaption: GoTo retry
            If cupday <= Range("StartDate") Or cupday >= Range("EndDate") Then MsgBox "The Date is not in this Financial Year. Please try again.", vbExclamation, MsgCaption: GoTo retry      '180609 wording for melb cup
            If MsgBox("Please confirm your public holiday for cup day is: " & Format(cupday, "dd/mmm/yyyy"), vbYesNo, MsgCaption) = vbNo Then GoTo retry
        Range("CupDayHoliday") = cupday
    Else
        Range("CupDayHoliday") = CDate("3/Nov/2020")
    
    End If
    Call logDataEntry("Fm_Timesheet_Setup > Cup day OK = " & Format(Range("CupDayHoliday"), "dd/mmm/yy") & " in " & GetLocationName(Range("WorkCentre")) & " (Checking for user errors)")
    
'------------------ Variance Display ---------------
    Fm_VarianceFormatSetup.Show
    If Fm_VarianceFormatSetup.OptionDecimal = True Then
        Range("VarianceFormat") = "decimal"
        Range("VarianceHeader") = "Variance to Work Hours : (Decimal)"
    Else
        Range("VarianceFormat") = "hh:mm"
        Range("VarianceHeader") = "Variance to Work Hours : (HH:MM)"
    End If
    Call logDataEntry("Fm_Timesheet_Setup > VarianceFormat OK: " & Range("VarianceFormat") & "")

    '-------------------Create/Update USER-------------------------
    Fm_SetupConfirmation.Show    'chg180520
    'If MsgBox("If you are sure all of your information is correct," & vbCr & vbCr & "click OK to complete seting up your timesheet." & vbCr & vbCr & " Click Cancel to start over.", vbOKCancel, MsgCaption) = vbCancel Then
    '   Me.Hide: ClearSetup2: Fm_Welcome.Show: Exit Sub
    'End If
    
    Call OpenPVTSConnection(tmode)
     If Not ConOpen Then
        Me.Hide
        MsgBox "Unable to connect to database. Please ensure you are connected to the Parks Victoria network", vbExclamation, MsgCaption
        Call logDataEntry("Fm_Timesheet_Setup > Setup Failed: Failed to connect to database2 (" & ActiveWorkbook.FullName & ")")
        ClearSetup2
        Exit Sub
    End If
     
    If OldTimesheetExists Then
    
                Cmd = "UPDATE PV_TS_USER_T "
                Cmd = Cmd & "SET "
                Cmd = Cmd & " LAST_UPDATE = '" & Format(Date, "dd-mmm-yyyy") & "', "
                Cmd = Cmd & " AT_BALANCE = " & Range("ATBalance") & ", "
                Cmd = Cmd & " RDO_BALANCE = " & Range("RDOBalance") & ", "
                Cmd = Cmd & " RDO_OPEN = " & Range("RDOCarried") & ", "
                Cmd = Cmd & " AT_OPEN = " & Range("ATCarried") & ", "
                Cmd = Cmd & " START_DATE = '" & Format(Range("StartDate"), "dd-mmm-yyyy") & "', "
                Cmd = Cmd & " PASSWORD = '" & Range("Pkey") & "', "
                Cmd = Cmd & " FILE_LOCATION = '" & Replace(ThisWorkbook.Path & "\" & ThisWorkbook.Name, "'", "''") & "', "
                Cmd = Cmd & " LOCATION_ID = " & Range("WorkCentre") & " "
                Cmd = Cmd & "WHERE Person_ID = '" & Range("PersonID") & "'"
                conn.Execute Cmd, recordsAffected
                Call logDataEntry("      SQL > " & Cmd & " (" & recordsAffected & " records affected)")
    Else
    
                Cmd = "INSERT INTO PV_TS_USER_T "
                Cmd = Cmd & "(PERSON_ID, "
                Cmd = Cmd & " LAST_UPDATE, "
                Cmd = Cmd & " AT_BALANCE, "
                Cmd = Cmd & " RDO_BALANCE, "
                Cmd = Cmd & " RDO_OPEN, "
                Cmd = Cmd & " AT_OPEN, "
                Cmd = Cmd & " START_DATE, "
                Cmd = Cmd & " PASSWORD, "
                Cmd = Cmd & " FILE_LOCATION, "
                Cmd = Cmd & " LOCATION_ID) "
                
                Cmd = Cmd & " VALUES "
                Cmd = Cmd & "(" & User_ID & ", "
                Cmd = Cmd & " '" & Format(Date, "dd-mmm-yyyy") & "', "
                Cmd = Cmd & "  " & Range("ATBalance") & ", "
                Cmd = Cmd & "  " & Range("RDOBalance") & ", "
                Cmd = Cmd & "  " & Range("RDOCarried") & ", "
                Cmd = Cmd & "  " & Range("ATCarried") & ", "
                Cmd = Cmd & " '" & Format(Range("StartDate"), "dd-mmm-yyyy") & "', "
                Cmd = Cmd & " '" & Range("Pkey") & "', "
                Cmd = Cmd & " '" & Replace(ThisWorkbook.Path & "\" & ThisWorkbook.Name, "'", "''") & "', "
                Cmd = Cmd & "  " & Range("WorkCentre") & ")"
                conn.Execute Cmd, recordsAffected
                Call logDataEntry("      SQL > " & Cmd & " (" & recordsAffected & " records affected)")
    End If
    'Create Work Life Balance rows
    Dim M As Integer
    For M = 1 To 12
            Cmd = "INSERT INTO PV_TS_WORKLIFE_T "
            Cmd = Cmd & "(PERSON_ID, "
            Cmd = Cmd & "PERIOD, "
            Cmd = Cmd & "FINANCIAL_YEAR, "
            Cmd = Cmd & "LOCATION_ID, "
            Cmd = Cmd & "HOURS_ACCRUED, "
            Cmd = Cmd & "HOURS_IN_LIEU, "
            Cmd = Cmd & "HOURS_SPONSORED, "
            Cmd = Cmd & "HOURS_OVERTIME, "
            Cmd = Cmd & "HOURS_AT_BALANCE, "
            Cmd = Cmd & "DAYS_PV_DUTY, "
            Cmd = Cmd & "DAYS_ER_DUTY, "
            Cmd = Cmd & "DAYS_OFF_DUTY, "
            Cmd = Cmd & "DAYS_WE_DUTY, "
            Cmd = Cmd & "DAYS_ROSTERED_OFF, "
            Cmd = Cmd & "DAYS_RDO_BALANCE, "
            Cmd = Cmd & "DAYS_ANNUAL_LEAVE, "
            Cmd = Cmd & "DAYS_OTHER_LEAVE, "
            Cmd = Cmd & "PV_ROLE, "
            Cmd = Cmd & "ER_ROLE "
            Cmd = Cmd & ")"
            
            Cmd = Cmd & "VALUES ( "
            Cmd = Cmd & User_ID & ", " 'Person ID (Number)
            Cmd = Cmd & " " & M & ", " 'Month (Number)
            Cmd = Cmd & " '" & OraFinYear & "', " 'Financial Year (VARCHAR2)
            Cmd = Cmd & Range("WorkCentre") & ", "  'Location ID (Number)
            Cmd = Cmd & 0 & ", " 'Hours Accrued (Number)
            Cmd = Cmd & 0 & ", " 'Hours in lieu (Number)
            Cmd = Cmd & 0 & ", " 'Hours Sponsored (Number)
            Cmd = Cmd & 0 & ", " 'Hours Overtime  (Number)
            Cmd = Cmd & 0 & ", " 'Hours AT Balance  (Number)
            Cmd = Cmd & 0 & ", " 'Days PV Duty (Number)
            Cmd = Cmd & 0 & ", " 'Days ER Duty (Number)
            Cmd = Cmd & 0 & ", " 'Days Off Duty (Number)
            Cmd = Cmd & 0 & ", " 'Days Weekend Duty (Number)
            Cmd = Cmd & 0 & ", " 'Days Rostered Off (Number)
            Cmd = Cmd & 0 & ", " 'Days RDO Balance (Number)
            Cmd = Cmd & 0 & ", " 'Days Annual Leave (Number)
            Cmd = Cmd & 0 & ", " 'Days incidental Leave (Number)
            Cmd = Cmd & " '" & Range("Position") & "', " 'PV Role (VARCHAR2)
            Cmd = Cmd & " '" & Range("FireRole") & "' " 'ER Role  (VARCHAR2)
            Cmd = Cmd & ") "
            conn.Execute Cmd, recordsAffected
            Call logDataEntry("      SQL > " & Cmd & " (" & recordsAffected & " records affected)")
    Next M
    conn.Close
    Set conn = Nothing
    
    '------------------------------------------------------------------------------------
    
    If OldTimesheetExists Then
        If MsgBox("Would you like to import your Activities from your previous timesheet?", vbYesNo, MsgCaption) = vbYes Then
                'Get activities from Old timesheet
                If ImportActivities(TempFileLocation) Then
                    MsgBox "Activity import complete.", vbInformation, MsgCaption
                Else
                    MsgBox "An error occured during activity import!", vbExclamation, MsgCaption
                    Call logDataEntry("An error occured during activity import!")
                End If
        End If
    End If
    
    'Call CalculateTimesheetSummary(Range("StartDate"), Range("EndDate"))
    Call CalculateTimesheetSummary(0)
    
    SetupRun = True
    ThisWorkbook.Save 'save timesheet
    SetupRun = False
    
    MsgBox "Thank you. Your timesheet setup is complete.", vbInformation, MsgCaption
    Sheets("PV").WorkLifeButton.Enabled = True
    Sheets("PV").TimesheetButton.Enabled = True

    Call logDataEntry("Fm_Timesheet_Setup > Setup Complete (" & ActiveWorkbook.FullName & ")")
    Exit Sub 'SETUP COMPLETE
    
setupErr:
    Me.Hide
    Call logDataEntry("Fm_Timesheet_Setup > Setup Failed: " & "An error occured setting up your timesheet: " & Err.Description & " - " & MsgCaption & " (" & ActiveWorkbook.FullName & ")")
    MsgBox "An error occured setting up your timesheet: " & Err.Description, vbExclamation, MsgCaption
    On Error Resume Next
    If Not conn.State = 0 Then conn.Close
    Set conn = Nothing: Set RS = Nothing
    On Error GoTo 0
    ClearSetup2
End Sub


Private Sub ClearSetup2()
    Dim N As Integer
    For N = 1 To 17
        Range("LastName").Cells(N) = ""
    Next
    For N = 1 To 15
        Range("PaidHours").Cells(N) = ""
    Next
    Sheets("Timesheet").Range("Office") = ""
End Sub

