#move to home directory
cd ~

#prompt user for system
read -p '
----------------------------------
| What is your system?           |
|                                |
| Ubuntu or Debian: 1            |
| Fedora: 2                      |
| Other/ Exit: Q                 |
----------------------------------

(1/2/q): ' systemChoice

#set package manager based on user choice
case "$systemChoice" in
    1)
        packageMan="apt"
        echo "==> Using apt as package manager."
        ;;
    2)
        packageMan="dnf"
        echo "==> Using dnf as package manager."
        ;;
    [qQ]*)
        echo "==> Exiting..." 
        exit 0
        ;;
    *)
        echo "==> Invalid choice. Exiting..."
        exit 1
        ;;
esac

#install git if not installed
if ! command -v git &> /dev/null
then
    echo "==> git could not be found, installing..."
    sudo $packageMan install git -y
else
    echo "==> git is already installed."
fi

#install gnome-tweaks if not installed
if ! command -v gnome-tweaks &> /dev/null
then
    echo "==> gnome-tweaks could not be found, installing..."
    sudo $packageMan install gnome-tweaks -y
else
    echo "==> gnome-tweaks is already installed."
fi

#install gnome extension manager
echo "==> Installing GNOME Extension Manager..."
flatpak install -y com.mattjakeman.ExtensionManager

#install user themes gnome extension
echo "==> Installing User Themes GNOME extension..."
gdbus call --session \
    --dest org.gnome.Shell.Extensions \
    --object-path /org/gnome/Shell/Extensions \
    --method org.gnome.Shell.Extensions.InstallRemoteExtension \
    "user-theme@gnome-shell-extensions.gcampax.github.com"
gnome-extensions enable "user-theme@gnome-shell-extensions.gcampax.github.com"

#clone mitsugen-installer if not in current directory so that the one-liner works
if [ ! -d "mitsugen-installer" ]; then
    echo "==> Cloning mitsugen-installer repository..."
    git clone https://github.com/parryo02/mitsugen-installer
fi

#move to cloned installer directory
cd mitsugen-installer

#clone mitsugen if not in current directory
if [ ! -d "mitsugen" ]; then
    echo "==> Cloning mitsugen repository..."
    git clone https://github.com/DimitrisMilonopoulos/mitsugen
else
    echo "==> mitsugen directory already exists."
fi

cd mitsugen

#make mitsugen install executable
chmod +x install.sh

#install dependencies
echo "==> Installing dependencies..."
if [ "$packageMan" = "dnf" ]; then
sudo dnf install -y \
        python3-gobject python3-devel cairo-devel \
        gobject-introspection-devel libadwaita-devel \
        pkg-config gcc pip
elif [ "$packageMan" = "apt" ]; then
    sudo apt update && sudo apt upgrade -y &&  sudo apt install -y \
        python3-gi python3-dev libcairo2-dev \
        libgirepository1.0-dev libadwaita-1-dev \
        pkg-config build-essential python3-pip
fi

#install poetry if not installed
if ! command -v poetry &> /dev/null; then
    echo "==> poetry could not be found, installing..."
    curl -sSL https://install.python-poetry.org | python3 -
else
    echo "==> poetry is already installed."
fi

#add poetry to path
export PATH="$HOME/.local/bin:$PATH"

#install papirus icon theme
echo "==> Installing Papirus icon theme..."
wget -qO- https://git.io/papirus-icon-theme-install | env DESTDIR="$HOME/.icons" sh

#install papirus-folders
echo "==> Installing papirus-folders..."
wget -qO- https://git.io/papirus-icon-theme-install | env DESTDIR="$HOME/.icons" sh

#get mitsugen featured wallpaper
echo "==> Downloading Mitsugen featured wallpaper..."
wget -O "$HOME/Pictures/mitsugen-wallpaper.jpg" https://w.wallhaven.cc/full/1j/wallhaven-1j7z19.jpg

#apply mitsugen wallpaper
echo "==> Setting Mitsugen wallpaper..."
gsettings set org.gnome.desktop.background picture-uri "file://$HOME/Pictures/mitsugen-wallpaper.jpg"
gsettings set org.gnome.desktop.background picture-uri-dark "file://$HOME/Pictures/mitsugen-wallpaper.jpg"

#patch pyproject.toml to allow different python versions
echo "==> Adjusting Python version constraints for compatibility..."
sed -i 's/python = "^3.10"/python = ">=3.10,<4.0"/' pyproject.toml

#enable system packages poetry
echo "==> Configuring Poetry to use system site packages..."
poetry config virtualenvs.options.system-site-packages true

#install mitsugen dependencies with poetry
echo "==> Installing Mitsugen dependencies with Poetry..."
poetry install --no-root

#install mitsugen
echo "==> Installing Mitsugen..."
./install.sh

#Create local font directory
echo "==> Creating local font directory..."
mkdir -p "$HOME/.local/share/fonts"

#Install Google fonts from Assets
echo "==> Installing Google Sans font..."
sudo cp -r Assets/GoogleSans/fonts/GoogleSans /usr/share/fonts/

echo "==> Installing Google Sans Code font..."
sudo cp -r Assets/GoogleSansCode/fonts/GoogleSansCode /usr/share/fonts/

echo "==> Installing Google Sans Flex font..."
sudo cp -r Assets/GoogleSansFlex/fonts/GoogleSansFlex /usr/share/fonts/

#Update font cache
echo "==> Updating font cache..."
sudo fc-cache -fv

#Apply Google Flex font
echo "==> Applying Google Sans Fonts..."
gsettings set org.gnome.desktop.interface font-name "Google Sans 11"
gsettings set org.gnome.desktop.interface document-font-name "Google Sans 11"
gsettings set org.gnome.desktop.interface monospace-font-name "Google Sans Code 11"

