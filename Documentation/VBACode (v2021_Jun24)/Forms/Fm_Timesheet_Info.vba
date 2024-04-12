Option Explicit

Dim InfoActivating As Boolean
Dim FireRole As String



Private Sub CupHolidayEdit_Click()
    Dim defaultCupDay As String
    Dim cday As String
    Dim cupday As Date
    defaultCupDay = Format(Range("CupDayHoliday"), "dd/mmm/yyyy")
retry:
        cday = InputBox("Please enter your cup day holiday (dd/mmm/yyyy) ", MsgCaption, defaultCupDay)
        If cday = "" Then Exit Sub  'user cancel
        If Not IsDate(cday) Then MsgBox "Cannot identify date. Please try again.", vbExclamation, MsgCaption: GoTo retry
        cupday = CDate(cday)
        If cupday <= Range("StartDate") Or cupday >= Range("EndDate") Then MsgBox "The Date is not in this Financial Year. Please try again.", vbExclamation, MsgCaption: GoTo retry      '180609 wording for melb cup
        If MsgBox("Please confirm your public holiday for cup day is: " & Format(cupday, "dd/mmm/yyyy"), vbYesNo, MsgCaption) = vbNo Then GoTo retry
        Range("CupDayHoliday") = cupday
        CupHolidayDate.Caption = Format(cupday, "dd/mmm/yyyy")
        Call logDataEntry("Fm_Timesheet_Info > Cup day OK = " & Format(Range("CupDayHoliday"), "dd/mmm/yy") & " in " & GetLocationName(Range("WorkCentre")) & " (Checking for user errors)")

End Sub

Private Sub Label58_Click()
    cday = InputBox("Please enter your cup day holiday (dd/mmm/yyyy) ", MsgCaption, defaultCupDay)
    If FireRoleBox.BackColor = &HFFFFFF Then
      FireRoleBox.BackColor = &HE9F8ED
      FireRoleBox.Enabled = True
    Else
      FireRoleBox.BackColor = &HFFFFFF
      FireRoleBox.Enabled = False
    End If

End Sub


Private Sub UserForm_Activate()
    With Fm_Timesheet_Info
      .StartUpPosition = 0
      .Left = Application.Left + (0.5 * Application.Width) - (0.5 * .Width)
      .Top = Application.Top + (0.5 * Application.Height) - (0.5 * .Height)
    End With
    DoEvents

    InfoActivating = True
    NameBox = "  " & Range("FirstName") & " " & Range("LastName")
    WorkCentreBox = "  " & GetLocationName(Range("WorkCentre"))
    PositionBox = "  " & Range("Position")
    FireRoleBox = "  " & Range("FireRole")
    
    If Range("RosteredDays") = 1 Then
        RosteredWeekendsBox = "As Worked"
    ElseIf Range("RosteredDays") = 0 Then
        RosteredWeekendsBox = "Not Rostered"
    Else
        RosteredWeekendsBox = Range("RosteredDays")
    End If
    
    WeekendsWorkedBox = Val(Range("WeekendsWorked"))
    RDOCarriedBox = Range("RDOCarried")
    RDOBalanceBox = Range("RDOBalance")
    CupHolidayDate = Range("CupDayHoliday")
   ' CupHolidayPicker.Visible = False

    ATCarriedBox = TimeToText(Range("ATCarried"), 0) 'Always HH:MM
    ATBalanceBox = TimeToText(Range("ATBalance"), 0)
    If LCase(Range("ATAgreement")) = "yes" Then OptionAT.Value = True Else OptionOT.Value = True
    
    TextBox1 = TimeToText(Range("PaidHours").Cells(1), 0)
    TextBox2 = TimeToText(Range("PaidHours").Cells(2), 0)
    TextBox3 = TimeToText(Range("PaidHours").Cells(3), 0)
    TextBox4 = TimeToText(Range("PaidHours").Cells(4), 0)
    TextBox5 = TimeToText(Range("PaidHours").Cells(5), 0)
    TextBox6 = TimeToText(Range("PaidHours").Cells(6), 0)
    TextBox7 = TimeToText(Range("PaidHours").Cells(7), 0)
    TextBox8 = TimeToText(Range("PaidHours").Cells(8), 0)
    TextBox9 = TimeToText(Range("PaidHours").Cells(9), 0)
    TextBox10 = TimeToText(Range("PaidHours").Cells(10), 0)
    TextBox11 = TimeToText(Range("PaidHours").Cells(11), 0)
    TextBox12 = TimeToText(Range("PaidHours").Cells(12), 0)
    TextBox13 = TimeToText(Range("PaidHours").Cells(13), 0)
    TextBox14 = TimeToText(Range("PaidHours").Cells(14), 0)

    InfoActivating = False
End Sub

Private Sub OptionAT_Click()
    If InfoActivating Then Exit Sub
    Range("ATAgreement") = "yes"
    MsgBox "Additional normal hours worked as Accrued Time.", vbInformation, MsgCaption
    
End Sub

Private Sub OptionOT_Click()
    If InfoActivating Then Exit Sub
    Range("ATAgreement") = "no"
    MsgBox "Additional normal hours worked as Overtime.", vbInformation, MsgCaption
End Sub

Private Sub FireRoleBox_Change()

End Sub

Private Sub FireRoleBox_Exit(ByVal Cancel As MSForms.ReturnBoolean)
    If Trim(FireRoleBox) <> Range("FireRole") Then
        Range("FireRole") = Trim(FireRoleBox)
        MsgBox "Your Fire Role has been updated", vbInformation, MsgCaption
    End If
End Sub

Private Sub CloseButton_Click()
    If Trim(FireRoleBox) <> Range("FireRole") Then
        Range("FireRole") = Trim(FireRoleBox)
    End If
    
    'Unload Me
    Me.Hide
End Sub

Private Sub UpdateButton_Click()
Dim RostDays As Integer

RostDays = Range("RosteredDays") 'save current workplan rostered days
 
 'Get personal info from Oracle
LoadPersonInformation (Range("PersonID"))
If Not InfoLoadedOK Then 'This is an error condition

        MsgBox "Cannot connect to Oracle." & vbCr & vbCr & _
        "Your work hours could not be updated.", vbExclamation, MsgCaption
        Exit Sub
End If


 'chg180410 - users want to turn rostered days on and off as required
 If True Then         'Val(Range("RosteredDays")) <> RostDays Then
     Range("Takes_RDOs") = "no" 'default
     If Val(Range("RosteredDays")) <> 0 Then
'            If Range("TotalHours") < 76 Then
                If MsgBox("Do you take 'Rostered Days Off' for weekend days worked?", vbYesNo, MsgCaption) = vbYes Then
                    Range("Takes_RDOs") = "yes"
                End If
'            Else
'                Range("Takes_RDOs") = "yes"
'            End If
     End If
 End If
 
    Call UserForm_Activate 'refresh the form
    MsgBox "Your personal information has been updated", vbInformation, MsgCaption
        

End Sub



