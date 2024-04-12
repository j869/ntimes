'When this form activates, the user has entered work hours,
'so a record needs to be created in the first instance
'and the Activity needs to be saved for use again

    Option Explicit
    Dim isNewActivity As Boolean
    Dim ActivityRow As Integer
    Dim FormActivating As Boolean
    Dim Total As Integer
    Dim N As Integer
    Dim p As Integer
    Dim S As String



Private Sub Label1_Click()
    Dim Link As String
    On Error GoTo NotAvailable
    Link = "O:\PVgroups\Timesheets\Information\Presentations\2021\PV PROGRAM descriptions.docx"
    ActiveWorkbook.FollowHyperlink Address:=Link, NewWindow:=True
    'Me.Hide
    Exit Sub
NotAvailable:
        MsgBox "The file " & Link & "could not be found.", vbExclamation

End Sub

Private Sub UserForm_Activate()
'********************************************************
'   Implemented "Edit" function 2013-14
'   "EditActivityName" is global variable
'   If "EditActivityName" is null then a new Activity will be created
'   IF EditActivityName is not null then edit the EditActivityName
'********************************************************

    With Fm_Activity_New
      .StartUpPosition = 0
      .Left = Application.Left + (0.5 * Application.Width) - (0.5 * .Width)
      .Top = Application.Top + (0.5 * Application.Height) - (0.5 * .Height)
    End With
    DoEvents
    
    FormActivating = True
    
        ProgramBox1 = "": PercentBox1 = ""
        ProgramBox2 = "": PercentBox2 = ""
        ProgramBox3 = "": PercentBox3 = ""
        ProgramBox4 = "": PercentBox4 = ""
        ProgramBox5 = "": PercentBox5 = ""
        ProgramBox6 = "": PercentBox6 = ""
    
    If Not ProgramListUpToDate Then UpdateProgramList (0)
    If ProgramListUpToDate Then RefreshLabel = "Program list updated" Else RefreshLabel = "Program list NOT updated"
    
    If EditActivityName = "" Then isNewActivity = True Else isNewActivity = False
    
    If isNewActivity Then
        FormHeader = "NEW WORK ACTIVITY"
        ActivityNameBox = ""
        ActivityNameBox.Enabled = True
        
    Else '**********   This is an Edit call   ******************
        ActivityNameBox = EditActivityName
        ActivityNameBox.Enabled = False
        
        FormHeader = "EDIT WORK ACTIVITY "
        ActNum = getActivityRowNumber(EditActivityName) 'ActNum is Global
        If ActNum = 0 Then
            Me.Hide
            MsgBox "The Activity you want to edit cannot be found", vbExclamation
            Exit Sub
        End If
        
        'Populate Program/Percentage info (
        N = 2
        Do While N < 14
        If Range("ActivityList").Cells(ActNum, N) <> "" Then
            ProgramBox1 = GetProgramName(Range("ActivityList").Cells(ActNum, N))
            PercentBox1 = Format(Range("ActivityList").Cells(ActNum, N + 1), "0%")
            N = N + 2
            Exit Do
        End If
        N = N + 2
        Loop
        
        Do While N < 14
        If Range("ActivityList").Cells(ActNum, N) <> "" Then
            ProgramBox2 = GetProgramName(Range("ActivityList").Cells(ActNum, N))
            PercentBox2 = Format(Range("ActivityList").Cells(ActNum, N + 1), "0%")
            N = N + 2
            Exit Do
        End If
        N = N + 2
        Loop
        
        Do While N < 14
        If Range("ActivityList").Cells(ActNum, N) <> "" Then
            ProgramBox3 = GetProgramName(Range("ActivityList").Cells(ActNum, N))
            PercentBox3 = Format(Range("ActivityList").Cells(ActNum, N + 1), "0%")
            N = N + 2
            Exit Do
        End If
        N = N + 2
        Loop
            
        Do While N < 14
        If Range("ActivityList").Cells(ActNum, N) <> "" Then
            ProgramBox4 = GetProgramName(Range("ActivityList").Cells(ActNum, N))
            PercentBox4 = Format(Range("ActivityList").Cells(ActNum, N + 1), "0%")
            N = N + 2
            Exit Do
        End If
        N = N + 2
        Loop
            
        Do While N < 14
        If Range("ActivityList").Cells(ActNum, N) <> "" Then
            ProgramBox5 = GetProgramName(Range("ActivityList").Cells(ActNum, N))
            PercentBox5 = Format(Range("ActivityList").Cells(ActNum, N + 1), "0%")
            N = N + 2
            Exit Do
        End If
        N = N + 2
        Loop
            
        Do While N < 14
        If Range("ActivityList").Cells(ActNum, N) <> "" Then
            ProgramBox6 = GetProgramName(Range("ActivityList").Cells(ActNum, N))
            PercentBox6 = Format(Range("ActivityList").Cells(ActNum, N + 1), "0%")
            Exit Do
        End If
        N = N + 2
        Loop
        
    End If
    FormActivating = False
    UpdateTotal
    'LoadProgramList 'Loads Program lists
        
