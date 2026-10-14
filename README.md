# Пример: CI для небольшого HTTP-сервиса

Приложение написано на Go и отвечает на `GET /health` и `GET /version`. Версия задается переменной `APP_VERSION`.

## Что делает CI

Файл `.github/workflows/ci.yml` запускается при каждом push и pull request. GitHub создает временный `ubuntu-latest` runner для workflow; отдельный сервер или self-hosted runner не нужен.

Workflow выполняет последовательно:

1. Получает исходный код.
2. Запускает unit-тесты командой `go test ./...`.
3. Собирает Docker-образ с тегом, равным commit SHA.
4. Запускает контейнер, задает `APP_VERSION` и проверяет `/health` и `/version` по HTTP.
5. Останавливает контейнер.

Образ нужен только внутри CI runner и в registry не публикуется. Для выкладки в Kubernetes и демонстрации rollback студент тегирует/собирает версию локально.

## Проверить локально

Нужны Go 1.25+; для container smoke test нужен также Docker.

```bash
go test ./...
docker build -t ci-starter:local .
docker run --rm --name ci-starter -p 8080:8080 -e APP_VERSION=local ci-starter:local
```

В другом терминале:

```bash
curl -i http://localhost:8080/health
curl -i http://localhost:8080/version
```

Ожидаемый ответ `/version`:

```json
{"version":"local"}
```

Остановить контейнер можно `Ctrl+C`.

## Проверить на GitHub

1. Создай пустой репозиторий на GitHub. Не добавляй README, license или `.gitignore`, чтобы избежать лишнего merge.
2. Скопируй содержимое **этого каталога** в корень нового репозитория. В нем должны лежать `go.mod`, `Dockerfile` и `.github/workflows/ci.yml`.
3. Инициализируй Git и отправь файлы:

   ```bash
   git init
   git add .
   git commit -m "Add Go service and CI workflow"
   git branch -M main
   git remote add origin https://github.com/USERNAME/REPOSITORY.git
   git push -u origin main
   ```

   Замени `USERNAME/REPOSITORY` на адрес своего репозитория.
4. На GitHub открой вкладку **Actions** и выбери запуск **CI**. Внутри job проверь зеленые шаги тестов, сборки образа и HTTP-проверок.
5. Для проверки pull request создай ветку, измени строку версии или ответ endpoint, отправь ветку и открой pull request в `main`. Workflow должен запуститься и на нем.

Если репозиторий принадлежит организации, администратор организации может ограничить запуск Actions. Для личного репозитория обычно достаточно включенного Actions; runner вручную регистрировать не нужно.


