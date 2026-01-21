# ALSTOM Alarm Matrix
Мини-приложение для просмотра и поиска сигналов из инженерной базы ALSTOM с поддержкой
русского, английского, итальянского и сербского языков.

## Запуск

Достаточно открыть `index.html` в браузере. Для локального сервера можно использовать:

```bash
python3 -m http.server 8000
```

И затем перейти на `http://localhost:8000`.

## Публикация через GitHub Pages

1. Откройте вкладку **Actions** и запустите workflow **Deploy GitHub Pages**.
2. После завершения сборки откройте вкладку **Settings → Pages** и убедитесь, что выбран источник
   `GitHub Actions`.
3. Сайт будет доступен по ссылке GitHub Pages для репозитория.

## Сборки Windows и Android через GitHub Actions (без команд)

1. Откройте репозиторий на GitHub и перейдите во вкладку **Actions**.
2. В списке workflow выберите **Build Desktop and Android Apps**.
3. Нажмите кнопку **Run workflow** и подтвердите запуск (ветка по умолчанию).
4. Дождитесь завершения сборки (статус `completed`).
5. Откройте выполненный запуск и скачайте артефакты:
     - `alstom-alarm-matrix-windows` — папка с `ALSTOM Alarm Matrix.exe`, DLL и ресурсами;
   - `alstom-alarm-matrix-android` — APK.