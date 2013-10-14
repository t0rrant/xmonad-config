-- @ 2013
-- Based xmonad config used by Vic Fryzel
-- Authors:
-- Vic Fryzel
-- http://github.com/vicfryzel/xmonad-config
-- Manuel Torrinha
-- http://github.com/t0rrant/xmonad-config


------------------------------------------------------------------------------
import XMonad

import XMonad.Actions.WindowGo

import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Hooks.ICCCMFocus

import XMonad.Layout.Fullscreen
import XMonad.Layout.Grid
import XMonad.Layout.IM
import XMonad.Layout.NoBorders  
import XMonad.Layout.PerWorkspace  
import XMonad.Layout.Spacing  
import XMonad.Layout.Spiral
import XMonad.Layout.Tabbed

import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.Run(safeSpawn)
import XMonad.Util.Run(safeSpawnProg)
import XMonad.Util.Run(unsafeSpawn)

import Data.Ratio ((%))

import System.IO
import System.Exit

import qualified XMonad.StackSet as W
import qualified Data.Map        as M


------------------------------------------------------------------------------
-- default terminal to launch
myTerminal = "xfce4-terminal"

------------------------------------------------------------------------------
-- Define amount and names of workspaces 
--

myWorkspaces = ["1:code","2:web","3:chat","4:vm","5:media"] ++ map show [6..9]  

------------------------------------------------------------------------------
-- Window rules
-- $ xprop | grep -i class
--
myManageHook = composeAll
    [ className =? "Firefox"      --> doShift "2:web"
    , resource =? "desktop_window" --> doIgnore
    , className =? "VirtualBox"   --> doShift "4:vm"
    , className =? "psi"          --> doShift "3:chat"
    , className =? "Skype"        --> doShift "3:chat"
    , className =? "Vlc"          --> doShift "5:media"
    , className =? "Spotify"      --> doShift "5:media"
    , className =? "Leksah"       --> doShift "4:vm"
    , className =? "Sublime_text" --> doShift "1:code"
    , className =? "MPlayer"      --> doFloat
    , resource =? "gpicview"      --> doFloat
    , isFullscreen --> (doF W.focusDown <+> doFullFloat)
    ]


