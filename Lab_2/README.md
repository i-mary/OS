# Отчёт по лабораторной работе №2. #
# Настройка ОС. #
Задание 1.

Создала VM с заданными характеристиками:
1 gb ram
1 cpu
2 hdd
SATA контроллер на 4 порта

![] https://github.com/i-mary/OS/blob/master/Lab_2/screenshots/Sceen1.jpg

То есть изначально у нас 2 пустых диска:

![] https://github.com/i-mary/OS/blob/master/Lab_2/screenshots/Screen02.jpg

После того, как завершена настройка отдельного раздела под /boot и определение свободного места под raid, видим:

![] https://github.com/i-mary/OS/blob/master/Lab_2/screenshots/Screen03.jpg

Выполним создание нового raid устройства
(зеркальный массив = raid1):

![] https://github.com/i-mary/OS/blob/master/Lab_2/screenshots/Screen04.jpg

Настройка LVM: создание томов root, var, log

![] https://github.com/i-mary/OS/blob/master/Lab_2/screenshots/Screen05.jpg

Выполнила разметку этих томов, установив mount point
/, /var, /var/log для root, var, log соответственно

Завершив настройку LVM, видим:

![] https://github.com/i-mary/OS/blob/master/Lab_2/screenshots/Screen06.jpg

![] https://github.com/i-mary/OS/blob/master/Lab_2/screenshots/Screen07.jpg

Скопируем содержимое раздела /boot с диска sda на диск sdb:

![] https://github.com/i-mary/OS/blob/master/Lab_2/screenshots/Screen08.jpg

У нас вот такие диски в системе:

![] https://github.com/i-mary/OS/blob/master/Lab_2/screenshots/Screen09.jpg

Выполним установку grub на диск sdb:

![] https://github.com/i-mary/OS/blob/master/Lab_2/screenshots/Screen10.jpg

Информация о текущем raid + команды pvs, vgs, lvs:

![] https://github.com/i-mary/OS/blob/master/Lab_2/screenshots/Screen11.jpg

Видно, что команда pvs информацию о физических томах, команда lvs — о логических томах, команда vgs — о группе томов.


Вывод: я узнала, как установить ОС на VM с нуля, выполнить разметку жёстких дисков и перенести таблицу разделов на «зеркальный» диск.

Задание 2.

Жестоко на ходу удалён 1 диск, => статус RAID-массива:

![] https://github.com/i-mary/OS/blob/master/Lab_2/screenshots/Screen12.jpg

Raid «развалился», ведь теперь у нас только 1 диск
VM по-прежнему работает.

Добавили в свойствах машины новый диск.
У него ещё нет никакой таблицы разделов:

![] https://github.com/i-mary/OS/blob/master/Lab_2/screenshots/Screen13.jpg

Скопируем её с диска sda1 и sda2 командами sfdisk -d /dev/ sda1 | sfdisk /dev/sdb, sfdisk -d /dev/ sda2 | sfdisk /dev/sdb

Примечание: на данном этапе у меня произошёл сбой из-за невнимательности, и пришлось заново проделывать всю предыдущую работу, поэтому во всех последующих скриншотах у меня вызовы происходят от root@kali (так задано в новой VM).

После установки grub на новый диск и перезагрузки у нас на диске sdb 2 раздела.
Добавим в raid-массив новый диск: mdadm --manage /dev/md0 --add /dev/sdb:

![] https://github.com/i-mary/OS/blob/master/Lab_2/screenshots/Screen14.jpg

Видим, что синхронизация началась.

Синхронизация разделов: с sda1 на sdb1 и с sda2 на sdb2:

![] https://github.com/i-mary/OS/blob/master/Lab_2/screenshots/Screen15.jpg

После перезагрузки архитектура дисков выглядит следующим образом:

![] https://github.com/i-mary/OS/blob/master/Lab_2/screenshots/Screen16.jpg

Вывод: выполнена замена диска после его удаления путём копирования данных с «зеркального» диска, находящегося raid-массиве.


Задание 3.

Снова создадим эмуляцию отказа диска:

![] https://github.com/i-mary/OS/blob/master/Lab_2/screenshots/Screen17.jpg

Добавим новый диск немного большего объема (7,5 Gi):

![] https://github.com/i-mary/OS/blob/master/Lab_2/screenshots/Screen18.jpg

