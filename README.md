# Cordova SmartIDReader

Cordova SmartIDReader is a plugin for SmartEngines [iOS](https://github.com/SmartEngines/SmartIDReader-iOS-SDK) and [Android](https://github.com/SmartEngines/SmartIDReader-Android-SDK) SDK which allows you to recognize identity and property rights documents while using camera.

![preview](https://smartengines.ru/wp-content/themes/newsmart/img/pasru_scanall2.jpg)

# Installation

1.  Add licence file to `<project_root>/libs/smartengine`

![like this](https://imgur.com/Uspk0DO.png)

2.  Add plugin to your project

```sh
cordova plugin add https://github.com/gordeev1/cordova-SmartIDReader
```

# Supported Platforms

-   Android >= 7
-   IOS

# API

## Methods

-   [SmartIDReaderPlugin.recognize](#recognize)

### recognize

```js
SmartIDReaderPlugin
    .recognize('ru.passport.national', '5.0')
    .then(r => console.log(r);
```

```js
{
    authority: { isAccepted: true, value: "ОУФМС РОССИИ ПО НИЖЕГОРОДСКОЙ ОБЛ. В АВТОЗАВОДСКОМ Р-НЕ ГОР. НИЖНЕГО НОВГОРОДА" },
    authority_code: { isAccepted: false, value: "100-001" },
    birthdate: { isAccepted: true, value: "13.08.1980" },
    birthplace: { isAccepted: false, value: "Г.НИЖНИЙ НОВГОРОД" },
    full_mrz: { isAccepted: true, value: "PNRUSIVANOV<<IVAN<IVANOVICH<<<<<<<<<<<<<<5436776512341<<<<<<<5436776512341<45" },
    gender: { isAccepted: true, value: "МУЖ." },
    issue_date: { isAccepted: true, value: "06.09.2010" },
    mrz_line1: { isAccepted: true, value: "PNRUSIVANOV<<IVAN<IVANOVIC<<<<<<<<<<<<<<" },
    mrz_line2: { isAccepted: true, value: "1000456476RUS4563457M<<<<<<<5436776512341<45" },
    name: { isAccepted: true, value: "Иван" },
    number: { isAccepted: true, value: "610563" },
    patronymic: { isAccepted: true, value: "Иванович" },
    series: { isAccepted: true, value: "1000" },
    surname: { isAccepted: false, value: "Иванов" }
}
```
