iOS Reels App (Instagram/TikTok-style Vertical Video Feed)

A lightweight, Instagram/TikTok-style Reels Viewer App built in UIKit + MVVM architecture. It features vertical scrollable video playback, mute/unmute, like/dislike, and pagination support using a clean and modular design pattern.


✨ Features

📹 Vertical full-screen auto-playing videos like Reels/TikTok
🔇 Mute / Unmute functionality per video
❤️ Like / Dislike toggle with Realm persistence
🔁 Seamless infinite scrolling via API-based pagination
💾 Realm database integration for offline/local support
🔄 MVVM architecture for clean separation of concerns
⚙️ Modular codebase with reusable components
📸 Screenshots

https://github.com/user-attachments/assets/9c1274c0-ebaa-4599-95c2-1223e5995496


UIKit – Programmatic UI
AVFoundation – Video playback
Realm – Local database for saving reels and state
MVVM – Scalable and testable architecture
URLSession / Custom Network Layer – For fetching paginated reels



🧠 Architecture Overview

ReelsViewController      // Handles UI and scrolling behavior
├── ReelsViewModel       // Handles data logic, pagination, Realm, API
├── ReelsCell            // Video player cell with mute/like logic
├── Reel Model           // Realm Object
├── RealmManager         // Singleton manager for all Realm interactions
└── NetworkManager       // API client to fetch paginated data


🔧 Getting Started

Clone the repository:
git clone [https://github.com/your-username/reels-app.git](https://github.com/samreenkaur/ReelsApp.git)
cd reels-app
Install dependencies:
Ensure you have Xcode installed.
Add RealmSwift via Swift Package Manager or CocoaPods.
Run the project:
Open .xcodeproj or .xcworkspace
Run on any iOS Simulator (iOS 14+ recommended)



📡 API Requirements

The app expects a paginated API response in this format:

[
  {
    "id": "1",
    "mediaURL": "https://yourserver.com/video.mp4",
    "isVideo": true
  },
  ...
]
