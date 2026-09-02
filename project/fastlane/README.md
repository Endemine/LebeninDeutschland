fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios set_price_direct

```sh
[bundle exec] fastlane ios set_price_direct
```

Set the app price tier in App Store Connect using direct Connect API model update.

### ios set_price

```sh
[bundle exec] fastlane ios set_price
```

Set the app price tier in App Store Connect with API key workflow.

### ios check_release_state

```sh
[bundle exec] fastlane ios check_release_state
```

Check App Store Connect build processing status without changing anything.

### ios debug_submission

```sh
[bundle exec] fastlane ios debug_submission
```

Dump app store version media and submission details for debugging.

### ios prepare_signing

```sh
[bundle exec] fastlane ios prepare_signing
```

Create or refresh distribution certificate + provisioning profile via API key.

### ios release

```sh
[bundle exec] fastlane ios release
```

Build and upload iOS release to App Store Connect via API key.

### ios submit_for_review

```sh
[bundle exec] fastlane ios submit_for_review
```

Submit an existing uploaded build for App Store review via API key.

### ios release_and_submit

```sh
[bundle exec] fastlane ios release_and_submit
```

Build, upload, and submit iOS release in one run.

### ios update_screenshots

```sh
[bundle exec] fastlane ios update_screenshots
```

Upload App Store screenshots only, without touching the binary.

### ios show_app_name

```sh
[bundle exec] fastlane ios show_app_name
```

App-Namen und Untertitel aus App Store Connect lesen. Aendert nichts.

### ios set_privacy_url

```sh
[bundle exec] fastlane ios set_privacy_url
```

Datenschutz-URL in App Store Connect fuer alle Sprachen setzen.

### ios find_free_app_name

```sh
[bundle exec] fastlane ios find_free_app_name
```

Kandidatenliste durchprobieren und den ersten freien Namen setzen.

### ios set_app_name

```sh
[bundle exec] fastlane ios set_app_name
```

App-Namen in App Store Connect setzen (alle Sprachen).

### ios set_version_localizations

```sh
[bundle exec] fastlane ios set_version_localizations
```

Release-Notes und Support-/Marketing-URL der Edit-Version setzen.

### ios fetch_rejection

```sh
[bundle exec] fastlane ios fetch_rejection
```

Ablehnungsgrund suchen: mehrere Endpunkte durchprobieren. Liest nur.

### ios diagnose_version

```sh
[bundle exec] fastlane ios diagnose_version
```

Pruefen, was einer Version zur Einreichung fehlt. Aendert nichts.

### ios create_version

```sh
[bundle exec] fastlane ios create_version
```

Neue App-Store-Version anlegen. Entsperrt die App-Informationen.

### ios show_privacy_url

```sh
[bundle exec] fastlane ios show_privacy_url
```

Datenschutz-URL in App Store Connect anzeigen. Aendert nichts.

### ios inspect_review_submissions

```sh
[bundle exec] fastlane ios inspect_review_submissions
```

Offene reviewSubmissions auflisten - liest nur, aendert nichts.

### ios cancel_review_submission

```sh
[bundle exec] fastlane ios cancel_review_submission
```

Haengende reviewSubmission abbrechen, damit eine neue eingereicht werden kann.

### ios reject_current_review

```sh
[bundle exec] fastlane ios reject_current_review
```

Reject the current App Store review submission for the editable iOS version.

----


## Android

### android check_signing

```sh
[bundle exec] fastlane android check_signing
```

Pruefen, ob der Release-Build signiert werden kann - baut nichts.

### android inspect_play_state

```sh
[bundle exec] fastlane android inspect_play_state
```

Play-Console-Zustand auslesen: Tracks, Releases, hochgeladene Builds. Aendert nichts.

### android build_aab

```sh
[bundle exec] fastlane android build_aab
```

Signiertes Android App Bundle (AAB) fuer den Play Store bauen.

### android play_app_details

```sh
[bundle exec] fastlane android play_app_details
```

App-Details in der Play Console lesen bzw. setzen (Kontakt, Standardsprache).

### android verify_play_listing

```sh
[bundle exec] fastlane android verify_play_listing
```

Play-Eintrag auslesen und pruefen. Aendert nichts.

### android upload_play_listing

```sh
[bundle exec] fastlane android upload_play_listing
```

Nur den Play-Store-Eintrag hochladen: Texte, Icon, Feature-Grafik, Screenshots.

### android deploy_play

```sh
[bundle exec] fastlane android deploy_play
```

AAB bauen und in den Play-Store-Track hochladen.

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
