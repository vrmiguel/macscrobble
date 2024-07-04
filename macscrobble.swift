import Foundation
import MediaPlayer

func getEnvironmentVariable(_ name: String) -> String {
    guard let value = ProcessInfo.processInfo.environment[name] else {
        fatalError("Environment variable \(name) not set")
    }
    return value
}

let apiKey = getEnvironmentVariable("LASTFM_API_KEY")
let apiSecret = getEnvironmentVariable("LASTFM_API_SECRET")
let sessionKey = getEnvironmentVariable("SESSION_KEY")

class MediaNotificationListener: NSObject {    
    override init() {
        super.init()
        setupNotificationListener()
    }
    
    private func setupNotificationListener() {
        let notificationCenter = DistributedNotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(mediaNotificationReceived(_:)),
                                       name: NSNotification.Name("com.spotify.client.PlaybackStateChanged"),
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(mediaNotificationReceived(_:)),
                                       name: NSNotification.Name("com.google.Chrome.playbackState"),
                                       object: nil)
        print("Notification listeners set up.")
    }
    
    @objc private func mediaNotificationReceived(_ notification: Notification) {
        print("Notification received: \(notification.name.rawValue)")
        guard let userInfo = notification.userInfo else {
            print("No user info in notification.")
            return
        }
        
        if notification.name.rawValue == "com.spotify.client.PlaybackStateChanged" {
            handleSpotifyNotification(userInfo: userInfo)
        } else if notification.name.rawValue == "com.google.Chrome.playbackState" {
            handleChromeNotification(userInfo: userInfo)
        }
    }
    
    private func handleSpotifyNotification(userInfo: [AnyHashable: Any]) {
        print("Handling Spotify notification: \(userInfo)")

        guard let trackID = userInfo["Track ID"] as? String,
              let trackName = userInfo["Name"] as? String,
              let artistName = userInfo["Artist"] as? String else {
            print("Missing track info in Spotify notification.")
            return
        }
        
        print("Spotify Track ID: \(trackID), Track Name: \(trackName), Artist: \(artistName)")
        scrobbleToLastFM(trackName: trackName, artistName: artistName)
    }
    
    private func handleChromeNotification(userInfo: [AnyHashable: Any]) {
        print("Handling Chrome notification: \(userInfo)")
        guard let trackName = userInfo["track"] as? String,
              let artistName = userInfo["artist"] as? String else {
            print("Missing track info in Chrome notification.")
            return
        }
        
        print("Chrome Track Name: \(trackName), Artist: \(artistName)")
        scrobbleToLastFM(trackName: trackName, artistName: artistName)
    }
    
    private func scrobbleToLastFM(trackName: String, artistName: String) {        
        let urlString = "https://ws.audioscrobbler.com/2.0/?method=track.scrobble&track=\(trackName)&artist=\(artistName)&api_key=\(apiKey)&sk=\(sessionKey)&format=json"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL for Last.fm scrobble.")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error scrobbling to Last.fm: \(error.localizedDescription)")
                return
            }
            print("Successfully scrobbled to Last.fm")
        }
        
        task.resume()
    }
}

let listener = MediaNotificationListener()
print("Starting run loop...")
RunLoop.main.run()