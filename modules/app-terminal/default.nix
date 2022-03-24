{ username, homeDir, ... }:

let
  configFile = "${homeDir}/Library/Preferences/com.apple.Terminal.plist";
in
{
  system.activationScripts.extraActivation.text = ''
    echo "setting up terminal..."
    plutil -replace "Window Settings".modus-operandi.useOptionAsMetaKey -bool YES ${configFile}
    plutil -replace "Window Settings".modus-operandi.Bell -bool NO ${configFile}
    plutil -replace "Window Settings".modus-operandi.Bell -bool NO ${configFile}
    plutil -replace "Window Settings".modus-operandi.ShowActiveProcessInTitle -bool NO ${configFile}
    plutil -replace "Window Settings".modus-operandi.ShowCommandKeyInTitle -bool NO ${configFile}
    plutil -replace "Window Settings".modus-operandi.ShowDimensionsInTitle -bool NO ${configFile}
    plutil -replace "Window Settings".modus-operandi.ShowWindowSettingsNameInTitle -bool NO ${configFile}
    plutil -replace "Window Settings".modus-operandi.ShowRepresentedURLInTitle -bool NO ${configFile}

    plutil -replace "Window Settings".modus-operandi.ShowActivityIndicatorInTab -bool NO ${configFile}
    plutil -replace "Window Settings".modus-operandi.ShowActiveProcessInTabTitle -bool NO ${configFile}
    plutil -replace "Window Settings".modus-operandi.ShowRepresentedURLInTabTitle -bool NO ${configFile}
  '';
}
