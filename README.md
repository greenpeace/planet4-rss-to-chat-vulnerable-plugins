# Greenpeace Planet4 Backup Docker Container

![Planet4](./planet4.png)

## Introduction

### What is it?
This repository contains the a small php application that reads an rss of vulnerable wordpress plugins and posts notifications in RocketChat and GoogleChat.

## How to build it

### In circleCI
Any git commit will create a new version of the docker image, tagged with the circleCI build number and "latest".

The docker image that gets build will then be pushed to the docker hub repository: [greenpeaceinternational/planet4-vulnerable-plugins-rss](https://hub.docker.com/r/greenpeaceinternational/planet4-vulnerable-plugins-rss)

### Locally
Run `make dev`

## How it works
- All the logic is in the file rss.php
- It reads the rss from https://wpvulndb.com/feed.xml
- It reads the CircleCI env variables for the webhook urls of RocketChat and Google Hangout chat
- It reads the timestamp of the last item it has posted from an env variable in CirlceCI
- If the posts from the RSS are newer, it posts them in the expected format to the webhook curl_setopt_array
- It updates the circleCI env variable with the latest timestamp (so that it does not post again the same things)


## Contribute

Please read the [Contribution Guidelines](https://planet4.greenpeace.org/handbook/dev-contribute-to-planet4/) for Planet4.
