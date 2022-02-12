{ pkgs, ... }:

{
  enable = true;
  package = pkgs.firefox-bin;
  extensions = with pkgs.nur.repos.rycee.firefox-addons; [
    ublock-origin
    clearurls
    https-everywhere
    wappalyzer
    wayback-machine
    single-file
  ];
  profiles.default = {
    id = 0;
    isDefault = true;
    bookmarks = { };
    # Attribute set of Firefox preferences.
    # visit `about:config` to show.
    settings = {
      "browser.shell.checkDefaultBrowser" = false;
      "app.update.auto" = false;
      "app.update.enabled" = false;
      "browser.startup.homepage" = "about:blank";
      "browser.onboarding.enabled" = false;
      "browser.newtabpage.enabled" = false;
      "browser.search.searchEnginesURL" = "";
      "browser.search.update" = false;
      "browser.search.suggest.enabled" = false;
      "browser.search.geoSpecificDefaults" = false;
      "browser.search.geoSpecificDefaults.url" = "";
      "browser.search.geoip.url" = "";
      "browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts" = false;
      "browser.urlbar.showSearchSuggestionsFirst" = false;
      "browser.urlbar.trimURLs" = false;
      "browser.urlbar.suggest.searches" = false;
      "browser.urlbar.suggest.topsites" = false;
      "browser.urlbar.suggest.engines" = false;
      "browser.urlbar.suggest.bookmark" = false;
      # font
      "font.name.serif.x-western" = "PragmataPro";
      "font.name.sans-serif.x-western" = "PragmataPro";
      "font.name.monospace.x-western" = "PragmataPro Mono";
      "font.name.serif.x-unicode" = "PragmataPro";
      "font.name.sans-serif.x-unicode" = "PragmataPro";
      "font.name.monospace.x-unicode" = "PragmataPro Mono";
      # remove the "Did you mean to go to..." drop down bar when searching
      # for something in the search bar.
      "browser.urlbar.dnsResolveSingleWordsAfterSearch" = 0;
      "browser.fixup.dns_first_for_single_words" = false;
      "browser.urlbar.suggest.history" = false;
      "browser.urlbar.suggest.openpage" = false;
      "browser.urlbar.speculativeConnect.enabled" = false;
      "browser.urlbar.shortcuts.bookmarks" = false;
      "browser.urlbar.shortcuts.history" = false;
      "browser.urlbar.shortcuts.tabs" = false;
      "browser.formfill.enable" = false;
      "browser.search.isUS" = true;
      "browser.search.region" = "en_US";
      "signon.rememberSignons" = false;
      # disable pocket
      "extensions.pocket.enabled" = false;
      # disable formautofill
      "extensions.formautofill.available" = "off";
      # settings: disable sync
      "identity.fxaccounts.enabled" = false;
      "identity.fxaccounts.toolbar.enabled" = false;
      # disable all recommendations of extensions
      "browser.discovery.enabled" = false;
      "browser.discovery.containers.enabled" = false;
      "extensions.getAddons.discovery.api_url" = "";
      "extensions.htmlaboutaddons.recommendations.enabled" = false;
    };

    # Extra preferences to add to user.js.
    extraConfig = "";

    # Customization Firefox user chrome CSS.
    userChrome = builtins.readFile ./userChrome.css;

    # Custom Firefox user content CSS.
    userContent = "";
  };
}
