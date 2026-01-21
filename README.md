# Alarm Matrix App

Кроссплатформенное приложение на Flutter для Desktop и Android.

## Поддерживаемые платформы
- Android
- Desktop (Windows/macOS/Linux)

> Включение desktop-платформ выполняется один раз на машине разработчика:
>
> ```bash
> flutter config --enable-windows-desktop
> flutter config --enable-macos-desktop
> flutter config --enable-linux-desktop
> ```
>
> После этого можно собрать приложение под нужную платформу.

## Быстрый старт
```bash
flutter pub get
flutter gen-l10n
```

## Запуск
### Android
```bash
flutter run -d android
```

### Desktop (пример для Windows)
```bash
flutter run -d windows
```

## Сборка
### Android APK
```bash
flutter build apk
```

### Desktop (пример для Windows)
```bash
flutter build windows
```

## Импорт данных
Импортируйте файл `.xlsx` через экран Settings. Рекомендуется `alarm_matrix_analysis.xlsx` (лист `Sheet1_clean`).
