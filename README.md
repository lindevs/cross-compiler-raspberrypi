# Raspberry Pi Cross Compiler

Raspberry Pi cross-compiler toolchain which contains:

| Name     | Version |
|:---------|:--------|
| GCC      | 12.2.0  |
| glibc    | 2.36    |
| Binutils | 2.40    |
| GDB      | 10.2    |

## Supported OS

* Host OS: any x64 Linux machine
* Target OS: Raspberry Pi OS Bookworm 64-bit

## Usage

* Build Docker image:

```shell
docker build -t cross-pi-gcc docker
```

* Build cross-compiler toolchain:

```shell
docker run -it --rm -v ~/out:/out cross-pi-gcc -c build.sh
```

**Note:** The `cross-gcc-12.2.0-pi_64.tar.gz` file will saved to `~/out` directory.
