Option Explicit
Dim ActManActivating As Boolean


Private Sub Label7_Click()
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
    'Position the form in the centre of the window
    With Fm_Activity_Manager
      .StartUpPosition = 0
      .Left = Application.Left + (0.5 * Application.Width) - (0.5 * .Width)
      .Top = Application.Top + (0.5 * Application.Height) - (0.5 * .Height)
    End With
    DoEvents
    
    
    'chg180411 - blank line in Activity list
    Dim row
    For row = Sheets("Activity").Cells(Sheets("Activity").Rows.Count, 2).End(xlUp).row To 7 Step -1     'Sheets("Activity").UsedRange.Rows.Count
        If Sheets("Activity").Cells(row, 2) = "" Then
'            Sheets("Activity").Select
'            Rows(row).Select
            Sheets("Activity").Rows(row).Delete
            Call logDataEntry("Recovered from Error Chg180411: removed 1 blank row in Activity List")
        End If
    Next row
    
    ActManActivating = True
    ShowActivities
    ActManActivating = False
    ResetFormButtons
End Sub


Private Sub DeleteButton_Click()
    Dim ActivityName As String
    Dim N As Integer
    
    If Not ListBox1.ListIndex < 0 Then ActivityName = ListBox1.List(ListBox1.ListIndex)
    If Not ListBox2.ListIndex < 0 Then ActivityName = ListBox2.List(ListBox2.ListIndex)
    If ActivityName = "" Then MsgBox "No Activity selected", vbExclamation, MsgCaption: Exit Sub
    
    If ActivityIsUsed(ActivityName) Then
        MsgBox "Cannot delete '" & ActivityName & "' because it has been used in your timesheet." & vbCr & _
        "You can only delete activities that have not been used in your timesheet.", vbExclamation, MsgCaption
        Exit Sub
    End If
        If MsgBox("Are you sure you want to delete activity '" & ActivityName & "'", vbYesNo, MsgCaption) = vbYes Then
            Application.ScreenUpdating = False
            N = getActivityRowNumber(ActivityName)
            If N > 0 Then
                N = N + Range("ActivityList").row - 1
                Sheets("Activity").Unprotect Password:=Pword
                Sheets("Activity").Rows(N).Delete Shift:=xlUp
                Sheets("Activity").Protect Password:=Pword, UserInterfaceOnly:=True, DrawingObjects:=True, Contents:=True, Scenarios:=True
            End If
            Application.ScreenUpdating = True
            ShowActivities
            ResetFormButtons
        End If
End Sub

Private Sub ImportButton_Click()
    If MsgBox("You have chosen to Import Activities from another Timesheet." & vbCr & vbCr & _
    "Would you like to continue?", vbYesNo, MsgCaption) = vbNo Then
        Exit Sub
    End If

    If ImportActivities(vbNullString) Then
        ShowActivities
        MsgBox "Import complete", vbInformation, MsgCaption
    Else
        MsgBox "An error occured during activity import.", vbExclamation, MsgCaption
    End If
    ResetFormButtons

End Sub

Private Sub EditButton_Click()
'Edit button is only enabled if an Activity is selected
    EditActivityName = ""
    If Not ListBox1.ListIndex < 0 Then
        EditActivityName = ListBox1.List(ListBox1.ListIndex)
    ElseIf Not ListBox2.ListIndex < 0 Then
        EditActivityName = ListBox2.List(ListBox2.ListIndex)
    End If
    If EditActivityName = "" Then MsgBox "No Activity selected", vbExclamation, MsgCaption: Exit Sub

    If MsgBox("The Activity : " & EditActivityName & ", will be modified." & vbCr & vbCr & "All changes will be back-dated to 1 July." & vbCr & "Are you sure you want to proceed?", vbYesNo, MsgCaption) = vbYes Then
        Fm_Activity_New.Show
    End If
End Sub

Private Sub CreateButton_Click()
    EditActivityName = ""
    Fm_Activity_New.Show
    'Return from New/Edit Activity Form
    ShowActivities
    ResetFormButtons
End Sub

