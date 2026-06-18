# ZFS для РЕД ОС

Инструкции по установке и настройке ZFS на РЕД ОС (RED OS).

## Требования

- РЕД ОС 7.3 или новее
- Ядро Linux 5.15 или новее
- Права суперпользователя (root)

## Быстрая установка

```bash
sudo bash install.sh
```

Скрипт автоматически:
- Установит необходимые зависимости через `dnf`
- Загрузит модуль ядра ZFS
- Включит все необходимые системные службы
- Добавит ZFS в автозагрузку модулей

## Ручная установка

### 1. Установка зависимостей

```bash
sudo dnf install -y kernel-devel libuuid-devel libblkid-devel \
    libattr-devel openssl-devel python3-devel dkms
```

### 2. Сборка из исходников

```bash
./autogen.sh
./configure
make -j$(nproc)
sudo make install
```

### 3. Загрузка модуля

```bash
sudo modprobe zfs
echo "zfs" | sudo tee /etc/modules-load.d/zfs.conf
```

### 4. Включение служб

```bash
sudo systemctl enable --now zfs-import-cache zfs-mount zfs-zed zfs.target
```

## Создание первого пула

```bash
# Простой пул на одном устройстве
sudo zpool create mypool /dev/sdb

# RAID-Z1 (аналог RAID-5)
sudo zpool create mypool raidz /dev/sdb /dev/sdc /dev/sdd

# Проверить состояние
sudo zpool status
```

## Поддержка

При возникновении проблем обратитесь в репозиторий: https://github.com/novad-core/zfs
