# Cordova SmartIDReader

Cordova SmartIDReader is a plugin for SmartEngines [iOS](https://github.com/SmartEngines/SmartIDReader-iOS-SDK) and [Android](https://github.com/SmartEngines/SmartIDReader-Android-SDK) SDK which allows you to recognize identity and property rights documents while using camera.
![preview](http://smartengines.ru/wp-content/themes/newsmart/img/index_pic1.png)

# Installation

1.  Add Android licence file to `<project_root>/libs/android/smartengine`
2.  Add iOS licence file to `<project_root>/libs/ios/smartengine`

![like this](https://imgur.com/Zg26VB1.png)

3.  Add plugin to your project

```sh
cordova plugin add https://github.com/gordeev1/cordova-SmartIDReader
```

> If you got the error `Unable to update build.xcconfig` when install plugin you need to do some manual steps -> see [iOS manual configuration](#iOS-manual-configuration) section

# Supported Platforms

-   Android >= 7
-   IOS

# API

## Methods

-   [SmartIDReader.recognize](#recognize)

### recognize

```js
SmartIDReader.recognize('ru.passport.national', '5.0').then(r => console.log(r));
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

# iOS manual configuration

If you see `Unable to update build.xcconfig file` in the CLI output when adding the plugin you will need to configure your Xcode project manualy.

-   Open `XCode` -> Navigate to `Build Settings` tab
-   Find `Header Search Paths` and add `$(PROJECT_NAME)/Resources/SESmartIDCore/include`
    ![like this](https://imgur.com/T9Gtscy.png)

-   Find `C++ Language Dialect` and select `GNU++11 [-std=gnu++11]`
    ![like this](https://imgur.com/4RCfCp4.png)

-   Find `C++ Standard Library` and select `libc++ (LLVM C++ standard library with C++ 11 support)`
    ![like this](https://imgur.com/rZ0XXpq.png)

# Authors:

-   Artem Gordeev - [@gordeev1](https://github.com/gordeev1)
