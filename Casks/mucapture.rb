cask "mucapture" do
  version "1.0.0"
  sha256 "f48b038779343aecf51133d1d30a5692163ec56e13d2d283d13c9c41cfa1c77a"

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
