# Discourse Response Bot
This is a <a href="https://www.discourse.org/">Discourse</a> plugin. It works as a bot automatically replying newly created topics within a Discourse forum with a default wiki post. This allows users to collaborate and construct a single answer for topics created.

## Installation

### Docker installation
As seen in a [how-to on meta.discourse.org](https://meta.discourse.org/t/advanced-troubleshooting-with-docker/15927#Example:%20Install%20a%20plugin), add this repository's `git clone` url to your container's `app.yml` file, at the bottom of the `cmd` section:

```yml
hooks:
  after_code:
    - exec:
        cd: $home/plugins
        cmd:
          - mkdir -p plugins
          - git clone https://github.com/bolariin/discourse-response-bot.git
```
rebuild your container:

```
cd /var/discourse
git pull
./launcher rebuild app
```

### Non-docker installation
* Run `bundle exec rake plugin:install repo=https://github.com/bolariin/discourse-response-bot.git` in your discourse directory
* In development mode, run `bundle exec rake assets:clean`
* In production, recompile your assets: `bundle exec rake assets:precompile`
* Restart Discourse

### Local Development Installation
* Clone the [Discourse Response Bot Repo](http://github.com/bolariin/discourse-) in a new local folder.
* Separately clone [Discourse Forum](https://github.com/discourse/discourse) in another local folder and [install Discourse](https://meta.discourse.org/t/beginners-guide-to-install-discourse-on-ubuntu-for-development/14727).
* In your terminal, go into Discourse folder navigate into the plugins folder.  Example ```cd ~/code/discourse/plugins```
* Create a symlink in this folder by typing the following into your terminal
```
ln -s ~/whereever_your_cloned_ad_plugin_path_is .
For example: ln -s ~/discourse-plugin-test .
```
* You can now make changes in your locally held Discourse Response Bot folder and see the effect of your changes when your run ```rails s``` in your locally held Discourse Forum files.

## License
MIT
