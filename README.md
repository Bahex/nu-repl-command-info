A nushell menu that display information about the command closest to the cursor.

Activate with <kbd>Alt+S</kbd>

<table>
<tr>
<td valign="top">

![pwd-help](https://github.com/user-attachments/assets/20468a25-bd69-46e8-b8ae-f76d6ac4a25c)

</td>
<td valign="top">

![pwd-source](https://github.com/user-attachments/assets/3207f972-cdb7-4d66-b757-187500db47a5)    
    
</td>
</tr>
</table>

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
