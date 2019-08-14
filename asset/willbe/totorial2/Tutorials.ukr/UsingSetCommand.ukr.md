# Використання команди '.set'

В туторіалі пояснюється призначення команди `.set` та дається приклад використання

Працюючи з програмним забезпеченням користувачі ставлять перед ним вимоги, які базуються на досвіді та конкретній задачі. При цьому налаштування програми за замовчуванням далеко не завжди влаштовують ці вимоги.  
Пакет `willbe` призначений для побудови та адміністрування модульних систем. `Will`-модуль, як основна одиниця пакету, складається з конфігураційного файла та того, що він описує, тому, майже всі налаштування системи поміщені в `will`-файлі. Запуск цих файлів відбувається з допомогою командного рядка системи і до цього моменту ви бачили ввід та результат, а внутрішні процеси були приховані. З командою `.set` можливо прослідкувати і за цим.  
На даний час `willbe` може встановити лише один параметр - `verbosity`, який відповідає за вивід сервісної інформації виконання збірки `will`-файла. Для використання введіть `will .set verbosity:[n] ; [command] [argument]` (в деяких bash-терміналах з лапками - `will ".set verbosity:[n] ; [command] [argument]"`), де `verbosity` - відповідно, деталізація логу; `[n]` - число від 0 до 8 яке встановлює ступінь деталізації, 8 - найвищий ступінь; `[command]` - команда для якої виводиться лог; `[argument]` - аргумент команди, якщо він необхідний.  
Створимо `will`-файл з двома збірками. Перша буде завантажувати підмодулі, а друга експортувати:

<details>
    <summary><u><em>Лістинг `.will.yml`</em></u></summary>

```yaml
about :

  name : setVerbosity
  description : "To use .set command"
  version : 0.0.1

submodule :
  PathBasic : git+https:///github.com/Wandalen/wPathBasic.git/out/wPathBasic#master
  
path :

  out : 'out'

  submodule.pathfundamental :
    criterion :
      debug : 1
    path : '.module/PathBasic'

step  :

  export.submodule :
    criterion :
      debug : 1
    export : path::submodule.*
        
build :

  submodules.download :
      criterion :
          default : 1
          debug : 0
      steps :
          - submodules.download

  submodules.export :
      criterion :
          export : 1
          debug : 1
      steps :
          - export.*

```

</details>

Протестуємо фразу `will .set verbosity:8 ; .build`:

<details>
    <summary><u><em>Лог побудови з `verbosity:8`</em></u></summary>
    
