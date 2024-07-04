# macscrobble (heavily wip)

## Building

### Requirements

1. Xcode Command line tools
    * Install via `xcode-select --install`
2. Python 3
    * Required for initial authentication (temporarily)
3. A Last.fm API account
    * Create one [here](https://www.last.fm/api/account/create)

## Compilation

To compile the scrobbler and produce the macscrobble binary, run:

```shell
make build
```

## Running

To use macscrobble, follow these steps to acquire a Last.fm session key:

### Set environment variables

Export the `LASTFM_API_KEY` and `LASTFM_API_SECRET` environment variables:

```
export LASTFM_API_KEY=your_api_key
export LASTFM_API_SECRET=your_api_secret
```

```
Please authorize the application by visiting this URL: http://www.last.fm/api/auth/?api_key=abc123def456ghi789jkl012mno345pq&token=randomToken12345
Press Enter after you have authorized the token...

Session Key: sk1234567890abcdef1234567890abcdef
```

Export the ovbtained session key and then finally run the scrobbler:

```shell
export SESSION_KEY=sk1234567890abcdef1234567890abcdef

./macscrobble
```
