# My Dotfiles

## One-Liner for system setup

Once `sudo` is activated:

```
DIR=.dotfiles.$(date +%s) && \
mkdir $DIR && \
(cd $DIR; wget https://github.com/dkorolev/dotfiles/archive/refs/heads/main.zip) &&
(cd $DIR; unzip main.zip) &&
./$DIR/dotfiles-main/dkorolev_setup_system.sh &&
(rm -rf $DIR)
```

## More

Please refer to the [NOTES](https://github.com/dkorolev/dotfiles/blob/main/NOTES.md) for deeper details.
