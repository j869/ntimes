Option Explicit

Private Sub UserForm_Activate()

    With Fm_FundSource_Change
        .StartUpPosition = 0
        .Left = Application.Left + (0.5 * Application.Width) - (0.5 * .Width)
        .Top = Application.Top + (0.5 * Application.Height) - (0.5 * .Height)
    End With
    DoEvents
    
    If Not FundSourceListUpToDate Then
        LoadFundSourceList
    End If
    
    If FundSourceListUpToDate Then RefreshLabel = "Fund Source list refreshed" Else RefreshLabel = ""
    LoadLocalList
    FundBox = GetFundSourceName(Range("PVFundSource"))
End Sub

Private Sub FundBox_Click()
    OKButton.SetFocus
End Sub

Private Sub OKButton_Click()
    If Not FundBox.MatchFound Then
        MsgBox "Please select a fundsource", vbExclamation, MsgCaption
        Exit Sub
    End If
    Me.Hide
End Sub

Private Sub LoadLocalList()
    Dim M, N As Integer
    Dim FundName As String
    Dim Match As Boolean
    FundBox.Clear
    N = 2
    FundName = Range("FundSourceList").Cells(N, 1)
    While Range("FundSourceList").Cells(N, 1) <> ""
        FundName = Range("FundSourceList").Cells(N, 2)
        FundBox.AddItem (FundName)
        N = N + 1
    Wend
    'FundBox = Fm_Record_Hours.FundLabel
End Sub

Private Sub LoadFundSourceList()
    Dim Cmd As String
    Dim C, R, N, W As Integer
    If LCase(Range("TSVersion")) = "test" Then Exit Sub
    
    Call OpenPVTSConnection(tmode)
    If Not ConOpen Then Exit Sub
    Set RS = New Adodb.Recordset
    On Error GoTo oraerror
       
    Application.ScreenUpdating = False
            Cmd = "Select FUND_SOURCE_NUMBER, FUND_SOURCE_NAME "
            Cmd = Cmd & "From TMSHEET.PV_TS_FUNDSOURCE_T"
            Cmd = Cmd & " Order by FUND_SOURCE_NAME"
            
            RS.Open Cmd, conn, adOpenStatic, adLockReadOnly
            If RS.RecordCount > 0 Then
                R = Range("FundSourceList").row + 1
                C = Range("FundSourceList").Column
                While Sheets("Admin").Cells(R, C) <> ""
                    Sheets("Admin").Cells(R, C).ClearContents
                    Sheets("Admin").Cells(R, C + 1).ClearContents
                    R = R + 1
                Wend
                R = Range("FundSourceList").row + 1
                'Sheets("Admin").Cells(R, C) = "000": Sheets("Admin").Cells(R, C + 1) = "000 Fund Source Not Specified"
                RS.MoveFirst
                'R = R + 1
                While Not RS.EOF
                    If IsNumeric(RS.Fields(0)) Then
                        Sheets("Admin").Cells(R, C) = RS.Fields(0): Sheets("Admin").Cells(R, C + 1) = RS.Fields(1)
                    End If
                    RS.MoveNext
                    R = R + 1
                Wend
                
                FundSourceListUpToDate = True
                
            Else
                MsgBox "Cannot find Fund Source list on server", vbExclamation, MsgCaption
            End If
            RS.Close
            conn.Close
            Set conn = Nothing: Set RS = Nothing
            Application.ScreenUpdating = True
            Exit Sub
            
oraerror:
        If conn.State <> 0 Then conn.Close
        Set conn = Nothing: Set RS = Nothing
        MsgBox Err.Description
        Application.ScreenUpdating = True
        MsgBox "Location list update error", vbExclamation, MsgCaption
End Sub


Private Sub UserForm_Terminate()
   If Not FundBox.MatchFound Then
        FundBox = GetFundSourceName(Range("PVFundSource"))
    End If
End Sub
