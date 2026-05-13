cask "popup" do
  version "v1.0.2,82d95c59e1ac3834e34238a2d092224a6e56f3bb"
  sha256 "1e739ad4760278ce9d75c922f485022f19d8eb79d97a0c6639c17e7d33e3af70"

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
