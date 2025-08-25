# lol.ps1 - Telegram Clipboard Bot

$token = "7437613640:AAG2c1zXYW2cXJagHIieiEySacEB9rvZOk"   # Токен бота
$chatId = "6365916323"                                      # Твой chat_id
$offset = 0

while ($true) {
    try {
        # Получаем новые обновления от бота
        $updates = Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/getUpdates?timeout=5&offset=$($offset+1)" -Method Get

        if ($updates.ok -and $updates.result) {
            foreach ($update in $updates.result) {
                $offset = $update.update_id

                if ($update.message.text) {
                    $msg = $update.message.text

                    # Проверка команды /stop
                    if ($msg -eq "/stop") {
                        Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/sendMessage" -Method Post -Body @{
                            chat_id = $chatId
                            text    = "🛑 Скрытый терминал завершён"
                        }
                        exit
                    }

                    # Копируем текст в буфер
                    Set-Clipboard -Value $msg

                    # Отправляем подтверждение в Telegram
                    $confirmText = "✅ Получено и скопировано:`n$msg"
                    Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/sendMessage" -Method Post -Body @{
                        chat_id = $chatId
                        text    = $confirmText
                    }
                }
            }
        }
    } catch {
        # Игнорируем ошибки сети
        Start-Sleep -Milliseconds 500
    }

    Start-Sleep -Seconds 1
}