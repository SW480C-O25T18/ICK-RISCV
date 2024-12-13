# ICK-RISCV

This is a capstone project at Pennsylvania State University - World Campus for Software Engineering 480/481, for the class of 2025.    
This is a copy of Ironclad, the original code is [here](https://ironclad.nongnu.org).


## Install Packages

```console
sudo apt-get update && sudo apt-get install -y autoconf automake perl texinfo gnatprove highlight
```

## Building

- Generate a configure.ac:
```console
./bootstrap
```

- Configure for target machine. Other option is `x86_64-limine-elf`:
```console
./configure --target=riscv64-limine-elf
```

- Build:
```console
make
make check
make install
```