```
[user@user ~]$ will ".set verbosity:8 ; .build"
Request ".set ; .build"
 s module::/path_to_module/UsingSetCommand preformed 1
 s module::/path_to_module/UsingSetCommand preformed 2
 s module::/path_to_module/UsingSetCommand preformed 3
 s module::/path_to_module/UsingSetCommand willFilesFound 1
 s module::/path_to_module/UsingSetCommand willFilesFound 2
Trying to open /path_to_module/UsingSetCommand.will
Trying to open /path_to_module/UsingSetCommand.im.will
Trying to open /path_to_module/UsingSetCommand.ex.will
Trying to open /path_to_module/UsingSetCommand/.will
Trying to open /path_to_module/UsingSetCommand/.im.will
Trying to open /path_to_module/UsingSetCommand/.ex.will
 s module::/path_to_module/UsingSetCommand willFilesFound 3
 s module::/path_to_module/UsingSetCommand willFilesOpened 1
 s module::/path_to_module/UsingSetCommand willFilesOpened 2
   . Read : /path_to_module/UsingSetCommand/.will.yml
 . Read 1 will-files in 0.081s
 s module::setVerbosity willFilesOpened 3
 s module::setVerbosity submodulesFormed 1
 s module::setVerbosity submodulesFormed 2
 s module::PathBasic preformed 1
 s module::PathBasic preformed 2
 s module::PathBasic preformed 3
 s module::PathBasic willFilesFound 1
 s module::PathBasic willFilesFound 2
Trying to open /path_to_module/UsingSetCommand/.module/PathBasic/out/wPathBasic.out.will
Trying to open /path_to_module/UsingSetCommand/.module/PathBasic/out/wPathBasic.out.im.will
Trying to open /path_to_module/UsingSetCommand/.module/PathBasic/out/wPathBasic.out.ex.will
Trying to open /path_to_module/UsingSetCommand/.module/PathBasic/out/wPathBasic/.out.will
Trying to open /path_to_module/UsingSetCommand/.module/PathBasic/out/wPathBasic/.out.im.will
Trying to open /path_to_module/UsingSetCommand/.module/PathBasic/out/wPathBasic/.out.ex.will
Trying to open /path_to_module/UsingSetCommand/.module/PathBasic/out/wPathBasic.will
Trying to open /path_to_module/UsingSetCommand/.module/PathBasic/out/wPathBasic.im.will
Trying to open /path_to_module/UsingSetCommand/.module/PathBasic/out/wPathBasic.ex.will
Trying to open /path_to_module/UsingSetCommand/.module/PathBasic/out/wPathBasic/.will
Trying to open /path_to_module/UsingSetCommand/.module/PathBasic/out/wPathBasic/.im.will
Trying to open /path_to_module/UsingSetCommand/.module/PathBasic/out/wPathBasic/.ex.will
 !s module::PathBasic willFilesFound failed
 s module::PathBasic willFilesOpened 1
 !s module::PathBasic willFilesOpened failed
 s module::PathBasic submodulesFormed 1
 !s module::PathBasic 3 failed
 s module::PathBasic resourcesFormed 1
 !s module::PathBasic resourcesFormed failed
 s module::setVerbosity resourcesFormed 1
 ! Failed to read submodule::PathBasic, try to download it with .submodules.download or even clean it before downloading
Failed to open submodule::PathBasic at "/path_to_module/UsingSetCommand/.module/PathBasic/out/wPathBasic" 
Found no .out.will file for module::setVerbosity at "/path_to_module/UsingSetCommand/.module/PathBasic/out/wPathBasic"             
 s module::setVerbosity submodulesFormed 3
 s module::setVerbosity resourcesFormed 2
 s module::setVerbosity resourcesFormed 3

  Building submodules.download
     - filesDelete 1 files at /path_to_module/UsingSetCommand/.module/PathBasic in 0.017s
 > git clone https://github.com/Wandalen/wPathBasic.git/ .
Клонирование в «.»…
 > git checkout master
Уже на «master»
Ваша ветка обновлена в соответствии с «origin/master».
 > git merge
Уже обновлено.
     + Reflect 92 files /path_to_module/UsingSetCommand/.module/PathBasic <- git+https:///github.com/Wandalen/wPathBasic.git/out/wPathBasic#master in 3.612s
 s module::PathBasic willFilesFound 1
 s module::PathBasic willFilesFound 2
    Trying to open /path_to_module/UsingSetCommand/.module/PathBasic/out/wPathBasic.out.will
    Trying to open /path_to_module/UsingSetCommand/.module/PathBasic/out/wPathBasic.out.im.will
    Trying to open /path_to_module/UsingSetCommand/.module/PathBasic/out/wPathBasic.out.ex.will
 s module::PathBasic willFilesFound 3
 s module::PathBasic willFilesOpened 1
 s module::PathBasic willFilesOpened 2
     . Read : /path_to_module/UsingSetCommand/.module/PathBasic/out/wPathBasic.out.will.yml
 s module::PathBasic willFilesOpened 3
 s module::PathBasic submodulesFormed 1
 s module::PathBasic submodulesFormed 2
 s module::PathBasic submodulesFormed 3
 s module::PathBasic resourcesFormed 1
 s module::PathBasic resourcesFormed 2
 s module::PathBasic resourcesFormed 3
     + module::PathBasic was downloaded in 4.276s
   + 1/1 submodule(s) of module::setVerbosity were downloaded in 4.282s
  Built submodules.download in 4.326s

```

</details>

Експортуємо модуль зі значенням `verbosity:4`:

<details>
    <summary><u><em>Лог експорту з `verbosity:4`</em></u></summary>
    
```
[user@user ~]$ will .set verbosity:4 ; .export submodules.export
Request ".set ; .export submodules.export"
Trying to open /path_to_module/UsingSetCommand.will
Trying to open /path_to_module/UsingSetCommand.im.will
Trying to open /path_to_module/UsingSetCommand.ex.will
Trying to open /path_to_module/UsingSetCommand/.will
Trying to open /path_to_module/UsingSetCommand/.im.will
Trying to open /path_to_module/UsingSetCommand/.ex.will
   . Read : /path_to_module/UsingSetCommand/.will.yml
 . Read 1 will-files in 0.104s
Trying to open /path_to_module/UsingSetCommand/.module/PathBasic/out/wPathBasic.out.will
Trying to open /path_to_module/UsingSetCommand/.module/PathBasic/out/wPathBasic.out.im.will
Trying to open /path_to_module/UsingSetCommand/.module/PathBasic/out/wPathBasic.out.ex.will
 . Read : /path_to_module/UsingSetCommand/.module/PathBasic/out/wPathBasic.out.will.yml

  Exporting submodules.export
     . Read : /path_to_module/UsingSetCommand/out/setVerbosity.out.will.yml
   . Read 1 will-files in 0.195s
   + Write out archive /path_to_module/UsingSetCommand/ : out/setVerbosity.out.tgs <- .module/PathBasic
   + Write out will-file /path_to_module/UsingSetCommand/out/setVerbosity.out.will.yml
   + Exported submodules.export with 46 files in 2.423s
  Exported submodules.export in 2.467s

```

</details>

Видалимо підмодулі (`will .submodules.clean`) та знову завантажимо з `verbosity:0`:

<details>
    <summary><u><em>Лог побудови `verbosity:0`</em></u></summary>
    
```
[user@user ~]$ will .set verbosity:0 ; .build
Request ".set ; .build"
 . Read 1 will-files in 0.082s

```

</details>

- Встановлення параметра `verbosity` найбільш корисне при відладці модулів

[Наступний туторіал]()  
[Повернутись до змісту](../README.md#tutorials)