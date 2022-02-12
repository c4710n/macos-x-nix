{ username, homeDir, ... }:

{
  system.activationScripts.extraActivation.text = ''
    # disable Handoff
    su ${username} -c 'defaults write "${homeDir}/Library/Preferences/ByHost/com.apple.coreservices.useractivityd.plist" ActivityAdvertisingAllowed -bool no'
    su ${username} -c 'defaults write "${homeDir}/Library/Preferences/ByHost/com.apple.coreservices.useractivityd.plist" ActivityReceivingAllowed -bool no'
  '';
}
