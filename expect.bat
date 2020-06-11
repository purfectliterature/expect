@ECHO OFF

set HOST=localhost
set PORT=8000
set VERSION=0.1.22

echo Expect version %VERSION%

if /i "%1" neq "silent" (
    echo:
    echo Before we begin, please ensure that:
    echo - A .jks keystore has been created and set the path, alias, and passwords in [1m[96mconfig.txt[0m[0m
    echo - WSL with Bash has been installed on your Windows machine, and:
    echo   - Node.js has been configured in it with [96mnvm install ^<your Node.js version^>[0m
    echo   - [1m[96mexpo-cli[0m[0m has been installed in it with [96mnpm install -g expo-cli[0m
    echo   - [1m[96mturtle-cli[0m[0m has been installed in it with [96mnpm install -g turtle-cli[0m
    echo   - For Android, you have set up turtle with Expo SDK with [96mturtle setup:android --sdk-version ^<your Expo SDK version^>[0m
    echo:
    echo Build will take approximately 15-20 minutes, so let's leave no room for errors.
    choice /c yn /N /M "Ready to roll? (y/n) "
    if errorlevel 2 goto :EOF
)

echo:
echo [93m[1] Exporting your Expo app to [1mdist[0m[0m
cd ..
call expo export --public-url https://%HOST%:%PORT% --dev
cd .expect

echo:
echo [93m[2] Preparing Experse server from [1mdist[0m[0m
copy /Y experse\experse.py ..\dist\experse.py
copy /Y experse\cert.pem ..\dist\cert.pem
copy /Y experse\key_unencrypted.pem ..\dist\key_unencrypted.pem

echo:
echo [93m[3] Starting Experse [1m(don't close the opened minimised window!)[0m[0m
start /min cmd.exe /c "title Experse & cd ..\dist\ & py ..\dist\experse.py %HOST% %PORT%"

echo:
echo [93m[4] Verifying connection to https://%HOST%:%PORT%[0m
curl --insecure https://%HOST%:%PORT% --silent -o nul

if errorlevel 9009 call :OK
if errorlevel 7 echo [91m    Connection cannot be established.[0m & goto :EOF

:OK
echo [92m    Connection is okay![0m

echo:
echo [93m[5] Starting Android build in WSL with turtle-cli[0m
echo     This might take 15 minutes. Sit back and enjoy!
wsl export NVM_DIR=^"$HOME/.nvm^";^
[ -s ^"$NVM_DIR/nvm.sh^" ] ^&^& \. ^"$NVM_DIR/nvm.sh^";^
[ -s ^"$NVM_DIR/bash_completion^" ] ^&^& \. ^"$NVM_DIR/bash_completion^";^
source config.txt;^
export EXPO_ANDROID_KEYSTORE_PASSWORD=$KEYSTORE_PASSWORD;^
export EXPO_ANDROID_KEY_PASSWORD=$KEY_PASSWORD;^
export NODE_TLS_REJECT_UNAUTHORIZED=0;^
cd ..;^
turtle build:android --type apk --keystore-path $KEYSTORE_PATH --keystore-alias $KEYSTORE_ALIAS --public-url https://%HOST%:%PORT%/android-index.json

echo:
echo [93m[6] Cleaning up[0m
taskkill /f /fi "WINDOWTITLE eq Experse*"
taskkill /f /fi "WINDOWTITLE eq Experse*"
del ..\dist\experse.py
del ..\dist\cert.pem
del ..\dist\key_unencrypted.pem

echo:
echo [92mExpect processes has finished. Hope you get what you expected![0m