End Sub

Private Sub ActivityNameBox_AfterUpdate()
    'Check for duplicate name
    If isNewActivity Then
        ActivityNameBox = Trim(ActivityNameBox)
        If ActivityNameBox <> "" Then
            If ActivityExists(ActivityNameBox) Then
                ActivityNameBox = ""
                MsgBox "The Activity name already exists." & vbCr & "Please enter a different name for this Activity", vbExclamation, MsgCaption
            End If
        End If
        If ActivityNameBox <> "" Then ActivityNameBox.BackColor = Green Else ActivityNameBox.BackColor = Red ': FormReady = False
    Else
        ActivityNameBox.BackColor = Green
    End If

End Sub



'***********  ProgramBox Enter **************
Private Sub ProgramBox1_Enter()
    FormActivating = True
'First, clear the ProgramBox
    S = ProgramBox1.Text: ProgramBox1.Clear: ProgramBox1.Text = S
    
    'If the total is 100% and the ProgramBox = "" then NO list
    If S = "" And Val(PercentBox1) + Val(PercentBox2) + Val(PercentBox3) + Val(PercentBox4) + Val(PercentBox5) + Val(PercentBox6) >= 100 Then
        FormActivating = False
        Exit Sub
    End If

    'OK, either the total is < 100 or The ProgramBox <> ""; So load all Programs
    p = 5: N = 2
    While Range("ProgramList").Cells(N, 1) <> ""
        If Range("programList").Cells(N, 2) = Range("programList").Cells(N, 3) Then 'Only show Active programs (mapped to same number)
            ProgramBox1.AddItem (PadString(Range("ProgramList").Cells(N, 1), p) & " " & Range("ProgramList").Cells(N, 2) & " " & Range("ProgramList").Cells(N, 4))
        End If
        N = N + 1
    Wend
    'Now remove all used Programs
    S = ProgramBox1.Text
    ProgramBox1 = ProgramBox2.Text
    If ProgramBox1.ListIndex >= 0 Then ProgramBox1.RemoveItem (ProgramBox1.ListIndex)
    ProgramBox1 = ProgramBox3.Text
    If ProgramBox1.ListIndex >= 0 Then ProgramBox1.RemoveItem (ProgramBox1.ListIndex)
    ProgramBox1 = ProgramBox4.Text
    If ProgramBox1.ListIndex >= 0 Then ProgramBox1.RemoveItem (ProgramBox1.ListIndex)
    ProgramBox1 = ProgramBox5.Text
    If ProgramBox1.ListIndex >= 0 Then ProgramBox1.RemoveItem (ProgramBox1.ListIndex)
    ProgramBox1 = ProgramBox6.Text
    If ProgramBox1.ListIndex >= 0 Then ProgramBox1.RemoveItem (ProgramBox1.ListIndex)
    ProgramBox1.Text = S

    If ProgramBox1 = "" Then ProgramBox1.DropDown
    FormActivating = False

End Sub


Private Sub ProgramBox2_Enter()
    FormActivating = True
    S = ProgramBox2.Text: ProgramBox2.Clear: ProgramBox2.Text = S
    
    If S = "" And Val(PercentBox1) + Val(PercentBox2) + Val(PercentBox3) + Val(PercentBox4) + Val(PercentBox5) + Val(PercentBox6) >= 100 Then
        FormActivating = False
        Exit Sub
    End If
    
    p = 5: N = 2
    While Range("ProgramList").Cells(N, 1) <> ""
        If Range("programList").Cells(N, 2) = Range("programList").Cells(N, 3) Then 'Only show Active programs (mapped to same number)
            ProgramBox2.AddItem (PadString(Range("ProgramList").Cells(N, 1), p) & " " & Range("ProgramList").Cells(N, 2) & " " & Range("ProgramList").Cells(N, 4))
        End If
        N = N + 1
    Wend
    'Now remove used Programs
    S = ProgramBox2.Text
    ProgramBox2 = ProgramBox1.Text
    If ProgramBox2.ListIndex >= 0 Then ProgramBox2.RemoveItem (ProgramBox2.ListIndex)
    ProgramBox2 = ProgramBox3.Text
    If ProgramBox2.ListIndex >= 0 Then ProgramBox2.RemoveItem (ProgramBox2.ListIndex)
    ProgramBox2 = ProgramBox4.Text
    If ProgramBox2.ListIndex >= 0 Then ProgramBox2.RemoveItem (ProgramBox2.ListIndex)
    ProgramBox2 = ProgramBox5.Text
    If ProgramBox2.ListIndex >= 0 Then ProgramBox2.RemoveItem (ProgramBox2.ListIndex)
    ProgramBox2 = ProgramBox6.Text
    If ProgramBox2.ListIndex >= 0 Then ProgramBox2.RemoveItem (ProgramBox2.ListIndex)
    ProgramBox2.Text = S

    If ProgramBox2 = "" Then ProgramBox2.DropDown
    FormActivating = False

End Sub


