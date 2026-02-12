# 🎮 BLauncher

> Форк [Prism Launcher](https://prismlauncher.org) с поддержкой офлайн-аккаунтов.

---

## Что это?

**BLauncher** — это модифицированная версия Prism Launcher, заточенная под:

- 🔓 **Офлайн-аккаунт** — играй без привязки к Microsoft / Mojang
- 🧪 **Бета-версии Minecraft** — готовые сборки для тестирования snapshot и beta
- ⚡ **Простота** — скачал, поставил, играешь

Проект в активной разработке. Обновления выходят по запросам в [Issues](https://github.com/FLEXIY0/BLauncher/issues).

---

## Скачать

| Платформа | Ссылка |
|---|---|
| 🪟 Windows (Setup.exe) | [Releases](https://github.com/FLEXIY0/BLauncher/releases/latest) |
| 🪟 Windows (Portable) | [Releases](https://github.com/FLEXIY0/BLauncher/releases/latest) |
| 🐧 Linux (AppImage) | [Releases](https://github.com/FLEXIY0/BLauncher/releases/latest) |
| 🐧 Linux (Portable) | [Releases](https://github.com/FLEXIY0/BLauncher/releases/latest) |

Дев-сборки доступны во вкладке [Actions](https://github.com/FLEXIY0/BLauncher/actions).

---

## Скриншоты

> 🖼️ *Скоро будут добавлены*

---

## Возможности

- Поддержка офлайн-аккаунтов (Ely.by OAuth2)
- Управление несколькими инстансами Minecraft
- Поддержка модов (Forge, Fabric, Quilt, NeoForge)
- Импорт модпаков CurseForge / Modrinth
- Автоматическая установка Java
- Ретро-установщик в стиле Windows 95/98 🖥️

---

## Сборка из исходников

Инструкции по сборке: [Build Instructions](https://prismlauncher.org/wiki/development/build-instructions)

```bash
git clone --recursive https://github.com/FLEXIY0/BLauncher.git
cd BLauncher
cmake --preset linux       # или windows_msvc / windows_mingw
cmake --build --preset linux --config Release
```

---

## Обратная связь

- 🐛 Баги и предложения → [Issues](https://github.com/FLEXIY0/BLauncher/issues)
- 📦 Релизы → [Releases](https://github.com/FLEXIY0/BLauncher/releases)
- 💬 Обсуждения → [Discussions](https://github.com/FLEXIY0/BLauncher/discussions)

Проект обновляется по требованиям из Issues — создавай запрос, и он будет рассмотрен.

---

## Лицензия

GPL-3.0 — см. [LICENSE](LICENSE)

Основан на [Prism Launcher](https://github.com/PrismLauncher/PrismLauncher) и [ElyPrismLauncher](https://github.com/ElyPrismLauncher/ElyPrismLauncher).
