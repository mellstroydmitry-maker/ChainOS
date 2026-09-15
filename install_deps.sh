#!/bin/bash

# Останавливать выполнение при любой ошибке
set -e

echo "=== Проверка установленного Python ==="
if ! command -v python3 &> /dev/null; then
    echo "Ошибка: Python3 не установлен в системе."
    echo "Пожалуйста, сначала запустите основной системный скрипт (getready.py)."
    exit 1
fi

echo "=== Проверка модуля venv ==="
# В Debian/Ubuntu venv вынесен в отдельный пакет python3-venv
if ! python3 -c "import venv" &> /dev/null; then
    echo "Установка системного пакета python3-venv..."
    sudo apt update && sudo apt install -y python3-venv
fi

echo "=== Создание виртуального окружения (папка .venv) ==="
if [ ! -d ".venv" ]; then
    python3 -m venv .venv
    echo "Виртуальное окружение успешно создано."
else
    echo "Виртуальное окружение .venv уже существует."
fi

echo "=== Активация виртуального окружения ==="
source .venv/bin/activate

echo "=== Обновление pip ==="
pip install --upgrade pip

echo "=== Установка зависимостей ==="
# Если у вас есть файл requirements.txt, раскомментируйте строку ниже:
# pip install -r requirements.txt

# Наш скрипт getready.py использует только встроенные библиотеки (os, sys, subprocess, urllib),
# но если вы захотите его расширить (например, добавить красивый интерфейс), 
# мы можем установить полезные утилиты, например, colorama для цветного вывода:
pip install colorama

echo "========================================================="
echo " Все зависимости установлены!"
echo " Для запуска вашего Python-скрипта используйте команды:"
echo " 1. source .venv/bin/activate"
echo " 2. sudo .venv/bin/python3 getready.py"
echo "========================================================="
