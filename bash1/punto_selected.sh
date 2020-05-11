#!/bin/bash
# v_1.0_20200511
# Bash-скрипт (простой аналог пунто-свитчера для Linux) изменяет символы выделенного фрагмента текста из Russian в English и обратно, 
# переключает раскладку.
# Требует наличия установленных утилит: xdotool, xsel, sed. Использую на Fedora 30. Часть утилит уже стояло, часть поставилась 
# из стандартного репозитория. 
# 
# По мотивам: https://forum.ubuntu.ru/index.php?topic=271377.0
# Спасибо участникам: adawdp, martin_wanderer, Cxms, Azure и других. 
# Известные проблемы: 
# 1. Подвисает при переключении раскладки с RU на EN
# 2. Не работает в консоли, терминале и других программах, где не работают стандартные сочетания клавиш копирования в буфер и вставки из буфера. 
# 
# Для использования необходимо:
# 1. Положить скрипт в локальную папку (можно в Home)
# 2. Сделать исполняемым
# 3. Стандартными средствами назначить горячую клавишу (например: Shift+Break, команда "sh /home/username/myscripts/punto/punto_selected.sh")

# Задержка
sec=0.2
sleep $sec

# Резерв содержимого буфера обмена
BKP_CLIP="$(xsel -ob)"

# Соответствие Английских и Русских символов, т.е. что на что меняем.
# \x2F = / = slash
# \x5C = \ = backslash
en1='`1234567890-=';    ru1='ё1234567890-=';
en2='qwertyuiop[]';     ru2='йцукенгшщзхъ';
en3="asdfghjkl;'\x5C";  ru3='фывапролджэ\x5C';
en4='zxcvbnm,.\x2F';    ru4='ячсмитьбю.';
EN1='~!@#$%^&*()_+';    RU1='Ё!"№;%:?*()_+';
EN2='QWERTYUIOP{}';     RU2='ЙЦУКЕНГШЩЗХЪ';
EN3='ASDFGHJKL:"|';     RU3='ФЫВАПРОЛДЖЭ\x2F';
EN4='ZXCVBNM<>?';       RU4='ЯЧСМИТЬБЮ,';

function SrcContainsRuChars () [[ "$forconvert" =~ [А-ЯЁа-яё] ]] # 0 - true, когда есть хотя бы одная русская буква

forconvert=$(xsel)
 
# направление конвертации определяем по наличию русских букв
if SrcContainsRuChars
then # ru -> en 
    srcchars="$ru1""$ru2""$ru3""$ru4""$RU1""$RU2""$RU3""$RU4"
    dstchars="$en1""$en2""$en3""$en4""$EN1""$EN2""$EN3""$EN4"
else # en -> ru
    srcchars="$en1""$en2""$en3""$en4""$EN1""$EN2""$EN3""$EN4"
    dstchars="$ru1""$ru2""$ru3""$ru4""$RU1""$RU2""$RU3""$RU4"
fi

# заменить srcchars на соотв dstchars
converted=$(printf '%s' "$forconvert" | sed "y/$srcchars/$dstchars/") 

# записать модифицированную строку в буфер
printf '%s' "$converted" | xsel --input --clipboard 
sleep $sec

# вставить строку из буфера
xdotool key --clearmodifiers Shift+Insert 
sleep $sec

# Восстановление содержимого буфера обмена
echo -n "$BKP_CLIP" | xsel -ib
sleep $sec

xdotool key --clearmodifiers Super+space
sleep $sec 
# notify-send 'Сообщение Punto' 'Punto_Selected отработал'