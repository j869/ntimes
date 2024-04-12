Option Explicit


Dim LocManActivating As Boolean
Dim ARow As Integer
Dim ACol As Integer


Private Sub UserForm_Activate()
    With Fm_Location_Manager
      .StartUpPosition = 0
      .Left = Application.Left + (0.5 * Application.Width) - (0.5 * .Width)
      .Top = Application.Top + (0.5 * Application.Height) - (0.5 * .Height)
    End With
    DoEvents
    
    LoadLocations
End Sub
Private Sub LoadLocations()
    Dim N As Integer
    ListBox1.Clear
    N = 2
    While Range("MyLocationList").Cells(N, 1) <> ""
        ListBox1.AddItem (GetLocationName(Range("MyLocationList").Cells(N, 1))) '***NEW*** LocationListMod
        N = N + 1
    Wend
    
    RemoveButton.Enabled = False

End Sub
Private Sub AddButton_Click()
    Dim LName As String
    Dim N As String
    Fm_Location_Add.Show
    '---------------------------------------------------------------------------------------------------
    'Return here with location Name or null
    LName = Fm_Location_Add.LocationBox
    If LName = "" Then Exit Sub
    
    
    N = 2
    While Range("MyLocationList").Cells(N, 1) <> ""
        N = N + 1
    Wend
    
    Sheets("Admin").Cells(Range("MyLocationList").row + N - 1, Range("MyLocationList").Column) = GetLocationID(LName)
    
    ListBox1.AddItem
    ListBox1.List(ListBox1.ListCount - 1) = LName
    ListBox1.Selected(ListBox1.ListCount - 1) = True

End Sub

Private Sub ListBox1_Click()
If LocManActivating Then Exit Sub
RemoveButton.Enabled = True
End Sub

Private Sub RemoveButton_Click()
    Dim LName As String
    Dim N As Integer
    Dim LocID As Long
    
    On Error GoTo RemLocErr
    If ListBox1.ListIndex < 0 Then Exit Sub 'No locations
    LocID = GetLocationID(ListBox1.List(ListBox1.ListIndex))
    
    If LocID = Range("WorkCentre") Then
        MsgBox "Cannot remove your current assigned work centre from this list", vbExclamation, MsgCaption
        Exit Sub
    End If
    Application.ScreenUpdating = False
    LocManActivating = True
    Sheets("Admin").Unprotect Password:=Pword
    N = 2
    Do While Range("MyLocationList").Cells(N, 1) <> ""
        If Range("MyLocationList").Cells(N, 1) = LocID Then
            Sheets("Admin").Range("MyLocationList").Cells(N, 1).Delete Shift:=xlUp
            Exit Do
        End If
        N = N + 1
    Loop
    ListBox1.RemoveItem (ListBox1.ListIndex)
    
RemLocErr:
    Sheets("Admin").Protect Password:=Pword, UserInterfaceOnly:=True, DrawingObjects:=True, Contents:=True, Scenarios:=True
    Application.ScreenUpdating = True

    LocManActivating = False
End Sub

Private Sub CloseButton_Click()
    Me.Hide
End Sub


