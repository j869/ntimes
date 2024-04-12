
Option Explicit


Private Sub InformationButton_Click()
    Fm_Timesheet_Manager.Show
End Sub

Private Sub TimesheetButton_Click()
    Sheets("Timesheet").Activate
End Sub


Private Sub WorkLifeButton_Click()
    Sheets("Work Life Balance").Select
End Sub

