!/bin/sh
# author: wangqiang <cnfreebsd@163.com>
# data: 2015-10-23
# note: vim auto config shell script

# install vim,dos2unix,git
yum install -y vim dos2unix git

# clone vundle
git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle

# create vim backup directory
mkdir ~/.vim/backup

cp vimrc ~/.vimrc

# install BundleInstall
vim <<FORMAT
:BundleInstall
FORMAT

# Convert to Unix Format
dos2unix ~/.vim/bundle/QFixToggle/plugin/qfixtoggle.vim

# Config Code Auto Tips
cd ~/.vim/bundle/YouCompleteMe
 ./install.sh --clang-completer

 cp $HOME/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp/ycm/.ycm_extra_conf.py ~/
