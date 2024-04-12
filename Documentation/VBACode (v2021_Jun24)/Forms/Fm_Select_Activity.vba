Option Explicit


'Normal Width, Height & Top of Images/Labels
Const NormalWidth = 96
Const NormalHeight = 66
Const ImageTop = 42
Const LabelTop = 114
Const LeftMargin = 36
Const Gap = 2

Dim Option1 As String
Dim Option2 As String
Dim Option3 As String
Dim Option4 As String
Dim Option5 As String
Dim Option6 As String

Dim CurRow As Integer 'Selected Row
Dim ThisDay As Date
Dim DayNum As Integer
Dim PaidHours As Single
Dim ImageSelected As Boolean 'to stop flicker as mouse moves overan form
Dim SelectedImage As Integer 'to stop flicker as mouse moves overan image


Private Sub UserForm_Activate() 'Always called when sheet("Timesheet") is Active
    Image3.Visible = False
    Image4.Visible = False
    Image5.Visible = False
    Image6.Visible = False
    
    'Dim lngStatus As Long
    'Dim typWhere As POINTAPI
     
    'lngStatus = GetCursorPos(typWhere)
    'typWhere.x & Chr(13) & "y: " & typWhere.y, vbInformation, "Pixels"

    
    With Fm_Select_Activity
        .StartUpPosition = 0
        
        .Left = Application.Left + (0.5 * Application.Width) - 300
        '.Left = Application.Left + (0.5 * Application.Width) - (0.5 * .Width)
        .Top = Application.Top + (0.5 * Application.Height) - (0.5 * .Height)
        '.Top = ActiveCell.Top * 0.75
        .Width = 170
        
    End With
    DoEvents
    

    CurRow = ActiveCell.row
    If Not IsDate(Cells(CurRow, DateCol)) Then Me.Hide: MsgBox "Illegal form call", vbExclamation, MsgCaption: Exit Sub
    ThisDay = Cells(CurRow, DateCol)
    
    Option1 = "PV Workday"
    Option2 = "Emergency Readiness & Response"
    Option3 = "Planned Leave"
    Option4 = "Other Leave"
    Option5 = "Time in Lieu"
    Option6 = "Rostered Day Off"
    
    
    Application.ScreenUpdating = False
    On Error GoTo OptionsError
    Me.Caption = Format(ThisDay, "dddd dd/mmm/yyyy")
    
    
    '--------------------------------------------------
    'Public Holiday (can be Sat/Sun)   All hours are paid, so no AT/TIL/RDO/Lve/AL
    If IsPublicHoliday(ThisDay) Then
        PubHol = True
        Me.Caption = Me.Caption & " - " & GetPublicHoliday(ThisDay)
        Image6.Visible = True
            If Weekday(ThisDay, 2) > 5 Then
                Option6 = "Weekend : Day off"
            Else
                Option6 = "Public Holiday : Day off"
            End If
        GoTo ShowForm '------- DONE
    Else
        PubHol = False
    End If
    
    '--------------------------------------------------
    'Weekend
    If Weekday(ThisDay, 2) > 5 Then
        Image6.Visible = True
        Option6 = "Weekend Day off"
        If Range("RosteredDays") <> 0 And Range("Takes_RDOs") = "yes" Then
            Image4.Visible = True  'Incidental leave
        End If
        GoTo ShowForm '------- DONE
    End If
     
    '--------------------------------------------------
    'Week Day
    PaidHours = Range("PaidHours").Cells(GetPeriodDayNumber(ThisDay))
    If PaidHours = 0 Then  'NOT A NORMAL WORKDAY SO, No Leave, No RDO, No TIL
        Image6.Visible = True
        Option6 = "Personal Time : Day off"
    Else                   'NORMAL WORKDAY
        Image3.Visible = True 'Planned Leave
        Image4.Visible = True 'Incidental leave
        
        If Range("RDOBalance") > 0 Then
            Image6.Visible = True
            Option6 = "Rostered Day Off"
        End If
        'Accrued Time off (TIL)
        If Range("ATBalance") >= PaidHours Then
            Image5.Visible = True
        End If
    End If
    
ShowForm:
    SelectedImage = 0 'to stop flicker s mouse moves overan image
    PresentForm
    Application.ScreenUpdating = True
    Exit Sub
    
OptionsError:
     Me.Hide: MsgBox "An error occured while preparing the form", vbExclamation, MsgCaption
End Sub


