Imports Microsoft.VisualBasic

Public Class PackageItem
    Public name As String
    Public desc As String
    Public depend As String
    Public version As UInteger
    Public installed As Boolean
    Public iindex As Integer
    Public Sub New()
        iindex = -1
    End Sub
End Class