Private Sub ProgramBox3_Enter()
    FormActivating = True
    S = ProgramBox3.Text: ProgramBox3.Clear: ProgramBox3.Text = S
    
    If S = "" And Val(PercentBox1) + Val(PercentBox2) + Val(PercentBox3) + Val(PercentBox4) + Val(PercentBox5) + Val(PercentBox6) >= 100 Then
        FormActivating = False
        Exit Sub
    End If
    
    p = 5: N = 2
    While Range("ProgramList").Cells(N, 1) <> ""
        If Range("programList").Cells(N, 2) = Range("programList").Cells(N, 3) Then 'Only show Active programs (mapped to same number)
            ProgramBox3.AddItem (PadString(Range("ProgramList").Cells(N, 1), p) & " " & Range("ProgramList").Cells(N, 2) & " " & Range("ProgramList").Cells(N, 4))
        End If
        N = N + 1
    Wend
    'Now remove used Programs
    S = ProgramBox3.Text
    ProgramBox3 = ProgramBox1.Text
    If ProgramBox3.ListIndex >= 0 Then ProgramBox3.RemoveItem (ProgramBox3.ListIndex)
    ProgramBox3 = ProgramBox2.Text
    If ProgramBox3.ListIndex >= 0 Then ProgramBox3.RemoveItem (ProgramBox3.ListIndex)
    ProgramBox3 = ProgramBox4.Text
    If ProgramBox3.ListIndex >= 0 Then ProgramBox3.RemoveItem (ProgramBox3.ListIndex)
    ProgramBox3 = ProgramBox5.Text
    If ProgramBox3.ListIndex >= 0 Then ProgramBox3.RemoveItem (ProgramBox3.ListIndex)
    ProgramBox3 = ProgramBox6.Text
    If ProgramBox3.ListIndex >= 0 Then ProgramBox1.RemoveItem (ProgramBox1.ListIndex)
    ProgramBox3.Text = S

    If ProgramBox3 = "" Then ProgramBox3.DropDown
    FormActivating = False

End Sub


Private Sub ProgramBox4_Enter()
    FormActivating = True
    S = ProgramBox4.Text: ProgramBox4.Clear: ProgramBox4.Text = S
    
    If S = "" And Val(PercentBox1) + Val(PercentBox2) + Val(PercentBox3) + Val(PercentBox4) + Val(PercentBox5) + Val(PercentBox6) >= 100 Then
        FormActivating = False
        Exit Sub
    End If
    
    p = 5: N = 2
    While Range("ProgramList").Cells(N, 1) <> ""
        If Range("programList").Cells(N, 2) = Range("programList").Cells(N, 3) Then 'Only show Active programs (mapped to same number)
            ProgramBox4.AddItem (PadString(Range("ProgramList").Cells(N, 1), p) & " " & Range("ProgramList").Cells(N, 2) & " " & Range("ProgramList").Cells(N, 4))
        End If
        N = N + 1
    Wend
    'Now remove used Programs
    S = ProgramBox4.Text
    ProgramBox4 = ProgramBox1.Text
    If ProgramBox4.ListIndex >= 0 Then ProgramBox4.RemoveItem (ProgramBox4.ListIndex)
    ProgramBox4 = ProgramBox2.Text
    If ProgramBox4.ListIndex >= 0 Then ProgramBox4.RemoveItem (ProgramBox4.ListIndex)
    ProgramBox4 = ProgramBox3.Text
    If ProgramBox4.ListIndex >= 0 Then ProgramBox4.RemoveItem (ProgramBox4.ListIndex)
    ProgramBox4 = ProgramBox5.Text
    If ProgramBox4.ListIndex >= 0 Then ProgramBox4.RemoveItem (ProgramBox4.ListIndex)
    ProgramBox4 = ProgramBox6.Text
    If ProgramBox4.ListIndex >= 0 Then ProgramBox4.RemoveItem (ProgramBox4.ListIndex)
    ProgramBox4.Text = S

    If ProgramBox4 = "" Then ProgramBox4.DropDown
    FormActivating = False

End Sub


Private Sub ProgramBox5_Enter()
    FormActivating = True
    S = ProgramBox5.Text: ProgramBox5.Clear: ProgramBox5.Text = S
    
    If S = "" And Val(PercentBox1) + Val(PercentBox2) + Val(PercentBox3) + Val(PercentBox4) + Val(PercentBox5) + Val(PercentBox6) >= 100 Then
        FormActivating = False
        Exit Sub
    End If
    
    p = 5: N = 2
    While Range("ProgramList").Cells(N, 1) <> ""
        If Range("programList").Cells(N, 2) = Range("programList").Cells(N, 3) Then 'Only show Active programs (mapped to same number)
            ProgramBox5.AddItem (PadString(Range("ProgramList").Cells(N, 1), p) & " " & Range("ProgramList").Cells(N, 2) & " " & Range("ProgramList").Cells(N, 4))
        End If
        N = N + 1
    Wend
    'Now remove used Programs
    S = ProgramBox5.Text
    ProgramBox5 = ProgramBox1.Text
    If ProgramBox5.ListIndex >= 0 Then ProgramBox5.RemoveItem (ProgramBox5.ListIndex)
    ProgramBox5 = ProgramBox2.Text
    If ProgramBox5.ListIndex >= 0 Then ProgramBox5.RemoveItem (ProgramBox5.ListIndex)
    ProgramBox5 = ProgramBox3.Text
    If ProgramBox5.ListIndex >= 0 Then ProgramBox5.RemoveItem (ProgramBox5.ListIndex)
    ProgramBox5 = ProgramBox4.Text
    If ProgramBox5.ListIndex >= 0 Then ProgramBox5.RemoveItem (ProgramBox5.ListIndex)
    ProgramBox5 = ProgramBox6.Text
    If ProgramBox5.ListIndex >= 0 Then ProgramBox5.RemoveItem (ProgramBox5.ListIndex)
    ProgramBox5.Text = S

    If ProgramBox5 = "" Then ProgramBox5.DropDown
    FormActivating = False

