#!/bin/bash

# 1. Recria os wrappers corrigindo a checagem do Linker Script
cat << 'WRAPPERS' > ./fake-gcc
#!/bin/bash
if [[ "$*" == *".lds.S"* ]]; then
    # Para o script do linker, passamos a FPU também para evitar o erro de ABI conflitante
    exec arm-linux-musleabihf-gcc -march=armv7-a -mfpu=vfpv4 -mfloat-abi=hard -D__LINUX_ARM_ARCH__=7 "$@"
else
    # Para os arquivos normais .c
    exec arm-linux-musleabihf-gcc -march=armv7-a -mfpu=vfpv4 -mfloat-abi=hard -D__LINUX_ARM_ARCH__=7 "$@"
fi
WRAPPERS
chmod +x ./fake-gcc

cat << 'WRAPPERS' > ./fake-as
#!/bin/bash
exec arm-linux-musleabihf-as -march=armv7-a -mfpu=vfpv4 "$@"
WRAPPERS
chmod +x ./fake-as

# 2. Executa o build em thread única para garantir que passe limpo por aqui
echo "Iniciando build corrigido para o Linker Script..."
make ARCH=arm \
     CROSS_COMPILE=arm-linux-musleabihf- \
     CC="$(pwd)/fake-gcc" \
     AS="$(pwd)/fake-as" \
     LD="arm-linux-musleabihf-ld" \
     zImage dtbs

