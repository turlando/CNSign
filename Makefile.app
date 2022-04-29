PKCS11-TOOL=pkcs11-tool
OPENSSL=openssl3

KEY_ID=01
SIGN=file.txt

certificate.der:
	$(PKCS11-TOOL) -r -y cert -d $(KEY_ID) --login -o $@

certificate.pem: certificate.der
	$(OPENSSL) x509 -inform der -in $< > $@

$(SIGN).p7m: $(SIGN) certificate.pem
	OPENSSL_CONF=openssl.cnf    \
	    openssl3 cms            \
	    -nosmimecap -md sha256  \
	    -nodetach -binary       \
	    -cades                  \
	    -stream                 \
	    -outform DER            \
	    -sign                   \
	    -signer certificate.pem \
	    -inkey $(KEY_ID)        \
	    -keyform engine         \
	    -in $<                  \
	    -out $@                 \
	    -engine pkcs11

.PHONY: sign
sign: $(SIGN).p7m