End Sub


Private Sub ProgramBox6_Enter()
    FormActivating = True
    S = ProgramBox6.Text: ProgramBox6.Clear: ProgramBox6.Text = S
    
    If S = "" And Val(PercentBox1) + Val(PercentBox2) + Val(PercentBox3) + Val(PercentBox4) + Val(PercentBox5) + Val(PercentBox6) >= 100 Then
        FormActivating = False
        Exit Sub
    End If
    
    p = 5: N = 2
    While Range("ProgramList").Cells(N, 1) <> ""
        If Range("programList").Cells(N, 2) = Range("programList").Cells(N, 3) Then 'Only show Active programs (mapped to same number)
            ProgramBox6.AddItem (PadString(Range("ProgramList").Cells(N, 1), p) & " " & Range("ProgramList").Cells(N, 2) & " " & Range("ProgramList").Cells(N, 4))
        End If
        N = N + 1
    Wend
    'Now remove used Programs
    S = ProgramBox6.Text
    ProgramBox6 = ProgramBox1.Text
    If ProgramBox6.ListIndex >= 0 Then ProgramBox6.RemoveItem (ProgramBox6.ListIndex)
    ProgramBox6 = ProgramBox2.Text
    If ProgramBox6.ListIndex >= 0 Then ProgramBox6.RemoveItem (ProgramBox6.ListIndex)
    ProgramBox6 = ProgramBox3.Text
    If ProgramBox6.ListIndex >= 0 Then ProgramBox6.RemoveItem (ProgramBox6.ListIndex)
    ProgramBox6 = ProgramBox4.Text
    If ProgramBox6.ListIndex >= 0 Then ProgramBox6.RemoveItem (ProgramBox6.ListIndex)
    ProgramBox6 = ProgramBox5.Text
    If ProgramBox6.ListIndex >= 0 Then ProgramBox6.RemoveItem (ProgramBox6.ListIndex)
    ProgramBox6.Text = S

    If ProgramBox6 = "" Then ProgramBox6.DropDown
    FormActivating = False

End Sub




'***********  ProgramBox Click **************
Private Sub ProgramBox1_Click()
    If FormActivating Then Exit Sub
    CancelButton.SetFocus                      'Change focus to cause ProgramBox1_Exit()
End Sub
Private Sub ProgramBox2_Click()
    If FormActivating Then Exit Sub
    CancelButton.SetFocus
End Sub
Private Sub ProgramBox3_Click()
    If FormActivating Then Exit Sub
    CancelButton.SetFocus
End Sub
Private Sub ProgramBox4_Click()
    If FormActivating Then Exit Sub
    CancelButton.SetFocus
End Sub
Private Sub ProgramBox5_Click()
    If FormActivating Then Exit Sub
    CancelButton.SetFocus
End Sub
Private Sub ProgramBox6_Click()
    If FormActivating Then Exit Sub
    CancelButton.SetFocus
End Sub


'***********  ProgramBox Exit  **************
Private Sub ProgramBox1_Exit(ByVal Cancel As MSForms.ReturnBoolean)
    If Not ProgramBox1.MatchFound Then ProgramBox1 = "": PercentBox1 = ""
    UpdateTotal
End Sub
Private Sub ProgramBox2_Exit(ByVal Cancel As MSForms.ReturnBoolean)
    If Not ProgramBox2.MatchFound Then ProgramBox2 = "": PercentBox2 = ""
    UpdateTotal
End Sub
Private Sub ProgramBox3_Exit(ByVal Cancel As MSForms.ReturnBoolean)
    If Not ProgramBox3.MatchFound Then ProgramBox3 = "": PercentBox3 = ""
    UpdateTotal
End Sub
Private Sub ProgramBox4_Exit(ByVal Cancel As MSForms.ReturnBoolean)
    If Not ProgramBox4.MatchFound Then ProgramBox4 = "": PercentBox4 = ""
    UpdateTotal
End Sub
Private Sub ProgramBox5_Exit(ByVal Cancel As MSForms.ReturnBoolean)
    If Not ProgramBox5.MatchFound Then ProgramBox5 = "": PercentBox5 = ""
    UpdateTotal
