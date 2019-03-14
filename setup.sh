sudo apt-get update
sudo apt-get install -y build-essential \
  python-dev \
  python3-dev \
  virtualenv

virtualenv --python=/usr/bin/python3 ~/py36
. ~/py36/bin/activate

pip install pdfminer.six
