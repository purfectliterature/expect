@ECHO OFF

REM
REM    Copyright 2020 Phillmont Muktar
REM
REM    Licensed under the Apache License, Version 2.0 (the "License");
REM    you may not use this file except in compliance with the License.
REM    You may obtain a copy of the License at
REM
REM        http://www.apache.org/licenses/LICENSE-2.0
REM
REM    Unless required by applicable law or agreed to in writing, software
REM    distributed under the License is distributed on an "AS IS" BASIS,
REM    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
REM    See the License for the specific language governing permissions and
REM    limitations under the License.

set HOST=localhost
set PORT=8000
set VERSION=0.2.41

echo Expect version %VERSION%

if /i "%1" neq "silent" (
    if /i "%1" equ "apk" (
        set BUILD=apk
    ) else (
        if /i "%1" equ "app-bundle" (
            set BUILD=app-bundle
        ) else (
            echo [91mUnrecognised input parameter(s^).[0m
            goto :EOF
        )
    )

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
    choice /c yn /N /M "Ready to build %1? (y/n) "
    if errorlevel 2 goto :EOF
) else (
    if /i "%2" equ "apk" (
        set BUILD=apk
    ) else (
        if /i "%2" equ "app-bundle" (
            set BUILD=app-bundle
        ) else (
            echo [91mUnrecognised input parameter(s^).[0m
            goto :EOF
        )
    )
)

echo:
echo [93m[1] Exporting your Expo app to [1mdist[0m[0m
call expo export --public-url https://%HOST%:%PORT% --dev

echo:
echo [93m[2] Starting Experse [1m(don't close the opened minimised window!)[0m[0m
start /min cmd.exe /c "title Experse & py .expect\experse\experse.py %HOST% %PORT%"

echo:
echo [93m[3] Verifying connection to https://%HOST%:%PORT%[0m
curl --insecure https://%HOST%:%PORT% --silent -o nul

if errorlevel 9009 call :OK
if errorlevel 7 echo [91m    Connection cannot be established.[0m & goto :EOF

:OK
echo [92m    Connection is okay![0m

echo:
echo [93m[4] Starting Android build in WSL with turtle-cli[0m
echo     This might take 15 minutes. Sit back and enjoy!
wsl export NVM_DIR=^"$HOME/.nvm^";^
[ -s ^"$NVM_DIR/nvm.sh^" ] ^&^& \. ^"$NVM_DIR/nvm.sh^";^
[ -s ^"$NVM_DIR/bash_completion^" ] ^&^& \. ^"$NVM_DIR/bash_completion^";^
source .expect/config.txt;^
export EXPO_ANDROID_KEYSTORE_PASSWORD=$KEYSTORE_PASSWORD;^
export EXPO_ANDROID_KEY_PASSWORD=$KEY_PASSWORD;^
export NODE_TLS_REJECT_UNAUTHORIZED=0;^
turtle build:android --type %BUILD% --keystore-path ^".expect/$KEYSTORE_PATH^" --keystore-alias ^"$KEYSTORE_ALIAS^" --public-url https://%HOST%:%PORT%/android-index.json

echo:
echo [93m[5] Cleaning up[0m
taskkill /f /fi "WINDOWTITLE eq Experse*"
taskkill /f /fi "WINDOWTITLE eq Experse*"

echo:
echo [92mExpect processes has finished. Hope you get what you expected![0m
