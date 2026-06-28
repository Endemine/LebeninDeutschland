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

### ios reject_current_review

```sh
[bundle exec] fastlane ios reject_current_review
```

Reject the current App Store review submission for the editable iOS version.

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
