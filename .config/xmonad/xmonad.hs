import XMonad
import XMonad.Core (withWindowSet)
import Data.Foldable (toList)
import XMonad.Hooks.StatusBar
import XMonad.StackSet (currentTag, Workspace)
import XMonad.Util.EZConfig
import XMonad.Hooks.ManageDocks
import XMonad.Util.Ungrab
import XMonad.Util.CustomKeys
import XMonad.Hooks.EwmhDesktops
import Graphics.X11.ExtraTypes.XF86 -- media keys
import XMonad.StackSet (Workspace(..), Stack(..))
import qualified XMonad.StackSet as W
import qualified Data.Map as M
import XMonad.Layout.Spacing
import System.Exit (exitSuccess)
import XMonad.Layout.IndependentScreens

modm = mod4Mask
term = "alacritty"
browser = "brave"
myBorderColor = "gray"
myFocusedBorderColor = "#10689B"
myBorderWidth = 1

-- we want to both introduce new keys and delete old ones (since I'm using the colemak layout)
myKeys :: XConfig Layout -> M.Map (KeyMask, KeySym) (X ())
myKeys conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $
    -- launching and killing programs
    [ ((modMask,               xK_Return), spawn $ XMonad.terminal conf) -- %! Launch terminal
    , ((modMask,               xK_p     ), spawn "dmenu_run") -- %! Launch dmenu
    , ((modMask,               xK_space     ), spawn "app-launcher") -- %! Launch dmenu
    , ((modMask,               xK_w     ), spawn browser) -- launch the browser
    , ((modMask,               xK_q     ), kill) -- %! Close the focused window

    , ((modMask,               xK_l     ), sendMessage NextLayout) -- %! Rotate through the available layout algorithms
    , ((modMask .|. shiftMask, xK_l     ), setLayout $ XMonad.layoutHook conf) -- %!  Reset the layouts on the current workspace to default

    , ((modMask,               xK_r     ), refresh) -- %! Resize viewed windows to the correct size

    -- control gaps
    , ((modMask,               xK_g       ), toggleWindowSpacingEnabled) 
    , ((modMask,               xK_Up       ), (incWindowSpacing 1)) 
    , ((modMask,               xK_Down     ), (decWindowSpacing 1))

    -- move focus up or down the window stack
    , ((modMask,               xK_e     ), windows W.focusDown)
    , ((modMask,               xK_i     ), windows W.focusUp  )
    , ((modMask,               xK_m     ), windows W.focusMaster  )
    , ((modMask .|. shiftMask, xK_m     ), windows W.swapMaster  ) 

    -- modifying the window order
    , ((modMask .|. shiftMask, xK_e     ), windows W.swapDown  ) -- %! Swap the focused window with the next window
    , ((modMask .|. shiftMask, xK_i     ), windows W.swapUp    ) -- %! Swap the focused window with the previous window

    -- resizing the master/slave ratio
    , ((modMask,               xK_n     ), sendMessage Shrink) -- %! Shrink the master area
    , ((modMask,               xK_o     ), sendMessage Expand) -- %! Expand the master area

    -- floating layer support
    , ((modMask,               xK_t     ), withFocused $ windows . W.sink) -- %! Push window back into tiling

    -- increase or decrease number of windows in the master area
    , ((modMask,               xK_comma ), sendMessage (IncMasterN 1)) -- %! Increment the number of windows in the master area
    , ((modMask,               xK_period), sendMessage (IncMasterN (-1))) -- %! Deincrement the number of windows in the master area

    -- quit, or restart
    , ((modMask .|. shiftMask, xK_c     ), io (exitSuccess)) -- %! Quit xmonad
    , ((modMask              , xK_c     ), spawn "if type xmonad; then xmonad --recompile && xmonad --restart; else xmessage xmonad not in \\$PATH: \"$PATH\"; fi") -- %! Restart xmonad
    ]
    ++
    [ ((0, xF86XK_AudioMute             ), spawn "pamixer -t")
    , ((0, xF86XK_AudioLowerVolume      ), spawn "pamixer --allow-boost -d 3")
    , ((0, xF86XK_AudioRaiseVolume      ), spawn "pamixer --allow-boost -i 3")
    , ((0, xF86XK_AudioMicMute          ), spawn "pactl set-source-mute @DEFAULT_SOURCE@ toggle")
    , ((0, xF86XK_MonBrightnessUp       ), spawn "brightnessctl set +10%")
    , ((0, xF86XK_MonBrightnessDown     ), spawn "brightnessctl set 10%-")
    -- , ((0, xF86XK_Display     ), spawn "do something here")
    -- , ((0, xF86XK_WLAN     ), spawn "do something here")
    -- , ((0, xF86XK_Favorites     ), spawn "do something here")
    -- , ((0, xF86XK_Calculator     ), spawn "do something here")
    ]
    ++
    -- mod-[1..9] %! Switch to workspace N
    -- mod-shift-[1..9] %! Move client to workspace N
    [((m .|. modMask, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

myLayout = smartSpacing 5 $ tiled ||| Mirror tiled ||| Full
  where
    tiled   = Tall nmaster delta ratio
    nmaster = 1
    ratio   = 1/2
    delta   = 3/100


safeHead :: [X()] -> X()
safeHead xs = if (null xs) then (io $ spawn "echo 'HELLO'") else (head xs)

workspaceIsEmpty :: Workspace i l a -> Bool
workspaceIsEmpty (Workspace {stack = s}) = null $ toList s
-- here i use the lookUpWorkspace to find the currently active workspace and send it to my bar (eww)
-- currentTag
ewwLogHook :: X ()
ewwLogHook = do
    wins <- gets windowset -- gets the current stack set
    let wi = currentTag wins
    let wss = W.workspaces wins
    let non_empty_tags = map W.tag $ filter (not . workspaceIsEmpty) wss
    let empty_tags =  map W.tag $ filter workspaceIsEmpty wss
    -- hack. we can map over the contents of the above tag lists but we must return a X () and not a [X ()], therefore we take the head
    safeHead $ map (\tag -> spawn ("eww update w" ++ tag ++ "Empty=true")) empty_tags
    safeHead $ map (\tag -> spawn ("eww update w" ++ tag ++ "Empty=false")) non_empty_tags
    spawn ("eww update activeW=" ++ wi)
    return ()

mySBConfig = StatusBarConfig 
    { sbLogHook = ewwLogHook
    , sbStartupHook = io $ spawn "eww open bar"
    , sbCleanupHook = io $ spawn "eww close-all; eww kill"
    }

-- combinator that applies the docks combinator and the avoidStruts layout modifier automatically
barConfig = withEasySB mySBConfig defToggleStrutsKey

myConfig = def 
    { modMask = modm
    , terminal = term
    , keys = myKeys
    , layoutHook = myLayout
    , normalBorderColor = myBorderColor
    , focusedBorderColor = myFocusedBorderColor
    , borderWidth = myBorderWidth
    }

main :: IO ()
main = 
    xmonad $ ewmh $ barConfig $ myConfig
