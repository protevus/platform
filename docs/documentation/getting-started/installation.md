# Installation

```py
dart pub global activate artisan
```

## Create a new project

```py
artisan create new_blog
```
!!! warning "Export bin path"
    Please make sure you have included `bin` path to your profile. If you did not added path to your profile yet, open `~/.bashrc` or `~/.zshrc` and paste below line.
    
    ```bash
    export PATH="$PATH":"~/.pub-cache/bin"
    ```

## Create a specific version

```py
artisan create new_blog --version v2.0.0
```

## Or download from github

```py
https://github.com/protevus/sample-app/archive/refs/tags/v2.0.0.zip
```

## Start server

```py
artisan s

or 

bin/artisan s
```

## Start server with docker

```py
docker-compose up -d --build
```

!!! tips
    Ensure that setting `APP_ENV` in `.env` to `development` facilitates server operations with hot reloading during development, while configuring it as `production` ensures compilation into machine code for server deployment.
    
## Watch the builder

```py
dart run build_runner watch 

or 

artisan build_runner:watch
```