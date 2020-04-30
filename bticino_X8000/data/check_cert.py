import subprocess
import sys
import os
from pathlib import Path
dns=sys.argv[1]
def find_cert():
    try:
       certs = []
       for path in Path('/ssl/').rglob('fullchain.pem'):
           ps = subprocess.Popen(["openssl", "x509", "-noout", "-text", "-in", str(path)], stdout=subprocess.PIPE)
           output = subprocess.check_output(["grep", "-i", "DNS"], stdin=ps.stdout)
           if dns in str(output):
              certs.append(path)
       system_cert = max(certs, key=os.path.getctime)
       system_cert_path = os.path.dirname(system_cert)
       ps = subprocess.Popen(["openssl", "x509", "-noout", "-modulus", "-in", str(system_cert)], stdout=subprocess.PIPE)
       md5_cert = subprocess.check_output(["openssl", "md5"], stdin=ps.stdout)
       for key in Path(os.path.dirname(system_cert)).rglob('privkey.pem'):
           ps = subprocess.Popen(["openssl", "rsa", "-noout", "-modulus", "-in", str(key)], stdout=subprocess.PIPE)
           md5_key = subprocess.check_output(["openssl", "md5"], stdin=ps.stdout)
           if md5_key == md5_cert:
              system_key = key
       print(system_cert, system_key)
       return(system_cert, system_key)
    except:
       pass
find_cert()