End Sub
Private Sub ProgramBox6_Exit(ByVal Cancel As MSForms.ReturnBoolean)
    If Not ProgramBox6.MatchFound Then ProgramBox6 = "": PercentBox6 = ""
    UpdateTotal
End Sub



'***********  PercentBox Enter  **************
Private Sub PercentBox1_Enter()
    S = PercentBox1.Text: PercentBox1.Clear: PercentBox1 = S
    If ProgramBox1 = "" Then PercentBox1 = "": Exit Sub
    Total = Val(PercentBox1) + Val(PercentBox2) + Val(PercentBox3) + Val(PercentBox4) + Val(PercentBox5) + Val(PercentBox6)
    N = Val(PercentBox1) + 100 - Total
        While N >= 5
            PercentBox1.AddItem (CStr(N) & "%")
            N = N - 5
        Wend
    If PercentBox1 = "" Then PercentBox1.DropDown
End Sub
Private Sub PercentBox2_Enter()
    S = PercentBox2.Text: PercentBox2.Clear: PercentBox2 = S
    If ProgramBox2 = "" Then PercentBox2 = "": Exit Sub
    Total = Val(PercentBox1) + Val(PercentBox2) + Val(PercentBox3) + Val(PercentBox4) + Val(PercentBox5) + Val(PercentBox6)
    N = Val(PercentBox2) + 100 - Total
        While N >= 5
            PercentBox2.AddItem (CStr(N) & "%")
            N = N - 5
        Wend
    If PercentBox2 = "" Then PercentBox2.DropDown
End Sub
Private Sub PercentBox3_Enter()
    S = PercentBox3.Text: PercentBox3.Clear: PercentBox3 = S
    If ProgramBox3 = "" Then PercentBox3 = "": Exit Sub
    Total = Val(PercentBox1) + Val(PercentBox2) + Val(PercentBox3) + Val(PercentBox4) + Val(PercentBox5) + Val(PercentBox6)
    N = Val(PercentBox3) + 100 - Total
        While N >= 5
            PercentBox3.AddItem (CStr(N) & "%")
            N = N - 5
        Wend
    If PercentBox3 = "" Then PercentBox3.DropDown
End Sub
Private Sub PercentBox4_Enter()
    S = PercentBox4.Text: PercentBox4.Clear: PercentBox4 = S
    If ProgramBox4 = "" Then PercentBox4 = "": Exit Sub
    Total = Val(PercentBox1) + Val(PercentBox2) + Val(PercentBox3) + Val(PercentBox4) + Val(PercentBox5) + Val(PercentBox6)
    N = Val(PercentBox4) + 100 - Total
        While N >= 5
            PercentBox4.AddItem (CStr(N) & "%")
            N = N - 5
        Wend
    If PercentBox4 = "" Then PercentBox4.DropDown
End Sub
Private Sub PercentBox5_Enter()
    S = PercentBox5.Text: PercentBox5.Clear: PercentBox5 = S
    If ProgramBox5 = "" Then PercentBox5 = "": Exit Sub
    Total = Val(PercentBox1) + Val(PercentBox2) + Val(PercentBox3) + Val(PercentBox4) + Val(PercentBox5) + Val(PercentBox6)
    N = Val(PercentBox5) + 100 - Total
        While N >= 5
            PercentBox5.AddItem (CStr(N) & "%")
            N = N - 5
        Wend
    If PercentBox5 = "" Then PercentBox5.DropDown
End Sub
Private Sub PercentBox6_Enter()
    S = PercentBox6.Text: PercentBox6.Clear: PercentBox6 = S
    If ProgramBox6 = "" Then PercentBox6 = "": Exit Sub
    Total = Val(PercentBox1) + Val(PercentBox2) + Val(PercentBox3) + Val(PercentBox4) + Val(PercentBox5) + Val(PercentBox6)
    N = Val(PercentBox6) + 100 - Total
        While N >= 5
            PercentBox6.AddItem (CStr(N) & "%")
            N = N - 5
        Wend
    If PercentBox6 = "" Then PercentBox6.DropDown
End Sub



'***********  PercentBox Click  **************
Private Sub PercentBox1_Click()
    If FormActivating Then Exit Sub
    CancelButton.SetFocus 'Change focus to call PercentBox1_Exit()
End Sub
Private Sub PercentBox2_Click()
    If FormActivating Then Exit Sub
    CancelButton.SetFocus
End Sub
Private Sub PercentBox3_Click()
    If FormActivating Then Exit Sub
    CancelButton.SetFocus
End Sub
Private Sub PercentBox4_Click()
    If FormActivating Then Exit Sub
    CancelButton.SetFocus
End Sub
Private Sub PercentBox5_Click()
    If FormActivating Then Exit Sub
    CancelButton.SetFocus
End Sub
Private Sub PercentBox6_Click()
    If FormActivating Then Exit Sub
    CancelButton.SetFocus
End Sub

