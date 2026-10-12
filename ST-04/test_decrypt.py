from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.primitives import padding
import hashlib

case_name = 'YOUR_DISCOVERED_CLUE'

# TODO: Reconstruct the key derivation from the incident notes.
key = b''

with open('incident_archive.enc', 'rb') as f:
	data = f.read()

iv = data[:16]
ciphertext = data[16:]

cipher = Cipher(algorithms.AES(key), modes.CBC(iv))
decryptor = cipher.decryptor()

padded_plaintext = decryptor.update(ciphertext) + decryptor.finalize()

unpadder = padding.PKCS7(128).unpadder()
plaintext = unpadder.update(padded_plaintext) + unpadder.finalize()

with open('recoverd_report.txt', 'wb') as f:
	f.write(plaintext)

print('Decryption successful.')