Private Sub UserForm_MouseMove(ByVal Button As Integer, ByVal Shift As Integer, ByVal X As Single, ByVal Y As Single)
    If ImageSelected Then DrawImages
    ImageSelected = False
    SelectedImage = 0
    Label1.Caption = "What did you do today? "
End Sub



Private Sub Image1_MouseMove(ByVal Button As Integer, ByVal Shift As Integer, ByVal X As Single, ByVal Y As Single)
    Call ImageSelect(1, Me.Image1, Option1)
End Sub
Private Sub Image1_Click()
    Me.Hide
    Caller = 0
    Fm_Record_Hours.Show
End Sub



Private Sub Image2_MouseMove(ByVal Button As Integer, ByVal Shift As Integer, ByVal X As Single, ByVal Y As Single)
    Call ImageSelect(2, Me.Image2, Option2)
End Sub
Private Sub Image2_Click()
    Me.Hide
    Caller = 1
    Fm_EmergencyResponse.Show
End Sub



Private Sub Image3_MouseMove(ByVal Button As Integer, ByVal Shift As Integer, ByVal X As Single, ByVal Y As Single)
    Call ImageSelect(3, Me.Image3, Option3)
End Sub
Private Sub Image3_Click()
    Me.Hide
    Fm_Leave_Planned.Show
End Sub



Private Sub Image4_MouseMove(ByVal Button As Integer, ByVal Shift As Integer, ByVal X As Single, ByVal Y As Single)
    Call ImageSelect(4, Me.Image4, Option4)
End Sub
Private Sub Image4_Click()
    Me.Hide
    Fm_Leave_Other.DayCountBox.Value = "1"
    Fm_Leave_Other.Show
End Sub



Private Sub Image5_MouseMove(ByVal Button As Integer, ByVal Shift As Integer, ByVal X As Single, ByVal Y As Single)
    Call ImageSelect(5, Me.Image5, Option5)
End Sub
Private Sub Image5_Click()
    Application.ScreenUpdating = False
    ClearTimesheetRow (CurRow)
    Cells(CurRow, TILCol) = "-" & Format((PaidHours / 24), "h:mm")
    Cells(CurRow, LocationIDCol) = 0 'won't get recorded in Oracle
    Cells(CurRow, ActivityCol) = "Time in lieu"
    Cells(CurRow, ActivityCol).Font.Color = RGB(51, 51, 255)
    Cells(CurRow, LocationCol) = "Day off"
    Cells(CurRow, LocationCol).Font.Color = RGB(51, 51, 255)
    Cells(CurRow, EntryDateCol) = Date 'entry date
    Cells(CurRow, DutyCol) = 0
    Cells(CurRow, CatagoryCol) = 5 'time in lieu
                
    If Cells(CurRow, StatusCol) = "saved" Or Cells(CurRow, StatusCol) = "updated" Then
        Cells(CurRow, StatusCol) = "updated"
    Else
        Cells(CurRow, StatusCol) = "entered"
    End If
    Me.Hide
    Cells(CurRow, FundCol) = ""
    UpdateWorkLifeBalance (GetPeriod(ThisDay))
    'Call CalculateTimesheetSummary(GetStartDate(), GetEndDate(ActiveCell.row))
    Call CalculateTimesheetSummary(0)
    Application.ScreenUpdating = True
End Sub



Private Sub Image6_MouseMove(ByVal Button As Integer, ByVal Shift As Integer, ByVal X As Single, ByVal Y As Single)
    Call ImageSelect(6, Me.Image6, Option6)
End Sub
Private Sub Image6_Click()
    Application.ScreenUpdating = False
    ClearTimesheetRow (CurRow)
    Cells(CurRow, LocationIDCol) = 0 'won't get recorded in Oracle
    Cells(CurRow, ActivityCol) = Label1.Caption
    Cells(CurRow, ActivityCol).Font.Color = RGB(51, 51, 255)
    Cells(CurRow, LocationCol) = "Day off"
    Cells(CurRow, LocationCol).Font.Color = RGB(51, 51, 255)
    If Label1.Caption = "Rostered Day Off" Then
        Cells(CurRow, CatagoryCol) = 6
    Else
        Cells(CurRow, CatagoryCol) = 7
    End If
    Cells(CurRow, EntryDateCol) = Date 'entry date
    Cells(CurRow, DutyCol) = 0
                
    If Cells(CurRow, StatusCol) = "saved" Or Cells(CurRow, StatusCol) = "updated" Then
        Cells(CurRow, StatusCol) = "updated"
    Else
        Cells(CurRow, StatusCol) = "entered"
    End If
    Cells(CurRow, FundCol) = ""
    UpdateWorkLifeBalance (GetPeriod(ThisDay))
                
    'Call CalculateTimesheetSummary(GetStartDate(), GetEndDate(ActiveCell.row))
    Call CalculateTimesheetSummary(0)
    Application.ScreenUpdating = True
    Me.Hide
