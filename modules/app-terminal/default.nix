{ username, homeDir, ... }:

let
  configFile = "${homeDir}/Library/Preferences/com.apple.Terminal.plist";
in
{
  system.activationScripts.extraActivation.text = ''
    echo "[Terminal] setting up..."
    plutil -replace "Window Settings".Basic.useOptionAsMetaKey -bool YES ${configFile}
    plutil -replace "Window Settings".Basic.Bell -bool NO ${configFile}
    plutil -replace "Window Settings".Basic.Bell -bool NO ${configFile}
    plutil -replace "Window Settings".Basic.ShowActiveProcessInTitle -bool NO ${configFile}
    plutil -replace "Window Settings".Basic.ShowCommandKeyInTitle -bool NO ${configFile}
    plutil -replace "Window Settings".Basic.ShowDimensionsInTitle -bool NO ${configFile}
    plutil -replace "Window Settings".Basic.ShowWindowSettingsNameInTitle -bool NO ${configFile}
    plutil -replace "Window Settings".Basic.ShowRepresentedURLInTitle -bool NO ${configFile}

    plutil -replace "Window Settings".Basic.ShowActivityIndicatorInTab -bool NO ${configFile}
    plutil -replace "Window Settings".Basic.ShowActiveProcessInTabTitle -bool NO ${configFile}
    plutil -replace "Window Settings".Basic.ShowRepresentedURLInTabTitle -bool NO ${configFile}
  '';
}
