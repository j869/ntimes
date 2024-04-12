Option Explicit

Dim PWActivating As Boolean

Private Sub TextBox1_Exit(ByVal Cancel As MSForms.ReturnBoolean)
    If Fm_Password.Visible Then Fm_Password.Hide
End Sub

Private Sub UserForm_Activate()
    With Fm_Password
      .StartUpPosition = 0
      .Left = Application.Left + (0.5 * Application.Width) - (0.5 * .Width)
      .Top = Application.Top + (0.5 * Application.Height) - (0.5 * .Height)
    End With
    DoEvents


    PWActivating = True
        TextBox1.Text = ""
        PasswordBox = ""
    PWActivating = False
    TextBox1.SetFocus
End Sub



Private Sub TextBox1_Change()
    Dim k As String
    Dim N As Integer
    If PWActivating Then Exit Sub
    If TextBox1 = "" Then Exit Sub
    Dim Is_Text As Boolean
    Is_Text = False
    k = Right(TextBox1.Text, 1)
    N = Asc(k)
    PWActivating = True
            If (Asc(k) >= 65 And Asc(k) <= 90) Or (Asc(k) >= 97 And Asc(k) <= 122) Then Is_Text = True
            If IsNumeric(k) Or Is_Text Then
                TextBox1.Text = Left(TextBox1.Text, Len(TextBox1.Text) - 1) & "l"
                PasswordBox = PasswordBox & k
            Else
                TextBox1.Text = Left(TextBox1.Text, Len(TextBox1.Text) - 1)
            End If
    PWActivating = False
End Sub

Private Sub CommandButton1_Click()
    Me.Hide
End Sub
