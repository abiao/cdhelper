echo "RSAAuthentication yes" >> /etc/ssh/sshd_config
echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config
echo "AuthorizedKeysFile     .ssh/authorized_keys" >> /etc/ssh/sshd_config
ssh-keygen -t rsa -P '' << EOD

EOD
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

USER=root
SERVER=192.168.1.106
scp  ~/.ssh/id_rsa.pub $USER@$SERVER: <<EOD
mlnsoft123
EOD

ssh $USER@$SERVER "cat ~/id_rsa.pub >> ~/.ssh/authorized_keys"
ssh $USER@$SERVER "chmod 600 ~/.ssh/authorized_keys"
