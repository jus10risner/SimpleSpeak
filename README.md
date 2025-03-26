<div align="center">
  <img src='https://github.com/jus10risner/jus10risner.github.io/blob/main/docs/assets/simplespeak-app-icon.png?raw=true' height='100'>
  <h1>SimpleSpeak AAC</h1>
  <p>Communicate quickly and easily, with this intuitive app that lets users save and organize phrases, then speak them with a tap.</p>

  <img src='https://github.com/jus10risner/jus10risner.github.io/docs/assets/simplespeak-site-image1.png?raw=true' height='500'> <img src='https://github.com/jus10risner/jus10risner.github.io/docs/assets/simplespeak-site-image2.png?raw=true' height='500'> <img src='https://github.com/jus10risner/jus10risner.github.io/docs/assets/simplespeak-site-image3.png?raw=true' height='500'>

  <a href="https://apps.apple.com/app/id6743131751">
    <img src="https://tools.applemediaservices.com/api/badges/download-on-the-app-store/white/en-us?size=250x83&amp;releaseDate=1276560000&h=7e7b68fad19738b5649a1bfb78ff46e9"
          alt="Download on the App Store"/>
  </a>
</div>

## 
When a close relative lost the ability to speak, I wanted to do something to help restore their ability to communicate. I learned about Apple's AVSpeechSynthesizer framework and built a very simple app that converted typed text into speech, which became the foundation of SimpleSpeak.

<br>
After finishing my first app, Socket, I returned to my text-to-speech app and decided to expand it into a more comprehensive tool to help anyone who struggles to communicate. Leveraging my background in user experience design and growing software development skills, I built an app that gives a voice to those who have lost theirs.


## Features

- Save phrases and organize them into categories, then speak with a tap
- Use system voices or speak with your own voice, using Apple’s Personal Voice feature (iOS 17 or later)
- Stay connected: speech audio is sent to other participants during phone or FaceTime calls
- Customize phrase button size, to make tapping or using eye tracking easier
- iCloud sync, for seamless use across multiple devices


## Details

- Built using SwiftUI
- `AVSpeechSynthesizer` used for speech synthesis
  - `AVSpeechSynthesizerDelegate` used to control speech playback and highlight words as they are spoken
- Core Data used for persistence
  - `NSPersistentCloudKitContainer` used to both persist data locally and sync to iCloud, for availability on users’ other devices


## Challenges

<details>
  <summary><b>Popover Tips</b></summary>
  </br>

To make onboarding simple and unobtrusive, I decided to use popover-style tips to communicate useful information. Since SimpleSpeak is available for iOS 16.4 and later, but TipKit isn’t available prior to iOS 17, I needed to use standard popovers to display tips. This required forcing an iPad-style popover when showing a tip, since iOS displays a sheet-style modal by default. 

The new `.presentationCompactAdaptation(.popover)` modifier in iOS 16.4 makes it easy to implement an iPad-style popover. However, popovers still behave like sheets, so they require careful handling to avoid issues (e.g., tapping a button to present a sheet while a popover is already visible can freeze the UI). To solve this, I used an enum to track which popover is displayed and disabled other interactive elements while the popover is active. The result is an onboarding experience that provides information as it becomes relevant.

</details>

<details>
  <summary><b>Simplifying Controls</b></summary>
  </br>

Creating simple controls in an Augmented and Alternative Communication (AAC) app presents the challenge of balancing ease of use with functionality. At the very least, the app needs to include essential buttons like play, pause, and cancel to ensure users can control speech playback. The key is designing intuitive, accessible controls that are straightforward while still offering the necessary functionality.

My solution was to create one button whose function changes depending on the current app context. When the app is idle, the button reveals the keyboard for text-to-speech functionality. When speech is occurring, the button animates into a pause button. If speech is paused, the button animates again to display play and cancel options. This improves accessibility, because users can control basic app functions without needing to move their finger excessively, making control more efficient and less physically demanding (especially important for ALS patients and others with fine motor control challenges).
  
</details>
