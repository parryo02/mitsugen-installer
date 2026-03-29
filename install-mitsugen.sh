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

case "$systemChoice" in
    1)
        packageMan="apt"
        ;;
    2)
        packageMan="dnf"
        ;;
    [qQ]*)
        echo "Exiting..." 
        exit 0
        ;;
    *)
        echo "Invalid choice. Exiting..."
        exit 1
        ;;
esac

#test above code
echo $systemChoice

#install git if not installed
#maybe apt list --installed | grep git

#clone mitsugen if not in current directory
if (ls mitsugen returns file not found)
    git clone https://github.com/DimitrisMilonopoulos/mitsugen
fi