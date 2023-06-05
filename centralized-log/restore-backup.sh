#!/bin/sh

# where are backups stored
# где хранятся backupЫ
backups_source_dir="/archive/"

# where to restore backups
# куда восстанавливать backupЫ
destination_dir="/backup/"

# data folder is not empty => backup is not needed
# -A output everything except . and .. , the stream of errors is redirected to the void
# папка с данными не пустая => backup не нужен
# -A выводим все кроме . и .. , поток ошибок перенаправляем в пустоту
if [ "$(ls -A "$destination_dir" 2> /dev/null)" != "" ]; 
then
    echo $destination_dir' is not empty';

# backupOB no => no backup
# backupОВ нет => backup не сделаем
elif [ "$(ls -A "$backups_source_dir" 2> /dev/null)" == "" ]
then
    echo $backups_source_dir' is empty';

# the data folder is empty and there is something to restore
# папка с данными пустая и есть, что восстанавливать 
else
    echo $destination_dir' is empty';
    echo 'backuping...';
    
    # 1 find files for the last 7 days, at the end *.tar.gz, file type, only in the archive folder
    # 2 sort them by name and select the first one
    # 1 найдем файлы за последнии 7 дней,  в конце *.tar.gz, тип файл, только в archive папке
    # 2 отсортируем их по имени и выберем первый
    file_backup_tar=$(find ${backups_source_dir} -maxdepth 1 -mtime -7 -type f -name '*.tar.gz' | sort -r | head -n 1);
    echo 'find tar '$file_backup_tar;

    # unpack archive into tmp (backup)
    # распаковать в tmp архив (backup)
    tar -C /tmp/ -xzvf $file_backup_tar;
    echo 'tar '$file_backup_tar' unpack in /tmp/backup';

    ls -lah /tmp/backup

    # from tmp to volume
    # из tmp в volume
    mv -n /tmp/backup/* $destination_dir;
    mv -n /tmp/backup/.[!.]* $destination_dir;
    echo 'mv file in '$destination_dir;
fi