------------------------------------------------------------------------------
-- Layouts
-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- defaultLayout = avoidStruts( Tall 1 (3/100) (1/2) ||| Mirror (Tall 1 (3/100) (1/2) ||| tabbed shrinkText tabConfig ||| Full ||| spiral (6/7) ) ||| noBorders (fullscreenFull Full)

defaultLayout = avoidStruts (
    Tall 1 (3/100) (1/2) |||
    Mirror (Tall 1 (3/100) (1/2)) |||
    tabbed shrinkText tabConfig |||
    Full |||
    spiral (6/7)) |||
    noBorders (fullscreenFull Full)


termLayout = defaultLayout

imLayout = withIM (1%7) (Resource "main") Grid ||| Full ||| Tall 1 (3/100) (1/2)

webLayout = noBorders (fullscreenFull Full)

myLayoutHook = avoidStruts $
    onWorkspace "1:code" termLayout $
    onWorkspace "2:web" webLayout $ 
    onWorkspace "3:chat" imLayout $
    defaultLayout


------------------------------------------------------------------------
-- Colors and borders
-- Currently based on the ir_black theme.
--

myNormalBorderColor  = "#7c7c7c"
myFocusedBorderColor = "#ffb6b0"

-- Colors for text and backgrounds of each tab when in "Tabbed" layout.
tabConfig = defaultTheme {
    activeBorderColor = "#7C7C7C",
    activeTextColor = "#CEFFAC",
    activeColor = "#000000",
    inactiveBorderColor = "#7C7C7C",
    inactiveTextColor = "#EEEEEE",
    inactiveColor = "#000000"
}

-- Color of current window title in xmobar.
xmobarTitleColor = "#FFB6B0"

-- Color of current workspace in xmobar.
xmobarCurrentWorkspaceColor = "#CEFFAC"

-- Width of the window border in pixels.
myBorderWidth = 1


------------------------------------------------------------------------
-- Key bindings
--
-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask = mod1Mask  

myKeys conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $
  
  ----------------------------------------------------------------------
  -- Custom key bindings
  --
  -- Start a terminal.  Terminal to start is specified by myTerminal variable.
  [ ((modMask .|. shiftMask, xK_Return),
     spawn $ XMonad.terminal conf)

  -- Lock the screen using xscreensaver.
  , ((modMask .|. controlMask, xK_l),
     spawn "xscreensaver-command -lock")

  -- Launch dmenu via yeganesh.
  -- Use this to launch programs without a key binding.
  , ((modMask, xK_p),
     spawn "exe=`~/.xmonad/bin/dmenu_themed | yeganesh` && eval \"exec $exe\"")

  -- Take full screenshot in multi-head mode.
  -- That is, take a screenshot of everything you see.
  , ((modMask , xK_Print), spawn "scrot /home/torrinha/screen-$(date +'%D').png")
  , ((modMask , xK_Sys_Req), spawn "scrot -s /home/torrinha/screen-$(date +'%D').png")


  -- Take a screenshot in select mode.
  -- After pressing this key binding, click a window, or draw a rectangle with
  -- the mouse.
  , ((modMask .|. shiftMask , xK_Print), spawn "select-screenshot")
  , ((modMask .|. shiftMask , xK_Sys_Req), spawn "select-screenshot")

  -- Mute volume.
  , ((modMask .|. controlMask, xK_m),
     spawn "amixer -q set Master toggle")
  -- Decrease volume.
  , ((modMask .|. controlMask, xK_j),
     spawn "amixer -q set Master 10%-")

  -- Increase volume.
  , ((modMask .|. controlMask, xK_k),
     spawn "amixer -q set Master 10%+")

  -- Audio previous.
  , ((0, 0x1008FF16),
     spawn "")

  -- Play/pause.
  , ((0, 0x1008FF14),
     spawn "")

  -- Audio next.
  , ((0, 0x1008FF17),
     spawn "")

  -- Eject CD tray.
  , ((0, 0x1008FF2C),
     spawn "eject -T")

--------------------------------------------------------------------
  -- "Standard" xmonad key bindings
  --

  -- Close focused window.
  , ((modMask .|. shiftMask, xK_c),
     kill)

  -- Cycle through the available layout algorithms.
  , ((modMask, xK_space),
     sendMessage NextLayout)

  --  Reset the layouts on the current workspace to default.
  , ((modMask .|. shiftMask, xK_space),
     setLayout $ XMonad.layoutHook conf)

  -- Resize viewed windows to the correct size.
  , ((modMask, xK_n),
     refresh)

  -- Move focus to the next window.
  , ((modMask, xK_Tab),
     windows W.focusDown)

  -- Move focus to the next window.
  , ((modMask, xK_j),
     windows W.focusDown)

  -- Move focus to the previous window.
  , ((modMask, xK_k),
     windows W.focusUp  )

  -- Move focus to the master window.
  , ((modMask, xK_m),
     windows W.focusMaster  )

  -- Swap the focused window and the master window.
  , ((modMask, xK_Return),
     windows W.swapMaster)

  -- Swap the focused window with the next window.
  , ((modMask .|. shiftMask, xK_j),
     windows W.swapDown  )

  -- Swap the focused window with the previous window.
  , ((modMask .|. shiftMask, xK_k),
     windows W.swapUp    )

  -- Shrink the master area.
  , ((modMask, xK_h),
     sendMessage Shrink)

  -- Expand the master area.
  , ((modMask, xK_l),
     sendMessage Expand)

  -- Push window back into tiling.
  , ((modMask, xK_t),
     withFocused $ windows . W.sink)

  -- Increment the number of windows in the master area.
  , ((modMask, xK_comma),
     sendMessage (IncMasterN 1))

  -- Decrement the number of windows in the master area.
  , ((modMask, xK_period),
     sendMessage (IncMasterN (-1)))

  -- Quit xmonad.
  , ((modMask .|. shiftMask, xK_q),
     io (exitWith ExitSuccess))

  -- Restart xmonad.
  , ((modMask, xK_q),
     restart "xmonad" True)
  ]
  ++

  -- mod-[1..9], Switch to workspace N
  -- mod-shift-[1..9], Move client to workspace N
  [((m .|. modMask, k), windows $ f i)
      | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
      , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
  ++

  -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
  -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
  [((m .|. modMask, key), screenWorkspace sc >>= flip whenJust (windows . f))
      | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
      , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


------------------------------------------------------------------------
-- Mouse bindings
--
-- Focus rules
-- True if your focus should follow your mouse cursor.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

myMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList $
  [
    -- mod-button1, Set the window to floating mode and move by dragging
    ((modMask, button1),
     (\w -> focus w >> mouseMoveWindow w))

    -- mod-button2, Raise the window to the top of the stack
    , ((modMask, button2),
       (\w -> focus w >> windows W.swapMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modMask, button3),
       (\w -> focus w >> mouseResizeWindow w))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
  ]


------------------------------------------------------------------------
-- Status bars and logging
-- Perform an arbitrary action on each internal state change or X event.
-- See the 'DynamicLog' extension for examples.
--
-- To emulate dwm's status bar
--
-- > logHook = dynamicLogDzen
--

------------------------------------------------------------------------
-- Startup hook
-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--

myStartupHook :: X ()

myStartupHook = do
    runOrRaise "firefox" (className =? "Firefox")
--    runOrRaise "psi" (className =? "psi")
    runOrRaise "spotify" (className =? "Spotify")
    spawn "xscreensaver -no-splash &"
 -- animation (fractals) on all screens
--    spawn "xwinwrap -ov -fs -ni -- /usr/lib/xscreensaver/electricsheep --root 1 -window-id WID --video-driver gl --nrepeats 3 > /dev/null 2>&1 &"
    setWMName "LG3D"

------------------------------------------------------------------------
-- Run xmonad with all the defaults we set up.
--

-- this can (and should) be moved to .xsession when you feel confortable with the settings.
-- while this is here remember to 'killall -9 trayer' before restarting xmonad (M-q)
trayerPanel = "trayer --edge top --align right --SetDockType true --SetPartialStrut false --expand true --width 5 --transparent true --tint gray --height 19"

main = do
  xmproc <- spawnPipe "/usr/bin/xmobar ~/.xmonad/xmobar.hs"
  trayer <- spawnPipe trayerPanel
  xmonad $ defaults {
      logHook = do
          takeTopFocus
          dynamicLogWithPP $ xmobarPP {
            ppOutput = hPutStrLn xmproc
          , ppTitle = xmobarColor xmobarTitleColor "" . shorten 100
          , ppCurrent = xmobarColor xmobarCurrentWorkspaceColor ""
          , ppSep = "   "}
      , manageHook = manageDocks <+> myManageHook
      , startupHook = myStartupHook
  }
  spawn "xwinwrap -ov -fs -ni -- /usr/lib/xscreensaver/electricsheep --root 1 -window-id WID --video-driver gl --nrepeats 3 > /dev/null 2>&1 &"


------------------------------------------------------------------------
-- Combine it all together
-- A structure containing your configuration settings, overriding
-- fields in the default config. Any you don't override, will
-- use the defaults defined in xmonad/XMonad/Config.hs
--
-- No need to modify this.
--
defaults = defaultConfig {
    -- simple stuff
    terminal           = myTerminal,
    focusFollowsMouse  = myFocusFollowsMouse,
    borderWidth        = myBorderWidth,
    modMask            = myModMask,
    workspaces         = myWorkspaces,
    normalBorderColor  = myNormalBorderColor,
    focusedBorderColor = myFocusedBorderColor,

    -- key bindings
    keys               = myKeys,
    mouseBindings      = myMouseBindings,

    -- hooks, layouts
    layoutHook         = smartBorders $ myLayoutHook,
    manageHook         = myManageHook,
    startupHook        = myStartupHook
}
