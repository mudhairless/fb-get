Imports System.IO

Public Class Form1
    Dim hasChanges As Boolean
    Dim pkglist As String
    Dim instlist As String
    Dim packages As List(Of PackageItem)
    Dim installed As List(Of PackageItem)

    Private Sub ExitToolStripMenuItem_Click(sender As System.Object, e As System.EventArgs) Handles ExitToolStripMenuItem.Click
        Dim result As MsgBoxResult
        result = MsgBoxResult.Yes
        If hasChanges Then
            result = MsgBox("There are unsaved changes, are you sure you want to exit?", MsgBoxStyle.YesNo)
        End If
        If result = MsgBoxResult.Yes Then
            Me.Close()
        End If

    End Sub

    Public Sub loadPackages()
        packages.Clear()
        Dim pr As StreamReader = My.Computer.FileSystem.OpenTextFileReader(Me.pkglist)
        Dim nump As UInteger = CUInt(pr.ReadLine())
        For index As UInteger = 1 To nump
            Dim curi As PackageItem = New PackageItem
            curi.name = pr.ReadLine
            curi.desc = pr.ReadLine
            curi.depend = pr.ReadLine
            curi.version = CUInt(pr.ReadLine)
            pr.ReadLine()
            packages.Add(curi)
        Next
        pr.Close()
        Try
            pr = My.Computer.FileSystem.OpenTextFileReader(Me.instlist)

            Dim nump_i As UInteger = CUInt(pr.ReadLine())
            For index As UInteger = 1 To nump_i
                Dim curi As PackageItem = New PackageItem
                curi.name = pr.ReadLine
                curi.desc = pr.ReadLine
                curi.depend = pr.ReadLine
                curi.version = CUInt(pr.ReadLine)
                pr.ReadLine()
                installed.Add(curi)
            Next
            StatusTextBox.Text &= vbNewLine & Str(nump_i) & " packages are installed."
        Catch e As FileNotFoundException
            StatusTextBox.Text &= vbNewLine & "No packages are installed."
        End Try

        Me.PackageList.Items.Clear()
        For Each i As PackageItem In Me.packages
            Dim ii As Integer
            Dim pkgi As Boolean = False

            ii = Me.PackageList.Items.Add(i.name)
            For Each ini As PackageItem In Me.installed
                If i.name.Equals(ini.name) Then
                    pkgi = True
                    i.iindex = installed.IndexOf(ini)
                    Exit For
                End If
            Next
            PackageList.SetItemChecked(ii, pkgi)

        Next
        StatusTextBox.Text = StatusTextBox.Text + vbNewLine + "Loaded " + Str(nump) + " packages."
    End Sub

    Public Sub New()

        ' This call is required by the designer.
        InitializeComponent()

        ' Add any initialization after the InitializeComponent() call.
        hasChanges = False
        Dim curdir As String = Environment.CurrentDirectory
        pkglist = curdir + "/packages.list"
        instlist = curdir + "/installed.list"
        packages = New List(Of PackageItem)
        installed = New List(Of PackageItem)
    End Sub

    Private Sub Form1_Shown(sender As Object, e As System.EventArgs) Handles Me.Shown
        StatusTextBox.Text = "FreeBASIC Package Manager" & vbNewLine & "Version 0.0a" & vbNewLine
        Me.loadPackages()

    End Sub

    Private Sub PackageList_SelectedIndexChanged(sender As Object, e As System.EventArgs) Handles PackageList.SelectedIndexChanged
        Dim curpkg As PackageItem = packages.ElementAt(PackageList.SelectedIndex)
        PackageNameBox.Text = curpkg.name
        DependsBox.Text = curpkg.depend
        DescBox.Text = curpkg.desc
        If curpkg.iindex >= 0 Then
            VersionBox.Text = "Remote Version: " & Str(curpkg.version) & " Installed Version: " & Str(installed.ElementAt(curpkg.iindex).version)
        Else
            VersionBox.Text = "Remote Version: " & Str(curpkg.version)
        End If
    End Sub
End Class
