
Option Explicit




Private Sub UserForm_Activate()
    With Fm_Location_Add
        .StartUpPosition = 0
        .Left = Application.Left + (0.5 * Application.Width) - (0.5 * .Width)
        .Top = Application.Top + (0.5 * Application.Height) - (0.5 * .Height)
    End With
    DoEvents
        
    If Not LocationListUpToDate Then
        LoadLocationList
    End If
    
    If LocationListUpToDate Then RefreshLabel = "Location list refreshed" Else RefreshLabel = ""
    
    OKButton.Enabled = False
    LoadLocalList
    
End Sub

Private Sub LocationBox_Click()
    OKButton.Enabled = True
    OKButton.SetFocus
End Sub


Private Sub OKButton_Click()
    Me.Hide
End Sub


Private Sub LoadLocalList()
    Dim M, N As Integer
    Dim LocID As Long
    Dim Match As Boolean
    LocationBox.Clear
    N = 2
    While Range("PVLocationList").Cells(N, 1) <> ""
        LocID = Range("PVLocationList").Cells(N, 1)
        M = 2: Match = False
        Do While Range("MyLocationList").Cells(M) <> ""
            If LocID = Range("MyLocationList").Cells(M) Then
                Match = True
                Exit Do
            End If
            M = M + 1
        Loop
        If Not Match Then LocationBox.AddItem (Range("PVLocationList").Cells(N, 2))
        N = N + 1
    Wend
    
End Sub

