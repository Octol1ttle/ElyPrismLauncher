<p align="center">
    <img width="503" height="185" alt="image-removebg-preview(1)" src="https://github.com/user-attachments/assets/250be340-02f6-40df-8553-42d8de262b1f" />
</p>
<p align="center">
  <a href="https://github.com/FLEXIY0/BLauncher/releases/latest">Скачать</a> · 
  <a href="https://github.com/FLEXIY0/BLauncher/issues">Issues</a> · 
  <a href="https://github.com/FLEXIY0/BLauncher/releases/tag/instances">Сборки</a>
</p>

---

**BLauncher** — форк [Prism Launcher](https://prismlauncher.org), собранный с прицелом на старые и бета-версии Minecraft. Лаунчер работает с офлайн-аккаунтами через Ely.by, не требуя привязки к Microsoft. Скачал, поставил, играешь — без лишних шагов.

Проект в стадии активной разработки. Новые функции и исправления добавляются по запросам из [Issues](https://github.com/FLEXIY0/BLauncher/issues) — если чего-то не хватает, создавай тикет.

---

### Установка

Готовые сборки для Windows и Linux доступны на странице [Releases](https://github.com/FLEXIY0/BLauncher/releases/latest). Для Windows предлагается Setup.exe в классическом стиле и portable-версия в архиве. На Linux — AppImage и portable tar.gz.

Дев-сборки (нестабильные) можно найти во вкладке [Actions](https://github.com/FLEXIY0/BLauncher/actions).

| Платформа | Формат |
|---|---|
| Windows x64 / ARM64 | Setup.exe, Portable .zip |
| Linux x86_64 / aarch64 | AppImage, Portable .tar.gz |

---

### Что внутри

BLauncher наследует весь функционал Prism Launcher — управление инстансами, поддержка Forge, Fabric, Quilt и NeoForge, импорт модпаков с CurseForge и Modrinth, автоматическая установка Java. Поверх этого добавлена авторизация через Ely.by с поддержкой скинов на серверах без специальных плагинов.

---

### Скриншоты

<img width="1576" height="787" alt="изображение" src="https://github.com/user-attachments/assets/2231155c-108b-4804-befd-8fbb27914344" />


---

### Сборка из исходников

Процесс сборки аналогичен оригинальному Prism Launcher. Подробная инструкция — в [документации](https://prismlauncher.org/wiki/development/build-instructions).

```bash
git clone --recursive https://github.com/FLEXIY0/BLauncher.git
cd BLauncher
cmake --preset linux
cmake --build --preset linux --config Release
```

Для Windows используйте пресеты `windows_msvc` или `windows_mingw`.

---

### Лицензия

Код распространяется под лицензией [GPL-3.0](LICENSE).

Основан на [Prism Launcher](https://github.com/PrismLauncher/PrismLauncher) и [ElyPrismLauncher](https://github.com/ElyPrismLauncher/ElyPrismLauncher).
