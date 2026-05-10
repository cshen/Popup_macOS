#!/bin/bash

# https://help.ticktick.com/articles/7055781515422072832#show-command

open ticktick://x-callback-url/v1/add_task?title="$@"&x-success={{scheme of next app}}


