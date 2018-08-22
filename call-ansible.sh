#!/usr/bin/env bash
set -eux
set -o pipefail
SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)
source $SCRIPT_DIR/common.sh

if [ -e $SCRIPT_DIR/.env ]; then
  source .env
else
  echo sudo 用のパスワードを入力してください
  read -s ANSIBLE_SUDO_PASS
  echo ANSIBLE_SUDO_PASS=$ANSIBLE_SUDO_PASS >> .env
fi

pushd $SCRIPT_DIR/ansible
trap 'popd' EXIT

date >> $SCRIPT_DIR/setup.log;
ansible-playbook -v -i arch-hosts.yml arch-setup.yml -e ansible_sudo_pass=$ANSIBLE_SUDO_PASS | \
tee -a $SCRIPT_DIR/setup.log

date >> $SCRIPT_DIR/user-prefs.log;
ansible-playbook -v -i arch-hosts.yml arch-user-prefs.yml | \
tee -a $SCRIPT_DIR/user-prefs.log

echo_info Press enter to continue...
read
