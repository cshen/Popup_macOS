cask "popup" do
  version "1.0,3fade0d2dd3f62d1c439571c8bb6900ab41b823e"
  sha256 "bad78c85b1ba0e5ad5d3b94fabd97d987e355374dc6505b130232ceb4b241713"

  url "https://raw.githubusercontent.com/cshen/Popup_macOS/#{version.csv.second}/Popup.dmg",
      verified: "raw.githubusercontent.com/cshen/Popup_macOS/"
  name "Popup"
  desc "Context-aware floating menu for selected text"
  homepage "https://github.com/cshen/Popup_macOS"

  depends_on macos: ">= :ventura"

  app "Popup.app"
  binary "#{appdir}/Popup.app/Contents/MacOS/popext"

  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-r", "-d", "com.apple.quarantine", "#{appdir}/Popup.app"]
  end

  caveats do
    <<~EOS
      Popup needs Accessibility permission to detect text selections in other apps.
      Grant it in System Settings > Privacy & Security > Accessibility after launch.
    EOS
  end

  zap trash: [
    "~/.config/Popup",
    "~/Library/Application Support/Popup",
    "~/Library/Preferences/com.example.Popup.plist",
  ]
end
