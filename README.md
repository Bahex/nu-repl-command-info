A nushell menu that display information about the command closest to the cursor.

Activate with <kbd>Alt+S</kbd>

# Usage
```nushell
# Import the module
use repl-command-info

# Apply default settings
repl-command-info --apply

# Or 
$env.config.menus ++= [( repl-command-info menu )]
$env.config.keybindings ++= [( repl-command-info keybind )]
# Or
$env.config.keybindings ++= [( repl-command-info keybind {keycode: char_d})]
```
