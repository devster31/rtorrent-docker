# Alpine rTorrent

## abuild-keygen
In order to sign packages built and avoid `--allow-untrusted` in the `apk add`
command the following can be run:

```shell
docker run -it --rm \
    -e PACKAGER="Name Last <email@mail.x>" \
    -v $(pwd)/abuild:/root/.abuild alpine \
    sh -c "apk add -U alpine-sdk && abuild-keygen -a -i -n"
```

## rTorrent option
The image comes with `-n -o system.daemon.set=true` and to pass additional
options the suggested way is to use the `RTORRENT_OPTS` env variable combined
with a volume mounting the configuration.
This is just a `docker-compose` example:

```yml
services:
  rtorrent:
    ...
    environment:
      - "RTORRENT_OPTS=-o import=/config/rtorrent.rc"
    ...
```

## Tmux config
The following can be added in case one wishes to use `tmux` to run rTorrent
ncurses interface.

```dockerfile
RUN git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm \
    && printf "\
# List of plugins\
set -g @plugin 'tmux-plugins/tpm'\
set -g @plugin 'tmux-plugins/tmux-sensible'\
\
# remap prefix to Control + a\
set -g prefix C-a\
# bind 'C-a C-a' to type 'C-a'\
bind C-a send-prefix\
unbind C-b\
\
# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)\
run '~/.tmux/plugins/tpm/tpm'" \
>> ~/.tmux.conf \
    && ~/.tmux/plugins/tpm/scripts/install_plugins.sh
```

## HTTPD
In Alpine the default Apache user is:
```
apache:apache
100:101
group exists for www-data, with GID 82
```
while in the `httpd:alpine` container the default user is:
```
www-data:www-data
82:82
```