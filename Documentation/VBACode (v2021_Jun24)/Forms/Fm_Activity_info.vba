Option Explicit






Private Sub ExitButton_Click()
    Me.Hide
End Sub

Private Sub UserForm_Activate()
    With Fm_Activity_Info
      .StartUpPosition = 0
      .Left = Application.Left + (0.5 * Application.Width) - (0.5 * .Width)
      .Top = Application.Top + (0.5 * Application.Height) - (0.5 * .Height)
    End With
    DoEvents
    
    NameLabel = EditActivityName
    ActNum = getActivityRowNumber(EditActivityName) 'ActNum is Global
    If ActNum = 0 Then
        MsgBox "Cannot locate Activity", vbExclamation, MsgCaption
        Me.Hide
        Exit Sub
    End If
    
    ListBox1.Clear
    ListBox1.ColumnCount = 2
    ListBox1.ColumnWidths = "8.5 cm;1.5cm"
            ListBox1.AddItem
            ListBox1.List(ListBox1.ListCount - 1, 0) = GetProgramName(Range("ActivityList").Cells(ActNum, 2))
            ListBox1.List(ListBox1.ListCount - 1, 1) = Format(Range("ActivityList").Cells(ActNum, 3), "00%")
            
            If Range("ActivityList").Cells(ActNum, 4) <> "" Then
            ListBox1.AddItem
            ListBox1.List(ListBox1.ListCount - 1, 0) = GetProgramName(Range("ActivityList").Cells(ActNum, 4))
            ListBox1.List(ListBox1.ListCount - 1, 1) = Format(Range("ActivityList").Cells(ActNum, 5), "00%")
            End If
            
            If Range("ActivityList").Cells(ActNum, 6) <> "" Then
            ListBox1.AddItem
            ListBox1.List(ListBox1.ListCount - 1, 0) = GetProgramName(Range("ActivityList").Cells(ActNum, 6))
            ListBox1.List(ListBox1.ListCount - 1, 1) = Format(Range("ActivityList").Cells(ActNum, 7), "00%")
            End If
            
            If Range("ActivityList").Cells(ActNum, 8) <> "" Then
            ListBox1.AddItem
            ListBox1.List(ListBox1.ListCount - 1, 0) = GetProgramName(Range("ActivityList").Cells(ActNum, 8))
            ListBox1.List(ListBox1.ListCount - 1, 1) = Format(Range("ActivityList").Cells(ActNum, 9), "00%")
            End If
            
            If Range("ActivityList").Cells(ActNum, 10) <> "" Then
            ListBox1.AddItem
            ListBox1.List(ListBox1.ListCount - 1, 0) = GetProgramName(Range("ActivityList").Cells(ActNum, 10))
            ListBox1.List(ListBox1.ListCount - 1, 1) = Format(Range("ActivityList").Cells(ActNum, 11), "00%")
            End If
            
            If Range("ActivityList").Cells(ActNum, 12) <> "" Then
            ListBox1.AddItem
            ListBox1.List(ListBox1.ListCount - 1, 0) = GetProgramName(Range("ActivityList").Cells(ActNum, 12))
            ListBox1.List(ListBox1.ListCount - 1, 1) = Format(Range("ActivityList").Cells(ActNum, 13), "00%")
            End If
            
End Sub