Private Sub InformationButton_Click()
    If Not ListBox1.ListIndex < 0 Then
        EditActivityName = ListBox1.List(ListBox1.ListIndex)
        Fm_Activity_Info.Show
        Exit Sub
    End If
    If Not ListBox2.ListIndex < 0 Then
        EditActivityName = ListBox2.List(ListBox2.ListIndex)
        Fm_Activity_Info.Show
    End If
End Sub

Private Sub ListBox2_Click()
    If ActManActivating Then Exit Sub
    If ListBox1.ListIndex >= 0 Then ListBox1.Selected(ListBox1.ListIndex) = False
    ResetFormButtons
End Sub

Private Sub ListBox2_DblClick(ByVal Cancel As MSForms.ReturnBoolean)
    InformationButton.SetFocus
    Call InformationButton_Click
End Sub

Private Sub ListBox1_Click()
    If ActManActivating Then Exit Sub
    If ListBox2.ListIndex >= 0 Then ListBox2.Selected(ListBox2.ListIndex) = False
    ResetFormButtons
End Sub

Private Sub ListBox1_DblClick(ByVal Cancel As MSForms.ReturnBoolean)
    InformationButton.SetFocus
    Call InformationButton_Click
End Sub

Private Sub OpenActivityButton_Click()
    Dim N, X, A As Integer
    Dim AName As String

    ActManActivating = True
        On Error Resume Next
        N = ListBox2.ListIndex
        AName = ListBox2.List(ListBox2.ListIndex)
        A = getActivityRowNumber(AName)
        If A > 0 Then
            ListBox2.RemoveItem (ListBox2.ListIndex)
            X = ListBox2.ListIndex
            ListBox2.Selected(X) = False
            InformationButton.Enabled = False
            Range("ActivityList").Cells(A, 14) = "open"
            ListBox1.AddItem
            ListBox1.List(ListBox1.ListCount - 1, 0) = AName
            OpenActivityButton.Enabled = False
        End If
    ActManActivating = False
    ResetFormButtons
End Sub

Private Sub CloseActivityButton_Click()
    Dim AName As String
    Dim A As Integer
    
    ActManActivating = True
        On Error Resume Next
        If ListBox1.ListIndex < 0 Then Exit Sub 'should never occur
        AName = ListBox1.List(ListBox1.ListIndex, 0)
        A = getActivityRowNumber(AName)
        If A > 0 Then
            ListBox1.RemoveItem (ListBox1.ListIndex)
            ListBox1.Selected(ListBox1.ListIndex) = False
            Range("ActivityList").Cells(A, 14) = "closed"
            ListBox2.AddItem
            ListBox2.List(ListBox2.ListCount - 1, 0) = AName
        End If
    ActManActivating = False
    ResetFormButtons
End Sub


Private Sub ShowActivities()
    Dim N As Integer
    ListBox1.Clear
    ListBox2.Clear
    
    N = 2
    While Range("ActivityList").Cells(N, 1) <> ""
            If Range("ActivityList").Cells(N, 14) = "open" Then
                    ListBox1.AddItem
                    ListBox1.List(ListBox1.ListCount - 1, 0) = Range("ActivityList").Cells(N, 1)
            ElseIf Range("ActivityList").Cells(N, 14) = "closed" Then
                    ListBox2.AddItem
                    ListBox2.List(ListBox2.ListCount - 1, 0) = Range("ActivityList").Cells(N, 1)
            End If
            N = N + 1
    Wend
    
End Sub


Private Sub ResetFormButtons()
        CloseActivityButton.Enabled = False
        OpenActivityButton.Enabled = False
        EditButton.Enabled = False
        InformationButton.Enabled = False
        DeleteButton.Enabled = False
    If ListBox1.ListIndex >= 0 Then
        CloseActivityButton.Enabled = True
        EditButton.Enabled = True
        InformationButton.Enabled = True
        DeleteButton.Enabled = True
    End If
    If ListBox2.ListIndex >= 0 Then
        OpenActivityButton.Enabled = True
        EditButton.Enabled = True
        InformationButton.Enabled = True
        DeleteButton.Enabled = True
    End If

End Sub

Private Sub ExitButton_Click()
    Me.Hide
End Sub



