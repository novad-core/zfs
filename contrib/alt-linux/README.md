# ZFS для ALT Linux / ALT Server

Инструкции по установке и настройке ZFS на ALT Linux и ALT Server.

## Требования

- ALT Linux 10 или новее / ALT Server 10 или новее
- Ядро Linux 5.15 или новее
- Права суперпользователя (root)

## Быстрая установка

```bash
sudo bash install.sh
```

## Ручная установка

### 1. Установка зависимостей

```bash
sudo apt-get install -y kernel-headers-modules-std-def \
    libuuid-devel libblkid-devel gcc make autoconf automake libtool
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

## Поддержка

https://github.com/novad-core/zfs
