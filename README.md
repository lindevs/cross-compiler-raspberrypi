# Raspberry Pi Cross-Compiler

Raspberry Pi cross-compiler toolchain which contains:

| Name     | Version |
|:---------|:--------|
| GCC      | 14.2.0  |
| glibc    | 2.41    |
| Binutils | 2.44    |
| GDB      | 10.2    |

## Supported OS

* Host OS: any x64 Linux machine
* Target OS: Raspberry Pi OS Trixie 64-bit

## Usage

* Clone repository:

```shell
git clone https://github.com/lindevs/cross-compiler-raspberrypi.git && cd cross-compiler-raspberrypi
```

* Build Docker image:

```shell
docker build -t cross-pi-gcc docker
```

* Build cross-compiler toolchain:

```shell
docker run -it --rm -v ./:/app cross-pi-gcc build.sh
```

**Note:** The `cross-gcc-14.2.0-pi_64.tar.gz` file will be saved to `build` directory.
