Private Sub Worksheet_Change(ByVal Target As Range)
    If Target.Parent.ProtectContents = False Then   'admin sheet is protected
        If Target.Address = "$B$56" Then
            If Target.Value <> #11/3/2020# Then    'Log changes where [Cup Holiday Field] is irregular... DELETE this logging in 2021   'looking for user errors around Range("CupDayHoliday") value. as suggested by Leonie Dickins 17Jun2020
                Call logDataEntry("Sheets(""Admin"") > Cup day OK = " & Format(Range("CupDayHoliday"), "dd/mmm/yy") & " in " & Range("WorkCentre") & " (Checking for user errors)")
            End If
        End If
    End If
End Sub
