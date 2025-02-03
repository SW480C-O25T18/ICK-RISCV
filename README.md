# ICK-RISCV

This is a capstone project at Pennsylvania State University - World Campus for Software Engineering 480/481, for the class of 2025.    
This is a copy of Ironclad, the original code is [here](https://ironclad.nongnu.org).


## Install Packages

```console
sudo apt-get install -y autoconf automake libtool autotools-dev dh-autoreconf
alr get gnatprove
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
- ***if build fails try***:
```bash
sudo make install
```

- confirm installed files:
```bash
ls -l /usr/local/share/ironclad
ls -l /usr/local/share/info
```

