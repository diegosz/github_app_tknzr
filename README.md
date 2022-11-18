# github_app_tknzr

`github_app_tknzr` is a command-line tool to retrieve a Github Apps Installation Token.

It's forked from [go-github-apps](https://github.com/nabeken/go-github-apps).

Github provides several ways to issue tokens, for example:

- **Personal Access Token via machine-user**: Before Github Apps exists, this is typical method to issue a token but it consumes one user seats.
- **Github Apps**: This is a new and recommended way. The problem is [it's not that easy to issue a token](https://docs.github.com/en/developers/apps/authenticating-with-github-apps#authenticating-as-a-github-app) just to automate small stuff.

This command-line tool allows you to get a token with just providing `App ID`, `Installation ID` and the private key.

## Usage

```sh
Usage of github_app_tknzr:
  -app-id int
    	App ID
  -export
    	show token as 'export GITHUB_TOKEN=...'
  -inst-id int
    	Installation ID
```

**Example**:

```sh
export GITHUB_PRIV_KEY=$(cat your-apps-2020-08-07.private-key.pem)
eval $(github_app_tknzr -export -app-id 12345 -inst-id 123456)

# github token is now exported to GITHUB_TOKEN environment variable
```

## Installation

https://github.com/diegosz/github_app_tknzr/releases

## Installation for continuous integration

`install-via-release.sh` allows you to grab the binary into the current working directory so that you can easy integrate it into your pipiline.

**Example**:

```sh
curl -sSLf https://raw.githubusercontent.com/diegosz/github_app_tknzr/master/install-via-release.sh | bash -s -- -v v0.1.0
sudo cp github_app_tknzr /usr/local/bin
```

## Github Actions

You can automate issuing a token with Github Actions.

Example:

```yml
- name: Generated GitHub Token
  uses: diegosz/github_app_tknzr@v0
  id: github_app_tknzr
  with:
    app_id: ${{ secrets.app_id }}
    installation_id: ${{ secrets.installation_id }}
    private_key: ${{ secrets.private_key }}

- name: Test Github API call
  run: |
    curl -s --fail -H 'Authorization: Bearer ${{ steps.github_app_tknzr.outputs.github_app_token }}' https://api.github.com/
```

## AppID and Installation ID

`app ID` is the GitHub App ID.

You can check as following:
Settings > Developer > settings > GitHub App > About item

`installation ID` is a part of WebHook request.

You can get the number from the installed app:
Settings > Developer > settings > GitHub Apps > Select the app
Install App > Select the organization wanted
Copy the Installation ID from the URL

For Example: https://github.com/owner/repo/settings/installations/12345678

Installation ID is `12345678`
