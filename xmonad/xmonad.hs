import Control.Monad
import System.Exit
import XMonad
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
import XMonad.Layout.NoBorders (noBorders, hasBorder, smartBorders)
import XMonad.Layout.ThreeColumns
import XMonad.Layout.Spacing
import XMonad.Layout.ToggleLayouts
import XMonad.Prompt
import XMonad.Prompt.Shell
import XMonad.Util.EZConfig
import XMonad.Util.Loggers
import XMonad.Util.SpawnOnce
import XMonad.Util.Ungrab
import XMonad.Util.Dmenu


myTerminal :: String
myTerminal = "alacritty"


myManageHook :: ManageHook
myManageHook =  composeAll
  [ className =? "Gimp" --> doFloat
  , isDialog            --> doFloat
  , className =? "stalonetray" --> hasBorder False
  ]


xmobar_config :: String
xmobar_config = "~/.config/xmobar/xmobar.rc "

myXmobarPP :: PP
myXmobarPP = def
    { ppSep             = magenta " • "
    , ppTitleSanitize   = xmobarStrip
    , ppCurrent         = wrap " " "" . xmobarBorder "Top" "#8be9fd" 2
    , ppHidden          = white . wrap " " ""
    , ppHiddenNoWindows = lowWhite . wrap " " ""
    , ppUrgent          = red . wrap (yellow "!") (yellow "!")
    , ppOrder           = \[ws, l, _, wins] -> [ws, l, wins]
    , ppExtras          = [logTitles formatFocused formatUnfocused]
    }
  where
    formatFocused   = wrap (white    "[") (white    "]") . magenta . ppWindow
    formatUnfocused = wrap (lowWhite "[") (lowWhite "]") . blue    . ppWindow

    -- | Windows should have *some* title, which should not not exceed a
    -- sane length.
    ppWindow :: String -> String
    ppWindow = xmobarRaw . (\w -> if null w then "untitled" else w) . shorten 30

    blue, lowWhite, magenta, red, white, yellow :: String -> String
    black    = xmobarColor "#2d2d2d" "" 
    red      = xmobarColor "#f2777a" ""
    green    = xmobarColor "#99cc99" ""
    yellow   = xmobarColor "#ffcc66" ""
    blue     = xmobarColor "#6699cc" ""
    magenta  = xmobarColor "#cc99cc" ""
    cyan     = xmobarColor "#66cccc" ""
    white    = xmobarColor "#cccccc" ""
    lowWhite = xmobarColor "#bbbbbb" ""


toggleStrutsKey :: XConfig Layout -> (KeyMask, KeySym)
toggleStrutsKey XConfig{ modMask = m } = (m, xK_b)


myStartupHook :: X ()
myStartupHook = do
  spawnOnce "trayer --edge bottom --align right --SetDockType true \
            \--SetPartialStrut true --expand true --width 10 \
	    \--transparent true --tint 0x5f5f5f --height 30"
--  SpawnOnce "feh --bg-fill --no-fehbg ~/.wallpapers/"


quitWithConfirm :: X()
quitWithConfirm = do
  let m = "confirm quit [y/N]:"
  s <- dmenu [m]
  when ((s == "y") || (s == "Y")) (io exitSuccess)


main :: IO ()
main = xmonad 
     . ewmhFullscreen 
     . ewmh 
     . withEasySB ( statusBarProp ("xmobar " ++ xmobar_config) (pure myXmobarPP)) toggleStrutsKey 
     $ myConfig

myConfig = def
  { modMask = mod4Mask
  , terminal = myTerminal
  , layoutHook = myLayouts
  , manageHook = myManageHook
  , borderWidth = 3
  , focusedBorderColor = "#f2777a"
  }
  `additionalKeysP`
  [ ("M-C-s", unGrab *> spawn "scrot -s" )
  , ("M-f", spawn "firefox" )
  , ("M-C-<Space>", sendMessage (Toggle "Full"))
  , ("M-C-t", spawn myTerminal )
  , ("M-C-x", shellPrompt def )
  , ("M-S-q", quitWithConfirm )
  ]


myLayouts = toggleLayouts (noBorders Full) (spacingWithEdge 10 $ myRegularLayouts)

myRegularLayouts = tiled ||| Mirror tiled ||| Full ||| threeCol
  where
    threeCol = ThreeColMid nmaster delta ratio
    tiled   = Tall nmaster delta ratio
    nmaster = 1
    ratio   = 3/5
    delta   = 3/100
		

-- # Default colors
-- [colors.primary]
-- background = '0x2d2d2d'
-- foreground = '0xcccccc'
--
-- # Colors the cursor will use if `custom_cursor_colors` is true
-- [colors.cursor]
-- text = '0x2d2d2d'
-- cursor = '0xcccccc'
--
-- # Normal colors
-- [colors.normal]
-- black = '0x2d2d2d'
-- red = '0xf2777a'
-- green = '0x99cc99'
-- yellow = '0xffcc66'
-- blue = '0x6699cc'
-- magenta = '0xcc99cc'
-- cyan = '0x66cccc'
-- white = '0xcccccc'
--
-- # Bright colors
-- [colors.bright]
-- black = '0x999999'
-- red = '0xf99157'
-- green = '0x393939'
-- yellow = '0x515151'
-- blue = '0xb4b7b4'
-- magenta = '0xe0e0e0'
-- cyan = '0xa3685a'
-- white = '0xffffff'