Машина видит новый диск. Старый диск не переименовался, так как его порядковый номер порта SATA был меньше чем у нового диска.

Скопировав файловую таблицу со старого диска на новый командой sfdisk -d /dev/sda | sfdisk /dev/sdb, видим, что /boot не скопировался.
Поэтому перемонтируем его и на новый диск.
И выполним установку grub на новый диск:

![] https://github.com/i-mary/OS/blob/master/Lab_2/screenshots/Screen19.jpg

Создадим новый массив командой mdadm --create --verbose /dev/md63 --level=1 --force --raid-devices=1 /dev/sdb2.

Ключи:
--create - указывает на то, что мы создаем массив;
--verbose - название массива;
--level=1 - тип RAID-массива, у нас зеркальный;
--force - собирает массив в любом случае, даже при каких-либо несоответствиях, в нашем случае количество дисков в массиве должно быть минимум равно 2;
--raid-devices=1 - задает количество дисков в массиве.

![] https://github.com/i-mary/OS/blob/master/Lab_2/screenshots/Screen20.jpg

Настройка LVM

Новый физический том с ранее созданным RAID массивом:

![] https://github.com/i-mary/OS/blob/master/Lab_2/screenshots/Screen21.jpg

Размер system действительно увеличился, но var, log, root содержатся в массиве md0, на диске sda:

![] https://github.com/i-mary/OS/blob/master/Lab_2/screenshots/Screen22.jpg

Перемещение данных var, log, root со старого диска на новый:

![] https://github.com/i-mary/OS/blob/master/Lab_2/screenshots/Screen23.jpg

Перемещение завершилось успешно:

![] https://github.com/i-mary/OS/blob/master/Lab_2/screenshots/Screen24.jpg

Удалим диск из группы командой vgreduce system /dev/md0.
Изменения (на диске sda не осталось смонтированных элементов):

![] https://github.com/i-mary/OS/blob/master/Lab_2/screenshots/Screen25.jpg

Теперь удалим диск, и добавим 1 SSD и 2 HDD:

![] https://github.com/i-mary/OS/blob/master/Lab_2/screenshots/Screen26.jpg

Необходимо восстановить raid-массив, скопировав таблицу разделов на новый SSD, и перенесём загрузочный раздел со старого диска на новый:

![] https://github.com/i-mary/OS/blob/master/Lab_2/screenshots/Screen27.jpg

Увеличим размер 2-го раздела:

![] https://github.com/i-mary/OS/blob/master/Lab_2/screenshots/Screen28.jpg

Расширим размер RAID:

![] https://github.com/i-mary/OS/blob/master/Lab_2/screenshots/Screen29.jpg

Расширим размер LV:

![] https://github.com/i-mary/OS/blob/master/Lab_2/screenshots/Screen30.jpg

Далее разделим место между разделами. Результат видно здесь;

![] https://github.com/i-mary/OS/blob/master/Lab_2/screenshots/Screen31.jpg

Переместим /var/log на новые диски, для этого создадим новый массив и lvm на hdd дисках (создадим новый PV, в нем создадим группу и выделим ему все свободное пространство). Что произошло:

![] https://github.com/i-mary/OS/blob/master/Lab_2/screenshots/Screen32.jpg

Отформатируем созданные разделы под ext4:

![] https://github.com/i-mary/OS/blob/master/Lab_2/screenshots/Screen33.jpg

Перенесем данные логов со старого раздела на новый, перенеся данные логов со старого раздела на новый и выполнив синхронизацию разделов.

С помощью утилиты для работы со службами(systemctl) останавливаем все процессы, которые работают с /var/log, а с помощью утилиты lsof, которая выводит информацию о том какие файлы используются теми или иными процессами узнаем, что всё остановилось.

И теперь Перемонтируем /var/log командами:
umount /mnt
umount /var/log
mount /dev/mapper/data-var_log /var/log

![] https://github.com/i-mary/OS/blob/master/Lab_2/screenshots/Screen34.jpg

После перезагрузки убеждаемся, что на нашей VM всё работает.

Сделаем проверку того, что выполнилось ранее:

![] https://github.com/i-mary/OS/blob/master/Lab_2/screenshots/Screen35.jpg

Вывод: я научилась настраивать ОС с нуля, поняла на практике, для чего нужен raid1, и научилась переносить данные на новые диски.
