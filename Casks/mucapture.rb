cask "mucapture" do
  version "1.0.1"
  sha256 "e9766668d41c465f73070b24b3c5bec631ce600e9cb1d9cf883a3a15c1bb90c8"

  url "https://github.com/cvrt-gmbh/mu-capture/releases/download/v#{version}/muCapture-#{version}.zip"
  name "μCapture"
  desc "Native macOS app for capturing images and videos from USB capture cards"
  homepage "https://github.com/cvrt-gmbh/mu-capture"

  depends_on macos: ">= :sonoma"

  app "μCapture.app"

  zap trash: [
    "~/Library/Preferences/de.cvrt.MuCapture.plist",
    "~/Library/Saved Application State/de.cvrt.MuCapture.savedState",
  ]

  caveats <<~EOS
    #{token} requires camera permissions to access capture devices.
    Grant permission when prompted on first launch.
  EOS
end
