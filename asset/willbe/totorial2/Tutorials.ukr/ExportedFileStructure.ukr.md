# Структура will-файла згенерованого при експорті модуля

В туторіалі показано особливості структури експортованого `*.out.will.`-файла та окремих ресурсів

`*.out.will.`-файл автоматично генерується при виконанні експорту модуля. Пакет створює структуру `*.out.will.`-файла використовуючи ресурси вихідного `will`-файла а також додаючи спеціальні.  

`*.out.will.`-файл має визначену структуру:  

```
exported will-file
    ├── format
    ├── about
    ├── execution 
    ├── path
    ├── submodule 
    ├── reflector 
    ├── step
    ├── build 
    └── exported

```

Секція-поле `format` - позначає формат файла для виконання пакетом. Має значення `willfile-1.0.0`.  
Секція `about` повністю копіюється з вихідного `will`-файла, додається поле `enabled : 1`. 
Секція `execution` - в стані розробки, має порожнє значення.  
Секція `path` копіює ресурси з вихідного файла та додатково включає згенеровані пакетом ресурси: `exportedDir.*` - шляхи до експортованих директорій модуля (тут і далі '\*' позначає назву збірки за якою виконувався експорт);  
`exportedFiles.*` - шляхи до експортованих файлів модуля;  
`archiveFile.*` - шлях до архіву з експортом модуля. Поле вказується якщо включене архівування при експорті (`tar : 1`).  
Секція `submodule` копіює ресурси з вихідного файла.  
В секцію `reflector` крім даних вихідного файла поміщено згенеровані ресурси:
`exported.*` - рефлектор за яким було створено експорт;  
`exportedFiles*` - рефлектор з детальним списком файлів які було експортовано.
Секції `step` i `build` копіюються без змін.
Секція `exported` автоматично генерується пакетом - присутня тільки в `*.out.will.`-файлі. Містить інфомацію про модуль і посилання на експортовані ресурси.

```yaml
exported:
  export.:
    version: 0.0.1
    criterion:
      default: 1
      debug: 0
      export: 1
    exportedReflector: 'reflector::exported.export.'
    exportedFilesReflector: 'reflector::exportedFiles.export.'
    exportedDirPath: 'path::exportedDir.export.'
    exportedFilesPath: 'path::exportedFiles.export.'
    archiveFilePath: 'path::archiveFile.export.'

```
