# GenerateModule 

GenerateModule.sh script uses Sourcery to generate empty module, it requires two params:  

- `Module name`
- `Output path`

---

### How to install?

Install Sourcery using Homebrew `brew install sourcery`
For more information visit [Sourcery GitHub page](https://github.com/krzysztofzablocki/Sourcery).

### How to use?

- Launch terminal
- cd to scripts folder
- Execute script with needed arguments, example: `sh GenerateModule.sh  -o '../Frontend' -n SignIn`

This example adds ampty module `SignIn` to `Frontend` folder.

---

# GenerateMock

GenerateMock.sh script uses Sourcery to generate mock for specifi protocol from module, it requires three params:  

- `Output path`
- `Source path`
- `Output file name`

---

### How to install?

Install Sourcery using Homebrew `brew install sourcery`
For more information visit [Sourcery GitHub page](https://github.com/krzysztofzablocki/Sourcery).

### How to use?

- Launch terminal
- cd to scripts folder
- Execute script with needed arguments, example: `sh GenerateMock.sh  -o '../FrontendTests/Onboarding/Onboarding+Signup' -s '../Frontend/Onboarding' -f 'Onboarding+Signup+Model+Mock'`

Upper example creates `Onboarding+Signup+Model+Mock.swift` file in location specified by `-o` option, the `-s` option describes the source directory, it should refer to a directory containing one module. Sourcery will scan files in source directory, find the interface protocol, and generate a proper mock for it.

---
