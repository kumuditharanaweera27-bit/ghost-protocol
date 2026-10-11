from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.primitives import padding
import hashlib
import os

#Incident case name
case_name = 'recovered_case_name'

#Weak key derivation
key = hashlib.sha256(case_name.encode()).digest()

#Generate a random IV
iv = os.urandom(16)

#Read the incident report
with open('incident_report.txt', 'rb') as f:
	plaintext = f.read()

#add PKCS7 padding
padder = padding.PKCS7(128).padder()
padded_data = padder.update(plaintext) + padder.finalize()

#Encrypt using AES-256-CBC
cipher = Cipher(algorithms.AES(key), modes.CBC(iv))
encryptor = cipher.encryptor()
ciphertext = encryptor.update(padded_data) + encryptor.finalize()

#Save IV + ciphertext
with open('incident_archive.enc', 'wb') as f:
	f.write(iv + ciphertext)

print('Encryption complete.')

