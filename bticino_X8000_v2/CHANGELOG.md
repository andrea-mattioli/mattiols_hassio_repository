# Changelog
### CLICK ON REBUILD AFTER ADD-ON UPGRADE
## 2.6
- Fix 32 bit error (https://github.com/andrea-mattioli/mattiols_hassio_repository/issues/22)
## 2.5
- Added Autologin mechanism to Legrand (check the doc https://github.com/andrea-mattioli/mattiols_hassio_repository/tree/master/bticino_X8000_v2#21-update-your-config I added 2 parameters legrand_user, legrand_pass).
- Added an automation for restart addon after json failure (add new package to enable it https://github.com/andrea-mattioli/mattiols_hassio_repository/tree/master/bticino_X8000_v2#4-home-assistant-integration)
NB this work only for 64bit system
## 2.4
- Solved Solved WARNING (MainThread) [supervisor.addons.validate] Add-on config 'startup' with 'before' is deprecated. Please report this to the maintainer
- Add Temperature Unit of measurement "enhancement" --> https://github.com/andrea-mattioli/mattiols_hassio_repository/issues/19#issuecomment-770057303
## 2.3
- Fix issue about automatic refresh token "Internal Server Error".

## 2.2
- Fix config file bug
- Add notication if addon have a problem (enhancement request)
- Add Daily activation time (enhancement request)

## 2.1
- Removed file config from UI
- Add C2C Subscription Management 

## 2.0
- Add integrate WEB UI
- Remove all stack nginx ssl 
- Remove Nat 5588 from Router
