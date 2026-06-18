# ZFS — высокопроизводительная файловая система для Linux

ZFS — это надёжная, масштабируемая файловая система и менеджер томов с поддержкой проверки целостности данных, встроенного сжатия, снапшотов и нативного шифрования.

Данный репозиторий содержит форк проекта [OpenZFS](https://openzfs.org) версии 2.3.4, адаптированный для использования в российской инфраструктуре.

## Назначение

ZFS предназначена для использования в качестве основной файловой системы серверного и инфраструктурного оборудования. Ключевые характеристики:

- **Контроль целостности данных** — каждый блок данных защищён контрольной суммой (SHA-256, BLAKE3)
- **Пулы хранения (zpool)** — объединение дисков с поддержкой RAID-Z
- **Снапшоты и клоны** — мгновенные копии файловых систем без копирования данных
- **Нативное шифрование** — AES-256-GCM/CCM на уровне датасета
- **Сжатие** — LZ4, ZSTD, gzip «из коробки»
- **Квоты и резервирование** — гранулярное управление дисковым пространством

## Сборка из исходного кода

### Зависимости (RPM-based дистрибутивы)

```bash
sudo dnf install -y autoconf automake libtool rpm-build \
    kernel-devel libuuid-devel libblkid-devel libattr-devel \
    openssl-devel python3-devel
```

### Зависимости (DEB-based дистрибутивы)

```bash
sudo apt install -y build-essential autoconf automake libtool \
    linux-headers-$(uname -r) uuid-dev libblkid-dev libattr1-dev \
    libssl-dev python3-dev
```

### Сборка

```bash
./autogen.sh
./configure
make -j$(nproc)
sudo make install
```

### Сборка RPM-пакетов

```bash
./autogen.sh
./configure
make rpm
```

## Установка

### Загрузка модулей ядра

```bash
sudo modprobe zfs
```

### Создание пула хранения

```bash
# Пул на одном диске
sudo zpool create mypool /dev/sdb

# RAID-Z1 из трёх дисков
sudo zpool create mypool raidz /dev/sdb /dev/sdc /dev/sdd
```

### Создание зашифрованного датасета

```bash
sudo zfs create -o encryption=aes-256-gcm -o keylocation=prompt \
    -o keyformat=passphrase mypool/secure
```

## Тестирование

Репозиторий содержит более 1100 функциональных тестов:

```bash
cd tests/
sudo ./zfs-tests.sh -v
```

## Документация

- [Журнал изменений](CHANGELOG.ru.md)
- [Описание безопасности](SECURITY.ru.md)
- [Лицензия](LICENSE)

## Ответственный за сопровождение

Контактные данные: [TBD]

## Лицензия

CDDL 1.0 — см. файл [LICENSE](LICENSE).
