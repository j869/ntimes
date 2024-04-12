Option Explicit
Dim InfoActivating As Boolean

Private Sub CloseButton_Click()
    Me.Hide
End Sub

Private Sub UserForm_Activate()
    With Fm_Info
      .StartUpPosition = 0
      .Left = Application.Left + (0.5 * Application.Width) - (0.5 * .Width)
      .Top = Application.Top + (0.5 * Application.Height) - (0.5 * .Height)
    End With
    DoEvents
    
    Dim Txt As String
    InfoActivating = True
    If Range("RosteredDays") <> 0 Then Txt = "Rostered - " Else Txt = "Non Rostered - "
    If Range("TotalHours") < 76 Then Txt = Txt & "Part Time" Else Txt = Txt & "Full Time"
    Label1 = Txt
    
    If Range("RosteredDays") = 1 Then
        RosteredWeekendsBox = "As Worked"
    ElseIf Range("RosteredDays") = 0 Then
        RosteredWeekendsBox = "Not Rostered"
    Else
        RosteredWeekendsBox = Range("RosteredDays")
    End If
    
    WeekendsWorkedBox = Range("WeekendsWorked")
    RDOBalanceBox = Range("RDOBalance")
    ATBalanceBox = TimeToText(Range("ATBalance"), 0) 'Always HH:MM
    If LCase(Range("ATAgreement")) = "yes" Then
        Lb_ExcessHours = "Accrued time for additional normal hours worked"
    Else
        Lb_ExcessHours = "Overtime for additional normal hours worked"
    End If
    
    InfoActivating = False
End Sub

