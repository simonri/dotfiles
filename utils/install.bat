@ECHO OFF

SET APPDATA_PATH=%LocalAppData%\nvim
SET COC_PATH=%UserProfile%\.config\coc
SET ~/.config/nvim=%UserProfile%\.config\nvim

echo Installing Neovim config...

:CHECK_PIP
WHERE pip 2>NUL >NUL && ECHO Pip already installed && GOTO :CHECK_NODE_NEOVIM
ECHO Please install pip && GOTO :EOF

:CHECK_NODE_NEOVIM
WHERE node 2>NUL >NUL && ECHO Node already installed && goto :CHECK_PYNVIM
ECHO Please install neovim && GOTO :EOF

:CHECK_PYNVIM
2>NUL pip list | findstr pynvim && ECHO Pynvim already installed, moving on... && GOTO :CHECK_CTAGS
ECHO Please install pynvim && GOTO :EOF

:CHECK_CTAGS
WHERE ctags 2>NUL >NUL && ECHO Ctags already installed && goto :MOVE_OLD_NVIM_DIR
ECHO Please install ctags
ECHO https://github.com/universal-ctags/ctags-win32/ && GOTO :EOF

:MOVE_OLD_NVIM_DIR
IF EXIST %~/.config/nvim% (
  RMDIR /Q/S "%~/.config/nvim%"
)
MKDIR "%~/.config/nvim%"

:MOVE_OLD_APPDATA_DIR
IF EXIST %APPDATA_PATH% (
  RMDIR /Q/S "%APPDATA_PATH%"
)
MKDIR "%APPDATA_PATH%"

:MOVE_OLD_COC_DIR
IF EXIST %COC_PATH% (
  RMDIR /Q/S "%COC_PATH%"
)
MKDIR "%COC_PATH%"

:CLONE_CONFIG
ECHO Cloning configuration
git clone https://github.com/simonri/nvim-config.git "%~/.config/nvim%"

:INSTALL_PLUGINS
WHERE nvim 2>NUL >NUL || GOTO :EOF

ECHO Add fake init file
MOVE "%~/.config/nvim%\appdata.init.vim" "%APPDATA_PATH%\"
REN "%APPDATA_PATH%\appdata.init.vim" "init.vim"

MOVE "%~/.config/nvim%\autoload" "%APPDATA_PATH%\autoload"

ECHO Move tmp init to ~/.config/nvim
REN "%~/.config/nvim%\init.vim" "init.vim.tmp"
MOVE "%~/.config/nvim%\utils\init.vim" "%~/.config/nvim%"

ECHO Installing plugins
nvim --headless +PlugInstall +qall

MOVE "%~/.config/nvim%\init.vim" "%~/.config/nvim%\utils"
REN "%~/.config/nvim%\init.vim.tmp" "init.vim"

:INSTALL_COC_EXTENSIONS
MKDIR "%~/.config/nvim%/../coc/extensions"