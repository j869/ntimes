Option Explicit

Public conn As Adodb.Connection
Public RS As Adodb.Recordset

Sub test()
    OpenPVTSConnection ("prod")
End Sub

Sub OpenPVTSConnection(env As String)
    Dim OracleConnectString As String
    Dim connList() As String
    Dim i As Integer
    
    ConOpen = False
    On Error GoTo AdodbErr 'test for Adodb error
    Set conn = New Adodb.Connection
    conn.ConnectionTimeout = 15
    conn.Mode = adModeReadWrite
    
    On Error GoTo ConnStrErr
    savedConnString = GetConnString
    connList = Split(savedConnString, vbCrLf)
    
    
    For i = 0 To UBound(connList)
        If connList(i) <> "" Then
            savedConnString = connList(i)
            If savedConnString = vbNullString Then GoTo ConnStrErr
            Call OpenConnection2(savedConnString)
            If ConOpen Then
                Exit Sub
                Call logDataEntry("Connected to: " & savedConnString)
            Else
                Call logDataEntry("Connection failed: " & savedConnString)
            End If
        End If
    Next i
    

ConnStrErr:
    Call logDataEntry("Failed finally to connect to Timesheet database")
    Exit Sub
    
   '----------------------------------------------------
AdodbErr:
    Call logDataEntry("ADODB System error. Please contact the Service centre")
    MsgBox "ADODB System error. Please contact the Service centre.", vbExclamation, MsgCaption
    
End Sub
Sub OpenConnection2(ConnString As String)
    On Error GoTo ConnErr
    conn.Open ConnString
    conn.CursorLocation = adUseClient
    ConOpen = True
    Exit Sub

ConnErr:
    Call logDataEntry("Failed to connect using: " & ConnString)
    savedConnString = vbNullString
    conn.Close
    ConOpen = False
End Sub

Private Function GetConnString() As String
'---------------------------------------------------------------
    'Data Row = 3
    'Data Column = 2
'---------------------------------------------------------------
    Dim ImportPath, FileName, Address, Data, connList, q As String
    Dim row, Column As Integer
    
    Const SheetName = "Sheet1"
    On Error GoTo networkErr
    On Error GoTo 0
    ImportPath = "\\Mlfiles2\pv-data\PVgroups\Timesheets\BIS Systems\Connections\Connection 19ct.xlsx"
    ImportPath = "O:\PVgroups\Timesheets\BIS Systems\Connections\"
    FileName = "Connection 11g.xlsx"
    
    'Check if the "Connections" file exists
    If Dir(ImportPath & FileName, vbDirectory) = vbNullString Then
        Call logDataEntry("Could not find Ora connection file: " & ImportPath & FileName)
        Exit Function
    End If
    
     
    row = 2
    Column = 2
'    Address = Cells(row, Column).Address
'    Data = "'" & ImportPath & "[" & FileName & "]" & SheetName & "'!" & _
'    Range(Address).Range("A1").Address(, , xlR1C1)
    connList = ""   'ExecuteExcel4Macro(Data)       'extracts data from a closed workbook
    Do
        row = row + 1
        Address = Cells(row, Column).Address
        Data = "'" & ImportPath & "[" & FileName & "]" & SheetName & "'!" & _
        Range(Address).Range("A1").Address(, , xlR1C1)
        q = ExecuteExcel4Macro(Data)       'extracts data from a closed workbook
        If q <> "0" Then connList = connList & vbCrLf & q
    Loop Until row >= 5
    
    GetConnString = connList
    Exit Function
    
networkErr:
    Call logDataEntry("Network Error: failed to open connections file in sub GetConnString()")
    GetConnString = vbNullString
End Function







