# Mission 13 - Can We Trust the File?

**Remote observations:** The original checksum was 7e8320091ff5b18af4c4b21db8c2bd0bbbadabe170236c86d98c433886d88dfc; sha256sum -c reported OK. After appending the test change, the digest was bbd7b221e620b35e51bda162276e595fb24263fb3312b327cae37403ac840016 and verification reported FAILED.

The digest changes when contents change. A hash alone does not identify who created a file. Integrity means data matches a reference; authenticity concerns source/identity. If an attacker can change both file and expected digest, this simple check can be defeated, so protect the baseline (for example, separate trusted control or signatures).

Source: aggregate remote run, M13 section. These are the captured run values.