'***********  PercentBox Exit  **************
Private Sub PercentBox1_Exit(ByVal Cancel As MSForms.ReturnBoolean)
    If Not PercentBox1.MatchFound Then PercentBox1 = "" 'remove any percentbox value that does not match percent list
    UpdateTotal
End Sub
Private Sub PercentBox2_Exit(ByVal Cancel As MSForms.ReturnBoolean)
    If Not PercentBox2.MatchFound Then PercentBox2 = ""
    UpdateTotal
End Sub
Private Sub PercentBox3_Exit(ByVal Cancel As MSForms.ReturnBoolean)
    If Not PercentBox3.MatchFound Then PercentBox3 = ""
    UpdateTotal
End Sub
Private Sub PercentBox4_Exit(ByVal Cancel As MSForms.ReturnBoolean)
    If Not PercentBox4.MatchFound Then PercentBox4 = ""
    UpdateTotal
End Sub
Private Sub PercentBox5_Exit(ByVal Cancel As MSForms.ReturnBoolean)
    If Not PercentBox5.MatchFound Then PercentBox5 = ""
    UpdateTotal
End Sub
Private Sub PercentBox6_Exit(ByVal Cancel As MSForms.ReturnBoolean)
    If Not PercentBox6.MatchFound Then PercentBox6 = ""
    UpdateTotal
End Sub

Private Sub UpdateTotal()
    Total = Val(PercentBox1) + Val(PercentBox2) + Val(PercentBox3) + Val(PercentBox4) + Val(PercentBox5) + Val(PercentBox6)
    TotalBox = CStr(Total) & " %"
    If Total = 100 And ActivityNameBox.Text <> "" Then
        SaveButton.Enabled = True
        TotalBox.BackColor = Green
    Else
        SaveButton.Enabled = False
        TotalBox.BackColor = Red
    End If
End Sub
'*************************************************

Private Sub SaveButton_Click()
Dim sh1, sh2 As Worksheet
Dim CallingSheet, A, B As String
Dim C, R, Rec As Integer

Set sh1 = Sheets("Activity")
Set sh2 = Sheets("Timesheet")
Me.Hide

Application.ScreenUpdating = False
'CallingSheet = ActiveSheet.Name 'We need to return to the right sheet
    
    If ActivityNameBox = "" Then Exit Sub   'dont save if Activity name is blank 'chg180411 blank lines in activity list

    C = Range("ActivityList").Column
    
    If isNewActivity Then    'Insert a new row (except for EDIT)
        A = Chr(C + 64)
        B = Chr(C + 64 + 13)
        R = Range("ActivityList").row + 2 'insert at top of list
        sh1.Range(A & R & ":" & B & R).Insert Shift:=xlDown
        sh1.Cells(R, C) = ActivityNameBox
    Else
        R = ActNum + Range("ActivityList").row - 1 'ActNum is set during UserForm_Activate()
    End If
    
    If ProgramBox1 <> "" And PercentBox1 <> "" Then
        sh1.Cells(R, C + 1) = GetProgramNumber(ProgramBox1)
        sh1.Cells(R, C + 2) = Val(PercentBox1) / 100
    Else 'Maybe an edit. so delete any old data
        sh1.Cells(R, C + 1) = ""
        sh1.Cells(R, C + 2) = ""
    End If
    If ProgramBox2 <> "" And PercentBox2 <> "" Then
        sh1.Cells(R, C + 3) = GetProgramNumber(ProgramBox2)
        sh1.Cells(R, C + 4) = Val(PercentBox2) / 100
    Else
        sh1.Cells(R, C + 3) = ""
        sh1.Cells(R, C + 4) = ""
    End If
    If ProgramBox3 <> "" And PercentBox3 <> "" Then
        sh1.Cells(R, C + 5) = GetProgramNumber(ProgramBox3)
        sh1.Cells(R, C + 6) = Val(PercentBox3) / 100
    Else
        sh1.Cells(R, C + 5) = ""
        sh1.Cells(R, C + 6) = ""
    End If
    If ProgramBox4 <> "" And PercentBox4 <> "" Then
        sh1.Cells(R, C + 7) = GetProgramNumber(ProgramBox4)
        sh1.Cells(R, C + 8) = Val(PercentBox4) / 100
    Else
        sh1.Cells(R, C + 7) = ""
        sh1.Cells(R, C + 8) = ""
    End If
    If ProgramBox5 <> "" And PercentBox5 <> "" Then
        sh1.Cells(R, C + 9) = GetProgramNumber(ProgramBox5)
        sh1.Cells(R, C + 10) = Val(PercentBox5) / 100
    Else
        sh1.Cells(R, C + 9) = ""
        sh1.Cells(R, C + 10) = ""
    End If
    If ProgramBox6 <> "" And PercentBox6 <> "" Then
        sh1.Cells(R, C + 11) = GetProgramNumber(ProgramBox6)
        sh1.Cells(R, C + 12) = Val(PercentBox6) / 100
    Else
        sh1.Cells(R, C + 11) = ""
        sh1.Cells(R, C + 12) = ""
    End If
    If isNewActivity Then sh1.Cells(R, C + 13) = "open" 'set status to "open" for NEW Activities ONLY
    
    '***********************************************************
    For Rec = Range("StartDate").row To Range("EndDate").row
        If sh2.Cells(Rec, ActivityCol) = EditActivityName Then
         If LCase(sh2.Cells(Rec, StatusCol)) = "saved" Then sh2.Cells(Rec, StatusCol) = "updated"
        End If
    Next
    '***********************************************************
    
    Application.ScreenUpdating = True
