apt-get install libssl-dev shtool libtool pkg-config autoconf automake
wget https://download.aircrack-ng.org/aircrack-ng-1.2.tar.gz
tar -xzf aircrack-ng-1.2.tar.gz
autoreconf -i
./configure
make
sudo make install
