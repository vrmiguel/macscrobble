import os
import requests
import hashlib
import json

# Retrieve the API key and secret from environment variables
API_KEY = os.getenv('LASTFM_API_KEY')
API_SECRET = os.getenv('LASTFM_API_SECRET')

if not API_KEY or not API_SECRET:
    raise EnvironmentError("Both LASTFM_API_KEY and LASTFM_API_SECRET environment variables must be set.")

def get_signature(params, api_secret):
    sig_string = ''.join(f'{key}{value}' for key, value in sorted(params.items()))
    sig_string += api_secret
    return hashlib.md5(sig_string.encode('utf-8')).hexdigest()

def get_token(api_key):
    url = 'https://ws.audioscrobbler.com/2.0/'
    params = {
        'method': 'auth.getToken',
        'api_key': api_key,
        'format': 'json'
    }
    response = requests.get(url, params=params)
    data = response.json()
    return data['token']

def get_session_key(api_key, api_secret, token):
    url = 'https://ws.audioscrobbler.com/2.0/'
    params = {
        'method': 'auth.getSession',
        'api_key': api_key,
        'token': token,
    }
    params['api_sig'] = get_signature(params, api_secret)
    params['format'] = 'json'
    response = requests.get(url, params=params)
    data = response.json()
    if 'session' in data:
        return data['session']['key']
    else:
        raise Exception(f"Failed to get session key. Response: {json.dumps(data, indent=2)}")

def main():
    token = get_token(API_KEY)
    print(f'Please authorize the application by visiting this URL: '
          f'http://www.last.fm/api/auth/?api_key={API_KEY}&token={token}')
    input('Press Enter after you have authorized the token...')

    try:
        session_key = get_session_key(API_KEY, API_SECRET, token)
        print(f'Session Key: {session_key}')
    except Exception as e:
        print(e)

if __name__ == '__main__':
    main()