End Sub

Private Sub CancelButton_Click() 'CANCEL
    ActivityNameBox = "" 'IMPORTANT clear this box if user cancels.
    'If the form was called by Fm_Record_Hours, ActivityNameBox flags successful activity creation
    Me.Hide
End Sub

Private Sub LoadProgramList()

    FormActivating = True
    'Clear the Program List Combo Boxs
    S = ProgramBox1.Text: ProgramBox1.Clear: ProgramBox1.Text = S
    S = ProgramBox2.Text: ProgramBox2.Clear: ProgramBox2.Text = S
    S = ProgramBox3.Text: ProgramBox3.Clear: ProgramBox3.Text = S
    S = ProgramBox4.Text: ProgramBox4.Clear: ProgramBox4.Text = S
    S = ProgramBox5.Text: ProgramBox5.Clear: ProgramBox5.Text = S
    S = ProgramBox6.Text: ProgramBox6.Clear: ProgramBox6.Text = S

    'First, load all Programs
    p = 5: N = 2
    While Range("ProgramList").Cells(N, 1) <> ""
        If Range("programList").Cells(N, 2) = Range("programList").Cells(N, 3) Then 'Only show Active programs (mapped to same number)
            ProgramBox1.AddItem (PadString(Range("ProgramList").Cells(N, 1), p) & " " & Range("ProgramList").Cells(N, 2) & " " & Range("ProgramList").Cells(N, 4))
            ProgramBox2.AddItem (PadString(Range("ProgramList").Cells(N, 1), p) & " " & Range("ProgramList").Cells(N, 2) & " " & Range("ProgramList").Cells(N, 4))
            ProgramBox3.AddItem (PadString(Range("ProgramList").Cells(N, 1), p) & " " & Range("ProgramList").Cells(N, 2) & " " & Range("ProgramList").Cells(N, 4))
            ProgramBox4.AddItem (PadString(Range("ProgramList").Cells(N, 1), p) & " " & Range("ProgramList").Cells(N, 2) & " " & Range("ProgramList").Cells(N, 4))
            ProgramBox5.AddItem (PadString(Range("ProgramList").Cells(N, 1), p) & " " & Range("ProgramList").Cells(N, 2) & " " & Range("ProgramList").Cells(N, 4))
            ProgramBox6.AddItem (PadString(Range("ProgramList").Cells(N, 1), p) & " " & Range("ProgramList").Cells(N, 2) & " " & Range("ProgramList").Cells(N, 4))
        End If
        N = N + 1
    Wend
    
    'Now remove used Programs
    S = ProgramBox1.Text
    ProgramBox1 = ProgramBox2.Text
    If ProgramBox1.ListIndex > 0 Then ProgramBox1.RemoveItem (ProgramBox1.ListIndex)
    ProgramBox1 = ProgramBox3.Text
    If ProgramBox1.ListIndex > 0 Then ProgramBox1.RemoveItem (ProgramBox1.ListIndex)
    ProgramBox1 = ProgramBox4.Text
    If ProgramBox1.ListIndex > 0 Then ProgramBox1.RemoveItem (ProgramBox1.ListIndex)
    ProgramBox1 = ProgramBox5.Text
    If ProgramBox1.ListIndex > 0 Then ProgramBox1.RemoveItem (ProgramBox1.ListIndex)
    ProgramBox1 = ProgramBox6.Text
    If ProgramBox1.ListIndex > 0 Then ProgramBox1.RemoveItem (ProgramBox1.ListIndex)
    ProgramBox1.Text = S
    
      S = ProgramBox2.Text
    ProgramBox2 = ProgramBox1.Text
    If ProgramBox2.ListIndex > 0 Then ProgramBox2.RemoveItem (ProgramBox2.ListIndex)
    ProgramBox2 = ProgramBox3.Text
    If ProgramBox2.ListIndex > 0 Then ProgramBox2.RemoveItem (ProgramBox2.ListIndex)
    ProgramBox2 = ProgramBox4.Text
    If ProgramBox2.ListIndex > 0 Then ProgramBox2.RemoveItem (ProgramBox2.ListIndex)
    ProgramBox2 = ProgramBox5.Text
    If ProgramBox2.ListIndex > 0 Then ProgramBox2.RemoveItem (ProgramBox2.ListIndex)
    ProgramBox2 = ProgramBox6.Text
    If ProgramBox2.ListIndex > 0 Then ProgramBox2.RemoveItem (ProgramBox2.ListIndex)
    ProgramBox2.Text = S
  
    S = ProgramBox3.Text
    ProgramBox3 = ProgramBox1.Text
    If ProgramBox3.ListIndex > 0 Then ProgramBox3.RemoveItem (ProgramBox3.ListIndex)
    ProgramBox3 = ProgramBox2.Text
    If ProgramBox3.ListIndex > 0 Then ProgramBox3.RemoveItem (ProgramBox3.ListIndex)
    ProgramBox3 = ProgramBox4.Text
    If ProgramBox3.ListIndex > 0 Then ProgramBox3.RemoveItem (ProgramBox3.ListIndex)
    ProgramBox3 = ProgramBox5.Text
    If ProgramBox3.ListIndex > 0 Then ProgramBox3.RemoveItem (ProgramBox3.ListIndex)
    ProgramBox3 = ProgramBox6.Text
    If ProgramBox3.ListIndex > 0 Then ProgramBox3.RemoveItem (ProgramBox3.ListIndex)
    ProgramBox3.Text = S
  
    S = ProgramBox4.Text
    ProgramBox4 = ProgramBox1.Text
    If ProgramBox4.ListIndex > 0 Then ProgramBox4.RemoveItem (ProgramBox4.ListIndex)
    ProgramBox4 = ProgramBox2.Text
    If ProgramBox4.ListIndex > 0 Then ProgramBox4.RemoveItem (ProgramBox4.ListIndex)
    ProgramBox4 = ProgramBox3.Text
    If ProgramBox4.ListIndex > 0 Then ProgramBox4.RemoveItem (ProgramBox4.ListIndex)
    ProgramBox4 = ProgramBox5.Text
    If ProgramBox4.ListIndex > 0 Then ProgramBox4.RemoveItem (ProgramBox4.ListIndex)
    ProgramBox4 = ProgramBox6.Text
    If ProgramBox4.ListIndex > 0 Then ProgramBox4.RemoveItem (ProgramBox4.ListIndex)
    ProgramBox4.Text = S
  
    S = ProgramBox5.Text
    ProgramBox5 = ProgramBox1.Text
    If ProgramBox5.ListIndex > 0 Then ProgramBox5.RemoveItem (ProgramBox5.ListIndex)
    ProgramBox5 = ProgramBox2.Text
    If ProgramBox5.ListIndex > 0 Then ProgramBox5.RemoveItem (ProgramBox5.ListIndex)
    ProgramBox5 = ProgramBox3.Text
    If ProgramBox5.ListIndex > 0 Then ProgramBox5.RemoveItem (ProgramBox5.ListIndex)
    ProgramBox5 = ProgramBox4.Text
    If ProgramBox5.ListIndex > 0 Then ProgramBox5.RemoveItem (ProgramBox5.ListIndex)
    ProgramBox5 = ProgramBox6.Text
    If ProgramBox5.ListIndex > 0 Then ProgramBox5.RemoveItem (ProgramBox5.ListIndex)
    ProgramBox5.Text = S
  
    S = ProgramBox6.Text
    ProgramBox6 = ProgramBox1.Text
    If ProgramBox6.ListIndex > 0 Then ProgramBox6.RemoveItem (ProgramBox6.ListIndex)
    ProgramBox6 = ProgramBox2.Text
    If ProgramBox6.ListIndex > 0 Then ProgramBox6.RemoveItem (ProgramBox6.ListIndex)
    ProgramBox6 = ProgramBox3.Text
    If ProgramBox6.ListIndex > 0 Then ProgramBox6.RemoveItem (ProgramBox6.ListIndex)
    ProgramBox6 = ProgramBox4.Text
    If ProgramBox6.ListIndex > 0 Then ProgramBox6.RemoveItem (ProgramBox6.ListIndex)
    ProgramBox6 = ProgramBox5.Text
    If ProgramBox6.ListIndex > 0 Then ProgramBox6.RemoveItem (ProgramBox6.ListIndex)
    ProgramBox6.Text = S
    
    'If the Total is 100% then clear any Program box with no labour i.e. cannot select another program in vacant fields
    If Val(PercentBox1) + Val(PercentBox2) + Val(PercentBox3) + Val(PercentBox4) + Val(PercentBox5) + Val(PercentBox6) = 100 Then
        If PercentBox1 = "" Then ProgramBox1.Clear
        If PercentBox2 = "" Then ProgramBox2.Clear
        If PercentBox3 = "" Then ProgramBox3.Clear
        If PercentBox4 = "" Then ProgramBox4.Clear
        If PercentBox5 = "" Then ProgramBox5.Clear
        If PercentBox6 = "" Then ProgramBox6.Clear
    End If
    
    FormActivating = False
    
 End Sub


Function GetProgramNumber(S As String) As String
    
    While Not IsNumeric(Left(S, 1))
        S = Right(S, (Len(S) - 1))
    Wend
    GetProgramNumber = Left(S, 3)
    GetProgramNumber = Format(CStr(Val(GetProgramNumber)), "000")
    
End Function

Private Sub UserForm_Terminate()
    ActivityNameBox = "" 'IMPORTANT clear this box if user cancels.
    'If the form was called by Fm_Record_Hours, ActivityNameBox flags successful activity creation
End Sub

