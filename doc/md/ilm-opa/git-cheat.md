# GIT-CHEAT

Use these cmd's to get 

## get the last msg 

```sh

export GIT_MSG=$(git log -1 --pretty=format:"%s"); echo "export GIT_MSG=\"$GIT_MSG\""|xclip -selection clipboard
```
than paste with Ctrl+V , than just with alt+backspace


to add all WITHOUT ammend
```sh
git add --all ; git commit -m "$GIT_MSG" --author "$GIT_USER_NAME <$GIT_USER_EMAIL>" 
```


to add all with ammend
```sh
git add --all ; git commit -m "$GIT_MSG" --author "$GIT_USER_NAME <$GIT_USER_EMAIL>" --amend
```
