'Constants
Global Const tmode = "prod" ' change to "dev" for test. "prod" for release
Global Const Pword = "pvts"
Global Const DateCol = 2
Global Const StartCol = 4
Global Const FinishCol = 5
Global Const BreakCol = 6
Global Const ExtraCol = 7
Global Const TotalCol = 8

Global Const LeaveCol = 12
Global Const TILCol = 11

Global Const ATCol = 10
Global Const OTCol = 13
Global Const CSCol = 14
Global Const CommentsCol = 15
Global Const LocationIDCol = 16
Global Const FundCol = 17
Global Const LocationCol = 18
Global Const ActivityCol = 19
Global Const NotesCol = 20
Global Const StandbyCol = 22

Global Const EntryDateCol = 25
Global Const DutyCol = 26
Global Const CatagoryCol = 27
Global Const StatusCol = 28
Global Const RWECol = 29

Global Const MsgCaption = "Parks Victoria Timesheet"
Global Const OraFinYear = "2020-21"
Global Const FinYear = "2020-2021"

Global Const Grey = &H8000000F
Global Const Red = &HC0E0FF
Global Const Green = &HC0FFC0
Global Const White = &H80000005
Global Const Buff = &HC0FFFF
Global Const DarkRed = &HC0&
Global Const Black = &H80000006

Public ActNum As Integer 'Activity Number - used by Fm_Activity_Info and Fm_Acrivity_New
Public CancelTimeEntry As Boolean
Public PubHol As Boolean
Public Caller As Integer
Public LocationListUpToDate As Boolean
Public FundSourceListUpToDate As Boolean
Public InfoLoadedOK As Boolean
Public ConOpen As Boolean
Public savedConnString As String ' Oracle connectionString (remote)
Public EditActivityName As String 'Name of Activity being edited
Public ProgramListUpToDate As Boolean
Public HolidayListUpToDate As Boolean
Public SetupRun As Boolean 'True when the setup routine runs. Stops the "UpdatedatabaseRecords" routine running.
Public TemplateFile As Boolean
