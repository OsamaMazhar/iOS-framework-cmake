## How to guide:

### Install Cmake

First install Homebrew using the following command:

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Now install cmake:

```
brew install cmake
cmake --version
```

You should see an output like this:

```cmake version 3.31.6```

### Build C++ Library with ios-cmake toolchain

Now create a folder to build your C++ library, in our case NLOPT, using ios-cmake toolchain.

```
mkdir nlopt_ios && cd nlopt_ios

# Clone the NLOPT repository
git clone https://github.com/stevengj/nlopt.git

# Clone the ios-cmake toolchain
git clone https://github.com/leetal/ios-cmake.git
```

Now build and install the NLOPT library for device (arm64)

```
mkdir build_device && cd build_device

cmake -G Xcode \
    -DCMAKE_TOOLCHAIN_FILE=../ios-cmake/ios.toolchain.cmake \
    -DPLATFORM=OS64 \
    -DCMAKE_INSTALL_PREFIX=../install_device \
    -DCMAKE_CONFIGURATION_TYPES="Release" \
    ../nlopt

cmake --build . --config Release --target install
```
Do the same for building and installing for the simulator (x86_64)

```
cd ..
mkdir build_simulator && cd build_simulator

cmake -G Xcode \
    -DCMAKE_TOOLCHAIN_FILE=../ios-cmake/ios.toolchain.cmake \
    -DPLATFORM=SIMULATOR64 \
    -DCMAKE_INSTALL_PREFIX=../install_simulator \
    -DCMAKE_CONFIGURATION_TYPES="Release" \
    ../nlopt

cmake --build . --config Release --target install
```

The install_device folder should have the following folder structure:

```
include/
├── nlopt.h
└── nlopt.hpp
lib/
├── cmake/
│   └── [CMake configuration files]
├── libnlopt.1.0.0.dylib
├── libnlopt.1.dylib
├── libnlopt.dylib
└── pkgconfig/
    └── [Package configuration files]
share/
└── man/
    └── [Man page files]
```

And similar for the install_simulator folder.

### Creating the Framework file

We will use a script shared in the file `create_nlopt_framework.sh` to convert the compiled library files into a framework for Xcode.

In this script, change the following variables:
```
OUT_DIR="path/to/folder/nlopt_ios/framework"
DYLIB_DEVICE="path/to/file/nlopt_ios/install_device/lib/libnlopt.dylib"
DYLIB_SIMULATOR="path/to/file/nlopt_ios/install_simulator/lib/libnlopt.dylib"
HEADERS_DIR="path/to/folder/nlopt_ios/install/include"
```

We also need to get the codesigning identity to sign the framework. This you can get with the following command:

`security find-identity -v -p codesigning`

You should get a code of around 40 characters. Paste it to the variable `CODESIGN_IDENTITY` in the `create_nlopt_framework.sh` file as follows:

```
CODESIGN_IDENTITY="YOUR Codesign ID"
```

Also make sure to change the `CFBundleIdentifier` key in the `Info.plist` file code inside the `create_nlopt_framework.sh` file.

Set the correct permissions after editing the file and run the file:

```
chmod +x /path/to/nlopt_ios/create_nlopt_framework.sh
/path/to/nlopt_ios/create_nlopt_framework.sh
```

You should now see the framework file in the `nlopt_ios/framework/nlopt.framework` path. Lets verify if we have the succeeded in creating the framework file:

```
cd /path/to/nlopt_ios/framework/nlopt.framework
ls -l
lipo -info nlopt
```

You should see the following in your terminal output:
```
Architectures in the fat file: nlopt are: arm64 x86_64
```
