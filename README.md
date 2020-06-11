# Expect
Expect is a simple Windows script written in Batch for automating the build of Expo apps to APK for quick testing.

>Expect can easily be extended to support building into app bundles and iOS IPAs (by writing a Shell script). At this stage, 
>Expect is still in early production stage and currently supports building to APK only.

## Integrating Expect
All you need to do to integrate Expect is run the following command from a Command Prompt in your Expo project directory:
```batch
curl -o setup.bat -s https://raw.githubusercontent.com/purfectliterature/expect/master/setup.bat & setup
```
If you have previously set up a local Expo build environment on your computer, then all you need to do after invoking the above command is to **copy over your `keystore.jks`** into `.expect` and provide the keystore's credentials in `config.txt` in `.expect`.

Otherwise, read on.

## Setting up a local Expo build environment
The following instructions were adopted from [Expo's article](https://docs.expo.io/distribution/turtle-cli/). At any time, these 
instructions may be outdated. If that happens, consult the article and make the necessary adaptations to these instructions.

These steps need only be performed **once**. So, bear with me here :)
### Pre-requisites
1. `expo-cli` on your Windows machine (obviously?)
2. Python 3.x on your Windows machine. You can get the latest distribution [here](https://www.python.org/downloads/).
3. Windows Subsystem for Linux set up with **`bash`** on your Windows machine.
4. Node.js set up with [Node Version Manager (`nvm`)](https://github.com/nvm-sh/nvm) on your **WSL distro**.
5. `turtle-cli` installed on your WSL distro. Invoke `npm install -g turtle-cli`. Don't use Yarn!
6. `expo-cli` installed on your WSL distro. Invoke `npm install -g expo-cli`. You can use Yarn if you want.
7. [Java Development Kit 8](https://www.oracle.com/java/technologies/javase/javase-jdk8-downloads.html) on your WSL distro.  
Note that Android only supports Java 8. Any other Java versions **will not work**.

### Instructions
1. You first need to create a **keystore**.  
It is recommended to use Android Studio for this. Open up Android Studio and create an empty project. Go to Build > Generate Signed Bundle > APK. Choose APK, Next, and then click on *Create new...*. Fill the form and save the `keystore.jks` to `.expect` (or somewhere else first).
2. Then, you need to set up [Turtle CLI](https://github.com/expo/turtle) for building APKs.  
Open Bash on Ubuntu and invoke the following command: `turtle setup:android --sdk-version <your Expo SDK version>`. You can find your Expo SDK version from `package.json`. See the version of the `"expo"` package. For example: `turtle setup:android --sdk-version 37.0.3`. This will take a while. **Ensure that JDK 8 has been configured before invoking this command**.
>Building with `turtle-cli` will only work on Unix-based machines. Therefore, you **need** `bash` to locally build Expo apps. This step will set up Android SDK and Gradle on your WSL distro for Turtle CLI to build Android packages.
Once the process finishes, you are good to go!

## Setting Expect up for your project
After invoking the above setup command, you will have an `.expect` folder. Ideally, this folder **should never** be commited to your
source control. The setup script automatically adds `.expect` to your `.gitignore` file. This behaviour is due to the fact that
intrinsically, Expect is just a build tool, and not really a part of your project. Moreover, it contains `config.txt` and your
`keystore.jks` that should **always** be kept secret.

In this folder, you will find a `config.txt` file with instructions commented in them with hashes (`#`). Open it up and provide
the credentials accordingly (your keystore file name, alias, keystore password, and key password).

### Set up a build script with Expect
You can add Expect as a build script to your package manager. Add `.expect/expect` to `scripts` in `package.json` as follows:
```json
...
  "scripts": {
    "start": "expo start",
    "android": "expo start --android",
    "ios": "expo start --ios",
    "web": "expo start --web",
    "eject": "expo eject",
    "build:android": ".expect/expect"
  },
...
```
You can choose whatever script name you want. Then, you can simply build by invoking `npm build:android` or `yarn build:android`.

**NOTE THAT** by default, Expect will print out a reminder of pre-requisites and prompt you if you are ready to build. If you have
set everything up and want to build seamlessly, you can suppress this message by adding `.expect/expect silent` as the build script.
>Expect supports the `silent` argument to suppress pre-requisites messages.

## How does Expect work?
Since Turtle CLI only works if your Expo app has been published to a server, Expect works by publishing your Expo app to a local server
and building your Expo app with `turtle-cli` from that local server as well. This server is called **Experse** and I have included
the SSL certificates in `experse` (the `cert.pem` and `key_unencrypted.pem` files). If these certificates were to expire, you can generate
a new SSL certificate by invoking the following commands:
```bash
$ openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -days 365
$ openssl rsa -in key.pem -out key_unencrypted.pem
```
to get a new pair of `.pem` files that will work for another year with Experse. Replace the expired `.pem` files in `experse` with
the new ones.
>Turtle CLI only works with HTTPS servers. Therefore, Experse has to have these SSL certificates to work. Note that these certificates
>are **self-signed** and will never work for deployment. These certificates are purely for local testing and development only.