End Sub
'-----------------------------------------------------






Private Sub ImageSelect(ImageNumber As Integer, Img As Object, Txt As String)
    If ImageNumber = SelectedImage Then Exit Sub
    DrawImages
    
    Img.Left = Img.Left - 18
    Img.Width = Img.Width + 36
    Img.Height = Img.Height + 36
    Img.Top = Img.Top - 9
    Img.ZOrder (0) 'top
    
    Label1.Caption = Txt
    'Label1.Left = Img.Left - 60
    ImageSelected = True
    SelectedImage = ImageNumber
End Sub




Sub DrawImages()
    Dim Count As Integer

    'Always visible
    Image1.Left = LeftMargin
    Image1.Width = NormalWidth
    Image1.Height = NormalHeight
    Image1.Top = ImageTop
    Image1.ZOrder (1)
    
    'Always visible
    Image2.Left = Image1.Left + NormalWidth + Gap
    Image2.Width = NormalWidth
    Image2.Height = NormalHeight
    Image2.Top = ImageTop
    Image2.ZOrder (1)
    
    Count = 2
    
    If Image3.Visible Then
        Image3.Left = LeftMargin + ((NormalWidth + Gap) * Count)
        Image3.Width = NormalWidth
        Image3.Height = NormalHeight
        Image3.Top = ImageTop
        Image3.ZOrder (1)
        Count = Count + 1
    End If
    
    If Image4.Visible Then
        Image4.Left = LeftMargin + ((NormalWidth + Gap) * Count)
        Image4.Width = NormalWidth
        Image4.Height = NormalHeight
        Image4.Top = ImageTop
        Image4.ZOrder (1)
        Count = Count + 1
    End If
    
    If Image5.Visible Then
        Image5.Left = LeftMargin + ((NormalWidth + Gap) * Count)
        Image5.Width = NormalWidth
        Image5.Height = NormalHeight
        Image5.Top = ImageTop
        Image5.ZOrder (1)
        Count = Count + 1
    End If
        
    If Image6.Visible Then
        Image6.Left = LeftMargin + ((NormalWidth + Gap) * Count)
        Image6.Width = NormalWidth
        Image6.Height = NormalHeight
        Image6.Top = ImageTop
        Image6.ZOrder (1)
        Count = Count + 1
    End If

End Sub


Sub PresentForm()
    Dim Count As Integer
    Dim W As Integer
    Dim C As Long

    'Always visible
    Image1.Left = LeftMargin
    Image1.Width = NormalWidth
    Image1.Height = NormalHeight
    Image1.Top = ImageTop
    Image1.ZOrder (1)
    
    'Always visible
    Image2.Left = Image1.Left + NormalWidth + Gap
    Image2.Width = NormalWidth
    Image2.Height = NormalHeight
    Image2.Top = ImageTop
    Image2.ZOrder (1)
    
    Count = 2
    
    If Image3.Visible Then
        Image3.Left = LeftMargin + ((NormalWidth + Gap) * Count)
        Image3.Width = NormalWidth
        Image3.Height = NormalHeight
        Image3.Top = ImageTop
        Image3.ZOrder (1)
        Count = Count + 1
    End If
    
    If Image4.Visible Then
        Image4.Left = LeftMargin + ((NormalWidth + Gap) * Count)
        Image4.Width = NormalWidth
        Image4.Height = NormalHeight
        Image4.Top = ImageTop
        Image4.ZOrder (1)
        Count = Count + 1
    End If
    
    If Image5.Visible Then
        Image5.Left = LeftMargin + ((NormalWidth + Gap) * Count)
        Image5.Width = NormalWidth
        Image5.Height = NormalHeight
        Image5.Top = ImageTop
        Image5.ZOrder (1)
        Count = Count + 1
    End If
        
    If Image6.Visible Then
        Image6.Left = LeftMargin + ((NormalWidth + Gap) * Count)
        Image6.Width = NormalWidth
        Image6.Height = NormalHeight
        Image6.Top = ImageTop
        Image6.ZOrder (1)
        Count = Count + 1
    End If
    
    For W = 175 To 75 + (Count * 100) Step 10
        Me.Width = W
        For C = 1 To 750000: Next
    Next
    Label1.Left = (Me.Width / 2) - (Label1.Width / 2)

End Sub

