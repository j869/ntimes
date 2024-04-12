Option Explicit


'Called from Fm_Record_Hours      AssistantButton_Click


Private Sub UserForm_Activate()
    With Fm_Timesheet_Assistant
      .StartUpPosition = 0
      .Left = Application.Left + (0.5 * Application.Width) - (0.5 * .Width)
      .Top = Application.Top + (0.5 * Application.Height) - (0.5 * .Height)
    End With
    DoEvents
    
    Dim N As Integer
    DefaultLocationBox.Clear

    N = 2
    While Range("MyLocationList").Cells(N, 1) <> ""
        DefaultLocationBox.AddItem (GetLocationName(Range("MyLocationList").Cells(N, 1))) '***NEW*** LocationListMod
        N = N + 1
    Wend
    
      If Range("DefaultLocation") <> "" Then
        DefaultLocationBox = Range("DefaultLocation")
        If Not DefaultLocationBox.MatchFound Then DefaultLocationBox = "": Range("DefaultLocation") = ""
    End If
    
    If Range("NormalStart") <> "" Then
        NormalStartBox = Range("NormalStart")
        If Not NormalStartBox.MatchFound Then NormalStartBox = "": Range("NormalStart") = ""
    End If

    If LCase(Range("AutoCalculateHours")) = "yes" Then
        AutocalculateBox.Value = True
    Else
        AutocalculateBox.Value = False
    End If



End Sub




Private Sub OKButton_Click()

    If AutocalculateBox Then
        Range("AutoCalculateHours") = "yes"
    Else
        Range("AutoCalculateHours") = "no"
    End If

    If NormalStartBox <> "" Then
        If NormalStartBox.MatchFound Then
            Range("NormalStart") = NormalStartBox
         Else
            MsgBox "Could not set normal start time. Please select your normal start time from the list", vbExclamation, MsgCaption
            NormalStartBox = ""
            Exit Sub
        End If
    Else
        Range("NormalStart") = ""
    End If
    
    If DefaultLocationBox <> "" Then
        If DefaultLocationBox.MatchFound Then
            Range("DefaultLocation") = DefaultLocationBox
         Else
            MsgBox "Could not set default location. Please select your default location from the list", vbExclamation, MsgCaption
            DefaultLocationBox = ""
            Exit Sub
        End If
    Else
        Range("DefaultLocation") = ""
    End If
    
    Me.Hide
End Sub
