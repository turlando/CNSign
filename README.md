# CNSign

Sign documents using Italian CNS (Carta Nazionale dei Servizi).

## Prerequisites

The CNS is just an ordinary smart card holding a cryptographic certificate. In
order to use it you will need a smart card reader. Some laptops such as my
ThinkPad X250 might ship with a buil-in reader, otherwise you will need to buy
an USB smart card reader.

The Italian CNS must be activated. Once the smart card has been activated you
will receive PIN, PUK and CIP codes. Refer to you region administrative website
to find out how to activete your CNS.

In Italy it is expected you will sign documents using the CAdES standard, which
is supported in OpenSSL 3. As many distributions still use OpenSSL 1.1 this
package includes a Dockerfile to build an image including all the required software.

## Usage

### Build the Docker container

```
make build
```

#### Make variables

- `DOCKER`: docker-compatible binary (e.g. `podman`). Default: `docker`

### Run the Docker container

```
make DEVICE=/dev/bus/usb/001/002 run
```

#### Make variables

- `DOCKER`: docker-compatible binary (e.g. `podman`). Default: `docker`
- `DEVICE`: path to smart card reader device (e.g. `/dev/bus/usb/001/002`)
- `SHARED`: path to shared folder. Default: `./shared`

You can find the path of your smart card reader using `lsusb`. The path is built
using the bus and device identifiers.

For instance the following example

```
% lsusb
...
Bus 001 Device 002: ID 058f:9540 Alcor Micro Corp. AU9540 Smartcard Reader
...
```

the path is `/dev/bus/usb/001/002`.

### Signing documents

From your host machine you can place files in the shared directory and access
them from `/shared` from within the container.

From within the container in the `/app` directory you can run

`make SIGN=/shared/file_to_sign.txt sign`

It will create a new file `/shared/file_to_sign.txt.p7m`.

Make sure the file name has no spaces. This is a known issue due to make. It will
maybe be fixed in the future.

#### Make variables

- `SIGN`: path to file to sign
- `KEY_ID`: signing certificate identifier. Default: `01`

You can find the signing certificate identifier using `pkcs11-tool`. Just run
`pkcs11-tool -O --login`. A list of data object will be shown. Find the id of
`Certificate Object; type = X.509 cert`.

For instance

```
# pkcs11-tool -O --login
Using slot 0 with a present token (0x0)
Logging in to "NAME SURNAME (PIN CNS0)".
WARNING: user PIN locked
Please enter User PIN:
Private Key Object; RSA 
  label:      CNS0
  ID:         01
  Usage:      sign, unwrap
  Access:     sensitive, always sensitive, never extractable, local
Public Key Object; RSA 1024 bits
  label:      CNS0
  ID:         01
  Usage:      verify, wrap
  Access:     none
Certificate Object; type = X.509 cert
  label:      CNS0
  subject:    DN: C=IT, O=Issuing org, OU=Region, CN=SSN, GN=NAME, SN=SURNAME
  ID:         01    <--- THIS IS WHAT YOU'RE LOOKING FOR
```