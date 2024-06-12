#whisper

to run debug create a `launch.json` file:

```
{
    "version": "0.0.1",
    "configurations": [
      {
        "name": "Flutter",
        "request": "launch",
        "type": "dart",
        "program": "lib/main.dart",
        "args": [
          "--dart-define",
          "WHISPERKEY=your_api_key_here"
        ]
      }
    ]
  }
```
#IMPORTANT
then add `launch.json` to your `gitignore` file 




##RELEASE COMMAND

To build release for Android run :

`flutter build apk --dart-define=WHISPERKEY=your_api_key_here
`

To build release for iOS run :

`flutter build ios --dart-define=WHISPERKEY=your_api_key_here`

To build using CI/CD e.g CodeMagic:

add `--dart-define=WHISPERKEY=your_api_key_here` to build argument

`WHISPERKEY` is not commited to github or stored in code for security reasons





