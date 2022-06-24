# CutiePi stage for building image using pi-gen 

Usage: 

    git clone https://github.com/RPi-Distro/pi-gen -b arm64
    cp stage4.5-cutiepi config -a pi-gen/
    cd pi-gen/
    sudo ./build.sh 


> disable [first boot password prompt](https://github.com/RPi-Distro/pi-gen/commit/95ac3cfb3b223dad058c1aee1d8b6e3f5e5b5935)