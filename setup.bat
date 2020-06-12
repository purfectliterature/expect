@ECHO OFF

echo Welcome to Expect set-up utility!
echo:
echo [93m[1] Cloning expect from the GitHub repository[0m
git clone https://github.com/purfectliterature/expect

echo:
echo [93m[2] Renaming [4mexpect[0m [93mto [4m.expect[0m[0m
rename expect .expect

echo:
echo [93m[3] Cleaning up[0m
del .expect\LICENSE
del .expect\README.md
del .expect\setup.bat

echo:
echo [92mYou are all done! Copy your [1mkeystore.jks[0m [92mto .expect and enter the credentials[0m
echo [92min .expect\[1mconfig.txt[0m [92mto finish setting Expect up. Enjoy![0m

(goto) 2>nul & del "%~f0"