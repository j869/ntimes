
Option Explicit


Dim variance As Single
Dim Activating As Boolean
Dim IsShortDay As Boolean
Dim ThisDay As Date
Dim normalworkhours As Single

Private Sub CancelButton_Click()
    ContinueButtonClicked = False
    Me.Hide
End Sub

Private Sub UserForm_Activate()
    With Fm_Variance
      .StartUpPosition = 0
      .Left = Application.Left + (0.5 * Application.Width) - (0.5 * .Width)
      .Top = Application.Top + (0.5 * Application.Height) - (0.5 * .Height)
    End With
    DoEvents
    
    ContinueButtonClicked = False 'If the form is closed, the variance distribution is cancelled

    Activating = True
    
    normalworkhours = TextToTime(Fm_Record_Hours.Lb_NormalHours_2) * 60
    variance = TextToTime(Fm_Record_Hours.VarHoursLabel) * 60 'minutes
    Lb_Note = ""
    OptionButton1.Value = True '1 minute step
    
    'set spinbuttons max and min
    SpinButton1.Max = Abs(variance): SpinButton1.Min = 0
    SpinButton2.Max = Abs(variance): SpinButton2.Min = 0
    
    If variance < 0 Then IsShortDay = True Else IsShortDay = False
    
    If IsShortDay Then
        TitleLabel = "Distribution of Short Worked Hours"
        Label1 = "Time in Lieu"
        Label2 = "Personal Leave"
        Lb_Note = "All Leave applications MUST be entered in FaP"
        variance = Abs(variance)
        If variance > (Range("ATBalance") * 60) Then
            SpinButton1.Max = Round((Range("ATBalance") * 60), 0)
            SpinButton2.Min = variance - SpinButton1.Max
        End If
        
    Else 'Long Day
        TitleLabel = "Distribution of Extra hours worked."
        Label1 = "Accrued Time"
        Label2 = "Overtime"
        Lb_Note = "All applications for Overtime  MUST be entered in FaP"
        
        'If Range("FTE") >= 1 Or normalworkhours = 0 Then
        '         'DO NOTHING - Spinbutton Max & Min unchanged
        'So, must be part-time & normal work day
        'ElseIf ((normalworkhours + variance) / 60) > 10 Then 'Total worked hours > 10
         '       SpinButton2.Max = (normalworkhours + variance) - 600 'eg if 11 hours worked, max overtime is 1 hour
         '       SpinButton1.Min = variance - SpinButton2.Max
        'End If
        
    End If
    SpinButton1.Value = SpinButton1.Max
    SpinButton2.Value = SpinButton2.Min
    
    TotalLabel = TimeToText(variance / 60, 0)
    TextBox1.Text = TimeToText(SpinButton1.Value / 60, 0)
    TextBox2.Text = TimeToText(SpinButton2.Value / 60, 0)
     
    Activating = False
End Sub



Private Sub SpinButton1_Change()
    If Activating Then Exit Sub
    TextBox1.Value = TimeToText(SpinButton1 / 60, 0) 'Always HMS
    SpinButton2 = variance - SpinButton1
    CheckLimits
End Sub


Private Sub SpinButton2_Change()
    If Activating Then Exit Sub
    TextBox2.Value = TimeToText(SpinButton2 / 60, 0) 'Always HMS
    SpinButton1.Value = variance - SpinButton2.Value
End Sub

Private Sub CheckLimits()
    'If Label2 = "Overtime" Then
    '    If Range("FTE") >= 1 Or normalworkhours = 0 Then Exit Sub
    
    '    'Must be part-time & normal work day
    '    If SpinButton2.Max = variance Then Exit Sub
    '    If SpinButton2.Value = SpinButton2.Max Then
    '        MsgBox "Sorry, you can only claim " & TimeToText(SpinButton2.Max / 60,0) & " overtime for hours in excess of 10 hours", vbExclamation
    '    End If
    'End If
    
    If Label1 = "Time in Lieu" Then
        If SpinButton1.Value = SpinButton1.Max And SpinButton1.Max < variance Then
            MsgBox "You only have " & TimeToText(Range("ATBalance"), 0) & _
            " accrued time." & vbCr & "You can only take " & _
            TimeToText(Range("ATBalance"), 0) & " Time in Lieu.", vbExclamation
        End If
    End If
    
End Sub

Private Sub ContinueButton_Click()
    ContinueButtonClicked = True
    If TextBox1.Text = "0:00" Then TextBox1 = ""
    If TextBox2.Text = "0:00" Then TextBox2 = ""
    Me.Hide
    
End Sub

Private Sub OptionButton1_Click()
    SpinButton1.SmallChange = 1: SpinButton2.SmallChange = 1
End Sub

Private Sub OptionButton2_Click()
    SpinButton1.SmallChange = 10: SpinButton2.SmallChange = 10
End Sub

Private Sub UserForm_Terminate()
    ContinueButtonClicked = False
End Sub
