: '
================================================================================
 [1] Install & Configure CVMFS based on NeuroDesk guide
================================================================================
'
# Installation of CVMFS
sudo yum install -y redhat-lsb-core # Less dependencies than redhat-lsb
sudo yum install https://ecsft.cern.ch/dist/cvmfs/cvmfs-release/cvmfs-release-latest.noarch.rpm
sudo yum install -y cvmfs

# Configuration of CVMFS
sudo mkdir -p /etc/cvmfs/keys/ardc.edu.au/
echo "-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwUPEmxDp217SAtZxaBep
Bi2TQcLoh5AJ//HSIz68ypjOGFjwExGlHb95Frhu1SpcH5OASbV+jJ60oEBLi3sD
qA6rGYt9kVi90lWvEjQnhBkPb0uWcp1gNqQAUocybCzHvoiG3fUzAe259CrK09qR
pX8sZhgK3eHlfx4ycyMiIQeg66AHlgVCJ2fKa6fl1vnh6adJEPULmn6vZnevvUke
I6U1VcYTKm5dPMrOlY/fGimKlyWvivzVv1laa5TAR2Dt4CfdQncOz+rkXmWjLjkD
87WMiTgtKybsmMLb2yCGSgLSArlSWhbMA0MaZSzAwE9PJKCCMvTANo5644zc8jBe
NQIDAQAB
-----END PUBLIC KEY-----" | sudo tee /etc/cvmfs/keys/ardc.edu.au/neurodesk.ardc.edu.au.pub

echo "CVMFS_USE_GEOAPI=yes" | sudo tee /etc/cvmfs/config.d/neurodesk.ardc.edu.au.conf

echo 'CVMFS_SERVER_URL="http://203.101.231.144/cvmfs/@fqrn@;http://150.136.239.221/cvmfs/@fqrn@;http://132.145.96.34/cvmfs/@fqrn@;http://140.238.170.185/cvmfs/@fqrn@;http://130.61.74.69/cvmfs/@fqrn@;http://152.67.114.42/cvmfs/@fqrn@"' | sudo tee -a /etc/cvmfs/config.d/neurodesk.ardc.edu.au.conf

echo 'CVMFS_KEYS_DIR="/etc/cvmfs/keys/ardc.edu.au/"' | sudo tee -a /etc/cvmfs/config.d/neurodesk.ardc.edu.au.conf

echo "CVMFS_HTTP_PROXY=DIRECT" | sudo tee  /etc/cvmfs/default.local
echo "CVMFS_QUOTA_LIMIT=5000" | sudo tee -a  /etc/cvmfs/default.local

echo "==========================================================="
echo "CVMFS_Config:"
sudo cvmfs_config setup
echo "==========================================================="
# this is only necessary for WSL:
# sudo cvmfs_config wsl2_start

sudo cvmfs_config chksetup

# Test that we can see stuff in the cvmfs file system
ls /cvmfs/neurodesk.ardc.edu.au

sudo cvmfs_talk -i neurodesk.ardc.edu.au host probe
sudo cvmfs_talk -i neurodesk.ardc.edu.au host info

cvmfs_config stat -v neurodesk.ardc.edu.au

:'
================================================================================
 [2] Install GO
  - Used to compile Singularity
  - Using go1.17.6.linux-amd64.tar.gz from https://go.dev/dl/
================================================================================
'

# Set up environment variables for the download
export VERSION=1.17.6
export OS=linux
export ARCH=amd64

# Download & Extract the archive
wget https://dl.google.com/go/go$VERSION.$OS-$ARCH.tar.gz
sudo tar -C /usr/local -xzvf go$VERSION.$OS-$ARCH.tar.gz

# Add to PATH environment variable
echo 'export PATH=/usr/local/go/bin:$PATH'
# >> ~/.bashrc && \ source ~/.bashrc # Adds PATH to .bashrc?

:'
================================================================================
 [3] Download, Build & Compile Singularity
 TODO: Modify as per this post https://stackoverflow.com/a/70852355/8214951
================================================================================
'
export VERSION=3.9.4
# wget https://github.com/sylabs/singularity/releases/download/v${VERSION}/singularity-${VERSION}.tar.gz
wget https://github.com/sylabs/singularity/archive/refs/tags/v${VERSION}.tar.gz
# tar -xzf singularity-${VERSION}.tar.gz
tar -xzf v${VERSION}.tar.gz
# cd singularity
cd singularity-3.9.4

# Add a file called VERSION with the version number in it
echo $VERSION | tee VERSION # Creates a file containing Singularity version no.

./mconfig
make -C builddir
sudo make -C builddir install

:'
================================================================================
 [4] Download & Install lmod
==============================================================================
'
wget http://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
sudo rpm -Uvh epel-release-latest-7.noarch.rpm

sudo yum install lmod
